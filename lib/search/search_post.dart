import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../profile/yalker_profile_page.dart';
import 'user_model.dart';
import '../post/post_model.dart';
import '../post/post_widget.dart';

class SearchPostListPage extends StatefulWidget {
  // 画面遷移元からのデータを受け取る変数
  final String keyword;
  const SearchPostListPage({Key? key, required this.keyword}) : super(key: key);

  @override
  _SearchPostListPageState createState() => _SearchPostListPageState();
}

class _SearchPostListPageState extends State<SearchPostListPage> {
  late List<User> _userList = []; // user_repost_list を格納するリスト
  late List<User> _userIdList = [];
  late List<Post> _postList = [];
  late ScrollController _scrollUserController; // ListView のスクロールを制御するコントローラー
  late ScrollController _scrollUserIdController;
  late ScrollController _scrollPostController;
  bool _loadingUser = false; // データをロード中かどうかを示すフラグ
  bool _loadingUserId = false;
  bool _loadingPost = false;
  int _pageUser = 1; // 現在のページ番号
  int _pageUserId = 1;
  int _pagePost = 1;
  late String searchKeyword;

  @override
  void initState() {
    super.initState();
    _clearCachePost();
    _scrollUserController = ScrollController()
      ..addListener(_scrollUserListener);
    _scrollUserIdController = ScrollController()
      ..addListener(_scrollUserIdListener);
    _scrollPostController = ScrollController()
      ..addListener(_scrollPostListener);
    searchKeyword = widget.keyword;
    _fetchSearchUserList(); // 最初のデータを読み込む
    _fetchSearchUserIdList();
    _fetchSearchPostList();
  }

  // ListView のスクロールイベントを監視するリスナー
  void _scrollUserListener() {
    // スクロール位置が最下部に達したかどうかをチェック
    if (_scrollUserController.position.pixels ==
        _scrollUserController.position.maxScrollExtent) {
      // 最下部に達したら新しいデータをロードする
      _loadMoreUserData();
    }
  }

  void _scrollUserIdListener() {
    // スクロール位置が最下部に達したかどうかをチェック
    if (_scrollUserIdController.position.pixels ==
        _scrollUserIdController.position.maxScrollExtent) {
      // 最下部に達したら新しいデータをロードする
      _loadMoreUserIdData();
    }
  }

  void _scrollPostListener() {
    // スクロール位置が最下部に達したかどうかをチェック
    if (_scrollPostController.position.pixels ==
        _scrollPostController.position.maxScrollExtent) {
      // 最下部に達したら新しいデータをロードする
      _loadMorePost();
    }
  }

  Future<void> _fetchSearchUserList() async {
    setState(() {
      _loadingUser = true; // データのロード中フラグをtrueに設定
    });

    SearchUserListResponse searchUserListResponse =
        await SearchUserListResponse.fetchSearchUserListResponse(
            _pageUser, searchKeyword);
    if (mounted) {
      setState(() {
        _userList
            .addAll(searchUserListResponse.searchUserList); // 新しいデータをリストに追加
        _loadingUser = false; // データのロード中フラグをfalseに設定
      });
    }
  }

  Future<void> _fetchSearchUserIdList() async {
    setState(() {
      _loadingUserId = true; // データのロード中フラグをtrueに設定
    });

    SearchUserIdListResponse searchUserIdListResponse =
        await SearchUserIdListResponse.fetchSearchUserIdListResponse(
            _pageUserId, searchKeyword);
    if (mounted) {
      setState(() {
        _userIdList
            .addAll(searchUserIdListResponse.searchUserIdList); // 新しいデータをリストに追加
        _loadingUserId = false; // データのロード中フラグをfalseに設定
      });
    }
  }

