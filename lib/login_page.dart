import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yalkey_0206_test/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'app.dart';
import 'register_page.dart';
import 'password_reset.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;


  TextEditingController emailController = TextEditingController(text: 'molcar@yalkey.com');
  TextEditingController passwordController = TextEditingController(text: 'hogehoge');
  //TextEditingController emailController = TextEditingController();
  //TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context, email, password) async {
    try {
      //final response = await httpPost('token/', {'email': 'molcar@yalkey.com', 'password': 'hogehoge'});
      final response = await httpPost('token/', {'email': email, 'password': password});
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', response['access'] as String);
      await prefs.setString('refresh_token', response['refresh'] as String);
      print('loginしました');
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AppPage(),
      ));
    } catch (error) {
      print('Error logging in: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Login')),
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
                        padding: const EdgeInsets.all(5.0), //マージン
                        child: TextFormField(
                          obscureText: _isObscure,
                          controller: passwordController,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return '必須です';
                              }
                              return null;
                            },
                          decoration: InputDecoration(
                              labelText: "Password",
                              hintText: "ここにパスワードを入力",
                            suffixIcon: IconButton(
                              icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
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
                              //③：formの内容をバリデート(検証)して送信するためのボタンを設置する
                              if (_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('ログイン中...')),
                                );
                                print(emailController.text);
                                print(passwordController.text);
                                login(context, emailController.text, passwordController.text);
                              }
                            },
                            child: const Text(
                              'Login',
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
                      Padding(
                        padding: const EdgeInsets.all(5.0), //マージン
                        child: RichText(
                            text: TextSpan(children: [
                              const TextSpan(
                                  text: 'パスワードを忘れた方は',
                              ),
                              TextSpan(
                                  text: 'こちら',
                                  style: const TextStyle(color: Colors.red),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const PasswordResetPage(),
                                        ),
                                      );
                                    }),
                            ])),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(5.0), //マージン
                          child: Text("アカウントをお持ちでない方は\n以下から新規登録できます"),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(10.0), //マージン
                          child: ElevatedButton(
                            //onPressed: () => login(context),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterPage(),
                                ),
                              );
                            },
                            child: const Text(
                              '無料で始める',
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
