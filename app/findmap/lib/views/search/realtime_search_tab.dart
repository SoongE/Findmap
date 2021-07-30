import 'package:findmap/src/my_colors.dart';
import 'package:findmap/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RealtimeSearchTab extends StatefulWidget {
  @override
  _RealtimeSearchTabState createState() => _RealtimeSearchTabState();
}

class _RealtimeSearchTabState extends State<RealtimeSearchTab>
    with SingleTickerProviderStateMixin {
  List<String> _tabs = ['종합', '뉴스', '음악', '영화', '스포츠', '책'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      key: const ValueKey('child'),
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
              GetRealtimeSearch(
                categoryID: 0,
              ),
              GetRealtimeSearch(
                categoryID: 1,
              ),
              GetRealtimeSearch(
                categoryID: 2,
              ),
              GetRealtimeSearch(
                categoryID: 3,
              ),
              GetRealtimeSearch(
                categoryID: 4,
              ),
              GetRealtimeSearch(
                categoryID: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GetRealtimeSearch extends StatefulWidget {
  final int categoryID;

  GetRealtimeSearch({Key? key, required this.categoryID}) : super(key: key);

  @override
  _GetRealtimeSearchState createState() => _GetRealtimeSearchState();
}

class _GetRealtimeSearchState extends State<GetRealtimeSearch> {
  final List<String> keyword1 = <String>[
    'C',
    'C++',
    'JAVA',
    'Javascript',
    'python',
    'ruby',
    'typescript',
    'scala',
    'Kotlin',
    'Dart',
  ];
  final List<String> keyword2 = <String>[
    'Pytorch',
    'Tensorflow',
    'Keras',
    'OpenCV',
    'Flask',
    'Django',
    'Scikit-learn',
    'Django',
    'NumPy',
    'Pandas',
  ];
  final List<String> keyword3 = <String>[
    'Butter',
    'Damselfly',
    'Clair de Lune',
    'Dang!',
    'Believer',
    'Drive',
    'Butterflies',
    'Rain On Me',
    'Your Power',
    'bad guy',
  ];
  final List<String> keyword4 = <String>[
    'IronMan',
    'Parasite',
    'The Dig',
    'To All The Boys',
    'The Father',
    'Tom & Jerry',
    'Frozen',
    'Justice League',
    'Avengers',
    'furious 9',
  ];
  final List<String> keyword5 = <String>[
    'baseball',
    'basketball',
    'soccer',
    'running',
    'boxing',
    'valley ball',
    'golf',
    'judo',
    'taekwondo',
    'swimming',
  ];
  final List<String> keyword6 = <String>[
    'Harry Potter',
    '1987',
    'The little prince',
    'Yearbook',
    'Atomic Habits',
    'Behold a Pale Horse',
    'Rich Dad Poor Dad',
    'Zero Fail',
    'People We Meet on Vacation',
    'The Alchemist',
  ];

  @override
  Widget build(BuildContext context) {
    List<List<String>> keywords = [
      keyword1,
      keyword2,
      keyword3,
      keyword4,
      keyword5,
      keyword6
    ];
    var id = widget.categoryID;

    return ListView.separated(
      padding: const EdgeInsets.all(8.0),
      itemCount: keywords.elementAt(id).length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            15.0,
            0.0,
            0.0,
            0.0,
          ),
          color: index % 2 == 0 ? Colors.yellow[100] : Colors.grey[200],
          height: 40,
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.push(context,
                    createRoute(_webView(keywords.elementAt(id)[index]))),
                child: Text(
                  (index + 1).toString() +
                      '      ' +
                      '${keywords.elementAt(id)[index]}',
                  style: new TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15.3,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(
        thickness: 1,
        color: Colors.black54,
      ),
    );
  }

  Widget _webView(String search) {
    return SafeArea(
      child: WebView(
        initialUrl:
            'https://search.naver.com/search.naver?where=nexearch&sm=top_hty&fbm=1&ie=utf8&query=$search',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
