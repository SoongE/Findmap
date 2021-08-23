import 'dart:convert';
import 'dart:io';

import 'package:findmap/models/feed.dart';
import 'package:findmap/models/user.dart';
import 'package:findmap/utils/image_loader.dart';
import 'package:findmap/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:line_icons/line_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';

class _FeedDescription extends StatelessWidget {
  const _FeedDescription({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.source,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String source;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Padding(padding: const EdgeInsets.symmetric(vertical: 1)),
        Text(source,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey, fontSize: 12)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 1)),
        Text(
          subtitle,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black, letterSpacing: 1.0),
        ),
      ],
    );
  }
}

class FollowingFeedTile extends StatefulWidget {
  const FollowingFeedTile(
      {Key? key,
      required this.feed,
      required this.onArchivePressed,
      required this.user})
      : super(key: key);

  final User user;
  final Feed feed;
  final VoidCallback onArchivePressed;

  @override
  _FollowingFeedTileState createState() => _FollowingFeedTileState();
}

class _FollowingFeedTileState extends State<FollowingFeedTile>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: 3),
        lowerBound: 0.0,
        upperBound: 1.0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _userDescription(widget.user, widget.feed.createdDate),
          Padding(padding: const EdgeInsets.symmetric(vertical: 5)),
          widget.feed.comment == ''
              ? Container()
              : Text(widget.feed.comment, style: TextStyle(letterSpacing: 1.0)),
          widget.feed.comment == ''
              ? Container()
              : Padding(padding: const EdgeInsets.symmetric(vertical: 5)),
          GestureDetector(
            onTap: () => {
              widget.feed.scrapHistoryCount =
                  (int.parse(widget.feed.scrapHistoryCount) + 1).toString(),
              fetchClick(context, widget.feed),
              Navigator.push(
                  context, createRoute(_webView(widget.feed.contentUrl)))
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[100]),
              padding: const EdgeInsets.all(10),
              height: 120,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    child: Align(
                        alignment: Alignment.center,
                        child:
                            imageLoader(controller, widget.feed.thumbnailUrl)),
                  ),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 10)),
                  Expanded(
                    child: _FeedDescription(
                      title: widget.feed.title,
                      subtitle: widget.feed.summary,
                      source: widget.feed.contentUrl,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: 5)),
          _bottomOptions(widget.feed),
          Padding(padding: const EdgeInsets.symmetric(vertical: 5)),
        ],
      ),
    );
  }

  Widget _bottomOptions(Feed feed) {
    return Row(
      children: [
        IconButton(
          alignment: Alignment.centerLeft,
          onPressed: () {
            fetchHeart(context, feed);
            setState(() {
              feed.scrapLikeCount = feed.userLikeStatus == "Y"
                  ? feed.scrapLikeCount - 1
                  : feed.scrapLikeCount + 1;
              feed.userLikeStatus = feed.userLikeStatus == "Y" ? "N" : "Y";
            });
          },
          icon: feed.userLikeStatus == "Y"
              ? Icon(LineIcons.heartAlt, color: Colors.red)
              : Icon(LineIcons.heart),
          padding: const EdgeInsets.only(right: 3),
          constraints: BoxConstraints(),
        ),
        Text(feed.scrapLikeCount.toString()),
        Spacer(flex: 1),
        IconButton(
          alignment: Alignment.centerLeft,
          onPressed: () {},
          icon: Icon(Icons.remove_red_eye_rounded),
          padding: const EdgeInsets.only(right: 3),
          constraints: BoxConstraints(),
        ),
        Text(feed.scrapHistoryCount),
        Spacer(flex: 10),
        IconButton(
          padding: const EdgeInsets.only(right: 3),
          constraints: BoxConstraints(),
          icon: Icon(LineIcons.archive, color: Colors.pink),
          onPressed: () => {
            widget.onArchivePressed.call(),
          },
        ),
        Text(feed.scrapStorageCount.toString()),
      ],
    );
  }

  Future<void> fetchClick(BuildContext context, Feed feed) async {
    final response = await http.patch(
      Uri.http(BASEURL, '/feeds/${feed.scrapIdx}/history'),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
      } else {
        showSnackbar(context, responseBody['message']);
        throw Exception('FUNCTIONNAME Exception: ${responseBody['message']}');
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to load post');
    }
  }

  Future<void> fetchHeart(BuildContext context, Feed feed) async {
    final response = await http.patch(
      Uri.http(BASEURL, '/feeds/${feed.scrapIdx}/heart'),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
      } else {
        showSnackbar(context, responseBody['message']);
        throw Exception('FUNCTIONNAME Exception: ${responseBody['message']}');
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to load post');
    }
  }

  Widget _userDescription(User user, String createDate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(child: circleImageLoader(controller, user.profileUrl)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 5)),
        Text(
          user.nickName,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(createDate ?? " "),
        ),
      ],
    );
  }

  Widget _webView(String url) {
    return SafeArea(
      child: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
