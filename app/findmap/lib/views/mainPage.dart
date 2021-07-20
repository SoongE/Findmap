import 'package:badges/badges.dart';
import 'package:findmap/src/my_colors.dart';
import 'package:findmap/views/alarm.dart';
import 'package:findmap/views/archive.dart';
import 'package:findmap/views/feed.dart';
import 'package:findmap/views/search.dart';
import 'package:findmap/views/userPage.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  int _badge = 0;
  double _gap = 10;
  final _padding = EdgeInsets.symmetric(horizontal: 18, vertical: 12);

  PageController _controller = PageController();

  static const List<IconData> _widgetIcons = <IconData>[
    LineIcons.archive,
    LineIcons.search,
    LineIcons.layerGroup,
    LineIcons.bell,
    LineIcons.user,
  ];
  static final List<Color> _widgetColors = <Color>[
    MyColors.archive,
    MyColors.search,
    MyColors.feed,
    MyColors.alarm,
    MyColors.user,
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> _widgetTitle = <String>[
      "Archive",
      "Search",
      "Feed",
      "Alarm",
      "NICKNAME"
    ];
    List<Widget> _widgetOptions = <Widget>[
      ArchivePage(),
      SearchPage(),
      FeedPage(),
      AlarmPage(),
      UserPage(nickName: "NICKNAME"),
    ];
    return Scaffold(
      extendBody: false,
      backgroundColor: Colors.white,
      body: PageView.builder(
        onPageChanged: (page) {
          setState(() {
            _selectedIndex = page;
            _badge = _badge + 1;
            if (_selectedIndex == 3) _badge = -1;
          });
        },
        controller: _controller,
        itemBuilder: (context, position) {
          return _widgetOptions.elementAt(position);
        },
        itemCount: 5,
      ),
      bottomNavigationBar: gNavContainer(_widgetTitle),
    );
  }

  SafeArea gNavContainer(_widgetTitle) {
    return SafeArea(
      child: Container(
        // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          // borderRadius: BorderRadius.all(Radius.circular(100)),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(.4),
              offset: Offset(0, 10),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3),
          child: GNav(
            tabs: gButtonTaps(_widgetTitle, _widgetColors, _widgetIcons),
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
              _controller.jumpToPage(index);
            },
          ),
        ),
      ),
    );
  }

  List<GButton> gButtonTaps(List<String> widgetTitle, List<Color> widgetColors,
      List<IconData> widgetIcons) {
    return [
      GButton(
        gap: _gap,
        iconActiveColor: widgetColors.elementAt(0),
        iconColor: Colors.black,
        textColor: widgetColors.elementAt(0),
        backgroundColor: widgetColors.elementAt(0).withOpacity(.2),
        iconSize: 24,
        padding: _padding,
        icon: widgetIcons.elementAt(0),
        text: widgetTitle[0],
      ),
      GButton(
        gap: _gap,
        iconActiveColor: widgetColors.elementAt(1),
        iconColor: Colors.black,
        textColor: widgetColors.elementAt(1),
        backgroundColor: widgetColors.elementAt(1).withOpacity(.2),
        iconSize: 24,
        padding: _padding,
        icon: widgetIcons.elementAt(1),
        text: widgetTitle[1],
      ),
      GButton(
        gap: _gap,
        iconActiveColor: widgetColors.elementAt(2),
        iconColor: Colors.black,
        textColor: widgetColors.elementAt(2),
        backgroundColor: widgetColors.elementAt(2).withOpacity(.2),
        iconSize: 24,
        padding: _padding,
        icon: widgetIcons.elementAt(2),
        text: widgetTitle[2],
      ),
      GButton(
        gap: _gap,
        iconActiveColor: widgetColors.elementAt(3),
        iconColor: Colors.black,
        textColor: widgetColors.elementAt(3),
        backgroundColor: widgetColors.elementAt(3).withOpacity(.2),
        iconSize: 24,
        padding: _padding,
        icon: widgetIcons.elementAt(3),
        text: widgetTitle[3],
        leading: _selectedIndex == 3 || _badge == 0
            ? null
            : Badge(
                badgeColor: Colors.red.shade100,
                elevation: 0,
                position: BadgePosition.topEnd(top: -12, end: -12),
                badgeContent: Text(
                  _badge.toString(),
                  style: TextStyle(color: Colors.red.shade900),
                ),
                child: Icon(
                  LineIcons.heart,
                  color: _selectedIndex == 3 ? Colors.pink : Colors.black,
                ),
              ),
      ),
      GButton(
        gap: _gap,
        iconActiveColor: widgetColors.elementAt(4),
        iconColor: Colors.black,
        textColor: widgetColors.elementAt(4),
        backgroundColor: widgetColors.elementAt(4).withOpacity(.2),
        iconSize: 24,
        padding: _padding,
        icon: widgetIcons.elementAt(4),
        leading: CircleAvatar(
          radius: 12,
          backgroundImage: NetworkImage(
            'https://avatars.githubusercontent.com/u/53206234?v=4',
          ),
        ),
        text: widgetTitle[4],
        textStyle: TextStyle(fontSize: 10),
      )
    ];
  }

// List<GButton> GButtonTaps2(List<String> widgetTitle, List<Color> widgetColors,
//     List<IconData> widgetIcons) {
//   List<GButton> _list = <GButton>[];
//
//   for (int i = 0; i < 5; i += 1) {
//     GButton _gb = GButton(
//       gap: _gap,
//       iconActiveColor: widgetColors.elementAt(i),
//       iconColor: Colors.black,
//       textColor: widgetColors.elementAt(i),
//       backgroundColor: widgetColors.elementAt(i).withOpacity(.2),
//       iconSize: 24,
//       padding: _padding,
//       icon: widgetIcons.elementAt(i),
//       text: widgetTitle.elementAt(i),
//     );
//     _list.add(_gb);
//   }
//   return _list;
// }
}
