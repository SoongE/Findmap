import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:findmap/models/post_folder.dart';
import 'package:findmap/models/user.dart';
import 'package:findmap/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:line_icons/line_icons.dart';

class FolderManage extends StatefulWidget {
  final User user;

  FolderManage({Key? key, required this.user}) : super(key: key);

  @override
  _FolderManageState createState() => _FolderManageState();
}

class _FolderManageState extends State<FolderManage> {
  List<PostFolder> _folderList = <PostFolder>[];
  late TextEditingController _addFolderController;
  late TextEditingController _changeFolderName;

  final AsyncMemoizer<List<PostFolder>> _memoizer =
      AsyncMemoizer<List<PostFolder>>();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  void initState() {
    _addFolderController = TextEditingController();
    _changeFolderName = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leading: BackButton(color: Colors.black),
          backgroundColor: Colors.white,
          elevation: 1,
          title: Text(
            '폴더 관리',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: FutureBuilder<List<PostFolder>>(
          future: _fetchMemoizer(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('');
            } else if (snapshot.hasError) {
              return new Text('Error: ${snapshot.error}');
            } else {
              _folderList = snapshot.data!;
              return Column(
                children: [
                  Expanded(child: _folderListView()),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      onFieldSubmitted: (value) {
                        fetchAddFolder(value);
                        _addFolderController.clear();
                      },
                      controller: _addFolderController,
                      decoration: InputDecoration(
                        hintText: "폴더 추가",
                        prefixIcon: Icon(LineIcons.plus),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<PostFolder>> _fetchMemoizer() {
    List<PostFolder> _list = [];
    return _memoizer.runOnce(() async {
      await fetchGetFolderList().then((value) => _list = value);
      return _list;
    });
  }

  AnimatedList _folderListView() {
    return AnimatedList(
        physics: BouncingScrollPhysics(),
        key: _listKey,
        initialItemCount: _folderList.length,
        itemBuilder: (context, index, animation) =>
            animatedListTile(context, index, animation));
  }

  Widget animatedListTile(BuildContext context, int index, animation) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: _slider(context, _folderList[index]),
    );
  }

  Future<void> fetchChangeFolderName(
      BuildContext context, PostFolder postFolder) async {
    final response = await http.patch(
      Uri.http(BASEURL, '/folders/${postFolder.idx}/name'),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
      body: json.encode({"name": postFolder.name}),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      if (responseBody['success']) {
      } else {
        showSnackbar(context, responseBody['message']);
        throw Exception(
            'fetchChangeFolderName Exception: ${responseBody['message']}');
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to load post');
    }
  }

  void fetchAddFolder(String name) async {
    final response = await http.post(
      Uri.http(BASEURL, '/folders'),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
      body: json.encode({"name": name}),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      if (responseBody['success']) {
        int idx = responseBody['result']['insertId'];
        _folderList.add(PostFolder(idx, -1, name, -1, '', '', ''));
        _listKey.currentState!.insertItem(_folderList.length - 1);
      } else {
        showSnackbar(context, responseBody['message']);
        throw Exception('fetchAddFolder Exception: ${responseBody['message']}');
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to load post');
    }
  }

  void fetchDeleteFolder(int idx) async {
    final response = await http.patch(
      Uri.http(BASEURL, '/folders/$idx/delete'),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      if (responseBody['success']) {
        // int removeIndex =
        //     _folderList.indexWhere((element) => element.idx == idx);
        // PostFolder removeElement = _folderList.removeAt(removeIndex);
        // AnimatedListRemovedItemBuilder builder = (context, animation) {
        //   return animatedListTileForDel(context, removeElement.name, animation);
        // };
        // _listKey.currentState!.removeItem(removeIndex, builder);
      } else {
        showSnackbar(context, responseBody['message']);
        throw Exception(
            'fetchDeleteFolder Exception: ${responseBody['message']}');
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

  Widget _slider(BuildContext context, PostFolder postFolder) {
    return Slidable(
        key: UniqueKey(),
        startActionPane: ActionPane(
          extentRatio: 0.2,
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (BuildContext context) {
                _changeFolderName.text = postFolder.name;
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text("폴더 이름 변경"),
                    content: TextFormField(
                      controller: _changeFolderName,
                      decoration: InputDecoration(hintText: postFolder.name),
                    ),
                    actions: [
                      TextButton(
                        child: Text("취소"),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                          child: Text("저장"),
                          onPressed: () {
                            setState(() {
                              postFolder.name = _changeFolderName.text;
                            });
                            fetchChangeFolderName(context, postFolder)
                                .then((value) => Navigator.of(context).pop());
                          }),
                    ],
                  ),
                  barrierDismissible: true,
                );
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
          dismissible: DismissiblePane(
            onDismissed: () => fetchDeleteFolder(postFolder.idx),
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
        child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: ListTile(title: Text(postFolder.name))));
  }
}
