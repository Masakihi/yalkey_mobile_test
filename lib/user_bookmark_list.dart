import 'package:flutter/material.dart';
import 'post/post_widget.dart';
import 'post/post_model.dart';
import 'search_user.dart';
import 'search_user_id.dart';

class UserBookmarkListPage extends StatefulWidget {
  const UserBookmarkListPage({Key? key}) : super(key: key);

  @override
  _UserBookmarkListPageState createState() => _UserBookmarkListPageState();
}

class _UserBookmarkListPageState extends State<UserBookmarkListPage> {
  late List<Post> _bookmarkPostList = [];
  late ScrollController _scrollController; // ListView のスクロールを制御するコントローラー
  bool _loading = false; // データをロード中かどうかを示すフラグ
  int _page = 1; // 現在のページ番号

  @override
  void initState() {
    super.initState();
    _clearCache();
    _scrollController = ScrollController()..addListener(_scrollListener);
    //_fetchBookmarkPostList();
  }

  void _scrollListener() {
    // スクロール位置が最下部に達したかどうかをチェック
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // 最下部に達したら新しいデータをロードする
      _loadMorePost();
    }
  }

  Future<void> _fetchBookmarkPostList() async {
    setState(() {
      _loading = true; // データのロード中フラグをtrueに設定
    });
    PostListResponse bookmarkPostListResponse =
        await PostListResponse.fetchPostListResponse(_page);
    if (mounted) {
      setState(() {
        _bookmarkPostList
            .addAll(bookmarkPostListResponse.postList); // 新しいデータをリストに追加
        _loading = false; // データのロード中フラグをfalseに設定
      });
    }
  }

  Future<void> _loadMorePost() async {
    if (!_loading) {
      setState(() {
        _loading = true; // データのロード中フラグをtrueに設定
        _page++; // ページ番号をインクリメントして新しいデータを取得
      });
      await _fetchBookmarkPostList();
    }
  }

  Future<void> _clearCache() async {
    try {
      setState(() {
        _bookmarkPostList.clear();
        _page = 1; // ページ番号をリセット
      });
      print("list refresh");
      await _fetchBookmarkPostList(); // データを再読み込み
    } catch (error) {
      print('Error clearing Bookmark Post cache: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("ブックマーク一覧"),
        ),
        body: RefreshIndicator(
          displacement: 0,
          onRefresh: () async {
            _clearCache();
          },
          child: Column(
            children: <Widget>[
              !_loading
                  ? const SizedBox(height: 20.0)
                  : const SizedBox.shrink(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController, // スクロールコントローラーを設定
                  itemCount:
                      _bookmarkPostList.length + 1, // リストアイテム数 + ローディングインジケーター
                  itemBuilder: (context, index) {
                    if (index == _bookmarkPostList.length) {
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
                    final post = _bookmarkPostList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          PostWidget(post: post),
                          if (index != _bookmarkPostList.length - 1)
                            const Divider(
                                height: 4.0,
                                thickness: 0.3,
                                color:
                                    Color(0xFF929292)), // 最後のポストの後には区切り線を表示しない
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
