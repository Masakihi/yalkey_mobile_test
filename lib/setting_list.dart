import 'package:flutter/material.dart';
import 'account_setting_list.dart';
import 'display_setting_list.dart';


class SettingListPage extends StatefulWidget {
  const SettingListPage({Key? key}) : super(key: key);

  @override
  _SettingListPageState createState() => _SettingListPageState();
}


class _SettingListPageState extends State<SettingListPage> {


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('設定'),
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

