import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:findmap/models/feed.dart';
import 'package:findmap/models/user.dart';
import 'package:findmap/models/userInfo.dart';
import 'package:findmap/utils/image_loader.dart';
import 'package:findmap/utils/utils.dart';
import 'package:findmap/views/feed/following_feed_tile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OtherUserPage extends StatefulWidget {
  OtherUserPage({Key? key, required this.user, required this.userIdx})
      : super(key: key);

  final int userIdx;
  final User user;

  @override
  _OtherUserPageState createState() => _OtherUserPageState();
}

class _OtherUserPageState extends State<OtherUserPage>
    with SingleTickerProviderStateMixin {
  late UserInfo userInfo;
  List<Feed> feedData = [];

  final _userInfoMemoizer = AsyncMemoizer<UserInfo>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserInfo>(
      future: _userInfoMemoizer.runOnce(() async => await fetchGetUserInfo()),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          userInfo = snapshot.data!;
          return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: BackButton(color: Colors.black),
                titleSpacing: 0,
                title: Text(
                  userInfo.nickName,
                  style: TextStyle(color: Colors.black),
                ),
                actions: [
                  Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 10),
                    child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: OutlinedButton(
                          onPressed: () {
                            fetchFollowing(widget.userIdx);
                            setState(() {
                              userInfo.status = !userInfo.status;
                            });
                          },
                          child: userInfo.status ? Text('팔로잉') : Text('팔로우'),
                          style: ElevatedButton.styleFrom(
                            primary:
                                userInfo.status ? Colors.white : Colors.blue,
                            onPrimary:
                                userInfo.status ? Colors.blue : Colors.white,
                            splashFactory: NoSplash.splashFactory,
                            elevation: 0,
                          ),
                        )),
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
        userInfo.description ?? " ",
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
          displayCounter("팔로워", userInfo.FollowCount.toString()),
          displayCounter("하트", userInfo.HaertCount.toString()),
        ],
      ),
    );
  }

  Widget displayCounter(String name, String count) {
    TextStyle textStyle = TextStyle(fontSize: 15);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(name, style: textStyle),
        Padding(padding: const EdgeInsets.symmetric(vertical: 3)),
        Text(count, style: textStyle),
      ],
    );
  }

  Widget _feedTile() {
    return FutureBuilder<List<Feed>>(
      future: _fetchGetUserFeed(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          feedData = snapshot.data!;
          return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: BouncingScrollPhysics(),
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
                    Padding(padding: const EdgeInsets.symmetric(vertical: 10)),
                    _description(),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 10)),
                  ]);
                }

                index -= 1;

                return FollowingFeedTile(
                  feed: feedData[index],
                  onArchivePressed: () {},
                  user: widget.user,
                );
              });
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Container();
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

  Future<UserInfo> fetchGetUserInfo() async {
    final response = await http.get(
      Uri.http(
          BASEURL, '/feeds/profile', {'userIdx': widget.userIdx.toString()}),
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

      return UserInfo.fromJson(responseBody['result'][0]);
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('fetchGetUserInfo: ${response.body}');
    }
  }

  Future<List<Feed>> _fetchGetUserFeed() async {
    final response = await http.get(
      // TODO change to feeds/recommend
      Uri.http(BASEURL, '/feeds', {'userIdx': widget.userIdx.toString()}),
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
