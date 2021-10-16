import 'dart:convert';
import 'dart:io';

import 'package:findmap/models/user.dart';
import 'package:findmap/src/digit.dart';
import 'package:findmap/src/my_colors.dart';
import 'package:findmap/utils/utils.dart';
import 'package:findmap/views/search/search_result.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({required this.user, Key? key}) : super(key: key);

  final User user;

  @override
  State<StatefulWidget> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  static const int MAX_Y = 19;
  static const int MAX_X = 5;
  static const int MAX_RADIO = 30;
  static const int MIN_RADIO = 10;

  final GlobalKey<FormState> _keywordKey = GlobalKey<FormState>();
  late TextEditingController _searchKeyword;
  bool _visibleSearchInput = false;
  late List<ChartData> chartData = [];
  var colorList = CHART_COLOR.toList()..shuffle();
  bool _isInit = true;

  @override
  void dispose() {
    _searchKeyword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _searchKeyword = TextEditingController(text: '');
    return FutureBuilder<String>(
      future: fetchGetInitData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('');
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          if (_isInit) {
            var valueList = snapshot.data!.split(',');
            // chartData = [
            //   ChartData(valueList[1], 1, 4, 3, colorList[0]),
            //   ChartData(valueList[2], 2, 16, 5, colorList[1]),
            //   ChartData('검색어', 3, 10, 30, colorList[2]),
            //   ChartData(valueList[4], 4, 14, 12, colorList[3]),
            //   ChartData(valueList[5], 5, 8, 15, colorList[4]),
            // ];
            //Todo remove
            chartData = [
              ChartData('백종원', 1, 4, 3, colorList[0]),
              ChartData('연남동', 2, 16, 5, colorList[1]),
              ChartData('검색어', 3, 10, 30, colorList[2]),
              ChartData('연돈', 4, 14, 12, colorList[3]),
              ChartData('스타벅스', 5, 8, 15, colorList[4]),
            ];
            _isInit = false;
          }

          return Scaffold(
            body: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: AnimatedOpacity(
                    opacity: _visibleSearchInput ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: Form(
                      key: this._keywordKey,
                      child: TextFormField(
                        autofocus: _visibleSearchInput ? true : false,
                        controller: _searchKeyword,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          labelText: "검색어를 입력하세요",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return '검색어를 최소 한 글자 이상 작성해주세요';
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) {
                          if (this._keywordKey.currentState!.validate()) {
                            var newKeyword = _searchKeyword.text.trim();
                            chartData[2].name = newKeyword;
                            _visibleSearchInput = false;
                            _tap(2);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: SfCartesianChart(
                      primaryXAxis: NumericAxis(
                          minimum: 0, maximum: MAX_X + 1, isVisible: false),
                      primaryYAxis: NumericAxis(
                          minimum: 0, maximum: MAX_Y + 1, isVisible: false),
                      plotAreaBorderColor: Colors.transparent,
                      series: <ChartSeries>[
                        BubbleSeries<ChartData, double>(
                          animationDuration: 1000,
                          maximumRadius: MAX_RADIO,
                          minimumRadius: MIN_RADIO,
                          dataSource: chartData,
                          sizeValueMapper: (ChartData sales, _) => sales.size,
                          xValueMapper: (ChartData sales, _) => sales.x,
                          yValueMapper: (ChartData sales, _) => sales.y,
                          pointColorMapper: (ChartData sales, _) => sales.color,
                          dataLabelMapper: (ChartData sales, _) => sales.name,
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            labelAlignment: ChartDataLabelAlignment.middle,
                          ),
                          onPointTap: (ChartPointDetails details) {
                            if (details.pointIndex == 2) {
                              // if click center keyword, then input new search keyword
                              setState(() {
                                _visibleSearchInput = true;
                              });
                            } else {
                              if (_visibleSearchInput == true)
                                _visibleSearchInput = !_visibleSearchInput;
                              _tap(details.pointIndex);
                            }
                          },
                          onPointLongPress: (ChartPointDetails details) {
                            _longTap(details.pointIndex);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  void _longTap(int? index) {
    print(index);
    String _searchKeyWord = '검색어가 존재하지 않습니다';
    if (index != null) {
      _searchKeyWord = chartData[index].name;
    }
    // Navigator.push(context, createRoute(_webView(_searchKeyWord)));
    Navigator.push(
        context,
        createRoute(SearchResult(
          user: widget.user,
          keyword: _searchKeyWord,
        )));
  }

  void _tap(int? index) {
    final String searchName = chartData[index as int].name;
    fetchGetKeywordData(searchName).then((value) {
      setState(() {
        var valueList = value.split(',');
        var colorList = CHART_COLOR.toList()..shuffle();
        var xList = POSITION_X.toList()..shuffle();
        var yList = POSITION_Y.toList()..shuffle();
        var size = SIZE.toList()..shuffle();
        chartData = [
          ChartData(valueList[1], xList[0], yList[0], size[0], colorList[0]),
          ChartData(valueList[2], xList[1], yList[1], size[1], colorList[1]),
          ChartData(searchName, 3, 10, 30, colorList[2]),
          ChartData(valueList[3], xList[3], yList[3], size[2], colorList[3]),
          ChartData(valueList[4], xList[4], yList[4], size[3], colorList[4]),
        ];
        //Todo remove later
        if (searchName == '레드벨벳') {
          chartData = [
            ChartData('스타벅스', xList[0], yList[0], size[0], colorList[0]),
            ChartData('조각케이크', xList[1], yList[1], size[1], colorList[1]),
            ChartData(searchName, 3, 10, 30, colorList[2]),
            ChartData('쿠키', xList[3], yList[3], size[2], colorList[3]),
            ChartData('투썸플레이스', xList[4], yList[4], size[3], colorList[4]),
          ];
        }
      });
    });
  }

  Future<String> fetchGetInitData() async {
    // Map<String, dynamic> param = {'keyword': widget.user.userIdx.toString()};
    Map<String, dynamic> param = {'keyword': '1'};

    final response = await http.get(
      Uri.http(BASEURL, '/test/recommend/initrecom', param),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": "widget.user.accessToken",
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      return responseBody['body']['searchinit'];
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to connect to server');
    }
  }

  Future<String> fetchGetKeywordData(String keyword) async {
    Map<String, dynamic> param = {'keyword': keyword};

    final response = await http.get(
      Uri.http(BASEURL, '/test/recommend', param),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": "widget.user.accessToken",
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      return responseBody['body']['model'];
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to connect to server');
    }
  }
}

class ChartData {
  String name;
  final double x;
  final double y;
  final double size;
  final Color color;

  ChartData(this.name, this.x, this.y, this.size, this.color);
}
