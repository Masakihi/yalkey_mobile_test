import 'package:flutter/material.dart';
import '../login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../profile/profile_edit_page.dart';
import '../setting/deactivate_account.dart';
import '../setting/password_update.dart';
import 'email_update.dart';
import 'dart:convert';
import '../api.dart';

class AccountSettingListPage extends StatefulWidget {
  const AccountSettingListPage({Key? key}) : super(key: key);

  @override
  _AccountSettingListPageState createState() => _AccountSettingListPageState();
}

class _AccountSettingListPageState extends State<AccountSettingListPage> {
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> logout(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => LoginPage()), (_) => false);
  }

  Future<void> _fetchProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // キャッシュからデータを取得
    String? cachedProfileData = prefs.getString('profileData');
    if (cachedProfileData != null) {
      setState(() {
        _profileData = json.decode(cachedProfileData);
      });
      return;
    }

    try {
      final Map<String, dynamic> response =
          await httpGet('login-user-profile/', jwt: true);
      setState(() {
        _profileData = response;
      });

      // データをキャッシュ
      await prefs.setString('profileData', json.encode(response));
    } catch (error) {
      print('Error fetching profile data: $error');
    }
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditPage(profileData: _profileData!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント設定'),
      ),
      body: Container(
        width: double.infinity,
        child: ListView(
          children: <Widget>[
            ListTile(
              //leading: Icon(Icons.photo_album),
              title: const Text('ユーザー情報の更新'),
              onTap: () {
                _editProfile();
              },
            ),
            /*
            ListTile(
              //leading: Icon(Icons.photo_album),
              title: const Text('メールアドレスの変更'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmailUpdatePage(),
                  ),
                );
              },
            ),
            ListTile(
              //leading: Icon(Icons.photo_album),
              title: const Text('パスワードの変更'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PasswordUpdatePage(),
                  ),
                );
              },
            ),
             */
            ListTile(
              //leading: Icon(Icons.photo_album),
              title: const Text('ログアウト'),
              onTap: () {
                logout(context);
              },
            ),
            ListTile(
              //leading: Icon(Icons.photo_album),
              title: const Text('退会'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeactivateAccountPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
