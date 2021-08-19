import 'dart:convert';
import 'dart:io';

import 'package:findmap/models/post.dart';
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
      required this.post,
      required this.onArchivePressed,
      required this.user})
      : super(key: key);

  final User user;
  final Post post;
  final VoidCallback onArchivePressed;

  @override
  _FollowingFeedTileState createState() => _FollowingFeedTileState();
}

class _FollowingFeedTileState extends State<FollowingFeedTile>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  bool _isHeart = false;

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
          _userDescription(widget.user),
          Padding(padding: const EdgeInsets.symmetric(vertical: 5)),
          widget.post.comment == ''
              ? Container()
              : Text(widget.post.comment, style: TextStyle(letterSpacing: 1.0)),
          widget.post.comment == ''
              ? Container()
              : Padding(padding: const EdgeInsets.symmetric(vertical: 5)),
          GestureDetector(
            onTap: () => Navigator.push(
                context, createRoute(_webView(widget.post.contentUrl))),
            child: Container(
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
                            imageLoader(controller, widget.post.thumbnailUrl)),
                  ),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 10)),
                  Expanded(
                    child: _FeedDescription(
                      title: widget.post.title,
                      subtitle: widget.post.summary,
                      source: widget.post.contentUrl,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _bottomOptions('1.5k', '1.2k', '0.7k', widget.post),
          Padding(padding: const EdgeInsets.symmetric(vertical: 5)),
        ],
      ),
    );
  }

  Widget _bottomOptions(
      String hearNum, String shareNum, String arcNum, Post post) {
    return Row(
      children: [
        IconButton(
          alignment: Alignment.centerLeft,
          onPressed: () {
            fetchHeart(context, post);
            setState(() {
              _isHeart = _isHeart ? false : true;
            });
          },
          icon: _isHeart
              ? Icon(LineIcons.heartAlt, color: Colors.red)
              : Icon(LineIcons.heart),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
        ),
        Text(hearNum),
        Spacer(flex: 1),
        IconButton(
          alignment: Alignment.centerLeft,
          onPressed: () {},
          icon: Icon(LineIcons.alternateShare),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
        ),
        Text(shareNum),
        Spacer(flex: 10),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          icon: Icon(LineIcons.archive, color: Colors.pink),
          onPressed: () => {
            widget.onArchivePressed.call(),
            fetchClick(context, post),
          },
        ),
        Text(arcNum),
      ],
    );
  }

  Future<void> fetchClick(BuildContext context, Post post) async {
    final response = await http.patch(
      Uri.http(BASEURL, '/feeds/${post.idx}/history'),
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

  Future<void> fetchHeart(BuildContext context, Post post) async {
    final response = await http.patch(
      Uri.http(BASEURL, '/feeds/${post.idx}/heart'),
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

  Widget _userDescription(User user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(child: imageLoader(controller, user.profileUrl)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 5)),
        Text(
          user.nickName,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        )
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
