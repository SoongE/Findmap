import 'package:findmap/models/feed.dart';
import 'package:findmap/utils/image_loader.dart';
import 'package:findmap/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';

class _FeedDescription extends StatelessWidget {
  const _FeedDescription({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.source,
    required this.createdTerm,
    required this.callback,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String source;
  final String createdTerm;
  final VoidCallback callback;

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
        Text(source + " ㆍ " + createdTerm,
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
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            padding: const EdgeInsets.all(0),
            icon: Icon(LineIcons.archive, color: Colors.pink),
            onPressed: () => callback.call(),
          ),
        ),
      ],
    );
  }
}

class RecommendFeedTile extends StatefulWidget {
  const RecommendFeedTile(
      {Key? key, required this.feed, required this.onArchivePressed})
      : super(key: key);

  final Feed feed;
  final VoidCallback onArchivePressed;

  @override
  _RecommendFeedTileState createState() => _RecommendFeedTileState();
}

class _RecommendFeedTileState extends State<RecommendFeedTile>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
        lowerBound: 0.0,
        upperBound: 1.0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, createRoute(_webView(widget.feed.contentUrl))),
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              child: Align(
                  alignment: Alignment.center,
                  child: imageLoader(
                      controller, widget.feed.thumbnailUrl, BoxFit.fitWidth)),
            ),
            Padding(padding: const EdgeInsets.symmetric(vertical: 5)),
            _FeedDescription(
              title: widget.feed.title,
              subtitle: widget.feed.summary,
              source: widget.feed.contentUrl,
              createdTerm: widget.feed.createdTerm,
              callback: widget.onArchivePressed,
            )
          ],
        ),
      ),
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
