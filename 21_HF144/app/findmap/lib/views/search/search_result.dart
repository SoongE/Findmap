import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:findmap/models/post.dart';
import 'package:findmap/models/user.dart';
import 'package:findmap/utils/utils.dart';
import 'package:findmap/views/search/search_result_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchResult extends StatefulWidget {
  const SearchResult({required this.user, required this.keyword, Key? key})
      : super(key: key);

  final User user;
  final String keyword;

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  final _memoizer = AsyncMemoizer<List<Post>>();
  late List<Post> _post = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _memoizer.runOnce(() async => await fetchGetSearchResult()),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
              color: Colors.white,
              child: Center(child: CupertinoActivityIndicator(radius: 30)));
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          _post = snapshot.data;
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                title: Text(
                  widget.keyword,
                  style: TextStyle(color: Colors.black),
                ),
                elevation: 0,
                titleSpacing: 0,
                leading: BackButton(color: Colors.black),
              ),
              body: _listView(),
            ),
          );
        }
      },
    );
  }

  Widget _listView() {
    return ScrollConfiguration(
      behavior: NoGlowBehavior(),
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(height: 1),
        itemCount: _post.length,
        itemBuilder: (context, index) =>
            SearchResultTile(user: widget.user, post: _post[index]),
      ),
    );
  }

  Future<List<Post>> fetchGetSearchResult() async {
    Map<String, dynamic> param = {"keyword": widget.keyword};

    final response = await http.get(
      Uri.http(BASEURL, '/recommend/search', param),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      return responseBody['body']['search_html']
          .map<Post>((json) => Post.fromJson(json))
          .toList();
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to connect to server');
    }
  }
}
