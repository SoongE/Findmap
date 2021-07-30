import 'package:findmap/src/my_colors.dart';
import 'package:findmap/views/search/realtime_search_tab.dart';
import 'package:findmap/views/search/search_tab.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  SearchPage({Key? key}) : super(key: key);
  final List<String> _tabs = ['실시간 검색어', '검색'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      key: const ValueKey('parent'),
      length: _tabs.length,
      child: Scaffold(
        appBar: TabBar(
          isScrollable: true,
          labelPadding: EdgeInsets.symmetric(horizontal: 0),
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          unselectedLabelStyle:
              TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
          indicatorColor: MyColors.search,
          indicator: UnderlineTabIndicator(
              insets: const EdgeInsets.only(left: 10, right: 10, bottom: 4),
              borderSide: BorderSide(
                width: 3,
                color: MyColors.search,
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
              RealtimeSearchTab(),
              SearchTab(),
            ],
          ),
        ),
      ),
    );
  }
}
