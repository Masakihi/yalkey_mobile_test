import 'package:flutter/material.dart';
import 'constant.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({Key? key}) : super(key: key);

  @override
  _NotificationListPageState createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  late List<UserNotification> _notificationList = []; // user_repost_list を格納するリスト
  late ScrollController _scrollController; // ListView のスクロールを制御するコントローラー
  bool _loading = false; // データをロード中かどうかを示すフラグ
  int _page = 1; // 現在のページ番号

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _fetchNotificationList(); // 最初のデータを読み込む
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

    NotificationListResponse  notificationListResponse =
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

  Future<void> _loadMoreData() async {
    if (!_loading) {
      setState(() {
        _loading = true; // データのロード中フラグをtrueに設定
        _page++; // ページ番号をインクリメントして新しいデータを取得
      });
      await _fetchNotificationList();
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


  @override
  Widget build(BuildContext context) {

    String ifNotificationText(int notificationType) {
      switch (notificationType){
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

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('通知一覧'),
            bottom: const TabBar(
              tabs: <Widget>[
                Tab(text: '通知'),
                Tab(text: 'リクエスト'),
                //Tab(icon: Icon(Icons.brightness_5_sharp)),
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
                child:Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController, // スクロールコントローラーを設定
                        itemCount: _notificationList.length + 1, // リストアイテム数 + ローディングインジケーター
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
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/iconimage/${notification.fromIconimage}',
                                      ),
                                    ),
                                    SizedBox(width: 16.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            '${notification.fromName} さん(@${notification.fromUserId})が'+ifNotificationText(notification.notificationType)+'しました！',
                                            style: TextStyle(fontSize: 14.0),
                                          ),
                                          SizedBox(height: 4.0),
                                          Text(
                                            '${notification.dateCreated.toString().substring(0, 10)} ${notification.dateCreated.toString().substring(11, 16)}',
                                            style: TextStyle(
                                                fontSize: 12.0, color: Colors.grey),
                                          ),
                                        ],
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
              Center(child: Text('リクエスト', style: TextStyle(fontSize: 50))),
            ],
          ),
        ),
      );
  }
}
