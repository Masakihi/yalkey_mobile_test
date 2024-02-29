import 'package:flutter/material.dart';
import 'package:yalkey_0206_test/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom_nav_bar.dart';
import 'setting_list.dart';

class AppPage extends StatelessWidget {
  AppPage({super.key});

  Future<void> logout(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),(_) => false);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => _scaffoldKey.currentState!.openDrawer(),
            icon: const Icon(Icons.person)),
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
                  onTap: () {},
                ),
                ListTile(
                  title: const Text("ホーム"),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text("投稿"),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text("目標"),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text("ミッション"),
                  onTap: () {},
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
                  onTap: () {},
                ),
                ListTile(
                  title: const Text("ブックマーク"),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text("通知"),
                  onTap: () {},
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
                const Divider(
                    height: 32.0,
                    thickness: 1.0,
                    color: Colors.grey
                ),
                ListTile(
                  title: const Text("開発者への支援"),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text("使い方"),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text("このアプリについて"),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text("便利なサイト＆ツール"),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text("サポーター・協賛"),
                  onTap: () {},
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
