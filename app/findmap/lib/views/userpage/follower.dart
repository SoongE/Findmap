import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:findmap/models/user.dart';
import 'package:findmap/models/userInfo.dart';
import 'package:findmap/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Follower extends StatefulWidget {
  @override
  _FollowerState createState() => _FollowerState();

  Follower(this.user);

  final User user;
}

class _FollowerState extends State<Follower> {
  final _getUserInfoMemoizer = AsyncMemoizer<List<UserInfo>>();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  late List<UserInfo> _followers = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          _getUserInfoMemoizer.runOnce(() async => await fetchGetUserInfo()),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('');
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          _followers = snapshot.data;
          return AnimatedList(
              key: _listKey,
              initialItemCount: _followers.length,
              itemBuilder: (context, index, animation) {
                return _buildItem(_followers[index], animation);
              });
        }
      },
    );
  }

  Future<List<UserInfo>> fetchGetUserInfo() async {
    final response = await http.get(
      Uri.http(BASEURL, '/follow/follower-list',
          {'userIdx': widget.user.userIdx.toString()}),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody['success'] == false) {
        showSnackbar(context, responseBody['message']);
      }
      return responseBody['result']
          .map<UserInfo>((json) => UserInfo.fromJson(json))
          .toList();
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('fetchGetUserInfo: ${response.body}');
    }
  }

  Widget _buildItem(UserInfo item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        color: Color(0xFFE6E6FA),
        child: ListTile(
          contentPadding: EdgeInsets.all(10),
          title: Text(
            item.nickName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              int removeIndex = _followers.indexOf(item);
              UserInfo removedItem = _followers.removeAt(removeIndex);

              AnimatedListRemovedItemBuilder builder = (context, animation) {
                return _buildItem(removedItem, animation);
              };

              _listKey.currentState!.removeItem(removeIndex, builder);

              SnackBar snackBar = SnackBar(
                  content: Text("$removedItem removed at index $removeIndex"));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
          ),
        ),
      ),
    );
  }
}
