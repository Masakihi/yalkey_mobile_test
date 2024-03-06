import 'dart:math';
import 'package:flutter/material.dart';
import 'constant.dart';

// 最大値を計算するためのジェネリック関数
double findMax(List<dynamic> values) {
  double maxVal = 0;
  if (values.isNotEmpty) {
    if (values[0] is double) {
      print("doubleです");
      for (var value in values) {
        if (value > maxVal) {
          maxVal = value;
        }
      }
    }
  }

  return maxVal;
}


String convertDateTime2String(DateTime dateTime) {
  return '${dateTime.year}年${dateTime.month}月${dateTime.day}日';
}

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
  late DateTime _startDate; // 開始日
  late DateTime _endDate; // 終了日
  late int _selectedYear;
  late int _selectedMonth;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedYear = today.year;
    _selectedMonth = today.month;
    _startDate = DateTime(today.year, today.month, 1); // 本日の月の最初の日
    _endDate = DateTime(today.year, today.month + 1, 0); // 本日の月の最後の日
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        // Row(
        //   children: [
        //     ElevatedButton(
        //       onPressed: () => _selectStartDate(context),
        //       child: Text(convertDateTime2String(_startDate)),
        //     ),
        //     SizedBox(width: 4),
        //     Text('～'),
        //     SizedBox(width: 4),
        //     ElevatedButton(
        //       onPressed: () => _selectEndDate(context),
        //       child: Text(convertDateTime2String(_endDate)),
        //     ),
        //   ],
        // ),
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
          SizedBox(height: 16),
          FutureBuilder<Map<DateTime, dynamic>>(
            future: YalkerProgressListResponse.fetchDataForGraphByReportTitle(
              widget.userId,
              _startDate,
              _endDate,
              widget.reportTitle,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                // データを取得できた場合はグラフを表示
                final Map<DateTime, dynamic> data = snapshot.data!;
                final List<DateTime> dates =
                    _generateDateList(_startDate, _endDate);
                final List<dynamic> values = dates.map((date) {
                  if (data.containsKey(date)) {
                    final value = data[date];
                    if (value is Duration) {
                      return value.inMinutes.toDouble();
                    } else if (value is double) {
                      return value;
                    } else {
                      return value.toDouble();
                    }
                  } else {
                    return 0.0;
                  }
                }).toList();

                final maxValue = findMax(values);

                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    //color: Colors.grey[200], // グラフエリアの背景色
                    border: Border.all(color: Colors.grey), // 枠線の色
                  ),
                  child: Stack(
                    children: [
                      ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: dates.length,
                        itemBuilder: (context, index) {
                          final date = dates[index];
                          final value = values[index];
                          final double height =
                              maxValue != 0 ? value / maxValue * 150 : 0;

                          return GestureDetector(
                            onTap: () =>
                                _showValuePopup(context, dates[index], value),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 20,
                                  height: height,
                                  color: const Color(0xFFAE0103),
                                ),
                                SizedBox(height: 4),
                                Text('${date.day}日'),
                              ],
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 8, // グラフエリアの上端からのオフセット
                        right: 8, // グラフエリアの右端からのオフセット
                        child: Text(
                          '単位: ${widget.reportUnit}', // レポートの単位を表示
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFAE0103),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ]
      ],
    );
  }

  void _updateDates() {
    _startDate = DateTime(_selectedYear, _selectedMonth, 1);
    _endDate = DateTime(_selectedYear, _selectedMonth + 1, 0);
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

  void _selectStartDate(BuildContext context) async {
    final DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2015, 8),
      lastDate: _endDate,
    );
    if (pickedStartDate != null && pickedStartDate != _startDate) {
      setState(() {
        _startDate = pickedStartDate;
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final DateTime? pickedEndDate = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );
    if (pickedEndDate != null && pickedEndDate != _endDate) {
      setState(() {
        _endDate = pickedEndDate;
      });
    }
  }

  void _showValuePopup(BuildContext context, DateTime dateTime, double value) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(''),
          content:
              Text('${convertDateTime2String(dateTime)}の進捗：${value.toInt()}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  /*
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
   */
}
