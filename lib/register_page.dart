import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yalkey_0206_test/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'app.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();//①：定義
  bool _isObscure = true;


  //TextEditingController emailController = TextEditingController(text: 'molcar@yalkey.com');
  //TextEditingController passwordController = TextEditingController(text: 'hogehoge');
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordController2nd = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController userIDController = TextEditingController();
  TextEditingController userProfileController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('ユーザー登録')),
        body: SingleChildScrollView(
    child:
        Form(
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
                              labelText: "メールアドレス（必須）",
                              hintText: "example@yalkey.com",
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
                              labelText: "パスワード（必須）",
                              hintText: "半角英数字8文字以上",
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
                          padding: const EdgeInsets.all(5.0), //マージン
                          child: TextFormField(
                            obscureText: _isObscure,
                            controller: passwordController2nd,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return '必須です';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "パスワード（確認用、必須）",
                              hintText: "パスワードをもう一度入力してください",
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
                          padding: const EdgeInsets.all(5.0), //マージン
                          child: TextFormField(
                            obscureText: _isObscure,
                            controller: userNameController,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return '必須です';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "表示名（必須）",
                              hintText: "（例）通りすがりのユーザー",
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
                            controller: userIDController,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return '必須です';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "ユーザーID（必須）",
                              hintText: "半角英数字6文字以上",
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
                            keyboardType: TextInputType.multiline,
                            maxLines: 3,
                            controller: userProfileController,
                            decoration: InputDecoration(
                              labelText: "プロフィール",
                              hintText: "ここにプロフィールを入力",
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
                                  const SnackBar(content: Text('登録確認中...')),
                                );
                                //print(emailController.text);
                                //print(passwordController.text);
                                //login(context, emailController.text, passwordController.text);
                              }
                            },
                            child: const Text(
                              '登録',
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
