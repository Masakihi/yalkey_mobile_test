import 'dart:convert';
import 'package:flutter/material.dart';
import 'api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'followed_list_page.dart';
import 'following_list_page.dart';
import 'profile_edit_page.dart';
import 'bar_graph.dart';
import 'constant.dart';
import 'achievement_calendar.dart';

const Map<String, String> badge2Explanation = {
  "超早起き": "過去1週間のうち7日間早起きしたヤルカー",
  "早起き": "過去1週間のうち3日間早起きしたヤルカー",
  "超努力家": "なんかめちゃくちゃ頑張ってるヤルカー",
  "努力家": "まあまあ頑張ってるヤルカー",
  "常連": "よく投稿する人",
};

class YalkerProfilePage extends StatefulWidget {
  final int userNumber;
  YalkerProfilePage({Key? key, required this.userNumber}) : super(key: key);

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
  int relationType = 1;


  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _fetchReportList();
    if (_profileData != null){
      if(_profileData!['yalker_profile']['relation_type']!=null){
        relationType = _profileData!['yalker_profile']['relation_type'];
      }
    }else{
      relationType = 1;
    }
  }


  Future<void> _fetchProfileData() async {
    try {
      final Map<String, dynamic> response =
          await httpGet('yalker-profile/${widget.userNumber}');
      setState(() {
        // print(response);
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
        await ReportListResponse.fetchReportListResponse(widget.userNumber);
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

  void _onPressedButton(){
    setState((){

      switch (relationType) {
        case 1:
          relationType++;
          break;
        case 2:
          relationType--;
          break;
        case 3:
          relationType++;
          break;
        case 4:
          relationType--;
          break;
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('yalkerプロフィール'),
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
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _profileData!['yalker_profile']['iconimage'] == ""
                            ? const CircleAvatar(
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(
                                'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/static/img/user.png',
                              ),
                              radius: 25,
                            )
                                : CircleAvatar(
                              backgroundImage: NetworkImage(
                                '${_profileData!['yalker_profile']['iconimage']}',
                              ),
                              radius: 25,
                            ),
                          SizedBox(width: 10), // アイコンと名前の間隔を設定
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _profileData!['yalker_profile']['name'],
                                style: TextStyle(fontSize: 19),
                              ),
                              Row(
                                children: [
                                  if (_profileData!['yalker_profile']['lock'] ?? false)
                                    const Icon(
                                      Icons.lock,
                                      color: Colors.grey,
                                      size: 16.0,
                                    ),
                                  Text(
                                    '@${_profileData!['yalker_profile']['user_id']}',
                                    style: const TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4.0),
                              Row(
                                children: [
                                  if (_profileData!['yalker_profile']['super_early_bird'] ??
                                      false)
                                    GestureDetector(
                                      behavior:
                                      HitTestBehavior.translucent,
                                      onTap: () {
                                        _showExplanation(context,
                                            badge2Explanation['超早起き']!);
                                      },
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 3,
                                            vertical: 1),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                            const Color(0xFFAE0103),
                                            borderRadius:
                                            BorderRadius.circular(
                                                8),
                                          ),
                                          child: const Padding(
                                            padding:
                                            EdgeInsets.symmetric(
                                                horizontal: 3,
                                                vertical: 1),
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
                                  if (_profileData!['yalker_profile']['lock'] ??
                                      false)
                                    GestureDetector(
                                      behavior:
                                      HitTestBehavior.translucent,
                                      onTap: () {
                                        _showExplanation(context,
                                            badge2Explanation['early_bird']!);
                                      },
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 3,
                                            vertical: 1),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                            const Color(0xFFAE0103),
                                            borderRadius:
                                            BorderRadius.circular(
                                                8),
                                          ),
                                          child: const Padding(
                                            padding:
                                            EdgeInsets.symmetric(
                                                horizontal: 3,
                                                vertical: 1),
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
                                  if (_profileData!['yalker_profile']['super_hard_worker'] ??
                                      false)
                                    GestureDetector(
                                      behavior:
                                      HitTestBehavior.translucent,
                                      onTap: () {
                                        _showExplanation(context,
                                            badge2Explanation['超努力家']!);
                                      },
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 3,
                                            vertical: 1),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                            const Color(0xFFAE0103),
                                            borderRadius:
                                            BorderRadius.circular(
                                                8),
                                          ),
                                          child: const Padding(
                                            padding:
                                            EdgeInsets.symmetric(
                                                horizontal: 3,
                                                vertical: 1),
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
                                  if (_profileData!['yalker_profile']['hard_worker'] ??
                                      false)
                                    GestureDetector(
                                      behavior:
                                      HitTestBehavior.translucent,
                                      onTap: () {
                                        _showExplanation(context,
                                            badge2Explanation['努力家']!);
                                      },
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 3,
                                            vertical: 1),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                            const Color(0xFFAE0103),
                                            borderRadius:
                                            BorderRadius.circular(
                                                8),
                                          ),
                                          child: const Padding(
                                            padding:
                                            EdgeInsets.symmetric(
                                                horizontal: 3,
                                                vertical: 1),
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
                                  if (_profileData!['yalker_profile']['regular_customer'] ??
                                      false)
                                    GestureDetector(
                                      behavior:
                                      HitTestBehavior.translucent,
                                      onTap: () {
                                        _showExplanation(context,
                                            badge2Explanation['常連']!);
                                      },
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 3,
                                            vertical: 1),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                            const Color(0xFFAE0103),
                                            borderRadius:
                                            BorderRadius.circular(
                                                8),
                                          ),
                                          child: const Padding(
                                            padding:
                                            EdgeInsets.symmetric(
                                                horizontal: 3,
                                                vertical: 1),
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
                          // Spacer(), // 編集ボタンを右端に配置するためのスペーサー
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                          children: [
                            GestureDetector( //InkWellでも同じ
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FollowingListPage(userNumber: _profileData!['yalker_profile']['user_number']),
                                  ),
                                );
                              },
                              child: Text(
                                'フォロー ',
                                textAlign: TextAlign.start, // 左詰めに設定
                              ),
                            ),
                            SizedBox(width: 20),
                            GestureDetector( //InkWellでも同じ
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FollowedListPage(userNumber: _profileData!['yalker_profile']['user_number']),
                                  ),
                                );
                              },
                              child: Text(
                                'フォロワー ',
                                textAlign: TextAlign.start, // 左詰めに設定
                              ),
                            ),
                          ]
                      ),
                      SizedBox(height: 20), // 余白を追加
                      Text(
                        '${_profileData!['yalker_profile']['profile']}',
                        textAlign: TextAlign.start, // 左詰めに設定
                      ),
                      SizedBox(height: 10),
                      if (relationType==0)
                        ElevatedButton(
                          onPressed: _editProfile, // 編集ボタンが押された時の処理
                          child: Text('編集'),
                        ),
                      if (relationType==1)
                        ElevatedButton(
                          onPressed: (){
                            try {
                              httpPost('follow/${_profileData!['yalker_profile']['user_number']}', {"email":"email"},jwt: true);
                              _onPressedButton();
                              print(relationType);
                            } catch (error) {
                              print('Error follow: $error');
                            }
                          },
                          child: Text('フォローする'),
                        ),
                      if (relationType==2)
                        ElevatedButton(
                          onPressed: (){
                            try {
                              httpPost('unfollow/${_profileData!['yalker_profile']['user_number']}', {"email":"email"},jwt: true);
                              _onPressedButton();
                            } catch (error) {
                              print('Error unfollow: $error');
                            }
                          },
                          child: Text('フォロー解除'),
                        ),
                      if (relationType==3)
                        ElevatedButton(
                          onPressed: (){
                            try {
                              httpPost('followrequest/${_profileData!['yalker_profile']['user_number']}', {"email":"email"},jwt: true);
                              _onPressedButton();
                            } catch (error) {
                              print('Error follow request: $error');
                            }
                          },
                          child: Text('リクエスト'),
                        ),
                      if (relationType==4)
                        ElevatedButton(
                          onPressed: (){
                            try {
                              httpPost('unfollowrequest/${_profileData!['yalker_profile']['user_number']}', {"email":"email"},jwt: true);
                              _onPressedButton();
                            } catch (error) {
                              print('Error unfollow request: $error');
                            }
                          },
                          child: Text('リクエスト解除'),
                        ),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _reportListMap['num_report_list']?.length,
                        itemBuilder: (context, index) {
                          final report =
                              _reportListMap['num_report_list']?[index];
                          return MonthlyBarChart(
                            userId: widget.userNumber,
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
