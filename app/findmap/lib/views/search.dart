import 'package:findmap/src/my_colors.dart';
import 'package:findmap/utils/utils.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: MyColors.search,
            toolbarHeight: 50,
            flexibleSpace: SafeArea(
              child: TabBar(
                tabs: [
                  Tab(text: '검색'),
                  Tab(text: '실시간검색어'),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              SearchTap(),
              RealtimeSearchTap(),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchTap extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _searchTapState();
}

class _searchTapState extends State<SearchTap> {
  late TextEditingController _searchKeyword;
  bool _visibleSearchInput = false;

  @override
  Widget build(BuildContext context) {
    _searchKeyword = TextEditingController(text: '');
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(15),
        child: AnimatedOpacity(
          // If the widget is visible, animate to 0.0 (invisible).
          // If the widget is hidden, animate to 1.0 (fully visible).
          opacity: _visibleSearchInput ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300),
          // The green box must be a child of the AnimatedOpacity widget.
          child: TextFormField(
            controller: _searchKeyword,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: "검색어를 입력하세요",
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _visibleSearchInput = !_visibleSearchInput;
          });
        },
        child: const Icon(Icons.search),
        backgroundColor: MyColors.search,
      ),
    );
  }
}

class RealtimeSearchTap extends StatefulWidget {
  @override
  _RealtimeSearchTapState createState() => _RealtimeSearchTapState();
}

class _RealtimeSearchTapState extends State<RealtimeSearchTap> {
  int pressed = 1;

  /*@override
  void initState() {
    super.initState();
    mainList.addAll(sampleMenList);
  }*/
  String textHolder = 'Old Sample Text';

  showList() {
    setState(() {
      textHolder = "New Sample Text...";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: <Widget>[
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                TextButton(
                  child: Text("종합"),
                  style: TextButton.styleFrom(
                    primary: Colors.black54,
                    padding: EdgeInsets.all(8.0),
                    textStyle: TextStyle(
                      fontWeight:
                          pressed == 1 ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16.5,
                      decoration: pressed == 1
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                  onPressed: () {
                    showList();
                    setState(() {
                      pressed = 1;
                    });
                  },
                ),
                TextButton(
                  child: Text("뉴스"),
                  style: TextButton.styleFrom(
                    primary: Colors.black54,
                    padding: EdgeInsets.all(8.0),
                    textStyle: TextStyle(
                      fontWeight:
                          pressed == 2 ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16.5,
                      decoration: pressed == 2
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      pressed = 2;
                    });
                  },
                ),
                TextButton(
                  child: Text("음악"),
                  style: TextButton.styleFrom(
                    primary: Colors.black54,
                    padding: EdgeInsets.all(8.0),
                    textStyle: TextStyle(
                      fontWeight:
                          pressed == 3 ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16.5,
                      decoration: pressed == 3
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      pressed = 3;
                    });
                  },
                ),
                TextButton(
                  child: Text("영화"),
                  style: TextButton.styleFrom(
                    primary: Colors.black54,
                    padding: EdgeInsets.all(8.0),
                    textStyle: TextStyle(
                      fontWeight:
                          pressed == 4 ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16.5,
                      decoration: pressed == 4
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      pressed = 4;
                    });
                  },
                ),
                TextButton(
                  child: Text("스포츠"),
                  style: TextButton.styleFrom(
                    primary: Colors.black54,
                    padding: EdgeInsets.all(8.0),
                    textStyle: TextStyle(
                      fontWeight:
                          pressed == 5 ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16.5,
                      decoration: pressed == 5
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      pressed = 5;
                    });
                  },
                ),
                TextButton(
                  child: Text("책"),
                  style: TextButton.styleFrom(
                    primary: Colors.black54,
                    padding: EdgeInsets.all(8.0),
                    textStyle: TextStyle(
                      fontWeight:
                          pressed == 6 ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16.5,
                      decoration: pressed == 6
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      pressed = 6;
                    });
                  },
                ),
              ],
            ),
          ),
          Container(
            child: GetRealtimeSearch(categoryID: pressed),
            padding: EdgeInsets.only(top: 40),
          ),
        ],
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
    'Numpy',
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
              Text(
                (index + 1).toString() +
                    '      ' +
                    '${keywords.elementAt(id)[index]}',
                style: new TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 15.3,
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
}
