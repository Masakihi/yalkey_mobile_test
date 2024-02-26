import 'package:flutter/material.dart';
import 'package:yalkey_0206_test/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom_nav_bar.dart';

class AppPage extends StatelessWidget {
  AppPage({super.key});

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const LoginPage(),
    ));
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
        title: const Text("Yalkey mobile"),
      ),
      body: const BottomNavBar(),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text("ログアウト"),
              onTap: () {
                logout(context);
              },
            ),
            ListTile(
              title: const Text("メニュー2"),
              onTap: () {},
            ),
            ListTile(
              title: const Text("メニュー3"),
              onTap: () {},
            )
          ],
        ),
      ),
    );
  }
}
