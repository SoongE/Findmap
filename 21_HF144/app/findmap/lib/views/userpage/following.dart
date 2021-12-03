import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:findmap/models/user.dart';
import 'package:findmap/models/userInfo.dart';
import 'package:findmap/utils/image_loader.dart';
import 'package:findmap/utils/utils.dart';
import 'package:findmap/views/userpage/other_user_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Following extends StatefulWidget {
  @override
  _FollowingState createState() => _FollowingState();

  Following(this.user);

  final User user;
}

class _FollowingState extends State<Following> {
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

  void fetchFollowing(int followingIdx) async {
    Map<String, dynamic> param = {"followingIdx": followingIdx.toString()};

    final response = await http.patch(
      Uri.http(BASEURL, '/follow/'),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
      body: json.encode(param),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
      } else {
        showSnackbar(context, responseBody['message']);
        throw Exception('fetchFollowing Exception: ${responseBody['message']}');
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to connect to server');
    }
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

      // add status
      for (var i in responseBody['result']) {
        i['status'] = true;
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
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(createRoute(OtherUserPage(
            user: widget.user, userIdx: item.idx, isFollower: false))),
        child: ListTile(
          contentPadding: EdgeInsets.all(10),
          title: Row(
            children: [
              Text(item.nickName),
            ],
          ),
          leading: circleImageLoader(item.profileUrl, 50),
          trailing: OutlinedButton(
            child: item.status
                ? Text('팔로잉', style: TextStyle(color: Colors.black))
                : Text('팔로우'),
            onPressed: () => setState(
              () => item.status = !item.status,
            ),
          ),
        ),
      ),
    );
  }
}
