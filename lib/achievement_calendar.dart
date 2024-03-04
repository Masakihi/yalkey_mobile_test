import 'package:flutter/material.dart';
import 'constant.dart';

class AchievementCalendar extends StatelessWidget {
  final int userId;
  final String reportTitle;
  final int year;
  final int month;

  AchievementCalendar({
    required this.userId,
    required this.reportTitle,
    required this.year,
    required this.month,
  });

  TableRow _buildWeekdayRow(DateTime startDate) {
    final weekdays = ['日', '月', '火', '水', '木', '金', '土'];
    // 開始日に対応する曜日のインデックスを取得
    int startWeekdayIndex = startDate.weekday % 7;
    // インデックスに合わせて曜日リストを並び替える
    List<String> orderedWeekdays = [
      for (int i = startWeekdayIndex; i < weekdays.length; i++) weekdays[i],
      for (int i = 0; i < startWeekdayIndex; i++) weekdays[i],
    ];
    List<Widget> cells =
        orderedWeekdays.map((day) => _buildDayCellText(day)).toList();
    return TableRow(children: cells);
  }

  List<DateTime> _generateDateList(DateTime startDate, DateTime endDate) {
    List<DateTime> dates = [];
    DateTime currentDate = startDate;
    // endDate を超えない範囲でループ
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      dates.add(currentDate);
      currentDate = currentDate.add(Duration(days: 1));
    }
    return dates;
  }

  Widget _buildCalendar(
    DateTime startDate,
    DateTime endDate,
    Map<DateTime, dynamic> date2dataMap,
  ) {
    List<DateTime> dates = _generateDateList(startDate, endDate);
    List<TableRow> rows = [];
    for (int i = 0; i < 6; i++) {
      List<Widget> cells = [];
      for (int j = 0; j < 7; j++) {
        if (i * 7 + j < dates.length) {
          DateTime date = dates[i * 7 + j];
          cells.add(
            TableCell(
              child: _buildDayCell(date, date2dataMap),
            ),
          );
        } else {
          // 空のセルを追加
          cells.add(Container());
        }
      }
      rows.add(TableRow(children: cells));
    }

    return Table(
      children: [
        _buildWeekdayRow(startDate),
        ...rows,
      ],
    );
  }

  Widget _buildDayCellText(String day) {
    return Center(
      child: Text(
        day,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDayCell(DateTime date, Map<DateTime, dynamic> date2dataMap) {
    Color cellColor = _getColor(date, date2dataMap);
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: cellColor,
        border: Border.all(color: Colors.black),
      ),
      child: Center(
        child: Text(
          date.day.toString(),
          style: TextStyle(
            color: cellColor == Colors.grey ? Colors.grey[600] : Colors.black,
          ),
        ),
      ),
    );
  }

  Color _getColor(DateTime date, Map<DateTime, dynamic> date2dataMap) {
    if (date2dataMap.containsKey(date)) {
      return date2dataMap[date] ? Colors.red : Colors.grey;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime startDate = DateTime(year, month, 1);
    DateTime endDate = DateTime(year, month + 1, 0);

    return FutureBuilder<Map<DateTime, dynamic>>(
      future: YalkerProgressListResponse.fetchDataForGraphByReportTitle(
        userId,
        startDate,
        endDate,
        reportTitle,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          Map<DateTime, dynamic> date2dataMap = snapshot.data!;
          return _buildCalendar(startDate, endDate, date2dataMap);
        }
      },
    );
  }
}
