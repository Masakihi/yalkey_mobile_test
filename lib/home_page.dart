import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api.dart';
import 'utill.dart';
import 'constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'post_detail_page.dart';
import 'reply_form.dart';

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
      await _fetchUserRepostList(); // データを再読み込み
    } catch (error) {
      print('Error clearing cache: $error');
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
        userRepostList.forEach((r) {
          if (r.postNumber == repost.postNumber) {
            r.postLiked = false;
            r.postLikeNumber--;
          }
        });
        prefs.setStringList(
            'user_repost_list',
            userRepostList
                .map((repost) => jsonEncode(repost.toJson()))
                .toList());
        setState(() {});
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('いいねを解除しました')),
        );
      } else {
        await repost.like();
        userRepostList.forEach((r) {
          if (r.postNumber == repost.postNumber) {
            r.postLiked = true;
            r.postLikeNumber++;
          }
        });
        prefs.setStringList(
            'user_repost_list',
            userRepostList
                .map((repost) => jsonEncode(repost.toJson()))
                .toList());
        setState(() {});
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('いいねしました')),
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
        userRepostList.forEach((r) {
          if (r.postNumber == repost.postNumber) {
            r.postBookmarked = false;
          }
        });
        prefs.setStringList(
            'user_repost_list',
            userRepostList
                .map((repost) => jsonEncode(repost.toJson()))
                .toList());
        setState(() {});
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ブックマークを解除しました')),
        );
      } else {
        await repost.bookmark();
        userRepostList.forEach((r) {
          if (r.postNumber == repost.postNumber) {
            r.postBookmarked = true;
          }
        });
        prefs.setStringList(
            'user_repost_list',
            userRepostList
                .map((repost) => jsonEncode(repost.toJson()))
                .toList());
        setState(() {});
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ブックマークしました')),
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
        userRepostList.forEach((r) {
          if (r.postNumber == repost.postNumber) {
            r.postReposted = false;
          }
        });
        prefs.setStringList(
            'user_repost_list',
            userRepostList
                .map((repost) => jsonEncode(repost.toJson()))
                .toList());
        setState(() {});
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('リポストを解除しました')),
        );
      } else {
        await repost.repost();
        userRepostList.forEach((r) {
          if (r.postNumber == repost.postNumber) {
            r.postReposted = true;
          }
        });
        prefs.setStringList(
            'user_repost_list',
            userRepostList
                .map((repost) => jsonEncode(repost.toJson()))
                .toList());
        setState(() {});
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('リポストしました')),
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
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _userRepostList.length + 1,
              itemBuilder: (context, index) {
                if (index == _userRepostList.length) {
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
                final repost = _userRepostList[index];
                return InkWell(
                  onTap: () {
                    // 投稿部分をタップしたときの処理
                    _navigateToPostDetailPage(repost.postNumber);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/iconimage/${repost.postUserIcon}',
                              ),
                            ),
                            SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    repost.postUserName,
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    '@${repost.postUserId} / ${repost.postCreatedAt.toString().substring(0, 10)} ${repost.postCreatedAt.toString().substring(11, 16)}',
                                    style: TextStyle(
                                        fontSize: 12.0, color: Colors.grey),
                                  ),
                                  SizedBox(height: 8.0),
                                  repost.postText != ''
                                      ? Text(
                                          repost.postText,
                                          style: TextStyle(fontSize: 16.0),
                                        )
                                      : SizedBox.shrink(),
                                  SizedBox(height: 4.0),
                                  ...repost.progressTextList
                                      .map((progressText) => Text(
                                          "・" + progressText,
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold)))
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
                              onPressed: () {
                                _showReplyForm(repost.postNumber);
                              },
                              icon: Icon(Icons.reply),
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
                                        ? Colors.red
                                        : null, // 赤色にするかどうか
                                  ),
                                ),
                                Text(
                                  '${repost.postLikeNumber}', // いいね数を表示
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: repost.postLiked
                                        ? Colors.red
                                        : Colors.black,
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
                                      ? Color.fromARGB(255, 255, 226, 59)
                                      : null),
                            ),
                            IconButton(
                              onPressed: () {
                                _repost(repost);
                              },
                              icon: Icon(Icons.refresh,
                                  color: repost.postReposted
                                      ? Color.fromARGB(255, 39, 181, 0)
                                      : null),
                            ),
                          ],
                        ),
                        if (index != _userRepostList.length - 1)
                          Divider(
                              height: 32.0,
                              thickness: 1.0,
                              color: Colors.grey), // 最後のポストの後には区切り線を表示しない
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
