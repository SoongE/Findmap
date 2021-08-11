import 'dart:convert';
import 'dart:io';

import 'package:findmap/models/post.dart';
import 'package:findmap/models/post_folder.dart';
import 'package:findmap/models/user.dart';
import 'package:findmap/utils/utils.dart';
import 'package:findmap/views/archive/folder_manage.dart';
import 'package:findmap/views/archive/post_tile.dart';
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
  late PostFolder _state = PostFolder(-1, -1, '아카이브', -1, '', '', '');
  List<String> _menuList = <String>['폴더 관리', '다른 메뉴'];

  @override
  void initState() {
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
                    List<PostFolder>? _folderList = snapshot.data;
                    _folderList!
                        .insert(0, PostFolder(-1, 0, '아카이브', 0, '', '', ''));
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
              ? fetchGetArchive(context)
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
      itemBuilder: (context, index) => _slider(data[index]),
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

  Widget _slider(Post post) {
    return Slidable(
      key: UniqueKey(),
      startActionPane: ActionPane(
        extentRatio: 0.5,
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            flex: 2,
            onPressed: (BuildContext context) {},
            backgroundColor: Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: Icons.screen_share,
            label: '피드로 공유',
          ),
          SlidableAction(
            onPressed: (BuildContext context) {},
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
        dismissible: DismissiblePane(
          onDismissed: () => fetchDelete(context, post),
        ),
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
      child: PostTile(
          url: post.contentUrl,
          thumbnail: post.thumbnailUrl,
          title: post.title,
          subtitle: post.summary,
          author: post.comment,
          source: post.contentUrl.substring(0, 5)),
    );
  }
}
