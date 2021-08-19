import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    items.add((items.length + 1).toString());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: ClassicHeader(
            refreshStyle: RefreshStyle.Behind,
            releaseText: '',
            idleText: '',
            completeText: '',
            completeIcon: Container(),
            completeDuration: const Duration(milliseconds: 0),
            refreshingText: '',
            refreshingIcon: SizedBox(
              width: 25.0,
              height: 25.0,
              child: const CircularProgressIndicator(
                  strokeWidth: 2.0, color: Colors.grey),
            )),
        footer: ClassicFooter(
          loadStyle: LoadStyle.ShowWhenLoading,
          loadingText: '',
          idleText: '',
          noDataText: '',
          canLoadingText: '',
          completeDuration: const Duration(milliseconds: 0),
          idleIcon: Container(),
          canLoadingIcon: Container(),
          loadingIcon: SizedBox(
            width: 25.0,
            height: 25.0,
            child: const CircularProgressIndicator(
                strokeWidth: 2.0, color: Colors.grey),
          ),
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemBuilder: (c, i) => Card(child: Center(child: Text(items[i]))),
          itemExtent: 100.0,
          itemCount: items.length,
        ),
      ),
    );
  }
}
