import 'dart:convert';

import 'package:findmap/models/post.dart';
import 'package:findmap/models/user.dart';
import 'package:findmap/utils/utils.dart';
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
  List<Post> archiveList = <Post>[];

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
          title: Row(
            children: [
              Text(
                "아카이브",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              IconButton(
                splashRadius: 1,
                icon: Icon(LineIcons.angleDown, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),
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
            IconButton(
              splashRadius: 1,
              icon: Icon(Icons.menu, color: Colors.black),
              onPressed: () {},
            )
          ],
        ),
        body: FutureBuilder<List<Post>>(
          future: fetchGetArchive(context),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Post>? data = snapshot.data;
              return _archiveListView(data);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Container();
          },
        ),
      ),
    );
  }

  ListView _archiveListView(data) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      physics: BouncingScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) => _slider(data[index]),
    );
  }

  List<Post> parseGetArchive(responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Post>((json) => Post.fromJson(json)).toList();
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

  Widget _slider(Post post) {
    return Slidable(
      key: UniqueKey(),

      // The start action pane is the one at the left or the top side.
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

      // The end action pane is the one at the right or the bottom side.
      endActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const DrawerMotion(),
        // A pane can dismiss the Slidable.
        dismissible: DismissiblePane(onDismissed: () {
          print("DISSMISS");
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

      // The child of the Slidable is what the user sees when the
      // component is not dragged.
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
