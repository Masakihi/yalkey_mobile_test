import 'dart:convert';
import 'package:flutter/material.dart';
import 'api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_edit_page.dart';
import 'bar_graph.dart';
import 'constant.dart';
import 'achievement_calendar.dart';

class YalkerProfilePage extends StatefulWidget {
  final int userId;
  const YalkerProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _YalkerProfilePageState createState() => _YalkerProfilePageState();
}

class _YalkerProfilePageState extends State<YalkerProfilePage> {
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
    try {
      final Map<String, dynamic> response =
          await httpGet('yalker-profile/${widget.userId}');
      setState(() {
        _profileData = response;
      });
    } catch (error) {
      print('Error fetching profile data: $error');
    }
  }

  Future<void> _fetchReportList() async {
    setState(() {
      _loadingReportList = true;
    });
    ReportListResponse reportListResponse =
        await ReportListResponse.fetchReportListResponse(widget.userId);
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
                              _profileData!['yalker_profile']['iconimage'],
                            ),
                            radius: 40, // アイコンの半径を小さくする
                          ),
                          SizedBox(width: 20), // アイコンと名前の間隔を設定
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _profileData!['yalker_profile']['name'],
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                '@${_profileData!['yalker_profile']['user_id']}',
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
                      Text(
                        '${_profileData!['yalker_profile']['profile']}',
                        textAlign: TextAlign.start, // 左詰めに設定
                      ),
                      SizedBox(height: 20), // 余白を追加
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _reportListMap['num_report_list']?.length,
                        itemBuilder: (context, index) {
                          final report =
                              _reportListMap['num_report_list']?[index];
                          return MonthlyBarChart(
                            userId: widget.userId,
                            reportTitle: report!.reportName,
                            reportUnit: report.reportUnit,
                          );
                        },
                      )
                    ],
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        )));
  }
}
