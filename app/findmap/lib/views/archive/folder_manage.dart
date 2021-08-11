import 'dart:convert';
import 'dart:io';

import 'package:findmap/models/post_folder.dart';
import 'package:findmap/models/user.dart';
import 'package:findmap/utils/utils.dart';
import 'package:flutter/material.dart';
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

  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  void initState() {
    _addFolderController = TextEditingController();
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
          future: fetchGetFolderList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('');
            } else if (snapshot.hasError) {
              return new Text('Error: ${snapshot.error}');
            } else {
              _folderList = snapshot.data!;
              print("HELLO");
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

  AnimatedList _folderListView() {
    return AnimatedList(
      physics: BouncingScrollPhysics(),
      key: _listKey,
      initialItemCount: _folderList.length,
      itemBuilder: (context, index, animation) => Row(
        children: [
          Expanded(child: animatedListTile(context, index, animation)),
          IconButton(
              splashRadius: 1,
              onPressed: () => fetchDeleteFolder(_folderList[index].idx),
              icon: Icon(LineIcons.times)),
        ],
      ),
    );
  }

  Widget animatedListTile(BuildContext context, int index, animation) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: ListTile(title: Text(_folderList[index].name)),
    );
  }

  Widget animatedListTileForDel(BuildContext context, String value, animation) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: ListTile(title: Text(value)),
    );
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
        int removeIndex =
            _folderList.indexWhere((element) => element.idx == idx);
        PostFolder removeElement = _folderList.removeAt(removeIndex);
        AnimatedListRemovedItemBuilder builder = (context, animation) {
          return animatedListTileForDel(context, removeElement.name, animation);
        };
        _listKey.currentState!.removeItem(removeIndex, builder);
      } else {
        showSnackbar(context, responseBody['message']);
        throw Exception('fetchDeleteFolder Exception: ${responseBody['message']}');
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
}
