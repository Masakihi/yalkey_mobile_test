import 'package:flutter/material.dart';
import '../constant.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyBarChart extends StatefulWidget {
  final int userId;
  final String reportTitle;
  final String reportUnit;

  MonthlyBarChart({
    required this.userId,
    required this.reportTitle,
    required this.reportUnit,
  });

  @override
  _MonthlyBarChartState createState() => _MonthlyBarChartState();
}

class _MonthlyBarChartState extends State<MonthlyBarChart> {
  final today = DateTime.now();
  late DateTime _startDate = DateTime(today.year, today.month, 1); // 開始日
  late DateTime _endDate = DateTime(today.year, today.month + 1, 0); // 終了日
  late int _selectedYear;
  late int _selectedMonth;
  Map<DateTime, double>? date2DataMap = null;
  bool _isExpanded = false;
  late int showingTooltip;

  @override
  void initState() {
    showingTooltip = -1;
    super.initState();
    final today = DateTime.now();
    _selectedYear = today.year;
    _selectedMonth = today.month;
    fetchData();
  }

  Future<void> fetchData() async {
    Map<DateTime, double> fetchedDate2DataMap =
        await YalkerProgressListResponse.fetchDataForGraphByReportTitle(
            widget.userId, _startDate, _endDate, widget.reportTitle);
    setState(() {
      date2DataMap = fetchedDate2DataMap;
    });
  }

  List<BarChartGroupData> generateGroupDataFromdate2DataMap(
      Map<DateTime, double> date2DataMap) {
    List<DateTime> dateList = _generateDateList(_startDate, _endDate);
    int index = -1;
    List<BarChartGroupData> fetchedBarGroups = dateList.map((date) {
      index += 1;
      return BarChartGroupData(
        x: index,
        showingTooltipIndicators: showingTooltip == index ? [0] : [],
        barRods: [
          BarChartRodData(
              toY: date2DataMap[date] ?? 0, color: const Color(0xFFAE0103))
        ],
      );
    }).toList();
    return fetchedBarGroups;
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: true,
        handleBuiltInTouches: false,
        touchCallback: (event, response) {
          if (response != null &&
              response.spot != null &&
              event is FlTapUpEvent) {
            print(response.spot!.touchedBarGroup.x);
            setState(() {
              final x = response.spot!.touchedBarGroup.x;
              final isShowing = showingTooltip == x;
              if (isShowing) {
                showingTooltip = -1;
              } else {
                showingTooltip = x;
              }
            });
          }
        },
        mouseCursorResolver: (event, response) {
          return response == null || response.spot == null
              ? MouseCursor.defer
              : SystemMouseCursors.click;
        },
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Color.fromARGB(122, 174, 1, 4),
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY > 0
                  ? '${group.x + 1}日\n${int.parse(rod.toY.round().toString())}${widget.reportUnit}'
                  : '',
              const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  Widget getBottomTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      fontSize: 10,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(value.toInt() % 3 == 0 ? '${value.toInt() + 1}' : '',
          style: style),
    );
  }

  Widget getLeftTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      fontSize: 10,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text('${value.toInt()}', style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          axisNameWidget: Text('日'),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getBottomTitles,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getLeftTitles,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: true,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 4.0, thickness: 0.3, color: Color(0xFF929292)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.reportTitle, // グラフのタイトル
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                // color: const Color(0xFFAE0103),
              ),
            ),
            IconButton(
              icon: _isExpanded
                  ? Icon(Icons.expand_less)
                  : Icon(Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ],
        ),
        SizedBox(height: 8),
        if (_isExpanded) ...[
          Row(
            children: [
              SizedBox(width: 8),
              DropdownButton<int>(
                value: _selectedYear,
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedYear = newValue;
                      _updateDates();
                    });
                  }
                },
                items: List<DropdownMenuItem<int>>.generate(
                  10,
                  (index) => DropdownMenuItem<int>(
                    value: DateTime.now().year + index,
                    child: Text('${DateTime.now().year + index}年'),
                  ),
                ),
              ),
              SizedBox(width: 16),
              DropdownButton<int>(
                value: _selectedMonth,
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedMonth = newValue;
                      _updateDates();
                    });
                  }
                },
                items: List<DropdownMenuItem<int>>.generate(
                  12,
                  (index) => DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text('${index + 1}月'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // 行を右寄せにする
            children: [
              Text(
                '（単位: ${widget.reportUnit}）',
                textAlign: TextAlign.right,
              ),
            ],
          ),
          if (date2DataMap != null) // date2DataMapがnullでない場合、グラフを表示する
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    barTouchData: barTouchData,
                    titlesData: titlesData,
                    borderData: borderData,
                    barGroups: generateGroupDataFromdate2DataMap(date2DataMap!),
                    gridData: const FlGridData(show: true),
                    alignment: BarChartAlignment.spaceAround,
                    maxY: getMaxYValue(
                        generateGroupDataFromdate2DataMap(date2DataMap!)),
                  ),
                  swapAnimationDuration:
                      Duration(milliseconds: 150), // Optional
                  swapAnimationCurve: Curves.linear,
                ),
              ),
            )
          else // barGroupsがnullの場合、読み込み中のインジケーターを表示する
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ],
    );
  }

  void _updateDates() {
    _startDate = DateTime(_selectedYear, _selectedMonth, 1);
    _endDate = DateTime(_selectedYear, _selectedMonth + 1, 0);
    fetchData();
    setState(() {});
  }

  List<DateTime> _generateDateList(DateTime startDate, DateTime endDate) {
    List<DateTime> dates = [];
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      dates.add(currentDate);
      currentDate = currentDate.add(Duration(days: 1));
    }
    return dates;
  }
}

double getMaxYValue(List<BarChartGroupData> barGroups) {
  double maxYValue = 0;
  for (final group in barGroups) {
    for (final rod in group.barRods) {
      if (rod.toY > maxYValue) {
        maxYValue = rod.toY;
      }
    }
  }
  // 少し余裕を持たせるために最大値より少し大きな値を返す
  return maxYValue * 1.1; // 例えば、最大値の110%を設定
}
