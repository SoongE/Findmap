import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:findmap/models/hot_ranking.dart';
import 'package:findmap/models/user.dart';
import 'package:findmap/src/feature_category.dart';
import 'package:findmap/src/my_colors.dart';
import 'package:findmap/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class RealtimeSearchTab extends StatefulWidget {
  final User user;

  RealtimeSearchTab({Key? key, required this.user}) : super(key: key);

  @override
  _RealtimeSearchTabState createState() => _RealtimeSearchTabState();
}

class _RealtimeSearchTabState extends State<RealtimeSearchTab>
    with SingleTickerProviderStateMixin {
  late List<String> _tabs = ['종합'];
  late List<int> _tabsIdx = [0];
  AsyncMemoizer<List<String>> _memoizer = AsyncMemoizer();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _memoizer.runOnce(() => fetchGetUserCategory()),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _tabController();
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Container();
      },
    );
  }

  Widget _tabController() {
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
              children: List.generate(
                  _tabs.length,
                  (index) => GetRealtimeSearch(
                      categoryIdx: _tabsIdx[index],
                      categoryName: _tabs[index],
                      user: widget.user))),
        ),
      ),
    );
  }

  Future<List<String>> fetchGetUserCategory() async {
    final response = await http.get(
      Uri.http(BASEURL, '/users/interest'),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      if (responseBody['success']) {
        if (responseBody['result'] == null) return [];
        List<String> interest = [];
        for (var i in responseBody['result']) {
          _tabs.add(CATEGORY_NAME[i['categoryIdx']] ?? '');
          _tabsIdx.add(i['categoryIdx']);
          interest.add(CATEGORY_NAME[i['categoryIdx']] ?? '');
        }
        return interest;
      } else {
        showSnackbar(context, responseBody['message']);
        throw Exception(
            'fetchGetUserCategory Exception: ${responseBody['message']}');
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to connect to server');
    }
  }
}

class GetRealtimeSearch extends StatefulWidget {
  final String categoryName;
  final User user;
  final int categoryIdx;

  GetRealtimeSearch(
      {Key? key,
      required this.categoryIdx,
      required this.categoryName,
      required this.user})
      : super(key: key);

  @override
  _GetRealtimeSearchState createState() => _GetRealtimeSearchState();
}

class _GetRealtimeSearchState extends State<GetRealtimeSearch> {
  List<HotRanking> _ranking = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HotRanking>>(
      future: fetchGetHotRanking(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _ranking = snapshot.data!;
          return _rankList();
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Container();
      },
    );
  }

  Widget _rankList() {
    return ListView.separated(
      padding: const EdgeInsets.all(8.0),
      itemCount: _ranking.length,
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
            onTap: () => Navigator.push(
                context, createRoute(_webView(_ranking[index].word))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  (index + 1).toString() + '      ' + '${_ranking[index].word}',
                  style: new TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15.3,
                  ),
                ),
                '${_ranking[index].changes}'.contains('UP') ?
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: Colors.blue,
                ) :
                '${_ranking[index].changes}'.contains('DOWN') ?
                Icon(
                  Icons.arrow_drop_up_rounded,
                  color: Colors.red,
                ) :
                '${_ranking[index].changes}'.contains('NEW') ?
                Icon(
                  Icons.star_rounded,
                  color: Colors.yellow,
                  size: 18.0,
                ):
                Text(
                  '-  ',
                  style: new TextStyle(
                    color: Colors.black26,
                  )
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
      Uri.http(BASEURL, '/search/hot',
          {'categoryIdx': widget.categoryIdx.toString()}),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
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
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to load Ranking');
    }
  }
}
