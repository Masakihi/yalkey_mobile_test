import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constant.dart';
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
  bool _liking = false;
  bool _bookmarking = false;
  bool _reposting = false;

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cachedBookmarkPostList = prefs.getStringList('bookmark_post_list');
    if (cachedBookmarkPostList != null && cachedBookmarkPostList.isNotEmpty) {
      setState(() {
        _bookmarkPostList = cachedBookmarkPostList
            .map((jsonString) => Post.fromJson(jsonDecode(jsonString)))
            .toList();
      });
    }
    PostListResponse bookmarkPostListResponse =
    await PostListResponse.fetchBookmarkPostListResponse(_page);
    if (mounted) {
      setState(() {
        _bookmarkPostList
            .addAll(bookmarkPostListResponse.postList); // 新しいデータをリストに追加
        _loading = false; // データのロード中フラグをfalseに設定
      });
    }
    prefs.setStringList('post_list',
        _bookmarkPostList.map((post) => jsonEncode(post.toJson())).toList());

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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('bookmark_post_list');
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



  Future<void> like(Post post) async {
    if (_liking) {
      return;
    }

    _liking = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cachedBookmarkPostList = prefs.getStringList('post_list');
    if (cachedBookmarkPostList != null && cachedBookmarkPostList.isNotEmpty) {
      var bookmarkPostList = cachedBookmarkPostList
          .map((jsonString) => Post.fromJson(jsonDecode(jsonString)));
      if (post.postLiked) {
        await post.unlike();
        for (var r in bookmarkPostList) {
          if (r.postNumber == post.postNumber) {
            r.postLiked = false;
            r.postLikeNumber--;
          }
        }
        prefs.setStringList(
            'bookmark_post_list',
            bookmarkPostList
                .map((post) => jsonEncode(post.toJson()))
                .toList());
        setState(() {});
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('いいねを解除しました')),
        );
      } else {
        await post.like();
        for (var r in bookmarkPostList) {
          if (r.postNumber == post.postNumber) {
            r.postLiked = true;
            r.postLikeNumber++;
          }
        }
        prefs.setStringList(
            'bookmark_post_list',
            bookmarkPostList
                .map((post) => jsonEncode(post.toJson()))
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

  Future<void> bookmark(Post post) async {
    if (_bookmarking) {
      return;
    }

    _bookmarking = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cachedBookmarkPostList = prefs.getStringList('bookmark_post_list');
    if (cachedBookmarkPostList != null && cachedBookmarkPostList.isNotEmpty) {
      var bookmarkPostList = cachedBookmarkPostList
          .map((jsonString) => Post.fromJson(jsonDecode(jsonString)));
      if (post.postBookmarked) {
        await post.unbookmark();
        for (var r in bookmarkPostList) {
          if (r.postNumber == post.postNumber) {
            r.postBookmarked = false;
          }
        }
        prefs.setStringList(
            'bookmark_post_list',
            bookmarkPostList
                .map((post) => jsonEncode(post.toJson()))
                .toList());
        setState(() {});
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ブックマークを解除しました')),
        );
      } else {
        await post.bookmark();
        for (var r in bookmarkPostList) {
          if (r.postNumber == post.postNumber) {
            r.postBookmarked = true;
          }
        }
        prefs.setStringList(
            'bookmark_post_list',
            bookmarkPostList
                .map((post) => jsonEncode(post.toJson()))
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

  Future<void> _repost(Post post) async {
    if (_reposting) {
      return;
    }

    _reposting = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cachedBookmarkPostList = prefs.getStringList('bookmark_post_list');
    if (cachedBookmarkPostList != null && cachedBookmarkPostList.isNotEmpty) {
      var bookmarkPostList = cachedBookmarkPostList
          .map((jsonString) => Post.fromJson(jsonDecode(jsonString)));
      if (post.postReposted) {
        await post.unrepost();
        for (var r in bookmarkPostList) {
          if (r.postNumber == post.postNumber) {
            r.postReposted = false;
          }
        }
        prefs.setStringList(
            'bookmark_post_list',
            bookmarkPostList
                .map((post) => jsonEncode(post.toJson()))
                .toList());
        setState(() {});
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('リポストを解除しました')),
        );
      } else {
        await post.repost();
        for (var r in bookmarkPostList) {
          if (r.postNumber == post.postNumber) {
            r.postReposted = true;
          }
        }
        prefs.setStringList(
            'bookmark_post_list',
            bookmarkPostList
                .map((post) => jsonEncode(post.toJson()))
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
                  !_loading ? const SizedBox(height: 20.0)
                      : const SizedBox.shrink(),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController, // スクロールコントローラーを設定
                      itemCount: _bookmarkPostList.length + 1, // リストアイテム数 + ローディングインジケーター
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
                              if(post.postReposted==true)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.refresh,
                                      color: Colors.grey,
                                      size: 12.0,
                                    ),
                                    Text(
                                      '${post.postUserName}さんがリポスト',
                                      style: const TextStyle(fontSize: 12.0, color: Colors.grey, fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                ),
                              if(post.postReposted==true)
                                const SizedBox(height: 8.0),
                              if(post.toPostUserName!=null)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.reply,
                                      color: Colors.grey,
                                      size: 12.0,
                                    ),
                                    Text(
                                      '${post.toPostUserName}さんに対する返信',
                                      style: const TextStyle(fontSize: 12.0, color: Colors.grey, fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                ),
                              if(post.toPostUserName!=null)
                                const SizedBox(height: 8.0),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  if (post.postUserIcon=="") const CircleAvatar(
                                    backgroundColor: Colors.white,
                                    backgroundImage: NetworkImage(
                                      'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/static/img/user.png',
                                    ),
                                  ),
                                  if (post.postUserIcon!="") CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/iconimage/${post.postUserIcon}',
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          post.postUserName,
                                          style: const TextStyle(fontSize: 18.0),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Row(
                                          children: [
                                            if (post.postUserPrivate ?? false) const Icon(
                                              Icons.lock,
                                              color: Colors.grey,
                                              size: 12.0,
                                            ),
                                            Text(
                                              '@${post.postUserId} / ${post.postCreatedAt.toString().substring(0, 10)} ${post.postCreatedAt.toString().substring(11, 16)}',
                                              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            if (post.postUserSuperEarlyBird ?? false) Padding(
                                              padding: const EdgeInsets.symmetric(horizontal:3, vertical: 1),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFAE0103),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(horizontal:3, vertical: 1),
                                                  child: Text(
                                                    "超早起き",
                                                    style: TextStyle(fontSize: 10.0, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (post.postUserSuperEarlyBird ?? false) Padding(
                                              padding: const EdgeInsets.symmetric(horizontal:3, vertical: 1),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFAE0103),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(horizontal:3, vertical: 1),
                                                  child: Text(
                                                    "早起き",
                                                    style: TextStyle(fontSize: 10.0, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (post.postUserSuperHardWorker ?? false) Padding(
                                              padding: const EdgeInsets.symmetric(horizontal:3, vertical: 1),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFAE0103),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(horizontal:3, vertical: 1),
                                                  child: Text(
                                                    "超努力家",
                                                    style: TextStyle(fontSize: 10.0, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (post.postUserHardWorker ?? false) Padding(
                                              padding: const EdgeInsets.symmetric(horizontal:3, vertical: 1),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFAE0103),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(horizontal:3, vertical: 1),
                                                  child: Text(
                                                    "努力家",
                                                    style: TextStyle(fontSize: 10.0, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (post.postUserRegularCustomer ?? false) Padding(
                                              padding: const EdgeInsets.symmetric(horizontal:3, vertical: 1),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFAE0103),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(horizontal:3, vertical: 1),
                                                  child: Text(
                                                    "常連",
                                                    style: TextStyle(fontSize: 10.0, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8.0),
                                        post.postText != ''
                                            ? Text(
                                          post.postText,
                                          style: const TextStyle(fontSize: 16.0),
                                        )
                                            : const SizedBox.shrink(),
                                        const SizedBox(height: 8.0),
                                        ...post.progressTextList
                                            .map((progressText) => Text(
                                            "$progressText",
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
                                    onPressed: () {

                                    },
                                    icon: const Icon(
                                      Icons.reply,
                                      color: Color(0xFF929292),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          like(post);
                                        },
                                        icon: Icon(
                                          post.postLiked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: post.postLiked
                                              ? const Color(0xFFF75D5D)
                                              : const Color(0xFF929292), // 赤色にするかどうか
                                        ),
                                      ),
                                      Text(
                                        '${post.postLikeNumber}', // いいね数を表示
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: post.postLiked
                                              ? const Color(0xFFF75D5D)
                                              : const Color(0xFF929292),
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      bookmark(post);
                                    },
                                    icon: Icon(
                                        post.postBookmarked
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        color: post.postBookmarked
                                            ? const Color.fromRGBO(255, 196, 67, 1)
                                            : const Color(0xFF929292)),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _repost(post);
                                    },
                                    icon: Icon(Icons.refresh,
                                        color: post.postReposted
                                            ? const Color.fromRGBO(102, 205, 170, 1)
                                            : const Color(0xFF929292)),
                                  ),
                                ],
                              ),
                              if (index != _bookmarkPostList.length - 1)
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
      ),
    );
  }
}
