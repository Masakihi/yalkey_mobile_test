import 'package:flutter/material.dart';
import 'constant.dart';
import 'mission_detail.dart';
import 'mission_create.dart';

class MissionListPage extends StatefulWidget {
  const MissionListPage({Key? key}) : super(key: key);

  @override
  _MissionListPageState createState() => _MissionListPageState();
}

class _MissionListPageState extends State<MissionListPage> {
  late final List<NewMission> _missionList = []; // user_repost_list を格納するリスト
  late ScrollController _scrollController; // ListView のスクロールを制御するコントローラー
  bool _loading = false; // データをロード中かどうかを示すフラグ
  int _page = 1; // 現在のページ番号

  late final List<NewMission> _missionTodayList =
      []; // user_repost_list を格納するリスト
  late ScrollController
      _scrollMissionTodayController; // ListView のスクロールを制御するコントローラー
  bool _loadingMissionToday = false; // データをロード中かどうかを示すフラグ
  int _pageMissionToday = 1;

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
      NewMissionListResponse missionListResponse =
          await NewMissionListResponse.fetchNewMissionListResponse(_page);
      print(missionListResponse.newMissionList.length);
      if (mounted) {
        setState(() {
          _missionList
              .addAll(missionListResponse.newMissionList); // 新しいデータをリストに追加
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

    try {
      NewMissionListResponse missionTodayListResponse =
          await NewMissionListResponse.fetchNewMissionTodayListResponse(_page);
      if (mounted) {
        setState(() {
          _missionTodayList
              .addAll(missionTodayListResponse.newMissionList); // 新しいデータをリストに追加
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
          // title: const Text('ミッション一覧'),
          bottom: const TabBar(
            labelColor: Color(0xFFAE0103),
            indicatorColor: Color(0xFFAE0103),
            tabs: <Widget>[
              Tab(text: 'ミッション一覧'),
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
                                            mission.title,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Checkbox(
                                          activeColor: const Color(0xFFAE0103),
                                          value: missionToday.achieved,
                                          onChanged:
                                              (bool? checkedValue) async {
                                            print("checked");
                                            await missionToday.handleAchieved();
                                            setState(() {});
                                          },
                                        ),
                                        GestureDetector(
                                          //InkWellでも同じ
                                          onTap: () {
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
                                            missionToday.title,
                                            style:
                                                const TextStyle(fontSize: 16.0),
                                          ),
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
          ],
        ),
      ),
    );
  }
}
