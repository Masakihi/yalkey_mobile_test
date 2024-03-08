import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'post/post.dart';
import 'post/post_model.dart';

const Map<String, String> badge2Explanation = {
  "超早起き": "過去1週間のうち7日間早起きしたヤルカー",
  "早起き": "過去1週間のうち3日間早起きしたヤルカー",
  "超努力家": "なんかめちゃくちゃ頑張ってるヤルカー",
  "努力家": "まあまあ頑張ってるヤルカー",
  "常連": "よく投稿する人",
};

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<UserRepost> _userRepostList = []; // user_repost_list を格納するリスト
  late ScrollController _scrollController; // ListView のスクロールを制御するコントローラー
  bool _loading = false; // データをロード中かどうかを示すフラグ
  int _page = 1; // 現在のページ番号

  @override
  void initState() {
    super.initState();
    _clearCache();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _fetchUserRepostList(); // 最初のデータを読み込む
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

  Future<void> _fetchUserRepostList() async {
    setState(() {
      _loading = true; // データのロード中フラグをtrueに設定
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cachedRepostList = prefs.getStringList('user_repost_list');
    if (cachedRepostList != null && cachedRepostList.isNotEmpty) {
      setState(() {
        _userRepostList = cachedRepostList
            .map((jsonString) => UserRepost.fromJson(jsonDecode(jsonString)))
            .toList();
      });
    }
    UserRepostListResponse userRepostListResponse =
        await UserRepostListResponse.fetchUserRepostListResponse(_page);
    if (mounted) {
      setState(() {
        _userRepostList
            .addAll(userRepostListResponse.userRepostList); // 新しいデータをリストに追加
        _loading = false; // データのロード中フラグをfalseに設定
      });
    }
    prefs.setStringList('user_repost_list',
        _userRepostList.map((repost) => jsonEncode(repost.toJson())).toList());
  }

  Future<void> _loadMoreData() async {
    if (!_loading) {
      setState(() {
        _loading = true; // データのロード中フラグをtrueに設定
        _page++; // ページ番号をインクリメントして新しいデータを取得
      });
      await _fetchUserRepostList();
    }
  }

  Future<void> _clearCache() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_repost_list');
      setState(() {
        _userRepostList.clear();
        _page = 1; // ページ番号をリセット
      });
      //print("list refresh");
      await _fetchUserRepostList(); // データを再読み込み
    } catch (error) {
      //print('Error clearing cache: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: _clearCache,
            icon: Icon(Icons.refresh),
            tooltip: 'Clear Cache',
          ),
        ],
      ),
       */
      body: RefreshIndicator(
        displacement: 0,
        onRefresh: () async {
          _clearCache();
        },
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scrollController, // スクロールコントローラーを設定
                itemCount:
                    _userRepostList.length + 1, // リストアイテム数 + ローディングインジケーター
                itemBuilder: (context, index) {
                  if (index == _userRepostList.length) {
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
                  final repost = _userRepostList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        PostWidget(userRepost: repost),
                        if (index != _userRepostList.length - 1)
                          const Divider(
                              height: 4.0,
                              thickness: 0.3,
                              color: Color(0xFF929292)), // 最後のポストの後には区切り線を表示しない
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
