import 'dart:convert';
import 'package:flutter/material.dart';
import 'api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_edit_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
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
        title: const Text('プロフィール'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: _profileData != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            _profileData!['login_user_profile']['iconimage'],
                          ),
                          radius: 40, // アイコンの半径を小さくする
                        ),
                        SizedBox(width: 20), // アイコンと名前の間隔を設定
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _profileData!['login_user_profile']['name'],
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              '@${_profileData!['login_user_profile']['user_id']}',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                        Spacer(), // 編集ボタンを右端に配置するためのスペーサー
                        ElevatedButton(
                          onPressed: _editProfile, // 編集ボタンが押された時の処理
                          child: Icon(Icons.edit),
                        ),
                      ],
                    ),
                    SizedBox(height: 20), // 余白を追加
                    Text(
                      '${_profileData!['login_user_profile']['profile']}',
                      textAlign: TextAlign.start, // 左詰めに設定
                    ),
                  ],
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
