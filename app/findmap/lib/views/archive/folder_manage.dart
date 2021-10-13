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
import 'package:smart_select/smart_select.dart';

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

  int _removeMenuIdx = 0;
  List<S2Choice<int>> _removeMenu = [
    S2Choice<int>(value: 0, title: '삭제'),
    S2Choice<int>(value: 1, title: '삭제하고 콘텐츠 옮기기'),
    S2Choice<int>(value: 2, title: '콘텐츠도 함께 삭제'),
  ];

  int _movedFolderIdx = 0;

  @override
  void initState() {
    _addFolderController = TextEditingController();
    _changeFolderName = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _folderList);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            leading: BackButton(color: Colors.black),
            backgroundColor: Colors.white,
            elevation: 1,
            title: Row(
              children: [
                Expanded(
                    flex: 1,
                    child:
                        Text('폴더 관리', style: TextStyle(color: Colors.black))),
                Expanded(flex: 3, child: _drawFolderDeleteSelectMenu()),
              ],
            ),
          ),
          body: FutureBuilder<List<PostFolder>>(
            future: _fetchMemoizer(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text('');
              } else {
                if (snapshot.data == null) {
                  _folderList = [];
                } else {
                  _folderList = snapshot.data!;
                }
                return Column(
                  children: [
                    Expanded(child: _folderListView()),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        onFieldSubmitted: (value) {
                          if (_folderAddValidator(value)) {
                            fetchAddFolder(_addFolderController.text);
                            _addFolderController.clear();
                          }
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

  Widget _drawFolderDeleteSelectMenu() {
    return SmartSelect<int>.single(
      title: '',
      tileBuilder: (context, state) {
        return S2Tile.fromState(state,
            trailing: const Icon(Icons.keyboard_arrow_down_outlined));
      },
      modalTitle: '삭제 옵션',
      modalHeader: true,
      value: _removeMenuIdx,
      onChange: (state) => setState(() => {_removeMenuIdx = state.value}),
      modalType: S2ModalType.bottomSheet,
      choiceLayout: S2ChoiceLayout.list,
      modalHeaderStyle: S2ModalHeaderStyle(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      ),
      modalStyle: S2ModalStyle(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      ),
      choiceItems: _removeMenu,
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
        print(responseBody);
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
    var url = '';
    if (_removeMenuIdx == 0)
      url = '/folders/$idx/delete';
    else if (_removeMenuIdx == 1)
      url = '/folders/$idx/delete-only';
    else
      url = '/folders/$idx/delete-all';

    final response = await http.patch(
      Uri.http(BASEURL, url),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
      body: json.encode({"moveFolderIdx": _movedFolderIdx}),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      if (responseBody['success']) {
        // int removeIndex =
        //     _folderList.indexWhere((element) => element.idx == idx);
        // AnimatedListRemovedItemBuilder builder = (context, animation) {
        //   return Container();
        // };
        // _listKey.currentState!.removeItem(removeIndex, builder);
        _folderList.removeWhere((e) => e.idx == idx);
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

  Future<void> showModifyDialog() async {
    List<S2Choice<int>> _s2FolderList = _folderList
        .map((e) => S2Choice<int>(value: e.idx, title: e.name))
        .toList();

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Container(
          width: 400,
          height: 100,
          child: Center(
            child: SmartSelect<int>.single(
              title: '이동할 폴더',
              value: _movedFolderIdx,
              onChange: (state) => {
                _movedFolderIdx = state.value,
                Navigator.of(context).pop(),
              },
              modalType: S2ModalType.bottomSheet,
              modalHeader: false,
              choiceLayout: S2ChoiceLayout.list,
              modalHeaderStyle: S2ModalHeaderStyle(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
              ),
              modalStyle: S2ModalStyle(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
              ),
              choiceItems: _s2FolderList,
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
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
            onDismissed: () {
              if (_removeMenuIdx == 1)
                showModifyDialog()
                    .then((value) => fetchDeleteFolder(postFolder.idx));
              else
                fetchDeleteFolder(postFolder.idx);
            },
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
        child: ListTile(title: Text(postFolder.name)));
  }

  bool _folderAddValidator(value) {
    if (value.trim().isEmpty || value.trim() == null) {
      showSnackbar(context, '폴더명을 한 글자 이상 적어주세요');
      return false;
    } else if (_isFolderExist(_folderList, value)) {
      showSnackbar(context, '기존에 존재하는 폴더명과 겹칩니다');
      return false;
    }
    return true;
  }

  bool _isFolderExist(List<PostFolder> _folderList, String _newFolderName) {
    // Find the index of folder. If not found, index = -1
    final index = _folderList.indexWhere((e) => e.name == _newFolderName);
    if (index >= 0)
      return true;
    else
      return false;
  }
}
