import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yalkey_0206_test/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yalkey_0206_test/post_page.dart';
import 'bottom_nav_bar.dart';
import 'setting/setting_list.dart';
import 'mission/mission_list.dart';
import 'goal/goal_list.dart';
import 'profile/profile_page.dart';
import 'notification/notification_list.dart';
import 'search/search_recommend_user.dart';
import 'user_bookmark_list.dart';

class AppPage extends StatefulWidget {
  const AppPage({Key? key}) : super(key: key);

  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  String? loginUserIconImage;

  @override
  void initState() {
    super.initState();
    _getLoginUserIconImage();
  }

  Future<void> _getLoginUserIconImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _loginUserIconImage = prefs.getString('login_user_iconimage');

    setState(() => loginUserIconImage = _loginUserIconImage);
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
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    loginUserIconImage ??
                        'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/static/img/user.png',
                  ),
                  radius: 20, // アイコンの半径を小さくする
                )),
        title: const Text("yalkey mobile"),
      ),
      body: const BottomNavBar(),
      drawer: SizedBox(
        width: 225,
        child: Drawer(
          child: Container(
            // 外側の余白（マージン）
            margin: EdgeInsets.all(8),
            child: ListView(
              children: [
                ListTile(
                  title: const Text("ログアウト"),
                  onTap: () {
                    logout(context);
                  },
                ),
                ListTile(
                  title: const Text("マイページ"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                ),
                /*
                ListTile(
                  title: const Text("ホーム"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  },
                ),
                */
                ListTile(
                  title: const Text("投稿"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PostPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text("目標"),
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
                  title: const Text("ミッション"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MissionListPage(),
                      ),
                    );
                  },
                ),
                /*
                ListTile(
                  title: const Text("レポート編集"),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text("CSVデータ出力"),
                  onTap: () {},
                ),
                */
                ListTile(
                  title: const Text("検索"),
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
                  title: const Text("ブックマーク"),
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
                  title: const Text("通知"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationListPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text("設定"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingListPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 32.0, thickness: 1.0, color: Colors.grey),
                ListTile(
                  title: const Text("開発者への支援"),
                  onTap: () {
                    _launchInBrowser(
                        "https://yalkey.net/ja/support-for-developer/");
                  },
                ),
                ListTile(
                  title: const Text("使い方"),
                  onTap: () {
                    _launchInBrowser("https://yalkey.net/ja/howto/");
                  },
                ),
                ListTile(
                  title: const Text("このアプリについて"),
                  onTap: () {
                    _launchInBrowser("https://yalkey.net/ja/about/");
                  },
                ),
                ListTile(
                  title: const Text("便利なサイト＆ツール"),
                  onTap: () {
                    _launchInBrowser("https://yalkey.net/ja/recommend/");
                  },
                ),
                ListTile(
                  title: const Text("サポーター・協賛"),
                  onTap: () {
                    _launchInBrowser("https://yalkey.net/ja/supporter/");
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
