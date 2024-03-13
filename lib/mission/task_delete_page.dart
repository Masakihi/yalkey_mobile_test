import 'package:flutter/material.dart';
import '../api.dart';
import 'task_page.dart';

class TaskDeletePage extends StatefulWidget {
  // 画面遷移元からのデータを受け取る変数
  final int value;
  const TaskDeletePage({Key? key, required this.value}) : super(key: key);

  @override
  _TaskDeletePageState createState() => _TaskDeletePageState();
}

class _TaskDeletePageState extends State<TaskDeletePage> {
  // 状態を管理する変数
  late int mission_number;
  Future<dynamic>? _missionData;

  @override
  void initState() {
    super.initState();
    // 受け取ったデータを状態を管理する変数に格納
    mission_number = widget.value;
    _fetchMissionData();
  }

  Future<void> _fetchMissionData() async {
    try {
      final Future<dynamic> response =
          httpGet('mission/detail/${mission_number}', jwt: true);
      setState(() {
        _missionData = response;
      });
    } catch (error) {
      print('Error fetching mission data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Mission Delete'),
        ),
        body: FutureBuilder(
          future: _missionData,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            final mission = snapshot.data;

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('エラーが発生しました'));
            } else {
              return Column(
                children: <Widget>[
                  //Text('${mission["mission_text"]}'),
                  Text('・ミッションタイトル：${mission["mission_text"]}'),
                  Text('・開始日：${mission["start_time"]}'),
                  Text('・終了日：${mission["opportunity"]}'),
                  Text("↑このミッションを削除します。この動作は取り消せません。本当によろしいですか？"),
                  ElevatedButton(
                    onPressed: () {
                      int count = 0;
                      Navigator.popUntil(context, (_) => count++ >= 2);
                    },
                    child: const Text(
                      'Delete',
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
                  ),
                ],
              );
            }
          },
        ));
  }
}
