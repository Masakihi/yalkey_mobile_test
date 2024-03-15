import 'package:flutter/material.dart';
import 'package:yalkey_0206_test/post/post_detail_page.dart';
import '../profile/yalker_profile_page.dart';
import '../api.dart';
import 'notification_model.dart';
import '../constant.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({Key? key}) : super(key: key);

  @override
  _NotificationListPageState createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  late List<UserNotification> _notificationList =
      []; // user_repost_list を格納するリスト
  late ScrollController _scrollController; // ListView のスクロールを制御するコントローラー
  bool _loading = false; // データをロード中かどうかを示すフラグ
  int _page = 1; // 現在のページ番号

  late List<FollowRequest> _followRequestList = []; // user_repost_list を格納するリスト
  late ScrollController
      _scrollFollowRequestController; // ListView のスクロールを制御するコントローラー
  bool _loadingFollowRequest = false; // データをロード中かどうかを示すフラグ
  int _pageFollowRequest = 1; // 現在のページ番号
  late List<bool> permitButtonPush = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _fetchNotificationList(); // 最初のデータを読み込む
    _scrollFollowRequestController = ScrollController()
      ..addListener(_scrollFollowRequestListener);
    _fetchFollowRequestList();
  }

  // ListView のスクロールイベントを監視するリスナー
  void _scrollFollowRequestListener() {
    // スクロール位置が最下部に達したかどうかをチェック
    if (_scrollFollowRequestController.position.pixels ==
        _scrollFollowRequestController.position.maxScrollExtent) {
      // 最下部に達したら新しいデータをロードする
      _loadMoreFollowRequestData();
    }
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

  Future<void> _fetchNotificationList() async {
    setState(() {
      _loading = true; // データのロード中フラグをtrueに設定
    });

    NotificationListResponse notificationListResponse =
        await NotificationListResponse.fetchNotificationListResponse(_page);
    if (mounted) {
      setState(() {
        _notificationList
            .addAll(notificationListResponse.notificationList); // 新しいデータをリストに追加
        _loading = false; // データのロード中フラグをfalseに設定
      });
    }
    /*prefs.setStringList('user_repost_list',
        _userRepostList.map((repost) => jsonEncode(repost.toJson())).toList());

     */
  }

  Future<void> _fetchFollowRequestList() async {
    setState(() {
      _loadingFollowRequest = true; // データのロード中フラグをtrueに設定
    });

    FollowRequestListResponse followRequestListResponse =
        await FollowRequestListResponse.fetchFollowRequestListResponse(_page);
    if (mounted) {
      setState(() {
        _followRequestList.addAll(
            followRequestListResponse.followRequestList); // 新しいデータをリストに追加
        for (var i = 0; i < _followRequestList.length; i++) {
          permitButtonPush.add(false);
        }
        //print(permitButtonPush);
        _loadingFollowRequest = false; // データのロード中フラグをfalseに設定
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
      await _fetchNotificationList();
    }
  }

  Future<void> _loadMoreFollowRequestData() async {
    if (!_loadingFollowRequest) {
      setState(() {
        _loadingFollowRequest = true; // データのロード中フラグをtrueに設定
        _pageFollowRequest++; // ページ番号をインクリメントして新しいデータを取得
      });
      await _fetchFollowRequestList();
    }
  }

  Future<void> _clearCache() async {
    try {
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      //await prefs.remove('user_repost_list');
      setState(() {
        _notificationList.clear();
        _page = 1; // ページ番号をリセット
      });
      print("list refresh");
      await _fetchNotificationList(); // データを再読み込み
    } catch (error) {
      print('Error clearing cache: $error');
    }
  }

  Future<void> _clearFollowRequestCache() async {
    try {
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      //await prefs.remove('user_repost_list');
      setState(() {
        _followRequestList.clear();
        permitButtonPush.clear();
        _pageFollowRequest = 1; // ページ番号をリセット
      });
      print("list refresh");
      await _fetchFollowRequestList(); // データを再読み込み
    } catch (error) {
      print('Error clearing cache: $error');
    }
  }

  Future<void> permit(context, int? user_number) async {
    try {
      final response =
          await httpPost('permit/${user_number}/', null, jwt: true);
      //print(response);
    } catch (error) {
      print('Error deactivate: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    String ifNotificationText(int notificationType) {
      switch (notificationType) {
        case 0:
          return 'あなたの投稿に返信';
        case 1:
          return 'あなたの投稿にいいね';
        case 2:
          return 'あなたの投稿をリポスト';
        case 3:
          return 'あなたの投稿にいいね';
        case 4:
          return 'あなたをフォロー';
        case 5:
          return 'あなた宛てにフォローリクエストを送信';
        default:
          return '[エラー：不明な通知]';
      }
    }

    String newNotificationCheck(bool newNotification) {
      if (newNotification)
        return "【New】";
      else
        return "";
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TabBar(
                labelColor: Color(0xFFAE0103),
                indicatorColor: Color(0xFFAE0103),
                tabs: <Widget>[
                  Tab(text: '新着通知'),
                  Tab(text: 'リクエスト'),
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
                      itemCount: _notificationList.length +
                          1, // リストアイテム数 + ローディングインジケーター
                      itemBuilder: (context, index) {
                        if (index == _notificationList.length) {
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
                        final notification = _notificationList[index];
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
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                YalkerProfilePage(
                                                    userNumber: notification
                                                            .fromUserNumber ??
                                                        1),
                                          ));
                                    },
                                    child: notification.fromIconimage == ""
                                        ? const CircleAvatar(
                                            backgroundColor: Colors.white,
                                            backgroundImage: NetworkImage(
                                              'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/static/img/user.png',
                                            ),
                                          )
                                        : CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/iconimage/${notification.fromIconimage}',
                                            ),
                                          ),
                                  ),
                                  SizedBox(width: 16.0),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (notification.post != null) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PostDetailPage(
                                                        postNumber:
                                                            notification.post!),
                                              ));
                                        }
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            newNotificationCheck(notification
                                                    .newNotification!) +
                                                '${notification.fromName} さん(@${notification.fromUserId})が' +
                                                ifNotificationText(notification
                                                    .notificationType) +
                                                'しました！',
                                            style: TextStyle(fontSize: 14.0),
                                          ),
                                          SizedBox(height: 4.0),
                                          Text(
                                            '${notification.dateCreated.toString().substring(0, 10)} ${notification.dateCreated.toString().substring(11, 16)}',
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.grey),
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
            RefreshIndicator(
              displacement: 0,
              onRefresh: () async {
                _clearFollowRequestCache();
              },
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      controller:
                          _scrollFollowRequestController, // スクロールコントローラーを設定
                      itemCount: _followRequestList.length +
                          1, // リストアイテム数 + ローディングインジケーター
                      itemBuilder: (context, index) {
                        if (index == _followRequestList.length) {
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
                        final follow_request = _followRequestList[index];
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
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                YalkerProfilePage(
                                                    userNumber: follow_request
                                                            .fromUserNumber ??
                                                        1),
                                          ));
                                    },
                                    child: follow_request.fromIconimage == ""
                                        ? const CircleAvatar(
                                            backgroundColor: Colors.white,
                                            backgroundImage: NetworkImage(
                                              'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/static/img/user.png',
                                            ),
                                          )
                                        : CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/iconimage/${follow_request.fromIconimage}',
                                            ),
                                          ),
                                  ),
                                  SizedBox(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          '${follow_request.fromName} さん(@${follow_request.fromUserId})からフォローリクエストが届いています！',
                                          style: TextStyle(fontSize: 14.0),
                                        ),
                                        SizedBox(height: 4.0),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        permit(context,
                                            follow_request.fromUserNumber);
                                        setState(() {
                                          // ボタンが押されたらisButtonPressedの値を切り替える
                                          permitButtonPush[index] =
                                              !permitButtonPush[index];
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: permitButtonPush[index]
                                            ? Colors.white
                                            : const Color(0xFFAE0103),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: permitButtonPush[index]
                                          ? const Text(
                                              '承認済み',
                                              style: TextStyle(
                                                color: const Color(0xFFAE0103),
                                              ),
                                            )
                                          : const Text(
                                              '承認する',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            )),
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
          ],
        ),
      ),
    );
  }
}
