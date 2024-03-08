import 'package:flutter/material.dart';
import 'profile/yalker_profile_page.dart';
import 'constant.dart';

class FollowedListPage extends StatefulWidget {
  final int userNumber;
  const FollowedListPage({Key? key, required this.userNumber})
      : super(key: key);

  @override
  _FollowedListPageState createState() => _FollowedListPageState();
}

class _FollowedListPageState extends State<FollowedListPage> {
  late List<Connection> _followedList = []; // user_repost_list を格納するリスト
  late ScrollController _scrollController; // ListView のスクロールを制御するコントローラー
  bool _loading = false; // データをロード中かどうかを示すフラグ
  int _page = 1; // 現在のページ番号

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _fetchFollowedList(); // 最初のデータを読み込む
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

  Future<void> _fetchFollowedList() async {
    setState(() {
      _loading = true; // データのロード中フラグをtrueに設定
    });

    FollowedListResponse followedListResponse =
        await FollowedListResponse.fetchFollowedListResponse(
            widget.userNumber, _page);
    if (mounted) {
      setState(() {
        _followedList
            .addAll(followedListResponse.followedList); // 新しいデータをリストに追加
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
      await _fetchFollowedList();
    }
  }

  Future<void> _clearCache() async {
    try {
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      //await prefs.remove('user_repost_list');
      setState(() {
        _followedList.clear();
        _page = 1; // ページ番号をリセット
      });
      print("list refresh");
      await _fetchFollowedList(); // データを再読み込み
    } catch (error) {
      print('Error clearing cache: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('フォロワー一覧'),
      ),
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
                itemCount: _followedList.length + 1, // リストアイテム数 + ローディングインジケーター
                itemBuilder: (context, index) {
                  if (index == _followedList.length) {
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
                  final followed = _followedList[index];
                  return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => YalkerProfilePage(
                                  userNumber: followed.followerUserNumber),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  if (followed.followerIconimage == "")
                                    const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      backgroundImage: NetworkImage(
                                        'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/static/img/user.png',
                                      ),
                                    ),
                                  if (followed.followerIconimage != "")
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/iconimage/${followed.followerIconimage}',
                                      ),
                                    ),
                                  SizedBox(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          followed.followerName,
                                          style:
                                              const TextStyle(fontSize: 20.0),
                                        ),
                                        Row(
                                          children: [
                                            if (followed.followerPrivate)
                                              const Icon(
                                                Icons.lock,
                                                color: Colors.grey,
                                                size: 12.0,
                                              ),
                                            Text(
                                              '@${followed.followerUserId}',
                                              style: const TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4.0),
                                        Row(
                                          children: [
                                            if (followed.followerSuperEarlyBird)
                                              Padding(
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
                                            if (followed.followerSuperEarlyBird)
                                              Padding(
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
                                            if (followed
                                                .followerSuperHardWorker)
                                              Padding(
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
                                            if (followed.followerHardWorker)
                                              Padding(
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
                                            if (followed
                                                .followerRegularCustomer)
                                              Padding(
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
                                          ],
                                        ),
                                        followed.followerProfile != ''
                                            ? Text(
                                                followed.followerProfile,
                                                style:
                                                    TextStyle(fontSize: 14.0),
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
    );
  }
}
