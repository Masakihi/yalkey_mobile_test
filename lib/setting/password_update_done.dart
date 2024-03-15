import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../login_page.dart';

class PasswordUpdateDonePage extends StatefulWidget {
  const PasswordUpdateDonePage({super.key});

  @override
  _PasswordUpdateDonePageState createState() => _PasswordUpdateDonePageState();
}

class _PasswordUpdateDonePageState extends State<PasswordUpdateDonePage> {

  Future<void> logout(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => LoginPage()), (_) => false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('パスワード更新完了')),
        body: SingleChildScrollView(
            child: Column(children: [
              Text('パスワードの更新が完了しました。以下のボタンから再度ログインしてください'),
              SizedBox(height: 40.0),
              ElevatedButton(
                onPressed: () {
                  logout(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAE0103),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'ログイン画面に移動',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
            ])
        ));
  }
}
