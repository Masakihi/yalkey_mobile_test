import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../login_page.dart';

class DeactivateAccountDonePage extends StatefulWidget {
  const DeactivateAccountDonePage({super.key});

  @override
  _DeactivateAccountDonePageState createState() => _DeactivateAccountDonePageState();
}

class _DeactivateAccountDonePageState extends State<DeactivateAccountDonePage> {

  Future<void> logout(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => LoginPage()), (_) => false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('退会完了')),
        body: SingleChildScrollView(
            child: Column(children: [
              Text('退会が完了しました。もし機会があれば再度登録いただけると幸いです'),
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
