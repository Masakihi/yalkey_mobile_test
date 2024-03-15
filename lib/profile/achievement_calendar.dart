import 'package:flutter/material.dart';
import '../constant.dart';

class AchievementCalendar extends StatefulWidget {
  final int userId;
  final String reportTitle;

  AchievementCalendar({
    required this.userId,
    required this.reportTitle,
  });

  @override
  _AchievementCalendarState createState() => _AchievementCalendarState();
}

class _AchievementCalendarState extends State<AchievementCalendar> {
  final today = DateTime.now();
  late int _selectedYear = today.year;
  late int _selectedMonth = today.month;
  late Map<DateTime, double> date2DataMap = {};
  late bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    print("hogehoge");
    Map<DateTime, double> _date2DataMap =
        await YalkerProgressListResponse.fetchDataForGraphByReportTitle(
      widget.userId,
      DateTime(_selectedYear, _selectedMonth, 1),
      DateTime(_selectedYear, _selectedMonth + 1, 0),
      widget.reportTitle,
    );
    setState(() => {date2DataMap = _date2DataMap});
    print(date2DataMap);
  }

  TableRow _buildWeekdayRow() {
    final weekdays = ['日', '月', '火', '水', '木', '金', '土'];
    List<Widget> cells = weekdays.map((day) => _buildDayCellText(day)).toList();
    return TableRow(children: cells);
  }

  List<List<DateTime>> _generateDateMatrix(int year, int month) {
    List<List<DateTime>> dateMatrix = [];
    final DateTime startDate = DateTime(year, month, 1);
    final DateTime endDate = DateTime(year, month + 1, 0);
    // 日曜日からスタート
    DateTime currentDate =
        startDate.subtract(Duration(days: startDate.weekday));
    // endDate を超えない範囲でループ
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      List<DateTime> dateList = [];
      for (int i = 0; i < 7; i++) {
        dateList.add(currentDate);
        currentDate = currentDate.add(Duration(days: 1));
      }
      dateMatrix.add(dateList);
    }
    return dateMatrix;
  }

  Widget _buildCalendar() {
    List<List<DateTime>> dateMatrix =
        _generateDateMatrix(_selectedYear, _selectedMonth);
    List<TableRow> rows = [];
    for (List<DateTime> dateList in dateMatrix) {
      List<Widget> cells = [];
      for (DateTime date in dateList) {
        cells.add(
          TableCell(
            child: _buildDayCell(date, date2DataMap),
          ),
        );
      }
      rows.add(TableRow(children: cells));
    }
    return Table(
      children: [
        _buildWeekdayRow(),
        ...rows,
      ],
    );
  }

  Widget _buildDayCellText(String day) {
    late Color color;
    switch (day) {
      case '日':
        color = Colors.red;
      case '土':
        color = Colors.blue;
      default:
        color = Colors.white;
    }
    return Center(
      child: Text(
        day,
        style: TextStyle(fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildDayCell(DateTime date, Map<DateTime, dynamic> date2dataMap) {
    Color cellColor = _getColor(date, date2dataMap);
    DateTime today = DateTime.now();
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: cellColor,
        border: Border.all(
            color: date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day
                ? Colors.white
                : Colors.black),
      ),
      child: Center(
        child: Text(
          date.day.toString(),
          style: TextStyle(
            color: date.month == _selectedMonth ? Colors.white : Colors.white24,
          ),
        ),
      ),
    );
  }

  Color _getColor(DateTime date, Map<DateTime, dynamic> date2dataMap) {
    if (date2dataMap.containsKey(date)) {
      return date2dataMap[date] > 0 ? const Color(0xFFAE0103) : Colors.white10;
    } else {
      return Colors.white10;
    }
  }

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
                      fetchData();
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
                      fetchData();
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
          _buildCalendar(),
          const SizedBox(height: 30),
        ],
      ],
    );
  }
}
