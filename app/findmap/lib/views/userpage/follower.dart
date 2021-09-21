import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:findmap/models/user.dart';
import 'package:findmap/models/userInfo.dart';
import 'package:findmap/utils/image_loader.dart';
import 'package:findmap/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_select/smart_select.dart';

import 'other_user_page.dart';

class Follower extends StatefulWidget {
  @override
  _FollowerState createState() => _FollowerState();

  Follower(this.user);

  final User user;
}

class _FollowerState extends State<Follower> {
  final _getUserInfoMemoizer = AsyncMemoizer<List<UserInfo>>();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  GlobalKey<S2SingleState<bool>> _smartSelectKey =
      GlobalKey<S2SingleState<bool>>();
  bool _smartSelectValue = false;

  late UserInfo _currentItem;

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

          return Column(
            children: [
              _deletePopUp(),
              Expanded(
                child: AnimatedList(
                    key: _listKey,
                    initialItemCount: _followers.length,
                    itemBuilder: (context, index, animation) {
                      return _buildItem(_followers[index], animation);
                    }),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _deletePopUp() {
    return SmartSelect<bool>.single(
      key: _smartSelectKey,
      value: _smartSelectValue,
      title: "",
      onChange: (state) {
        if (state.value) {
          int removeIndex = _followers.indexOf(_currentItem);
          UserInfo removedItem = _followers.removeAt(removeIndex);

          AnimatedListRemovedItemBuilder builder = (context, animation) {
            return _buildItem(removedItem, animation);
          };
          _listKey.currentState!.removeItem(removeIndex, builder);
          _smartSelectValue = false;
        }
      },
      choiceLayout: S2ChoiceLayout.wrap,
      modalType: S2ModalType.bottomSheet,
      modalHeaderBuilder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Row(children: [
              circleImageLoader(_currentItem.profileUrl, 45),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 5)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("정말 팔로워를 삭제하시나요?"),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 1)),
                  Text(
                    "${_currentItem.nickName}님은 회원님의 팔로워 리스트에 삭제된 사실을\n알 수 없습니다",
                    style: TextStyle(color: Colors.grey, height: 1.5),
                  )
                ],
              )
            ]),
          ),
        );
      },
      modalHeaderStyle: S2ModalHeaderStyle(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      ),
      modalStyle: S2ModalStyle(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      ),
      choiceItems: [S2Choice<bool>(value: true, title: '삭제')],
      choiceDivider: true,
      choiceBuilder: (context, choice, searchText) {
        return InkWell(
          onTap: () => choice.select(!choice.selected),
          child: Container(
            padding: const EdgeInsets.all(7),
            child: Text(
              choice.title,
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      },
      tileBuilder: (context, state) {
        return Container();
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
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(createRoute(OtherUserPage(
            user: widget.user, userIdx: item.idx, isFollower: true))),
        child: ListTile(
          contentPadding: EdgeInsets.all(10),
          title: Row(
            children: [
              Text(item.nickName),
            ],
          ),
          leading: circleImageLoader(item.profileUrl, 50),
          trailing: OutlinedButton(
            child: Text("삭제", style: TextStyle(color: Colors.black)),
            onPressed: () {
              _currentItem = item;
              _smartSelectKey.currentState!.showModal();
            },
          ),
        ),
      ),
    );
  }
}
