import 'dart:convert';
import 'package:flutter/material.dart';
import '../api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_edit_page.dart';
// import 'bar_graph.dart';
import 'bar_graph copy.dart';
import 'report_model.dart';
import 'achievement_calendar.dart';
import '../post/linkify_util.dart';
import 'package:fl_chart/fl_chart.dart';
import 'bar_chart_sample3.dart';
import 'bar_chart_sample_blog.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'calendar_example/basics_example.dart';
import 'calendar_example/complex_example.dart';
import 'calendar_example/events_example.dart';
import 'calendar_example/multi_example.dart';
import 'calendar_example/range_example.dart';


const Map<String, String> badge2Explanation = {
  "超早起き": "超早起き：過去1週間のうち7日早起き投稿したyalker",
  "早起き": "早起き：過去1週間のうち3日早起き投稿したyalker",
  "超努力家": "超努力家：めちゃくちゃ頑張って投稿してるyalker",
  "努力家": "努力家：けっこう頑張って投稿してるyalker",
  "常連": "常連：継続して投稿してるyalker",
};


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _profileData;
  late Map<String, List<Report>> _reportListMap = {
    'num_report_list': [],
    'bool_report_list': []
  };
  late bool _loadingReportList = false;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _fetchReportList();
  }

  Future<void> _fetchProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // キャッシュからデータを取得
    String? cachedProfileData = prefs.getString('profileData');
    if (cachedProfileData != null) {
      setState(() {
        _profileData = json.decode(cachedProfileData);
      });
      return;
    }

    try {
      final Map<String, dynamic> response =
          await httpGet('login-user-profile/', jwt: true);
      setState(() {
        _profileData = response;
      });

      // データをキャッシュ
      await prefs.setString('profileData', json.encode(response));
    } catch (error) {
      print('Error fetching profile data: $error');
    }
  }

  Future<void> _fetchReportList() async {
    setState(() {
      _loadingReportList = true;
    });
    ReportListResponse reportListResponse =
        await ReportListResponse.fetchReportListResponse(59);
    if (mounted) {
      setState(() {
        reportListResponse.reportList.forEach((report) => {
              if (report.reportType == 4)
                {_reportListMap['bool_report_list']?.add(report)}
              else
                {_reportListMap['num_report_list']?.add(report)}
            });
        _loadingReportList = false;
      });
    }
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditPage(profileData: _profileData!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('プロフィール'),
        ),
        body: SingleChildScrollView(
            child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _profileData != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              _profileData!['login_user_profile']['iconimage'],
                            ),
                            radius: 40, // アイコンの半径を小さくする
                          ),
                          SizedBox(width: 20), // アイコンと名前の間隔を設定
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _profileData!['login_user_profile']['name'],
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                '@${_profileData!['login_user_profile']['user_id']}',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                          Spacer(), // 編集ボタンを右端に配置するためのスペーサー
                          ElevatedButton(
                            onPressed: _editProfile, // 編集ボタンが押された時の処理
                            child: Icon(Icons.edit),
                          ),
                        ],
                      ),
                      SizedBox(height: 20), // 余白を追加
                      LinkifyUtil(
                          text: _profileData!['login_user_profile']['profile'],
                          withPreview: false,
                          maxWords: 300),
                      SizedBox(height: 20), // 余白を追加
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _reportListMap['num_report_list']?.length,
                        itemBuilder: (context, index) {
                          final report =
                              _reportListMap['num_report_list']?[index];
                          return MonthlyBarChart(
                            userId: 59,
                            reportTitle: report!.reportName,
                            reportUnit: report.reportUnit,
                          );
                        },
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _reportListMap['bool_report_list']?.length,
                        itemBuilder: (context, index) {
                          final report =
                              _reportListMap['bool_report_list']?[index];
                          return AchievementCalendar(
                            userId: 59,
                            reportTitle: report!.reportName,
                          );
                        },
                      ),
                    ],
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        )));
  }

  @override
  Widget build2(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TableCalendar Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20.0),
            ElevatedButton(
              child: Text('Basics'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TableBasicsExample()),
              ),
            ),
            const SizedBox(height: 12.0),
            ElevatedButton(
              child: Text('Range Selection'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TableRangeExample()),
              ),
            ),
            const SizedBox(height: 12.0),
            ElevatedButton(
              child: Text('Events'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TableEventsExample()),
              ),
            ),
            const SizedBox(height: 12.0),
            ElevatedButton(
              child: Text('Multiple Selection'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TableMultiExample()),
              ),
            ),
            const SizedBox(height: 12.0),
            ElevatedButton(
              child: Text('Complex'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TableComplexExample()),
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
