import 'dart:convert';
import 'dart:io';

import 'package:findmap/models/feed.dart';
import 'package:findmap/models/user.dart';
import 'package:findmap/models/userInfo.dart';
import 'package:findmap/utils/image_loader.dart';
import 'package:findmap/utils/utils.dart';
import 'package:findmap/views/feed/following_feed_tile.dart';
import 'package:findmap/views/userpage/setting.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:line_icons/line_icons.dart';

import 'follower_following.dart';

class UserPage extends StatefulWidget {
  final User user;

  UserPage({Key? key, required this.user}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>
    with SingleTickerProviderStateMixin {
  late UserInfo userInfo;
  List<Feed> feedData = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserInfo>(
      future: _fetchGetUserInfo(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          userInfo = snapshot.data!;
          return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                title: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    userInfo.nickName,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => Navigator.of(context)
                        .push(createRouteRight(Setting(widget.user))),
                    splashRadius: 1,
                    icon: Icon(
                      LineIcons.cog,
                      color: Colors.black,
                    ),
                  )
                ],
              ),
              body: _feedTile());
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Container();
      },
    );
  }

  Widget _description() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Text(
        userInfo.description,
        style: const TextStyle(color: Colors.black, letterSpacing: 1.0),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          circleImageLoader(userInfo.profileUrl, 65),
          displayCounter("스크랩", userInfo.ScrapCount.toString()),
          displayCounter("팔로워", userInfo.FollowerCount.toString(),
              callback: _toFollowingFollow),
          displayCounter("하트", userInfo.HaertCount.toString()),
        ],
      ),
    );
  }

  Widget displayCounter(String name, String count, {VoidCallback? callback}) {
    TextStyle textStyle = TextStyle(fontSize: 15);
    return GestureDetector(
      onTap: () => callback!(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(name, style: textStyle),
          Padding(padding: const EdgeInsets.symmetric(vertical: 3)),
          Text(count, style: textStyle),
        ],
      ),
    );
  }

  void _toFollowingFollow() {
    Navigator.of(context).push(createRoute(FollowerFollowing(widget.user)));
  }

  Widget _feedTile() {
    return FutureBuilder<List<Feed>>(
      future: _fetchGetUserFeed(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          feedData = snapshot.data!;
          if (feedData.length == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _header(),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 10)),
                  _description(),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 10)),
                  Flexible(
                    flex: 2,
                    child: Center(
                      child: Text(
                        "등록된 피드가 없습니다.\n피드를 등록해주세요",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      ),
                    ),
                  ),
                  Flexible(flex: 2, child: Container()),
                ],
              ),
            );
          }
          return ScrollConfiguration(
            behavior: NoGlowBehavior(),
            child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                separatorBuilder: (BuildContext context, int i) {
                  if (i == 0) return Container();
                  return Divider(height: 1);
                },
                itemCount: feedData.isEmpty ? 1 : feedData.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // return the header
                    return Column(children: [
                      _header(),
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10)),
                      _description(),
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10)),
                    ]);
                  }

                  index -= 1;

                  return FollowingFeedTile(
                    user: widget.user,
                    feed: feedData[index],
                    onArchivePressed: () {},
                  );
                }),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Container();
      },
    );
  }

  Future<UserInfo> _fetchGetUserInfo(BuildContext context) async {
    final response = await http.get(
      Uri.http(BASEURL, '/feeds/profile',
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
      return UserInfo.fromJson(responseBody['result'][0]);
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('_fetchGetUserInfo: ${response.body}');
    }
  }

  Future<List<Feed>> _fetchGetUserFeed() async {
    final response = await http.get(
      // TODO change to feeds/recommend
      Uri.http(BASEURL, '/feeds', {'userIdx': widget.user.userIdx.toString()}),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      if (responseBody['success'])
        return responseBody['result']
            .map<Feed>((json) => Feed.fromJson(json))
            .toList();
      else {
        showSnackbar(context, responseBody['message']);
        throw Exception(
            'fetchGetUserFeed Exception: ${responseBody['message']}');
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to load Feed');
    }
  }
}
