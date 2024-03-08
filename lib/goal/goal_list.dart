import 'package:flutter/material.dart';
import '../constant.dart';
import 'goal_detail.dart';
import 'goal_create.dart';

class GoalListPage extends StatefulWidget {
  const GoalListPage({Key? key}) : super(key: key);

  @override
  _GoalListPageState createState() => _GoalListPageState();
}

class _GoalListPageState extends State<GoalListPage> {
  late List<Goal> _goalList = []; // user_repost_list を格納するリスト
  late ScrollController _scrollController; // ListView のスクロールを制御するコントローラー
  bool _loading = false; // データをロード中かどうかを示すフラグ
  int _page = 1; // 現在のページ番号

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _fetchGoalList(); // 最初のデータを読み込む
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

  Future<void> _fetchGoalList() async {
    setState(() {
      _loading = true; // データのロード中フラグをtrueに設定
    });

    GoalListResponse goalListResponse =
        await GoalListResponse.fetchGoalListResponse(_page);
    if (mounted) {
      setState(() {
        _goalList.addAll(goalListResponse.goalList); // 新しいデータをリストに追加
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
      await _fetchGoalList();
    }
  }

  Future<void> _clearCache() async {
    try {
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      //await prefs.remove('user_repost_list');
      setState(() {
        _goalList.clear();
        _page = 1; // ページ番号をリセット
      });
      print("list refresh");
      await _fetchGoalList(); // データを再読み込み
    } catch (error) {
      print('Error clearing cache: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('目標一覧'),
      ),
      body: RefreshIndicator(
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
                      builder: (context) => GoalCreatePage(),
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
                '目標を追加',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController, // スクロールコントローラーを設定
                itemCount: _goalList.length + 1, // リストアイテム数 + ローディングインジケーター
                itemBuilder: (context, index) {
                  if (index == _goalList.length) {
                    return _loading
                        ? Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 3.0,
                            ),
                          )
                        : SizedBox.shrink(); // ローディングインジケーターを表示
                  }
                  final goal = _goalList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            GestureDetector(
                              //InkWellでも同じ
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GoalDetailPage(
                                        value: int.parse('${goal.goalNumber}')),
                                    //builder: (context) => TaskDetailPage(value: int.parse('352')),
                                  ),
                                );
                              },

                              child: Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      goal.goalText,
                                      style: const TextStyle(fontSize: 18.0),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      '期限：${goal.deadline.toString().substring(0, 10)} ${goal.deadline.toString().substring(11, 16)}',
                                      style: TextStyle(
                                          fontSize: 12.0, color: Colors.grey),
                                    ),
                                  ],
                                ),
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
