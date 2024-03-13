import 'package:flutter/material.dart';
import 'package:yalkey_0206_test/post_page.dart';
import 'post/post_widget.dart';
import 'post/post_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Post> _postList = []; // user_repost_list を格納するリスト
  late ScrollController _scrollController; // ListView のスクロールを制御するコントローラー
  bool _loading = false; // データをロード中かどうかを示すフラグ
  int _page = 1; // 現在のページ番号

  late List<Post> _postAllList = []; // user_repost_list を格納するリスト
  late ScrollController _scrollAllController; // ListView のスクロールを制御するコントローラー
  bool _loadingAll = false; // データをロード中かどうかを示すフラグ
  int _pageAll = 1; // 現在のページ番号

  @override
  void initState() {
    super.initState();
    _clearCache();
    _clearAllPostCache();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _scrollAllController = ScrollController()..addListener(_scrollAllListener);
    _fetchPostList(); // 最初のデータを読み込む
    _fetchAllPostList();
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

  void _scrollAllListener() {
    // スクロール位置が最下部に達したかどうかをチェック
    if (_scrollAllController.position.pixels ==
        _scrollAllController.position.maxScrollExtent) {
      // 最下部に達したら新しいデータをロードする
      _loadMorePostAllData();
    }
  }

  Future<void> _fetchPostList() async {
    setState(() {
      _loading = true; // データのロード中フラグをtrueに設定
    });
    PostListResponse postListResponse =
        await PostListResponse.fetchPostListResponse(_page);
    if (mounted) {
      setState(() {
        _postList.addAll(postListResponse.postList); // 新しいデータをリストに追加
        _loading = false; // データのロード中フラグをfalseに設定
      });
    }
  }

  Future<void> _fetchAllPostList() async {
    setState(() {
      _loadingAll = true; // データのロード中フラグをtrueに設定
    });
    PostListResponse postAllListResponse =
    await PostListResponse.fetchAllPostResponse(_pageAll);
    if (mounted) {
      setState(() {
        _postAllList.addAll(postAllListResponse.postList); // 新しいデータをリストに追加
        _loadingAll = false; // データのロード中フラグをfalseに設定
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (!_loading) {
      setState(() {
        _loading = true; // データのロード中フラグをtrueに設定
        _page++; // ページ番号をインクリメントして新しいデータを取得
      });
      await _fetchPostList();
    }
  }

  Future<void> _loadMorePostAllData() async {
    if (!_loadingAll) {
      setState(() {
        _loadingAll = true; // データのロード中フラグをtrueに設定
        _pageAll++; // ページ番号をインクリメントして新しいデータを取得
      });
      await _fetchAllPostList();
    }
  }

  Future<void> _clearCache() async {
    try {
      setState(() {
        _postList.clear();
        _page = 1; // ページ番号をリセット
      });
      //print("list refresh");
      await _fetchPostList(); // データを再読み込み
    } catch (error) {
      //print('Error clearing cache: $error');
    }
  }

  Future<void> _clearAllPostCache() async {
    try {
      setState(() {
        _postAllList.clear();
        _pageAll = 1; // ページ番号をリセット
      });
      //print("list refresh");
      await _fetchAllPostList(); // データを再読み込み
    } catch (error) {
      //print('Error clearing cache: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
          child:  Scaffold(
              appBar: AppBar(
                flexibleSpace: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TabBar(
                        labelColor: Color(0xFFAE0103),
                        indicatorColor: Color(0xFFAE0103),
                        tabs: <Widget>[
                        Tab(text: 'フォロー中'),
                        Tab(text: '全体'),
                        ],
                      ),
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
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController, // スクロールコントローラーを設定
                    itemCount: _postList.length + 1, // リストアイテム数 + ローディングインジケーター
                    itemBuilder: (context, index) {
                      if (index == _postList.length) {
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
                      final post = _postList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            PostWidget(post: post),
                            if (index != _postList.length - 1)
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



          RefreshIndicator(
            displacement: 0,
            onRefresh: () async {
              _clearAllPostCache();
            },
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    controller: _scrollAllController, // スクロールコントローラーを設定
                    itemCount: _postAllList.length + 1, // リストアイテム数 + ローディングインジケーター
                    itemBuilder: (context, index) {
                      if (index == _postAllList.length) {
                        return _loadingAll
                            ? Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16.0),
                          child: const CircularProgressIndicator(
                            strokeWidth: 3.0,
                          ),
                        )
                            : const SizedBox.shrink(); // ローディングインジケーターを表示
                      }
                      final post = _postAllList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            PostWidget(post: post),
                            if (index != _postAllList.length - 1)
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
        ]
        ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: ()  {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PostPage(),
                  ),
                );
              },
              icon: new Icon(Icons.add),
              label: Text("投稿"),
            ),
          )
    );
  }
}
