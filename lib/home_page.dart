import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'post_detail_page.dart';
import 'reply_form.dart';
import 'linkify_util.dart';

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
  bool _liking = false;
  bool _bookmarking = false;
  bool _reposting = false;

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

  void _showReplyForm(int postNumber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 画面の9割を覆うようにする
      builder: (context) {
        return FractionallySizedBox(
          // 画面の9割の高さを調整
          heightFactor: 0.9,
          child: ReplyForm(postNumber: postNumber),
        );
      },
    ).then((value) {
      // モーダルが閉じられた後の処理
      if (value == 'replyPosted') {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('返信しました')),
        );
      }
    });
  }

  Future<void> like(UserRepost repost) async {
    if (_liking) {
      return;
    }

    _liking = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cachedRepostList = prefs.getStringList('user_repost_list');
    if (cachedRepostList != null && cachedRepostList.isNotEmpty) {
      var userRepostList = cachedRepostList
          .map((jsonString) => UserRepost.fromJson(jsonDecode(jsonString)));
      if (repost.postLiked) {
        await repost.unlike();
        for (var r in userRepostList) {
          if (r.postNumber == repost.postNumber) {
            r.postLiked = false;
            r.postLikeNumber--;
          }
        }
        prefs.setStringList(
            'user_repost_list',
            userRepostList
                .map((repost) => jsonEncode(repost.toJson()))
                .toList());
        setState(() {});
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('いいねを解除しました')),
        );
      } else {
        await repost.like();
        for (var r in userRepostList) {
          if (r.postNumber == repost.postNumber) {
            r.postLiked = true;
            r.postLikeNumber++;
          }
        }
        prefs.setStringList(
            'user_repost_list',
            userRepostList
                .map((repost) => jsonEncode(repost.toJson()))
                .toList());
        setState(() {});
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('いいねしました')),
        );
      }
    }

    _liking = false;
  }

  Future<void> bookmark(UserRepost repost) async {
    if (_bookmarking) {
      return;
    }

    _bookmarking = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cachedRepostList = prefs.getStringList('user_repost_list');
    if (cachedRepostList != null && cachedRepostList.isNotEmpty) {
      var userRepostList = cachedRepostList
          .map((jsonString) => UserRepost.fromJson(jsonDecode(jsonString)));
      if (repost.postBookmarked) {
        await repost.unbookmark();
        for (var r in userRepostList) {
          if (r.postNumber == repost.postNumber) {
            r.postBookmarked = false;
          }
        }
        prefs.setStringList(
            'user_repost_list',
            userRepostList
                .map((repost) => jsonEncode(repost.toJson()))
                .toList());
        setState(() {});
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ブックマークを解除しました')),
        );
      } else {
        await repost.bookmark();
        for (var r in userRepostList) {
          if (r.postNumber == repost.postNumber) {
            r.postBookmarked = true;
          }
        }
        prefs.setStringList(
            'user_repost_list',
            userRepostList
                .map((repost) => jsonEncode(repost.toJson()))
                .toList());
        setState(() {});
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ブックマークしました')),
        );
      }
    }

    _bookmarking = false;
  }

  Future<void> _repost(UserRepost repost) async {
    if (_reposting) {
      return;
    }

    _reposting = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cachedRepostList = prefs.getStringList('user_repost_list');
    if (cachedRepostList != null && cachedRepostList.isNotEmpty) {
      var userRepostList = cachedRepostList
          .map((jsonString) => UserRepost.fromJson(jsonDecode(jsonString)));
      if (repost.postReposted) {
        await repost.unrepost();
        for (var r in userRepostList) {
          if (r.postNumber == repost.postNumber) {
            r.postReposted = false;
          }
        }
        prefs.setStringList(
            'user_repost_list',
            userRepostList
                .map((repost) => jsonEncode(repost.toJson()))
                .toList());
        setState(() {});
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('リポストを解除しました')),
        );
      } else {
        await repost.repost();
        for (var r in userRepostList) {
          if (r.postNumber == repost.postNumber) {
            r.postReposted = true;
          }
        }
        prefs.setStringList(
            'user_repost_list',
            userRepostList
                .map((repost) => jsonEncode(repost.toJson()))
                .toList());
        setState(() {});
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('リポストしました')),
        );
      }
    }

    _reposting = false;
  }

  void _navigateToPostDetailPage(int postNumber) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailPage(postNumber: postNumber),
        ));
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
                        if (repost.isRepost == 1)
                          Row(
                            children: [
                              const Icon(
                                Icons.refresh,
                                color: Colors.grey,
                                size: 12.0,
                              ),
                              Text(
                                '${repost.repostUserName}さんがリポスト',
                                style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        if (repost.isRepost == 1) const SizedBox(height: 8.0),
                        if (repost.toPostUserName != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.reply,
                                color: Colors.grey,
                                size: 12.0,
                              ),
                              Text(
                                '${repost.toPostUserName}さんに対する返信',
                                style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        if (repost.toPostUserName != null)
                          const SizedBox(height: 8.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (repost.postUserIcon == "")
                              const CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(
                                  'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/static/img/user.png',
                                ),
                              ),
                            if (repost.postUserIcon != "")
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/iconimage/${repost.postUserIcon}',
                                ),
                              ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    repost.postUserName,
                                    style: const TextStyle(fontSize: 18.0),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Row(
                                    children: [
                                      if (repost.postUserPrivate ?? false)
                                        const Icon(
                                          Icons.lock,
                                          color: Colors.grey,
                                          size: 12.0,
                                        ),
                                      Text(
                                        '@${repost.postUserId} / ${repost.postCreatedAt.toString().substring(0, 10)} ${repost.postCreatedAt.toString().substring(11, 16)}',
                                        style: const TextStyle(
                                            fontSize: 12.0, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      if (repost.postUserSuperEarlyBird ??
                                          false)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3, vertical: 1),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFAE0103),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 3, vertical: 1),
                                              child: Text(
                                                "超早起き",
                                                style: TextStyle(
                                                    fontSize: 10.0,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (repost.postUserSuperEarlyBird ??
                                          false)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3, vertical: 1),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFAE0103),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 3, vertical: 1),
                                              child: Text(
                                                "早起き",
                                                style: TextStyle(
                                                    fontSize: 10.0,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (repost.postUserSuperHardWorker ??
                                          false)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3, vertical: 1),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFAE0103),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 3, vertical: 1),
                                              child: Text(
                                                "超努力家",
                                                style: TextStyle(
                                                    fontSize: 10.0,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (repost.postUserHardWorker ?? false)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3, vertical: 1),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFAE0103),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 3, vertical: 1),
                                              child: Text(
                                                "努力家",
                                                style: TextStyle(
                                                    fontSize: 10.0,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (repost.postUserRegularCustomer ??
                                          false)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3, vertical: 1),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFAE0103),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 3, vertical: 1),
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
                                  const SizedBox(height: 8.0),
                                  repost.postText != ''
                                      ? Text(
                                          repost.postText,
                                          style:
                                              const TextStyle(fontSize: 16.0),
                                        )
                                      : const SizedBox.shrink(),
                                  const SizedBox(height: 8.0),
                                  ...repost.progressTextList
                                      .map((progressText) =>
                                          Text("$progressText",
                                              style: const TextStyle(
                                                fontSize: 16.0,
                                                //fontWeight: FontWeight.bold,
                                                fontStyle: FontStyle.italic,
                                                //decoration: TextDecoration.underline,
                                              )))
                                      .toList(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.reply,
                                color: Color(0xFF929292),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    like(repost);
                                  },
                                  icon: Icon(
                                    repost.postLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: repost.postLiked
                                        ? const Color(0xFFF75D5D)
                                        : const Color(0xFF929292), // 赤色にするかどうか
                                  ),
                                ),
                                Text(
                                  '${repost.postLikeNumber}', // いいね数を表示
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: repost.postLiked
                                        ? const Color(0xFFF75D5D)
                                        : const Color(0xFF929292),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                bookmark(repost);
                              },
                              icon: Icon(
                                  repost.postBookmarked
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: repost.postBookmarked
                                      ? const Color.fromRGBO(255, 196, 67, 1)
                                      : const Color(0xFF929292)),
                            ),
                            IconButton(
                              onPressed: () {
                                _repost(repost);
                              },
                              icon: Icon(Icons.refresh,
                                  color: repost.postReposted
                                      ? const Color.fromRGBO(102, 205, 170, 1)
                                      : const Color(0xFF929292)),
                            ),
                          ],
                        ),
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
