import 'package:findmap/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'follower.dart';

class FollowerFollowing extends StatefulWidget {
  @override
  _FollowerFollowingState createState() => _FollowerFollowingState();

  FollowerFollowing(this.user);

  final User user;
}

class _FollowerFollowingState extends State<FollowerFollowing> {
  final List<String> _tabs = ['팔로워', '팔로잉'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        key: const ValueKey('parent'),
        length: _tabs.length,
        child: Scaffold(
          appBar: AppBar(
            elevation: 1,
            titleSpacing: 0,
            title: Text(widget.user.nickName,
                style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
            leading: BackButton(color: Colors.black),
            bottom: TabBar(
              indicatorColor: Colors.black,
              indicatorWeight: 1,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: _tabs.map((e) => Tab(text: "$e")).toList(),
            ),
          ),
          body: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowGlow();
              return false;
            },
            child: TabBarView(
              children: [
                Follower(widget.user),
                Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
