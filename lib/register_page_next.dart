import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class RegisterNextPage extends StatefulWidget {
  const RegisterNextPage({super.key});

  @override
  _RegisterNextPageState createState() => _RegisterNextPageState();
}

class _RegisterNextPageState extends State<RegisterNextPage> {

  Future<void> logout(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => LoginPage()), (_) => false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('無料ユーザー登録')),
        body: SingleChildScrollView(
        child: Column(children: [
          Text('確認メールを送信しました。メール内のリンクをクリックした後、アプリを再度開いてログインしてください。メールが見当たらない場合は迷惑メールフォルダをご確認ください'),
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
