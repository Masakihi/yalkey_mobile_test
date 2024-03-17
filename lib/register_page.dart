import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yalkey_0206_test/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'app.dart';
import 'login_page.dart';
import 'register_page_next.dart';
import 'dart:io';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>(); //①：定義
  bool _isObscure = true;
  bool _isPrivate = false;
  bool _isAgreed = false;
  bool passwordsMatch = true;
  File? _iconImage;

  //TextEditingController emailController = TextEditingController(text: 'molcar@yalkey.com');
  //TextEditingController passwordController = TextEditingController(text: 'hogehoge');
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordController2nd = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController userIDController = TextEditingController();
  TextEditingController userProfileController = TextEditingController();
  String userIdError = '';
  String emailError = '';
  bool hasError = false;

  Future<void> _getImages() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _iconImage = File(pickedFile.path);
      });
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

  Future<void> logout(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => LoginPage()), (_) => false);
  }

  Future<void> register(BuildContext context, data) async {
    try {
      setState(() => {userIdError = '', emailError = '', hasError = true});
      //final response = await httpPost('token/', {'email': 'molcar@yalkey.com', 'password': 'hogehoge'});

      //print(image.path);
      final response = await httpPost('user-create/', data);
      logResponse(response);
      if (response == 201) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const RegisterNextPage()));
        return;
      }
      if (response['profile_form_error']["user_id"]?.length > 0) {
        response['profile_form_error']["user_id"]?.forEach(
            (errorText) => {setState(() => userIdError += '$errorText\n')});
        setState(() => hasError = true);
      }
      if (response['user_form_error']["email"]?.length > 0) {
        response['user_form_error']["email"]?.forEach(
            (errorText) => {setState(() => emailError += '$errorText\n')});
        setState(() => hasError = true);
      }
      if (!hasError) {
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登録エラー：フォームを確認してください')),
        );
      }
    } catch (error) {
      print('Error logging in: $error');
    }
  }

  void checkPasswordsMatch() {
    if (passwordController.text != passwordController2nd.text) {
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
        appBar: AppBar(title: const Text('無料ユーザー登録')),
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
                    child: Text("登録ボタンを押すと入力したメールアドレス宛てに確認用のリンクが送られます。"),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(5.0), //マージン
                      child: TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'メールアドレスは必須です';
                          }
                          if (500 < value!.length) {
                            return 'メールアドレスは500文字以下で入力してください';
                          }
                          bool emailValid = RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value);
                          if (!emailValid) {
                            return '正規のメールアドレスを入力してください';
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
                  if (emailError != '')
                    Text(
                      emailError,
                      style: TextStyle(color: Colors.red),
                    ),
                  Padding(
                      padding: const EdgeInsets.all(5.0), //マージン
                      child: TextFormField(
                        obscureText: _isObscure,
                        controller: passwordController,
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
                          labelText: "パスワード（必須）",
                          hintText: "半角英数字8文字以上",
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
                        controller: passwordController2nd,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '確認用パスワードは必須です';
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
                          labelText: "パスワード（確認用、必須）",
                          hintText: "パスワードをもう一度入力してください",
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
                      padding: const EdgeInsets.all(5.0), //マージン
                      child: TextFormField(
                        controller: userNameController,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '表示名は必須です';
                          }
                          if (15 < value!.length) {
                            return '表示名は15文字以下で設定してください';
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
                        controller: userIDController,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'ユーザーIDは必須です';
                          }
                          if (value!.length <= 4) {
                            return 'ユーザーIDは8文字以上の半角英数字で設定してください';
                          }
                          if (30 < value.length) {
                            return 'ユーザーIDは30文字以下で設定してください';
                          }
                          bool userIdValid =
                              RegExp(r"^[a-zA-Z0-9_]").hasMatch(value);
                          if (!userIdValid) {
                            return 'ユーザーIDは8文字以上の半角英数字またはアンダーバーで設定してください';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "ユーザーID（必須、後から変更不可）",
                          hintText: "半角英数字8文字以上。アンダーバー(_)も可",
                          /*
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red, width: 2)
                              ),
                              */
                        ),
                      )),
                  if (userIdError != '')
                    Text(
                      userIdError,
                      style: TextStyle(color: Colors.red),
                    ),
                  Padding(
                      padding: const EdgeInsets.all(5.0), //マージン
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        controller: userProfileController,
                        validator: (value) {
                          if (value != null && 1000 < value.length) {
                            return 'プロフィールは1000文字以下で設定してください';
                          }
                          return null;
                        },
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
                  SizedBox(height: 20.0),
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: _isPrivate,
                        onChanged: (value) {
                          setState(() {
                            _isPrivate = value!;
                          });
                        },
                      ),
                      Text('投稿を非公開にする'),
                    ],
                  ),
                  /*
                      TextButton(
                        onPressed: _getImages,
                        child: const Text('アイコン画像を選択'),
                      ),
                      const SizedBox(height: 16.0),
                      if(_iconImage != null) Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.file(
                        _iconImage!,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                       */
                  SizedBox(height: 40.0),
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: _isAgreed,
                        onChanged: (value) {
                          setState(() {
                            _isAgreed = value!;
                          });
                        },
                      ),
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: '利用規約',
                            style: const TextStyle(color: Color(0xFFAE0103)),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _launchInBrowser(
                                    "https://yalkey.net/ja/terms-of-use/");
                              }),
                        TextSpan(
                          text: 'に同意する',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ])),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Padding(
                      padding: const EdgeInsets.all(10.0), //マージン
                      child: ElevatedButton(
                        //onPressed: () => login(context),
                        onPressed: _isAgreed
                            ? () {
                                checkPasswordsMatch();
                                if (passwordsMatch) {
                                  if (_formKey.currentState!.validate()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('登録確認中...')),
                                    );
                                    //print(emailController.text);
                                    //print(passwordController.text);
                                    //print(userIDController.text);
                                    //print(userNameController.text);
                                    //print(userProfileController.text);
                                    //print(_isPrivate);
                                    // print(_iconImage);

                                    var data = {
                                      'email': emailController.text,
                                      'password': passwordController.text,
                                      // 'password': '',
                                      'name': userNameController.text,
                                      'user_id': userIDController.text,
                                      'profile': userProfileController.text,
                                      'private': _isPrivate,
                                    };

                                    register(context, data);
                                  }
                                }
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('利用規約に同意してください')),
                                );
                              },
                        child: const Text(
                          '登録',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isAgreed ? const Color(0xFFAE0103) : Colors.grey,
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
