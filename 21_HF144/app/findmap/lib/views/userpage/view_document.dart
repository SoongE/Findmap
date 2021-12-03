import 'package:findmap/src/text.dart';
import 'package:flutter/material.dart';

class DocumentView extends StatelessWidget {
  const DocumentView({Key? key, required this.name}) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    Map sourceText = {'ToS': TERMS_AND_CONDITIONS, 'license': LICENSE};
    Map title = {'ToS': '이용 약관', 'license': '오픈소스 라이선스'};

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leading: BackButton(color: Colors.black),
          title: Text(title[name], style: TextStyle(color: Colors.black)),
          elevation: 1,
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(sourceText[name]))),
      ),
    );
  }
}

class DocumentViewCustom extends StatelessWidget {
  const DocumentViewCustom(
      {Key? key, required this.title, required this.content})
      : super(key: key);

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leading: BackButton(color: Colors.black),
          title: Text(title, style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(10), child: Text(content))),
      ),
    );
  }
}
