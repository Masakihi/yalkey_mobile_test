import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yalkey_0206_test/setting/password_update_done.dart';
import '../api.dart';
import '../app.dart';
import '../login_page.dart';

class PasswordUpdatePage extends StatefulWidget {
  const PasswordUpdatePage({super.key});

  @override
  _PasswordUpdatePageState createState() => _PasswordUpdatePageState();
}

class _PasswordUpdatePageState extends State<PasswordUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  bool passwordsMatch = true;

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController newPasswordController2nd = TextEditingController();

  Future<void> logout(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => LoginPage()), (_) => false);
  }

  Future<void> passwordUpdate(
      BuildContext context, oldPassword, newPassword, newPassword2nd) async {
    try {
      final response = await httpPost('password-change/', {
        'old_password': oldPassword,
        'new_password1': newPassword,
        'new_password2': newPassword2nd
      });
    } catch (error) {
      print('Error password update: $error');
    }
  }

  void checkPasswordsMatch() {
    if (newPasswordController.text != newPasswordController2nd.text) {
      setState(() {
        passwordsMatch = false;
      });
    } else {
      setState(() {
        passwordsMatch = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('パスワードの更新')),
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
                    child: Text("変更前後のパスワードを以下に入力してください。"),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(5.0), //マージン
                      child: TextFormField(
                        obscureText: _isObscure,
                        controller: oldPasswordController,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '必須です';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "現在のパスワード",
                          hintText: "ここにパスワードを入力",
                          suffixIcon: IconButton(
                            icon: Icon(_isObscure
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
                          /*
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red, width: 2)
                              ),
                              */
                        ),
                      )),
                  Padding(
                      padding: const EdgeInsets.all(5.0), //マージン
                      child: TextFormField(
                        obscureText: _isObscure,
                        controller: newPasswordController,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'パスワードは必須です';
                          }
                          if (value!.length <= 7) {
                            return 'パスワードは8文字以上の半角英数字で設定してください';
                          }
                          if (1000 < value.length) {
                            return 'パスワードは1000文字以下で設定してください';
                          }
                          bool passwordValid =
                          RegExp(r"^[a-zA-Z0-9]{8,}").hasMatch(value);
                          if (!passwordValid) {
                            return 'パスワードは8文字以上の半角英数字で設定してください';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "新しいパスワード",
                          hintText: "ここにパスワードを入力",
                          suffixIcon: IconButton(
                            icon: Icon(_isObscure
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
                          /*
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red, width: 2)
                              ),
                              */
                        ),
                      )),
                  Padding(
                      padding: const EdgeInsets.all(5.0), //マージン
                      child: TextFormField(
                        obscureText: _isObscure,
                        controller: newPasswordController2nd,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '必須です';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "新しいパスワード（確認用、再入力してください）",
                          hintText: "もう一度入力してください",
                          errorText: passwordsMatch ? null : 'パスワードが一致しません',
                          suffixIcon: IconButton(
                            icon: Icon(_isObscure
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
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
                          checkPasswordsMatch();
                          if (passwordsMatch) {
                            //③：formの内容をバリデート(検証)して送信するためのボタンを設置する
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('パスワード更新中...')),
                              );
                              passwordUpdate(
                                  context,
                                  oldPasswordController.text,
                                  newPasswordController.text,
                                  newPasswordController2nd.text);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (
                                      context) => const PasswordUpdateDonePage(),
                                ),
                              );
                            }
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
