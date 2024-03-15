import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:yalkey_0206_test/profile/yalker_repost.dart';
import '../api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../followed_list_page.dart';
import '../following_list_page.dart';
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
    if (_profileData!=null) _profileData!.clear();
    _fetchProfileData();
    _fetchReportList();
  }

  Future<void> _fetchProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // キャッシュからデータを取得
    String? cachedProfileData = prefs.getString('profileData');

    try {
      final Map<String, dynamic> response =
          await httpGet('login-user-profile/', jwt: true);
      setState(() {
        _profileData = response;
        print(_profileData);
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
    final Map<String, dynamic> response = await httpGet('login-user-profile/', jwt: true);
    _profileData = response;
    ReportListResponse reportListResponse =
        await ReportListResponse.fetchReportListResponse(_profileData!['login_user_profile']['user_number']);
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

  void _showExplanation(BuildContext context, String explanation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('説明'),
          content: Text(explanation),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
        appBar: AppBar(
          title: const Text('yalkerプロフィール'),
        ),

       */
        body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: _profileData != null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _profileData!['login_user_profile']['iconimage'] == ""
                            ? const CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(
                            'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/static/img/user.png',
                          ),
                          radius: 35,
                        )
                            : CircleAvatar(
                          backgroundImage: NetworkImage(
                            '${_profileData!['login_user_profile']['iconimage']}',
                          ),
                          radius: 35,
                        ),
                        SizedBox(width: 20), // アイコンと名前の間隔を設定

                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _profileData!['login_user_profile']['name'],
                                style: TextStyle(fontSize: 24),
                              ),
                              Row(
                                children: [
                                  if (_profileData!['login_user_profile']
                                  ['private'] ??
                                      false)
                                    const Icon(
                                      Icons.lock,
                                      color: Colors.grey,
                                      size: 14.0,
                                    ),
                                  Text(
                                    '@${_profileData!['login_user_profile']['user_id']}',
                                    style: const TextStyle(
                                        fontSize: 14.0, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  if (_profileData!['login_user_profile']
                                  ['super_early_bird'] ??
                                      false)
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        _showExplanation(context,
                                            badge2Explanation['超早起き']!);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 3, vertical: 1),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFAE0103),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 3, vertical: 1),
                                            child: Text(
                                              "超早起き",
                                              style: TextStyle(
                                                  fontSize: 10.0,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (_profileData!['login_user_profile']
                                  ['early_bird'] ??
                                      false)
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        _showExplanation(context,
                                            badge2Explanation['早起き']!);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 3, vertical: 1),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFAE0103),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 3, vertical: 1),
                                            child: Text(
                                              "早起き",
                                              style: TextStyle(
                                                  fontSize: 10.0,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (_profileData!['login_user_profile']
                                  ['super_hard_worker'] ??
                                      false)
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        _showExplanation(context,
                                            badge2Explanation['超努力家']!);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 3, vertical: 1),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFAE0103),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 3, vertical: 1),
                                            child: Text(
                                              "超努力家",
                                              style: TextStyle(
                                                  fontSize: 10.0,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (_profileData!['login_user_profile']
                                  ['hard_worker'] ??
                                      false)
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        _showExplanation(context,
                                            badge2Explanation['努力家']!);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 3, vertical: 1),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFAE0103),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 3, vertical: 1),
                                            child: Text(
                                              "努力家",
                                              style: TextStyle(
                                                  fontSize: 10.0,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (_profileData!['login_user_profile']
                                  ['regular_customer'] ??
                                      false)
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        _showExplanation(context,
                                            badge2Explanation['常連']!);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 3, vertical: 1),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFAE0103),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 3, vertical: 1),
                                            child: Text(
                                              "常連",
                                              style: TextStyle(
                                                  fontSize: 10.0,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                ],
                              ),
                              const SizedBox(height: 8.0),
                            ],
                          ),
                        )
                        // Spacer(), // 編集ボタンを右端に配置するためのスペーサー
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(children: [
                      GestureDetector(
                        //InkWellでも同じ
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FollowingListPage(
                                  userNumber: _profileData!['login_user_profile']
                                  ['user_number']),
                            ),
                          );
                        },
                        child: Text(
                          'フォロー ${_profileData!['following_num']}',
                          textAlign: TextAlign.start, // 左詰めに設定
                        ),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        //InkWellでも同じ
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FollowedListPage(
                                  userNumber: _profileData!['login_user_profile']
                                  ['user_number']),
                            ),
                          );
                        },
                        child: Text(
                          'フォロワー ${_profileData!['followed_num']}',
                          textAlign: TextAlign.start, // 左詰めに設定
                        ),
                      ),
                    ]),
                    SizedBox(height: 10), // 余白を追加
                    LinkifyUtil(
                        text: _profileData!['login_user_profile']['profile'],
                        withPreview: false,
                        maxWords: 300),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: _editProfile, // 編集ボタンが押された時の処理
                            child: Text('編集'),
                          ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => YalkerRepostPage(
                                      userNumber: _profileData!['login_user_profile']
                                      ['user_number']),
                                ));
                          },
                          child: Text('投稿一覧'),
                        ),
                      ]
                    ),
                    SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _reportListMap['num_report_list']?.length,
                      itemBuilder: (context, index) {
                        final report =
                        _reportListMap['num_report_list']?[index];
                        return MonthlyBarChart(
                          userId: _profileData!['login_user_profile']['user_number'],
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
                          userId: _profileData!['login_user_profile']['user_number'],
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
}
