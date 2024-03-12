import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api.dart';
import 'mission_model.dart';
import 'mission_detail.dart';
import 'mission_create.dart';
import 'package:yalkey_0206_test/post_page.dart';

class MissionListPage extends StatefulWidget {
  const MissionListPage({Key? key}) : super(key: key);

  @override
  _MissionListPageState createState() => _MissionListPageState();
}

class _MissionListPageState extends State<MissionListPage> {
  late final List<Mission> _missionList = []; // user_repost_list を格納するリスト
  late ScrollController _scrollController; // ListView のスクロールを制御するコントローラー
  bool _loading = false; // データをロード中かどうかを示すフラグ
  int _page = 1; // 現在のページ番号

  late final List<Mission> _missionTodayList =
      []; // user_repost_list を格納するリスト
  late ScrollController
      _scrollMissionTodayController; // ListView のスクロールを制御するコントローラー
  bool _loadingMissionToday = false; // データをロード中かどうかを示すフラグ
  int _pageMissionToday = 1;

  Map<int, bool> checkboxToday = {
    //'Option 1': false,
    // 1 : false,
    // Add more options if needed
  };



  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _fetchMissionList(); // 最初のデータを読み込む
    _scrollMissionTodayController = ScrollController()
      ..addListener(_scrollMissionTodayListener);
    _fetchMissionTodayList();
  }

  // ListView のスクロールイベントを監視するリスナー
  void _scrollListener() {
    // スクロール位置が最下部に達したかどうかをチェック
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // 最下部に達したら新しいデータをロードする
      _loadMoreData();
    }
  }

  void _scrollMissionTodayListener() {
    // スクロール位置が最下部に達したかどうかをチェック
    if (_scrollMissionTodayController.position.pixels ==
        _scrollMissionTodayController.position.maxScrollExtent) {
      // 最下部に達したら新しいデータをロードする
      _loadMoreMissionTodayData();
    }
  }

  Future<void> _fetchMissionList() async {
    setState(() {
      _loading = true; // データのロード中フラグをtrueに設定
    });

    try {
      MissionListResponse missionListResponse =
          await MissionListResponse.fetchMissionListResponse(_page);
      // print(missionListResponse.newMissionList.length);
      if (mounted) {
        setState(() {
          _missionList
              .addAll(missionListResponse.missionList); // 新しいデータをリストに追加
          _loading = false; // データのロード中フラグをfalseに設定
        });
      }
    } catch (error) {
      print('error: $error');
    }
    /*prefs.setStringList('user_repost_list',
        _userRepostList.map((repost) => jsonEncode(repost.toJson())).toList());

     */
  }

  Future<void> _fetchMissionTodayList() async {
    setState(() {
      _loadingMissionToday = true; // データのロード中フラグをtrueに設定
    });

    DateTime now = DateTime.now();

    try {
      MissionListResponse missionTodayListResponse =
          await MissionListResponse.fetchMissionDailyListResponse(now.year, now.month, now.day, _pageMissionToday);
      if (mounted) {
        setState(() {
          _missionTodayList
              .addAll(missionTodayListResponse.missionList); // 新しいデータをリストに追加

          for(Mission mission in _missionTodayList){
            checkboxToday[mission.missionNumber] = mission.achieved!;
          }


          _loadingMissionToday = false; // データのロード中フラグをfalseに設定
        });
      }
    } catch (error) {
      print('error: $error');
    }
    /*prefs.setStringList('user_repost_list',
        _userRepostList.map((repost) => jsonEncode(repost.toJson())).toList());

     */
  }

  Future<void> _loadMoreData() async {
    if (!_loading) {
      setState(() {
        _loading = true; // データのロード中フラグをtrueに設定
        _page++; // ページ番号をインクリメントして新しいデータを取得
      });
      await _fetchMissionList();
    }
  }

  Future<void> _loadMoreMissionTodayData() async {
    if (!_loadingMissionToday) {
      setState(() {
        _loadingMissionToday = true; // データのロード中フラグをtrueに設定
        _pageMissionToday++; // ページ番号をインクリメントして新しいデータを取得
      });
      await _fetchMissionTodayList();
    }
  }

  Future<void> _clearCache() async {
    try {
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      //await prefs.remove('user_repost_list');
      setState(() {
        _missionList.clear();
        _page = 1; // ページ番号をリセット
      });
      print("list refresh");
      await _fetchMissionList(); // データを再読み込み
    } catch (error) {
      // print('Error clearing cache: $error');
    }
  }

  Future<void> _clearMissionTodayCache() async {
    try {
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      //await prefs.remove('user_repost_list');
      setState(() {
        _missionTodayList.clear();
        _pageMissionToday = 1; // ページ番号をリセット
      });
      print("list refresh");
      await _fetchMissionTodayList(); // データを再読み込み
    } catch (error) {
      // print('Error clearing cache: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ミッション'),
          bottom: const TabBar(
            labelColor: Color(0xFFAE0103),
            indicatorColor: Color(0xFFAE0103),
            tabs: <Widget>[
              Tab(text: '一覧'),
              Tab(text: '今日'),
              //Tab(icon: Icon(Icons.brightness_5_sharp)),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            RefreshIndicator(
              displacement: 0,
              onRefresh: () async {
                _clearCache();
              },
              child: Column(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MissionCreatePage(),
                            //builder: (context) => TaskDeletePage(value: int.parse('352'))
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAE0103),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'ミッションを追加',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController, // スクロールコントローラーを設定
                      itemCount:
                          _missionList.length + 1, // リストアイテム数 + ローディングインジケーター
                      itemBuilder: (context, index) {
                        if (index == _missionList.length) {
                          return _loading
                              ? Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(16.0),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 3.0,
                                  ),
                                )
                              : const SizedBox.shrink(); // ローディングインジケーターを表示
                        }
                        final mission = _missionList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        GestureDetector(
                                          //InkWellでも同じ
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MissionDetailPage(
                                                        value: int.parse(
                                                            '${mission.missionNumber}')),
                                                //builder: (context) => TaskDetailPage(value: int.parse('352')),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            mission.missionText,
                                            style:
                                                const TextStyle(fontSize: 18.0),
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          '${mission.endTime.toString().substring(0, 10)} ${mission.endTime.toString().substring(11, 16)}まで',
                                          style: const TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),



            RefreshIndicator(
              displacement: 0,
              onRefresh: () async {
                _clearMissionTodayCache();
              },
              child: Column(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MissionCreatePage(),
                            //builder: (context) => TaskDeletePage(value: int.parse('352'))
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAE0103),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'ミッションを追加',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller:
                          _scrollMissionTodayController, // スクロールコントローラーを設定
                      itemCount: _missionTodayList.length +
                          1, // リストアイテム数 + ローディングインジケーター
                      itemBuilder: (context, index) {
                        if (index == _missionTodayList.length) {
                          return _loadingMissionToday
                              ? Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(16.0),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 3.0,
                                  ),
                                )
                              : const SizedBox.shrink(); // ローディングインジケーターを表示
                        }
                        final missionToday = _missionTodayList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Row(
                            children: <Widget>[
                              Checkbox(
                                activeColor: const Color(0xFFAE0103),
                                value: checkboxToday[missionToday.missionNumber], //missionToday.achieved,
                                onChanged:
                                    (bool? checkedValue) async {
                                  // print("checked");
                                  // await missionToday.handleAchieved();
                                      if (checkboxToday[missionToday.missionNumber] == true){
                                        print("mission-done-remove");
                                        await httpPost('mission-done-remove/${missionToday.missionNumber}/', null, jwt:true);

                                      }else{
                                        print("mission-done");
                                        await httpPost('mission-done/${missionToday.missionNumber}/', null, jwt:true);

                                      }
                                  setState(() {
                                    checkboxToday[missionToday.missionNumber] = checkedValue!;
                                  });
                                  if (checkboxToday[missionToday.missionNumber]==true){
                                    _showAlertDialog(context);
                                  }
                                },
                              ),
                              GestureDetector(
                                onTap: () {
                                  // テキストをタップしたときの処理
                                  // // print('Text at index $index tapped');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MissionDetailPage(
                                              value: int.parse(
                                                  '${missionToday.missionNumber}')),
                                      //builder: (context) => TaskDetailPage(value: int.parse('352')),
                                    ),
                                  );
                                },
                                child: Text(
                                  '${missionToday.missionText}',  //missionToday.title,
                                  style:
                                  const TextStyle(fontSize: 16.0),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


void _showAlertDialog(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hideCheckbox = prefs.getBool('hideMissionToReport') ?? false;

  if (!hideCheckbox) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('おめでとうございます！'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ミッションの達成おめでとうございます！フォロワーに達成報告しますか？',
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Report to followers
                          Navigator.of(context).pop(); // Close the alert dialog
                          // Write your code to report to followers here
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostPage(),
                                //builder: (context) => TaskDeletePage(value: int.parse('352'))
                              ));
                        },
                        child: Text(
                            'レポート投稿',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFAE0103),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the alert dialog
                        },
                        child: Text('やめておく'),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Checkbox(
                        value: hideCheckbox,
                        onChanged: (bool? value) async {
                          setState(() {
                            hideCheckbox = value!;
                          });
                          prefs.setBool('hideMissionToReport', hideCheckbox);
                        },
                      ),
                      Flexible(
                        child: Text(
                          '次回以降このメッセージを表示しない',
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
