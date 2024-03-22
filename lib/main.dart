import 'package:flutter/material.dart';
import 'package:yalkey_0206_test/home_page.dart';
import 'package:yalkey_0206_test/login_page.dart';
import 'app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';

// [StatefulWidget]を使う場合
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await FlutterDownloader.initialize();
  }
  initializeDateFormatting('jp');
  WidgetsFlutterBinding.ensureInitialized();
  // accessTokenを取得する
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var accessToken = prefs.getString('access_token');
  var refreshToken = prefs.getString('refresh_token');
  var loginUserIconImage = prefs.getString('login_user_iconimage');

  // // ネットワーク接続状態を取得
  //var connectivityResult = await Connectivity().checkConnectivity();


  // // オフラインの場合はアプリを終了
  // if (connectivityResult == ConnectivityResult.none) {
  //   runApp(MaterialApp(
  //     builder: (context, child) => AlertDialog(
  //       title: const Text('ネットワーク接続エラー'),
  //       content: const Text('ネットワークに接続していません。アプリを終了します。'),
  //       actions: [
  //         ElevatedButton(
  //           onPressed: () => exit(0),
  //           child: const Text('終了'),
  //         ),
  //       ],
  //     ),
  //   ));
  //   return;
  // }

  if (true) {
    final response =
        await httpPost('token/refresh/', {'refresh': refreshToken});
    accessToken = response['access'];
    if (accessToken != null) {
      prefs.setString('access_token', accessToken);
    }
  }
  runApp(MyApp(token: accessToken, loginUserIconImage: loginUserIconImage));
}

class MyApp extends StatelessWidget {
  final String? token; // main()で取得したtokenを受け取る
  final String? loginUserIconImage;

  const MyApp({Key? key, this.token, this.loginUserIconImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'yalkey mobile',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFAE0103),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFFAE0103),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.dark,
      home: token == null
          ? LoginPage()
          : AppPage(), // tokenがあればHomePage、なければLoginPageを表示
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ja', ''),
        Locale('en', ''),
        const Locale.fromSubtags(languageCode: 'zh'), // generic Chinese 'zh'
        const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hans'), // generic simplified Chinese 'zh_Hans'
        const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant'), // generic traditional Chinese 'zh_Hant'
        const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hans',
            countryCode: 'CN'), // 'zh_Hans_CN'
        const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
            countryCode: 'TW'), // 'zh_Hant_TW'
        const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
            countryCode: 'HK'), // 'zh_Hant_HK'
      ],
    );
  }
}
