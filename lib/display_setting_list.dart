import 'package:flutter/material.dart';
import 'account_setting_list.dart';
import 'theme_setting.dart';


class DisplaySettingListPage extends StatefulWidget {
  const DisplaySettingListPage({Key? key}) : super(key: key);

  @override
  _DisplaySettingListPageState createState() => _DisplaySettingListPageState();
}


class _DisplaySettingListPageState extends State<DisplaySettingListPage> {


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('表示設定'),
      ),
      body: Container(
        width: double.infinity,
        child: ListView(
          children: <Widget>[
            ListTile(
              //leading: Icon(Icons.map),
              title: Text('(調整中...)ダークテーマとライトテーマの手動切り替え'),
              onTap: () {
                /*
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ThemeSettingPage(),
                  ),
                );
              */
              },
            ),
          ],
        ),
      ),
    );
  }
}

