import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'app.dart';
import 'register_page.dart';
import 'setting/password_reset.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;

  TextEditingController emailController =
      TextEditingController();
  TextEditingController passwordController =
      TextEditingController();
  //TextEditingController emailController = TextEditingController();
  //TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context, email, password) async {
    try {
      final response =
          await httpPost('token/', {'email': email, 'password': password});
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', response['access'] as String);
      await prefs.setString('refresh_token', response['refresh'] as String);
      final loginUserDataResponse =
          await httpGet('login-user-profile/', jwt: true);
      //print(loginUserDataResponse);
      //print(loginUserDataResponse['login_user_profile']['iconimage']);
      await prefs.setString('login_user_name',
          loginUserDataResponse['login_user_profile']['name'] as String);
      await prefs.setString('login_user_iconimage',
          loginUserDataResponse['login_user_profile']['iconimage'] as String);
      await prefs.setString('login_user_id',
          loginUserDataResponse['login_user_profile']['user_id'] as String);
      await prefs.setInt('login_user_number',
          loginUserDataResponse['login_user_profile']['user_number'] as int);

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => AppPage(),
      ));
    } catch (error) {
      print('Error logging in: $error');
    }
  }

  _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'このURLにはアクセスできません';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('yalkeyログイン')),
        body: SingleChildScrollView(
            child: Form(
          key: _formKey,
          //①：formのkeyプロパティにオブジェクトを持たせる。ここ以下のWidgetを管理できるようになる
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: AutofillGroup(
                    child: Column(children: [
                  Padding(
                      padding: const EdgeInsets.all(5.0), //マージン
                      child: TextFormField(
                        controller: emailController,
                        autofillHints: const [AutofillHints.email],
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '必須です';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: "メールアドレス",
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
                        autofillHints: const [AutofillHints.password],
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '必須です';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "パスワード",
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
                      padding: const EdgeInsets.all(10.0), //マージン
                      child: ElevatedButton(
                        onPressed: () {
                          TextInput.finishAutofillContext();
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ログイン中...')),
                            );
                            login(context, emailController.text,
                                passwordController.text);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFAE0103),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      )),
                  const Padding(
                    padding: EdgeInsets.all(10.0), //マージン
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
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFAE0103),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          '無料で始める',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(10.0), //マージン
                    child: RichText(
                        text: TextSpan(children: [
                      const TextSpan(
                        text: 'パスワードを忘れた方は',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextSpan(
                          text: 'こちら',
                          style: const TextStyle(color: Color(0xFFAE0103)),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _launchInBrowser("https://yalkey.com/password-reset/");
                            }),
                    ])),
                  ),
                ])))
          ]),
        )));
  }
}
