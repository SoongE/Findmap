import 'package:findmap/models/user.dart';
import 'package:findmap/views/feed/following_feed_tab.dart';
import 'package:findmap/views/feed/recommend_feed_tab.dart';
import 'package:flutter/material.dart';

class FeedPage extends StatelessWidget {
  FeedPage({Key? key, required this.user}) : super(key: key);

  final User user;
  final List<String> _tabs = ['피드', '팔로잉'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      key: const ValueKey('parent'),
      length: _tabs.length,
      child: Scaffold(
        appBar: TabBar(
          isScrollable: true,
          labelPadding: EdgeInsets.symmetric(horizontal: 0),
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          unselectedLabelStyle:
              TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
          indicatorColor: Colors.black87,
          indicator: UnderlineTabIndicator(
              insets: const EdgeInsets.only(left: 10, right: 10, bottom: 4),
              borderSide: BorderSide(
                width: 2.5,
                color: Colors.black87,
              )),
          tabs: _tabs
              .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Tab(text: "$e"),
                  ))
              .toList(),
        ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return false;
          },
          child: TabBarView(
            children: [
              RecommendFeedTab(user: user),
              FollowingFeedTab(user: user),
            ],
          ),
        ),
      ),
    );
  }
}
