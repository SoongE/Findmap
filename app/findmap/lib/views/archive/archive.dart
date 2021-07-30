import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_icons/line_icons.dart';

class ArchivePage extends StatefulWidget {
  @override
  _ArchivePageState createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
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
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            _slider(),
            _slider(),
            _slider(),
          ],
        ),
      ),
    );
  }

  Widget _slider() {
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
      child: const ListTile(title: Text('Slide me')),
    );
  }
}
