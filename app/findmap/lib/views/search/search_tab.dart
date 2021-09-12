import 'package:findmap/src/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SearchTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  late TextEditingController _searchKeyword;
  bool _visibleSearchInput = false;

  final List<ChartData> chartData = [
    ChartData('2010', 1, 1, 3),
    ChartData('2011', 2, 2, 5),
    ChartData('CENTER', 3, 10, 20),
    ChartData('2013', 4, 14, 12),
    ChartData('2014', 5, 20, 15)
  ];

  @override
  Widget build(BuildContext context) {
    _searchKeyword = TextEditingController(text: '');
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            child: AnimatedOpacity(
              opacity: _visibleSearchInput ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
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
          Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: SfCartesianChart(
                primaryXAxis:
                    NumericAxis(minimum: 0, maximum: 6, isVisible: true),
                primaryYAxis:
                    NumericAxis(minimum: 0, maximum: 21, isVisible: true),
                plotAreaBorderColor: Colors.transparent,
                series: <ChartSeries>[
                  BubbleSeries<ChartData, double>(
                    maximumRadius: 20,
                    minimumRadius: 10,
                    dataSource: chartData,
                    sizeValueMapper: (ChartData sales, _) => sales.size,
                    xValueMapper: (ChartData sales, _) => sales.x,
                    yValueMapper: (ChartData sales, _) => sales.y,
                    dataLabelMapper: (ChartData sales, _) => sales.name,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.middle,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
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

class ChartData {
  final String name;
  final double x;
  final double y;
  final double size;

  ChartData(this.name, this.x, this.y, this.size);
}
