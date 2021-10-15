import 'package:findmap/utils/utils.dart';
import 'package:findmap/views/userpage/view_document.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Notice extends StatefulWidget {
  const Notice({Key? key}) : super(key: key);

  @override
  _NoticeState createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(color: Colors.black),
          title: Text('공지사항', style: TextStyle(color: Colors.black)),
          titleSpacing: 0,
          elevation: 1,
          backgroundColor: Colors.white,
        ),
        body: ListView.separated(
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => Navigator.of(context).push(createRouteRight(
                  DocumentViewCustom(
                      title: '환영합니다', content: 'Findmap의 가입을 진심으로 환영합니다.'))),
              child: ListTile(
                title: Text("환영합니다"),
                subtitle: Text("Findmap의 가입을 진심으로 환영합니다."),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int i) {
            if (i == 0) return Container();
            return Divider(height: 1);
          },
          itemCount: 1,
        ),
      ),
    );
  }
}
