import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'app.dart';
import 'login_page.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();


  TextEditingController emailController = TextEditingController();

  Future<void> logout(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),(_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('パスワードのリセット')),
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
                            child: Text("登録済みのメールアドレスを以下に入力してください。パスワードリセットボタンを押すと、入力したメールアドレス宛てに再設定用のリンクが送られます。メール内のリンクをクリックし、新しいパスワードを設定してください。"),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(5.0), //マージン
                              child: TextFormField(
                                controller: emailController,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return '必須です';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: "email",
                                  hintText: "sample@yalkey.com",
                                  /*
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width: 2)
                              ),
                               */
                                ),
                              )),
                          Padding(
                              padding: const EdgeInsets.all(10.0), //マージン
                              child: ElevatedButton(
                                //onPressed: () => login(context),
                                onPressed: () {
                                  //③：formの内容をバリデート(検証)して送信するためのボタンを設置する
                                  if (_formKey.currentState!.validate()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('パスワード再設定用メール送信中...')),
                                    );
                                    logout(context);
                                  }
                                },
                                child: const Text(
                                  'パスワードリセット',
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
