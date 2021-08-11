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
            if (snapshot.hasData) {
              _folderList = snapshot.data!;
              return Column(
                children: [
                  Expanded(child: _folderListView(_folderList)),
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
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Container();
          },
        ),
      ),
    );
  }

  ListView _folderListView(List<PostFolder> data) {
    return ListView.separated(
        physics: BouncingScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (context, index) => Row(
              children: [
                Expanded(child: ListTile(title: Text(data[index].name))),
                IconButton(
                    splashRadius: 1,
                    onPressed: () => {},
                    icon: Icon(LineIcons.times)),
              ],
            ),
        separatorBuilder: (BuildContext context, int index) =>
            Divider(height: 1, thickness: 1));
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
        setState(() {
          _folderList.add(PostFolder(idx, -1, name, -1, '', '', ''));
        });
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
        "token": "widget.user.accessToken",
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      if (responseBody['success']) {
        setState(() {
          _folderList.remove
        });
      } else {
        showSnackbar(context, responseBody['message']);
        throw Exception('FUNCTIONNAME Exception: ${responseBody['message']}');
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
