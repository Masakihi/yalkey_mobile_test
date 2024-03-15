import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yalkey_0206_test/setting/email_update_done.dart';
import '../api.dart';
import '../app.dart';
import '../login_page.dart';

class EmailUpdatePage extends StatefulWidget {
  const EmailUpdatePage({super.key});

  @override
  _EmailUpdatePageState createState() => _EmailUpdatePageState();
}

class _EmailUpdatePageState extends State<EmailUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;

  TextEditingController emailController = TextEditingController();

  Future<void> logout(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => LoginPage()), (_) => false);
  }

  Future<void> emailChange(BuildContext context, email) async {
    try {
      final response = await httpPost('email-change/', {'email': email});
    } catch (error) {
      print('Email change error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('メールアドレスの更新')),
        body: SingleChildScrollView(
            child: Form(
          key: _formKey,
          //①：formのkeyプロパティにオブジェクトを持たせる。ここ以下のWidgetを管理できるようになる
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0), //マージン
                    child: Text(
                        "変更後のメールアドレスを以下に入力してください。更新ボタンを押すと入力したメールアドレス宛てに再設定用のリンクが送られます。メール内のリンクをクリックした後、再度ログインしてください。"),
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
                              const SnackBar(content: Text('更新用メール送信中...')),
                            );
                            print(emailController.text);
                            emailChange(context, emailController.text);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EmailUpdateDonePage(),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          '更新',
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
          ]),
        )));
  }
}
