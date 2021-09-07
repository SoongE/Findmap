import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:findmap/models/post.dart';
import 'package:findmap/models/post_folder.dart';
import 'package:findmap/models/user.dart';
import 'package:findmap/utils/utils.dart';
import 'package:findmap/views/archive/folder_manage.dart';
import 'package:findmap/views/archive/post_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:line_icons/line_icons.dart';

class ArchivePage extends StatefulWidget {
  final User user;

  ArchivePage({Key? key, required this.user}) : super(key: key);

  @override
  _ArchivePageState createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  List<Post> _archiveList = <Post>[];
  List<PostFolder> _folderList = <PostFolder>[];
  List<String> _menuList = <String>['폴더 관리', '다른 메뉴'];

  final _getArchiveMemoizer = AsyncMemoizer<List<Post>>();

  late PostFolder _state = PostFolder(-1, -1, '아카이브', -1, '', '', '');

  late TextEditingController _title;
  late TextEditingController _comment;

  @override
  void initState() {
    _title = TextEditingController();
    _comment = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(color: Colors.black),
          title: Row(children: [
            Text(_state.name,
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            FutureBuilder<List<PostFolder>>(
                future: fetchGetFolderList(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    _folderList = snapshot.data!;
                    _folderList.insert(
                        0, PostFolder(-1, 0, '아카이브', 0, '', '', ''));
                    return PopupMenuButton<PostFolder>(
                      padding: const EdgeInsets.all(0),
                      icon: Icon(
                        Icons.keyboard_arrow_down_outlined,
                        color: Colors.black,
                        size: 30,
                      ),
                      onSelected: (value) => setState(() => {
                            _state = value,
                            value.idx == -1
                                ? fetchGetArchive(context)
                                    .then((newValue) => _archiveList = newValue)
                                : fetchGetFolderArchive(context, value).then(
                                    (newValue) => _archiveList = newValue),
                          }),
                      itemBuilder: (BuildContext context) {
                        return _folderList
                            .map<PopupMenuItem<PostFolder>>((PostFolder value) {
                          return PopupMenuItem<PostFolder>(
                            value: value,
                            child: _state.name == value.name
                                ? Row(children: [
                                    Text(
                                      value.name,
                                      style: TextStyle(color: Colors.pink),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 3)),
                                    Icon(Icons.check, color: Colors.pink)
                                  ])
                                : Text(value.name),
                          );
                        }).toList();
                      },
                    );
                  }
                  return Container();
                }),
          ]),
          elevation: 0,
          actions: [
            IconButton(
              splashRadius: 1,
              icon: Icon(LineIcons.search, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              splashRadius: 1,
              icon: Icon(LineIcons.checkCircle, color: Colors.black),
              onPressed: () {},
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.menu, color: Colors.black),
              onSelected: (value) => menuPopUponSelected(value),
              itemBuilder: (BuildContext context) {
                return _menuList.map((String value) {
                  return PopupMenuItem<String>(
                      value: value, child: Text(value));
                }).toList();
              },
            ),
          ],
        ),
        body: FutureBuilder<List<Post>>(
          future: _state.idx == -1
              ? _getArchiveMemoizer
                  .runOnce(() async => await fetchGetArchive(context))
              : fetchGetFolderArchive(context, _state),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _archiveList = snapshot.data!;
              return _archiveListView(_archiveList);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Container();
          },
        ),
      ),
    );
  }

  void menuPopUponSelected(String value) {
    if (value == '폴더 관리') {
      Navigator.of(context)
          .push(createRouteRight(FolderManage(user: widget.user)))
          .then((value) {
        setState(() {
          _folderList = value;
        });
      });
    }
  }

  ListView _archiveListView(data) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      physics: BouncingScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) => _slider(index, data[index]),
    );
  }

  Future<List<Post>> fetchGetFolderArchive(
      BuildContext context, PostFolder postFolder) async {
    final response = await http.get(
      Uri.http(BASEURL, '/scrap/by-folder/${postFolder.idx}'),
      headers: {
        "token": widget.user.accessToken,
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      if (responseBody['success']) {
        if (responseBody['code'] == 3101) {
          return [];
        }
        return responseBody['result']
            .map<Post>((json) => Post.fromJson(json))
            .toList();
      } else {
        showSnackbar(context, responseBody['message']);
        throw Exception(
            'fetchGetFolderArchive Exception: ${responseBody['message']}');
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to load post');
    }
  }

  Future<List<Post>> fetchGetArchive(BuildContext context) async {
    final response = await http.get(
      Uri.http(BASEURL, '/scrap'),
      headers: {
        "token": widget.user.accessToken,
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      if (responseBody['success'])
        return responseBody['result']
            .map<Post>((json) => Post.fromJson(json))
            .toList();
      else {
        showSnackbar(context, responseBody['message']);
        throw Exception(
            'fetchGetArchive Exception: ${responseBody['message']}');
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to load post');
    }
  }

  void fetchDelete(BuildContext context, Post post) async {
    final response = await http.patch(
      Uri.http(BASEURL, '/scrap/${post.idx}/delete'),
      headers: {
        "token": widget.user.accessToken,
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody['success'] == false) {
        showSnackbar(context, responseBody['message']);
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to load post');
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

      if (responseBody['success'])
        return responseBody['result']
            .map<PostFolder>((json) => PostFolder.fromJson(json))
            .toList();
      else {
        showSnackbar(context, responseBody['message']);
        throw Exception(
            'fetchGetFolderList Exception: ${responseBody['message']}');
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to load post');
    }
  }

  Widget _slider(int index, Post post) {
    var isFeedShareLabel = post.isFeed == 'Y' ? '피드로 공유' : '피드 공유 해제';
    return Slidable(
      key: UniqueKey(),
      startActionPane: ActionPane(
        extentRatio: 0.5,
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            flex: 2,
            onPressed: (BuildContext context) {
              fetchFeedUpDown(
                      context, post.idx, post.isFeed == 'Y' ? true : false)
                  .then((value) {
                post.isFeed = post.isFeed == 'Y' ? 'N' : 'Y';
                setState(() {
                  isFeedShareLabel = post.isFeed == 'Y' ? '피드로 공유' : '피드 공유 해제';
                });
              });
            },
            backgroundColor: Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: Icons.screen_share,
            label: isFeedShareLabel,
          ),
          SlidableAction(
            onPressed: (BuildContext context) {
              showModifyDialog(post);
            },
            backgroundColor: Color(0xFF0392CF),
            foregroundColor: Colors.white,
            icon: LineIcons.pen,
            label: '수정',
          ),
        ],
      ),
      endActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const DrawerMotion(),
        dismissible: DismissiblePane(onDismissed: () {
          setState(() {
            fetchDelete(context, post);
            _archiveList.removeAt(index);
          });
        }),
        children: [
          SlidableAction(
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '삭제',
            onPressed: (BuildContext context) {},
          ),
        ],
      ),
      child: PostTile(post: post),
    );
  }

  Future<void> fetchFeedUpDown(
      BuildContext context, int idx, bool status) async {
    var url = status ? '/scrap/$idx/feed-down' : '/scrap/$idx/feed-upload';
    final response = await http.patch(
      Uri.http(BASEURL, url),
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
        throw Exception(
            'fetchFeedUpDown Exception: ${responseBody['message']}');
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to load post');
    }
  }

  Future<void> fetchModifyScrap(BuildContext context, int idx, String title,
      String comment, String folderIdx) async {
    Map<String, dynamic> param = {
      "title": title,
      "comment": comment,
      "folderIdx": folderIdx,
    };

    final response = await http.patch(
      Uri.http(BASEURL, '/scrap/$idx'),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
      body: json.encode(param),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      if (responseBody['success']) {
      } else {
        showSnackbar(context, responseBody['message']);
        throw Exception(
            'fetchModifyScrap Exception: ${responseBody['message']}');
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to load post');
    }
  }

  void showModifyDialog(Post post) {
    _title.text = post.title;
    _comment.text = post.comment;
    String nowFolder =
        _folderList.firstWhere((element) => element.idx == post.folderIdx).name;

    List<String> _stringFolderList = [];
    _stringFolderList.addAll(_folderList.map((e) => e.name));
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("수정"),
        content: Container(
          width: 400,
          height: 200,
          child: Column(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _title,
                  decoration:
                      InputDecoration(labelText: '제목', hintText: _title.text),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _comment,
                  decoration: InputDecoration(
                      labelText: '코멘트', hintText: _comment.text),
                ),
              ),
              Expanded(
                child: DropdownButtonFormField(
                    value: nowFolder,
                    items: _stringFolderList.map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    icon: const Icon(Icons.arrow_drop_down),
                    elevation: 16,
                    onChanged: (String? val) => nowFolder = val!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text("취소"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
              child: Text("저장"),
              onPressed: () {
                var folderIdx = _folderList
                    .firstWhere((element) => element.name == nowFolder)
                    .idx;
                fetchModifyScrap(context, post.idx, _title.text, _comment.text,
                        folderIdx.toString())
                    .then((value) => Navigator.of(context).pop());
                setState(() {
                  post.title = _title.text;
                  post.comment = _comment.text;
                  post.folderIdx = folderIdx;
                });
              }),
        ],
      ),
      barrierDismissible: true,
    );
  }
}
