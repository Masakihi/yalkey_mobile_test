import 'package:flutter/material.dart';
import 'account_setting_list.dart';
import 'display_setting_list.dart';



class ThemeSettingPage extends StatefulWidget {
  const ThemeSettingPage({Key? key}) : super(key: key);

  @override
  _ThemeSettingPageState createState() => _ThemeSettingPageState();
}


class _ThemeSettingPageState extends State<ThemeSettingPage> {


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('テーマの切り替え'),
      ),
      body: Container(
        width: double.infinity,
        child: ListView(
          children: <Widget>[
            ListTile(
              //leading: Icon(Icons.map),
              title: Text('アカウント'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountSettingListPage(),
                  ),
                );
              },
            ),
            ListTile(
              //leading: Icon(Icons.photo_album),
              title: Text('表示'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DisplaySettingListPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

