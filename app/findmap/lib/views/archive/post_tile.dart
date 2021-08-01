import 'package:findmap/utils/image_loader.dart';
import 'package:findmap/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class _ArticleDescription extends StatelessWidget {
  const _ArticleDescription(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.author,
      required this.source})
      : super(key: key);

  final String title;
  final String subtitle;
  final String author;
  final String source;

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
              Text(
                author,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black87,
                ),
              ),
              Text(
                source,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
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
  const PostTile({
    Key? key,
    required this.url,
    required this.thumbnail,
    required this.title,
    required this.subtitle,
    required this.author,
    required this.source,
  }) : super(key: key);

  final String url;
  final String thumbnail;
  final String title;
  final String subtitle;
  final String author;
  final String source;

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile>
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
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                margin: const EdgeInsets.all(10),
                child: imageLoader(controller, widget.thumbnail),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    Navigator.push(context, createRoute(_webView(widget.url))),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0),
                  child: _ArticleDescription(
                      title: widget.title,
                      subtitle: widget.subtitle,
                      author: widget.author,
                      source: widget.source),
                ),
              ),
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
