import 'package:flutter/material.dart';
import 'constant.dart';
import 'mission_detail.dart';


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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _fetchMissionList(); // 最初のデータを読み込む
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

  Future<void> _fetchMissionList() async {
    setState(() {
      _loading = true; // データのロード中フラグをtrueに設定
    });

    MissionListResponse  missionListResponse =
    await MissionListResponse.fetchMissionListResponse(_page);
    if (mounted) {
      setState(() {
        _missionList
            .addAll(missionListResponse.missionList); // 新しいデータをリストに追加
        _loading = false; // データのロード中フラグをfalseに設定
      });
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ミッション一覧'),
      ),
      body: RefreshIndicator(
        displacement: 0,
        onRefresh: () async {
          _clearCache();
        },
        child:Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: () {

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
                itemCount: _missionList.length + 1, // リストアイテム数 + ローディングインジケーター
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  GestureDetector( //InkWellでも同じ
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MissionDetailPage(value: int.parse('${mission.missionNumber}')),
                                          //builder: (context) => TaskDetailPage(value: int.parse('352')),
                                        ),
                                      );
                                    },
                                    child: Text(
                                        mission.missionText,
                                        style: const TextStyle(fontSize: 18.0),
                                      ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    '${mission.endTime.toString().substring(0, 10)} ${mission.endTime.toString().substring(11, 16)}まで',
                                    style: const TextStyle(
                                        fontSize: 12.0, color: Colors.grey),
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
    );
  }
}
