import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yalkey_0206_test/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yalkey_0206_test/post/post_page.dart';
import 'bottom_nav_bar.dart';
import 'setting/setting_list.dart';
import 'mission/mission_list.dart';
import 'goal/goal_list.dart';
import 'profile/profile_page.dart';
import 'notification/notification_list.dart';
import 'search/search_recommend_user.dart';
import 'user_bookmark_list.dart';
import 'profile/profile_page.dart';

class AppPage extends StatefulWidget {
  const AppPage({Key? key}) : super(key: key);

  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  String? loginUserName;
  String? loginUserIconImage;
  String? loginUserId;
  int? loginUserNumber;

  @override
  void initState() {
    super.initState();
    _getLoginUserData();
  }

  void _navigateToYalkerDetailPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfilePage(),
        ));
  }

  Future<void> _getLoginUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _loginUserName = prefs.getString('login_user_name');
    var _loginUserIconImage = prefs.getString('login_user_iconimage');
    var _loginUserId = prefs.getString('login_user_id');
    var _loginUserNumber = prefs.getInt('login_user_number');
    setState(() => {
          loginUserName = _loginUserName,
          loginUserIconImage = _loginUserIconImage,
          loginUserId = _loginUserId,
          loginUserNumber = _loginUserNumber,
        });
  }

  Future<void> logout(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => LoginPage()), (_) => false);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _launchInBrowser(String url) async {
    //const url = 'https://pub.dev/packages/url_launcher';
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'このURLにはアクセスできません';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading:
            /*
        (true)?
        GestureDetector(
          onTap: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          // 対象の画像を記述
          child: Image.network(
            'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/static/img/user.png',
          )
        )
            :
        GestureDetector(
          onTap: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          // 対象の画像を記述
          child: Image.network(
            'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/iconimage/${repost.postUserIcon}',
        ),



             */
            // IconButton(
            //     onPressed: () => _scaffoldKey.currentState!.openDrawer(),
            //     icon: const Icon(Icons.person)),
            GestureDetector(
          onTap: () => _scaffoldKey.currentState!.openDrawer(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            child: ClipOval(
              child: Image.network(
                loginUserIconImage ??
                    'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/static/img/user.png',
                width: 20,
                height: 20,
                fit: BoxFit.cover,
              ),
            ),
          ),

          /*
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    loginUserIconImage ??
                        'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/static/img/user.png',
                  ),
                  radius: 5, // アイコンの半径を小さくする
                )

                 */
        ),
        title: const Text("yalkey mobile"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchRecommendUserListPage(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: SizedBox(
        width: 250,
        child: Drawer(
          child: Container(
            // 外側の余白（マージン）
            margin: EdgeInsets.all(8),
            child: ListView(
              shrinkWrap: false,
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 10.0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _navigateToYalkerDetailPage(),
                        child: ClipOval(
                          child: Image.network(
                            loginUserIconImage ??
                                'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/static/img/user.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        loginUserName ?? '',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 5),
                      Text('@${loginUserId ?? ''}'),
                    ],
                  ),
                ),
                const Divider(height: 32.0, thickness: 0.1, color: Colors.grey),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 15),
                      Text('マイページ'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.flag),
                      SizedBox(width: 15),
                      Text('目標'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GoalListPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.search),
                      SizedBox(width: 15),
                      Text('検索'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SearchRecommendUserListPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.bookmark),
                      SizedBox(width: 15),
                      Text('ブックマーク'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserBookmarkListPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 15),
                      Text('設定'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingListPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 32.0, thickness: 0.1, color: Colors.grey),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.medication),
                      SizedBox(width: 15),
                      Text('開発者を支援'),
                    ],
                  ),
                  onTap: () {
                    _launchInBrowser(
                        "https://yalkey.net/ja/support-for-developer/");
                  },
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.help),
                      SizedBox(width: 15),
                      Text('使い方'),
                    ],
                  ),
                  onTap: () {
                    _launchInBrowser("https://yalkey.net/ja/howto/");
                  },
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.info),
                      SizedBox(width: 15),
                      Text('アプリについて'),
                    ],
                  ),
                  onTap: () {
                    _launchInBrowser("https://yalkey.net/ja/about/");
                  },
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.school),
                      SizedBox(width: 15),
                      Text('便利なツール'),
                    ],
                  ),
                  onTap: () {
                    _launchInBrowser("https://yalkey.net/ja/recommend/");
                  },
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.redeem),
                      SizedBox(width: 15),
                      Text('協賛・サポート'),
                    ],
                  ),
                  onTap: () {
                    _launchInBrowser("https://yalkey.net/ja/supporter/");
                  },
                )
              ],
            ),
          ),
        ),
      ),
      body: const BottomNavBar(),
    );
  }
}
