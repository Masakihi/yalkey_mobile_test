import 'package:flutter/material.dart';
import 'package:yalkey_0206_test/home_page.dart';
import 'package:yalkey_0206_test/login_page.dart';
import 'app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

// [StatefulWidget]を使う場合
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // accessTokenを取得する
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var accessToken = prefs.getString('access_token');
  var refreshToken = prefs.getString('refresh_token');
  if (true) {
    final response =
        await httpPost('token/refresh/', {'refresh': refreshToken});
    accessToken = response['access'];
    if (accessToken != null) {
      prefs.setString('access_token', accessToken);
    }
  }
  runApp(MyApp(token: accessToken));
}

class MyApp extends StatelessWidget {
  final String? token; // main()で取得したtokenを受け取る

  const MyApp({Key? key, this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'yalkey mobile',
      theme: ThemeData(
        colorSchemeSeed:const Color(0xFFAE0103),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed:const Color(0xFFAE0103),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.dark,
      home: token == null
          ? LoginPage()
          : AppPage(), // tokenがあればHomePage、なければLoginPageを表示
    );
  }
}
