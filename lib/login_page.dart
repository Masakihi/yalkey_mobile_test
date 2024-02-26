import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yalkey_0206_test/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'app.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController =
      TextEditingController(text: 'molcar@yalkey.com');
  TextEditingController passwordController =
      TextEditingController(text: 'hogehoge');

  Future<void> login(BuildContext context) async {
    try {
      final response = await httpPost(
          'token/', {'email': 'molcar@yalkey.com', 'password': 'hogehoge'});
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
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'email')),
              TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password')),
              ElevatedButton(
                onPressed: () => login(context),
                child: const Text('Login'),
              )
            ])));
  }
}
