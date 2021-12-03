import 'dart:async';

import 'package:findmap/models/post.dart';
import 'package:findmap/utils/image_loader.dart';
import 'package:findmap/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class _ArticleDescription extends StatelessWidget {
  const _ArticleDescription({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.url,
    required this.isFeed,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String url;
  final bool isFeed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Text(
                subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.0,
                  letterSpacing: 1.0,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              isFeed
                  ? Icon(Icons.screen_share, size: 15, color: Colors.green)
                  : Container(),
              isFeed
                  ? Padding(padding: const EdgeInsets.symmetric(horizontal: 3))
                  : Container(),
              Expanded(
                child: Text(
                  url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PostTile extends StatefulWidget {
  const PostTile({Key? key, required this.post}) : super(key: key);

  final Post post;

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final Completer<WebViewController> _webViewController =
      Completer<WebViewController>();

  @override
  void initState() {
    controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 0),
        lowerBound: 0.0,
        upperBound: 1.0);
    super.initState();
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.0,
              child: imageLoader(
                  controller, widget.post.thumbnailUrl, BoxFit.cover),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(
                    context, createRoute(_webView(widget.post.contentUrl))),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0),
                  child: _ArticleDescription(
                    title: widget.post.title,
                    subtitle: widget.post.summary,
                    url: widget.post.contentUrl,
                    isFeed: widget.post.isFeed == 'Y' ? true : false,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _webView(String url) {
    return WebView(
      initialUrl: url,
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}
