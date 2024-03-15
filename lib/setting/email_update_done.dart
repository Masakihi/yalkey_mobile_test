import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../login_page.dart';

class EmailUpdateDonePage extends StatefulWidget {
  const EmailUpdateDonePage({super.key});

  @override
  _EmailUpdateDonePageState createState() => _EmailUpdateDonePageState();
}

class _EmailUpdateDonePageState extends State<EmailUpdateDonePage> {

  Future<void> logout(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => LoginPage()), (_) => false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('確認メール送信')),
        body: SingleChildScrollView(
            child: Column(children: [
              Text('新しいメールアドレス宛てに再設定用のリンクを送信しました。メール内のリンクをクリックした後、アプリを再度開いてログインしてください。メールが見当たらない場合は迷惑メールフォルダをご確認ください'),
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
