import 'package:findmap/src/my_colors.dart';
import 'package:flutter/material.dart';

class SearchTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
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
