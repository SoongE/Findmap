import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:findmap/models/hot_ranking.dart';
import 'package:http/http.dart' as http;
import 'package:findmap/src/my_colors.dart';
import 'package:findmap/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:findmap/models/user.dart';

class RealtimeSearchTab extends StatefulWidget {
  final User user;

  RealtimeSearchTab({Key? key, required this.user}) : super(key: key);

  @override
  _RealtimeSearchTabState createState() => _RealtimeSearchTabState();
}

class _RealtimeSearchTabState extends State<RealtimeSearchTab>
    with SingleTickerProviderStateMixin {
  List<String> _tabs = ['종합', '뉴스', '음악', '영화', '스포츠', '책'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      key: const ValueKey('child'),
      length: _tabs.length,
      child: Scaffold(
        appBar: TabBar(
          isScrollable: true,
          labelPadding: EdgeInsets.symmetric(horizontal: 0),
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          unselectedLabelStyle:
              TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
          indicatorColor: MyColors.search,
          indicator: UnderlineTabIndicator(
              insets: const EdgeInsets.only(left: 10, right: 10, bottom: 4),
              borderSide: BorderSide(
                width: 3,
                color: MyColors.search,
              )),
          tabs: _tabs
              .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Tab(text: "$e"),
                  ))
              .toList(),
        ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return false;
          },
          child: TabBarView(
            children: [
              GetRealtimeSearch(
                categoryID: 0, user: widget.user,
              ),
              GetRealtimeSearch(
                categoryID: 1, user: widget.user,
              ),
              GetRealtimeSearch(
                categoryID: 2, user: widget.user,
              ),
              GetRealtimeSearch(
                categoryID: 3, user: widget.user,
              ),
              GetRealtimeSearch(
                categoryID: 4, user: widget.user,
              ),
              GetRealtimeSearch(
                categoryID: 5, user: widget.user,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GetRealtimeSearch extends StatefulWidget {

  final int categoryID;
  final User user;

  GetRealtimeSearch({Key? key, required this.categoryID, required this.user}) : super(key: key);

  @override
  _GetRealtimeSearchState createState() => _GetRealtimeSearchState();
}

class _GetRealtimeSearchState extends State<GetRealtimeSearch> {
  List<HotRanking> keyword1 = [HotRanking('', 0, '')];
  List<HotRanking> keyword2 = [HotRanking('', 0, '')];
  List<HotRanking> keyword3 = [HotRanking('', 0, '')];
  List<HotRanking> keyword4 = [HotRanking('', 0, '')];
  List<HotRanking> keyword5 = [HotRanking('', 0, '')];
  List<HotRanking> keyword6 = [HotRanking('', 0, '')];

  @override
  void initState() {
    fetchGetHotRanking().then((value) {
      keyword1 = value;
      setState(() {
        // _folderList.addAll(value.map((e) => e.name));
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<List<HotRanking>> keywords = [
      keyword1,
      keyword2,
      keyword3,
      keyword4,
      keyword5,
      keyword6
    ];
    var id = widget.categoryID;

    return ListView.separated(
      padding: const EdgeInsets.all(8.0),
      itemCount: keywords.elementAt(id).length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            15.0,
            0.0,
            15.0,
            0.0,
          ),
          height: 40,
          child: InkWell(
            onTap: () => Navigator.push(context,
                createRoute(_webView(keywords.elementAt(id)[index].word))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                    (index + 1).toString() +
                        '      ' +
                        '${keywords.elementAt(id)[index].word}',
                    style: new TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 15.3,
                    ),
                  ),
                Text(
                  // 실시간 검색어 변동 순위
                  '${keywords.elementAt(id)[index].changes}',
                  style: new TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15.3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(
        thickness: 1,
        color: Colors.black26,
      ),
    );
  }

  Widget _webView(String search) {
    return SafeArea(
      child: WebView(
        initialUrl:
            'https://search.naver.com/search.naver?where=nexearch&sm=top_hty&fbm=1&ie=utf8&query=$search',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }

  Future<List<HotRanking>> fetchGetHotRanking() async {
    final response = await http.get(
      Uri.http(BASEURL, '/search/hot'),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      print('200');
      if (responseBody['success']) {
        return responseBody['result']
            .map<HotRanking>((json) => HotRanking.fromJson(json))
            .toList();
      } else {
        showSnackbar(context, responseBody['message']);
        throw Exception(
            'fetchGetFolderList Exception: ${responseBody['message']}');
      }
    } else {
      print('error');
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to load Ranking');
    }
  }
}
