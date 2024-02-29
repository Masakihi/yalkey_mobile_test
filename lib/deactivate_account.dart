import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'app.dart';
import 'login_page.dart';

class DeactivateAccountPage extends StatefulWidget {
  const DeactivateAccountPage({super.key});

  @override
  _DeactivateAccountPageState createState() => _DeactivateAccountPageState();
}

class _DeactivateAccountPageState extends State<DeactivateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;


  Future<void> logout(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),(_) => false);
  }


  Future<void> deactivateUser(context) async {
    try {
      final response = await httpPost('deactivate/', {'email': 'email'});
    } catch (error) {
      print('Error deactivate: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('退会')),
        body: SingleChildScrollView(
            child:Form(
              key: _formKey,
              //①：formのkeyプロパティにオブジェクトを持たせる。ここ以下のWidgetを管理できるようになる
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0), //マージン
                            child: Text("退会後はデータは復元できませんが、本当によろしいですか？"),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(10.0), //マージン
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('メール送信中...')),
                                  );
                                  deactivateUser(context);
                                  logout(context);
                                },
                                child: const Text(
                                  '本当に退会する',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFAE0103),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              )),
                        ]))
                  ]),)));
  }
}
