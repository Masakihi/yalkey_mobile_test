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

void _showValuePopup(BuildContext context, double value) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('バーの値'),
        content: Text('値: $value'),
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

class MonthlyBarChart extends StatelessWidget {
  final int userId;
  final String reportTitle;
  final DateTime startDate;
  final DateTime endDate;

  MonthlyBarChart({
    required this.userId,
    required this.reportTitle,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<DateTime, dynamic>>(
      future: YalkerProgressListResponse.fetchDataForGraphByReportTitle(
          userId, startDate, endDate, reportTitle),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final Map<DateTime, dynamic> data = snapshot.data!;
          final List<DateTime> dates = _generateDateList(startDate, endDate);
          final List<dynamic> values = dates.map((date) {
            if (data.containsKey(date)) {
              final value = data[date];
              if (value is Duration) {
                return value.inMinutes.toDouble(); // Durationを分に変換してdoubleに変換
              } else if (value is double) {
                return value; // doubleの場合はそのまま返す
              } else {
                return value.toDouble(); // intをdoubleに変換
              }
            } else {
              return 0.0; // キーが存在しない場合は0.0を返す
            }
          }).toList();

          // 最大値の取得
          final maxValue = findMax(values);
          print(maxValue);

          return Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final value = values[index];
                final double height =
                    maxValue != 0 ? value / maxValue * 150 : 0;

                return GestureDetector(
                  onTap: () {
                    _showValuePopup(context, value); // タップしたときにポップアップを表示
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 20, // 棒グラフの幅
                        height: height,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 4),
                      Text('${date.day}日'),
                    ],
                  ),
                );
              },
            ),
          );
        }
      },
    );
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