  Future<void> _fetchSearchPostList() async {
    setState(() {
      _loadingPost = true; // データのロード中フラグをtrueに設定
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cachedSearchPostList = prefs.getStringList('search_post_list');
    if (cachedSearchPostList != null && cachedSearchPostList.isNotEmpty) {
      setState(() {
        _postList = cachedSearchPostList
            .map((jsonString) => Post.fromJson(jsonDecode(jsonString)))
            .toList();
      });
    }
    PostListResponse searchPostListResponse =
        await PostListResponse.fetchSearchPostResponse(
            _pagePost, searchKeyword);
    if (mounted) {
      setState(() {
        _postList.addAll(searchPostListResponse.postList); // 新しいデータをリストに追加
        _loadingPost = false; // データのロード中フラグをfalseに設定
      });
    }
  }

  Future<void> _loadMoreUserData() async {
    if (!_loadingUser) {
      setState(() {
        _loadingUser = true; // データのロード中フラグをtrueに設定
        _pageUser++; // ページ番号をインクリメントして新しいデータを取得
      });
      await _fetchSearchUserList();
    }
  }

  Future<void> _loadMoreUserIdData() async {
    if (!_loadingUserId) {
      setState(() {
        _loadingUserId = true; // データのロード中フラグをtrueに設定
        _pageUserId++; // ページ番号をインクリメントして新しいデータを取得
      });
      await _fetchSearchUserIdList();
    }
  }

  Future<void> _loadMorePost() async {
    if (!_loadingPost) {
      setState(() {
        _loadingPost = true; // データのロード中フラグをtrueに設定
        _pagePost++; // ページ番号をインクリメントして新しいデータを取得
      });
      await _fetchSearchPostList();
    }
  }

  Future<void> _clearCacheUser() async {
    try {
      setState(() {
        _userList.clear();
        _pageUser = 1; // ページ番号をリセット
      });
      print("list refresh");
      await _fetchSearchUserList(); // データを再読み込み
    } catch (error) {
      print('Error clearing User cache: $error');
    }
  }

  Future<void> _clearCacheUserId() async {
    try {
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      //await prefs.remove('user_repost_list');
      setState(() {
        _userIdList.clear();
        _pageUserId = 1; // ページ番号をリセット
      });
      print("list refresh");
      await _fetchSearchUserIdList(); // データを再読み込み
    } catch (error) {
      print('Error clearing UserId cache: $error');
    }
  }

  Future<void> _clearCachePost() async {
    try {
      setState(() {
        _postList.clear();
        _pagePost = 1; // ページ番号をリセット
      });
      print("list refresh");
      await _fetchSearchPostList(); // データを再読み込み
    } catch (error) {
      print('Error clearing Post cache: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget searchTextField() {
      return TextFormField(
        onFieldSubmitted: (String? value) {
          if (value != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchPostListPage(keyword: value),
              ),
            );
          }
        },
        //controller: TextEditingController(text: searchKeyword),
        initialValue: searchKeyword,
        //autofocus: true, //TextFieldが表示されるときにフォーカスする（キーボードを表示する）
        //cursorColor: Colors.white, //カーソルの色
        style: const TextStyle(
          //テキストのスタイル
          //color: Colors.white,
          fontSize: 20,
        ),
        textInputAction: TextInputAction.search, //キーボードのアクションボタンを指定
        decoration: const InputDecoration(
          //TextFiledのスタイル
          enabledBorder: UnderlineInputBorder(
              //デフォルトのTextFieldの枠線
              borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              //TextFieldにフォーカス時の枠線
              borderSide: BorderSide(color: Colors.grey)),
          hintText: 'Search', //何も入力してないときに表示されるテキスト
          hintStyle: TextStyle(
            //hintTextのスタイル
            //color: Colors.grey,
            fontSize: 18,
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: searchTextField(),
          bottom: const TabBar(
            labelColor: Color(0xFFAE0103),
            indicatorColor: Color(0xFFAE0103),
            tabs: <Widget>[
              Tab(text: 'ユーザー'),
              Tab(text: 'ユーザーID'),
              Tab(text: '投稿'),
              //Tab(icon: Icon(Icons.brightness_5_sharp)),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            RefreshIndicator(
              displacement: 0,
              onRefresh: () async {
                _clearCacheUser();
              },
              child: Column(
                children: <Widget>[
                  !_loadingUser
                      ? const SizedBox(height: 20.0)
                      : const SizedBox.shrink(),
                  !_loadingUser
                      ? Container(
                          alignment: Alignment.centerLeft, //任意のプロパティ
                          width: double.infinity,
                          child: const Text(
                            '検索結果',
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 20.0),
                          ))
                      : const SizedBox.shrink(),
                  !_loadingUser
                      ? const SizedBox(height: 10.0)
                      : const SizedBox.shrink(),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollUserController, // スクロールコントローラーを設定
                      itemCount:
                          _userList.length + 1, // リストアイテム数 + ローディングインジケーター
                      itemBuilder: (context, index) {
                        if (index == _userList.length) {
                          return _loadingUser
                              ? Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(16.0),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 3.0,
                                  ),
                                )
                              : SizedBox.shrink(); // ローディングインジケーターを表示
                        }
                        final user = _userList[index];
                        return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => YalkerProfilePage(
                                        userNumber: user.userNumber ?? 1),
                                  ));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {},
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        if (user.iconimage == "")
                                          const CircleAvatar(
                                            backgroundColor: Colors.white,
                                            backgroundImage: NetworkImage(
                                              'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/static/img/user.png',
                                            ),
                                          ),
                                        if (user.iconimage != "")
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/iconimage/${user.iconimage}',
                                            ),
                                          ),
                                        SizedBox(width: 16.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                user.name ?? '???',
                                                style: const TextStyle(
                                                    fontSize: 20.0),
                                              ),
                                              Row(
                                                children: [
                                                  if (user.private ?? false)
                                                    const Icon(
                                                      Icons.lock,
                                                      color: Colors.grey,
                                                      size: 12.0,
                                                    ),
                                                  Text(
                                                    '@${user.userId}',
                                                    style: const TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 4.0),
                                              Row(
                                                children: [
                                                  if (user.superEarlyBird ??
                                                      false)
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 3,
                                                          vertical: 1),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                              0xFFAE0103),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 3,
                                                                  vertical: 1),
                                                          child: Text(
                                                            "超早起き",
                                                            style: TextStyle(
                                                                fontSize: 10.0,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if (user.superEarlyBird ??
                                                      false)
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 3,
                                                          vertical: 1),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                              0xFFAE0103),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 3,
                                                                  vertical: 1),
                                                          child: Text(
                                                            "早起き",
                                                            style: TextStyle(
                                                                fontSize: 10.0,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if (user.superHardWorker ??
                                                      false)
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 3,
                                                          vertical: 1),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                              0xFFAE0103),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 3,
                                                                  vertical: 1),
                                                          child: Text(
                                                            "超努力家",
                                                            style: TextStyle(
                                                                fontSize: 10.0,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if (user.hardWorker ?? false)
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 3,
                                                          vertical: 1),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                              0xFFAE0103),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 3,
                                                                  vertical: 1),
                                                          child: Text(
                                                            "努力家",
                                                            style: TextStyle(
                                                                fontSize: 10.0,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if (user.regularCustomer ??
                                                      false)
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 3,
                                                          vertical: 1),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                              0xFFAE0103),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 3,
                                                                  vertical: 1),
                                                          child: Text(
                                                            "常連",
                                                            style: TextStyle(
                                                                fontSize: 10.0,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              user.profile != ''
                                                  ? Text(
                                                      user.profile ?? '',
                                                      style: TextStyle(
                                                          fontSize: 14.0),
                                                    )
                                                  : SizedBox.shrink(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ));
                      },
                    ),
                  ),
                ],
              ),
            ),
            RefreshIndicator(
              displacement: 0,
              onRefresh: () async {
                _clearCacheUserId();
              },
              child: Column(
                children: <Widget>[
                  !_loadingUserId
                      ? const SizedBox(height: 20.0)
                      : const SizedBox.shrink(),
                  !_loadingUserId
                      ? Container(
                          alignment: Alignment.centerLeft, //任意のプロパティ
                          width: double.infinity,
                          child: const Text(
                            '検索結果',
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 20.0),
                          ))
                      : const SizedBox.shrink(),
                  !_loadingUserId
                      ? const SizedBox(height: 10.0)
                      : const SizedBox.shrink(),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollUserIdController, // スクロールコントローラーを設定
                      itemCount:
                          _userIdList.length + 1, // リストアイテム数 + ローディングインジケーター
                      itemBuilder: (context, index) {
                        if (index == _userIdList.length) {
                          return _loadingUserId
                              ? Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3.0,
                                  ),
                                )
                              : SizedBox.shrink(); // ローディングインジケーターを表示
                        }
                        final userId = _userIdList[index];
                        return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => YalkerProfilePage(
                                        userNumber: userId.userNumber ?? 1),
                                  ));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      print("tap");
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        if (userId.iconimage == "")
                                          const CircleAvatar(
                                            backgroundColor: Colors.white,
                                            backgroundImage: NetworkImage(
                                              'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/static/img/user.png',
                                            ),
                                          ),
                                        if (userId.iconimage != "")
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/iconimage/${userId.iconimage}',
                                            ),
                                          ),
                                        SizedBox(width: 16.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                userId.name ?? '???',
                                                style: const TextStyle(
                                                    fontSize: 20.0),
                                              ),
                                              Row(
                                                children: [
                                                  if (userId.private ?? false)
                                                    const Icon(
                                                      Icons.lock,
                                                      color: Colors.grey,
                                                      size: 12.0,
                                                    ),
                                                  Text(
                                                    '@${userId.userId}',
                                                    style: const TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 4.0),
                                              Row(
                                                children: [
                                                  if (userId.superEarlyBird ??
                                                      false)
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 3,
                                                          vertical: 1),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                              0xFFAE0103),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 3,
                                                                  vertical: 1),
                                                          child: Text(
                                                            "超早起き",
                                                            style: TextStyle(
                                                                fontSize: 10.0,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if (userId.superEarlyBird ??
                                                      false)
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 3,
                                                          vertical: 1),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                              0xFFAE0103),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 3,
                                                                  vertical: 1),
                                                          child: Text(
                                                            "早起き",
                                                            style: TextStyle(
                                                                fontSize: 10.0,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if (userId.superHardWorker ??
                                                      false)
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 3,
                                                          vertical: 1),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                              0xFFAE0103),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 3,
                                                                  vertical: 1),
                                                          child: Text(
                                                            "超努力家",
                                                            style: TextStyle(
                                                                fontSize: 10.0,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if (userId.hardWorker ??
                                                      false)
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 3,
                                                          vertical: 1),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                              0xFFAE0103),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 3,
                                                                  vertical: 1),
                                                          child: Text(
                                                            "努力家",
                                                            style: TextStyle(
                                                                fontSize: 10.0,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if (userId.regularCustomer ??
                                                      false)
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 3,
                                                          vertical: 1),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                              0xFFAE0103),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 3,
                                                                  vertical: 1),
                                                          child: Text(
                                                            "常連",
                                                            style: TextStyle(
                                                                fontSize: 10.0,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              userId.profile != ''
                                                  ? Text(
                                                      userId.profile ?? '',
                                                      style: TextStyle(
                                                          fontSize: 14.0),
                                                    )
                                                  : SizedBox.shrink(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ));
                      },
                    ),
                  ),
                ],
              ),
            ),
            RefreshIndicator(
              displacement: 0,
              onRefresh: () async {
                _clearCachePost();
              },
              child: Column(
                children: <Widget>[
                  !_loadingPost
                      ? const SizedBox(height: 20.0)
                      : const SizedBox.shrink(),
                  !_loadingPost
                      ? Container(
                          alignment: Alignment.centerLeft, //任意のプロパティ
                          width: double.infinity,
                          child: const Text(
                            '検索結果',
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 20.0),
                          ))
                      : const SizedBox.shrink(),
                  !_loadingPost
                      ? const SizedBox(height: 10.0)
                      : const SizedBox.shrink(),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollPostController, // スクロールコントローラーを設定
                      itemCount:
                          _postList.length + 1, // リストアイテム数 + ローディングインジケーター
                      itemBuilder: (context, index) {
                        if (index == _postList.length) {
                          return _loadingPost
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
                                    color: Color(
                                        0xFF929292)), // 最後のポストの後には区切り線を表示しない
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
