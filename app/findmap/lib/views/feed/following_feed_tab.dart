import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:findmap/models/feed.dart';
import 'package:findmap/models/post_folder.dart';
import 'package:findmap/models/user.dart';
import 'package:findmap/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'following_feed_tile.dart';

class FollowingFeedTab extends StatefulWidget {
  FollowingFeedTab({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  _FollowingFeedTabState createState() => _FollowingFeedTabState();
}

class _FollowingFeedTabState extends State<FollowingFeedTab>
    with AutomaticKeepAliveClientMixin<FollowingFeedTab> {
  List<Feed> data = [];
  List<PostFolder> folderList = [PostFolder(0, 0, '아카이브', 0, '', '', '')];

  PostFolder _selectedFolder = PostFolder(-1, -1, '', -1, '', '', '');

  final _getFolderListMemoizer = AsyncMemoizer<List<PostFolder>>();

  @override
  void initState() {
    _onRefresh();
    _getFolderListMemoizer
        .runOnce(() async => await fetchGetFolderList().then((value) {
              folderList.addAll(value);
              return folderList;
            }));
    super.initState();
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    fetchGetFollowingFeeds(context).then((value) {
      setState(() {
        data = value;
      });
    });
    _refreshController.refreshCompleted();
  }

  // void _onLoading() async {
  //   // monitor network fetch
  //   await Future.delayed(Duration(milliseconds: 1000));
  //   // if failed,use loadFailed(),if no data return,use LoadNodata()
  //   if (mounted) setState(() {});
  //   _refreshController.loadComplete();
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: ClassicHeader(
            refreshStyle: RefreshStyle.Behind,
            releaseText: '',
            idleText: '',
            completeText: '',
            completeIcon: Container(),
            completeDuration: const Duration(milliseconds: 0),
            refreshingText: '',
            refreshingIcon: SizedBox(
              width: 25.0,
              height: 25.0,
              child: const CircularProgressIndicator(
                  strokeWidth: 2.0, color: Colors.grey),
            )),
        footer: ClassicFooter(
          loadStyle: LoadStyle.ShowWhenLoading,
          loadingText: '',
          idleText: '',
          noDataText: '',
          canLoadingText: '',
          completeDuration: const Duration(milliseconds: 0),
          idleIcon: Container(),
          canLoadingIcon: Container(),
          loadingIcon: SizedBox(
            width: 25.0,
            height: 25.0,
            child: const CircularProgressIndicator(
                strokeWidth: 2.0, color: Colors.grey),
          ),
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        // onLoading: _onLoading,
        child: data.length == 0
            ? Center(
                child: Text(
                  "팔로잉하는 사람이 없습니다.\n사람들을 팔로잉 해보세요!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: BouncingScrollPhysics(),
                itemCount: data.length,
                separatorBuilder: (BuildContext context, int i) =>
                    Divider(height: 1),
                itemBuilder: (context, index) => FollowingFeedTile(
                  user: widget.user,
                  feed: data[index],
                  onArchivePressed: () => _drawSaveToArchive(data[index]),
                ),
              ),
      ),
    );
  }

  void _drawSaveToArchive(Feed feed) {
    showSaveToArchiveDialog().then((val) {
      if (_selectedFolder.idx != -1) {
        fetchSaveScrap(feed, _selectedFolder).then((v) {});
      }
    });
    _selectedFolder.idx = -1;
  }

  showSaveToArchiveDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('이동할 폴더'),
        actions: [
          CupertinoDialogAction(
            child: Text('취소'),
            onPressed: () => Navigator.pop(context),
          )
        ],
        content: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: folderList.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(folderList[index].name),
              onTap: () {
                _selectedFolder = folderList[index];
                Navigator.pop(context, folderList[index]);
              },
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> fetchSaveScrap(Feed feed, PostFolder folder) async {
    Map<String, dynamic> body = {
      "title": feed.title,
      "comment": feed.comment,
      "summary": feed.summary,
      "contentUrl": feed.contentUrl,
      "thumbnailUrl": feed.thumbnailUrl,
      "folderIdx": folder.idx,
      "categoryIdx": '23',
      "isFeed": 'N',
    };
    final response = await http.post(
      Uri.http(BASEURL, '/scrap'),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody['success'] == false) {
        showSnackbar(context, responseBody['message']);
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('fetchSaveScrap: ${response.body}');
    }
  }

  Future<List<PostFolder>> fetchGetFolderList() async {
    final response = await http.get(
      Uri.http(BASEURL, '/folders'),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      if (responseBody['success']) {
        if (responseBody['code'] == 3202) {
          return [];
        }
        return responseBody['result']
            .map<PostFolder>((json) => PostFolder.fromJson(json))
            .toList();
      } else {
        showSnackbar(context, responseBody['message']);
        throw Exception(
            'fetchGetFolderList Exception: ${responseBody['message']}');
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to load post');
    }
  }

  Future<List<Feed>> fetchGetFollowingFeeds(BuildContext context) async {
    final response = await http.get(
      Uri.http(BASEURL, '/feeds/following'),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      if (responseBody['success'])
        return responseBody['result']
            .map<Feed>((json) => Feed.fromJson(json))
            .toList();
      else {
        showSnackbar(context, responseBody['message']);
        throw Exception(
            'fetchGetFollowingFeeds Exception: ${responseBody['message']}');
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to load Feed');
    }
  }

  @override
  bool get wantKeepAlive => true;
}
