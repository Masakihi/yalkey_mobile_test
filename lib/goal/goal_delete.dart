import 'package:flutter/material.dart';
import '../api.dart';
import 'goal_model.dart';

class GoalDeletePage extends StatefulWidget {
  // 画面遷移元からのデータを受け取る変数
  final int value;
  const GoalDeletePage({Key? key, required this.value}) : super(key: key);

  @override
  _GoalDeletePageState createState() => _GoalDeletePageState();
}

class _GoalDeletePageState extends State<GoalDeletePage> {
  // 状態を管理する変数
  late int goalNumber;
  Goal? goalData;
  bool loading = false; // データをロード中かどうかを示すフラグ

  @override
  void initState() {
    super.initState();
    // 受け取ったデータを状態を管理する変数に格納
    goalNumber = widget.value;
    _fetchGoalData();
  }

  Future<void> _fetchGoalData() async {
    setState(() {
      loading = true; // データのロード中フラグをtrueに設定
    });

    GoalResponse goalResponse =
        await GoalResponse.fetchGoalResponse(goalNumber);
    if (mounted) {
      setState(() {
        goalData = goalResponse.goal; // 新しいデータをリストに追加
        loading = false; // データのロード中フラグをfalseに設定
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget loadingWidget(bool loading) {
      if (loading) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16.0),
          child: const CircularProgressIndicator(
            strokeWidth: 3.0,
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('目標削除'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text(
                '以下の目標を削除します。一度削除すると復元できませんが、よろしいですか？',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 12.0),
              if (loading)
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(16.0),
                  child: const CircularProgressIndicator(
                    strokeWidth: 3.0,
                  ),
                ),
              if (!loading) ...[
                ListTile(
                  // leading: Icon(Icons.account_circle),
                  title: Text(
                    '目標タイトル',
                    style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                  subtitle: Text(
                    '${goalData?.goalText}',
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
                ListTile(
                  // leading: Icon(Icons.account_circle),
                  title: Text(
                    '目的',
                    style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                  subtitle: Text(
                    '${goalData?.purpose}',
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
                ListTile(
                  // leading: Icon(Icons.account_circle),
                  title: Text(
                    '目標達成時に得られるもの',
                    style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                  subtitle: Text(
                    '${goalData?.benefit}',
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
                ListTile(
                  // leading: Icon(Icons.account_circle),
                  title: Text(
                    '目標達成できなかった場合の損失',
                    style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                  subtitle: Text(
                    '${goalData?.loss}',
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
                ListTile(
                  // leading: Icon(Icons.account_circle),
                  title: Text(
                    'メモ',
                    style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                  subtitle: Text(
                    '${goalData?.note}',
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
                ListTile(
                  // leading: Icon(Icons.account_circle),
                  title: Text(
                    '期限',
                    style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                  subtitle: Text(
                    '${goalData?.deadline.toString().substring(0, 10)} ${goalData?.deadline.toString().substring(11, 16)}',
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
              ],
              SizedBox(height: 50.0),
              ElevatedButton(
                onPressed: () async {
                  await httpDelete('goal/delete/${goalNumber}/', jwt: true);
                  int count = 0;
                  Navigator.popUntil(context, (_) => count++ >= 2);
                  // ここに削除の処理書く
                },
                child: const Text(
                  '本当に削除する',
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
              SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () {
                  int count = 0;
                  Navigator.popUntil(context, (_) => count++ >= 1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAE0103),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'キャンセル',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),



        /*
        Column(
          children: <Widget>[
            if (loading)
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16.0),
                child: const CircularProgressIndicator(
                  strokeWidth: 3.0,
                ),
              ),
            if (!loading) ...[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('・目標タイトル：${goalData?.goalText}'),
                    Text('・目的：${goalData?.purpose}'),
                    Text('・目標達成時に得られるもの：${goalData?.benefit}'),
                    Text('・目標達成できなかった場合の損失：${goalData?.loss}'),
                    Text('・メモ：${goalData?.note}'),
                    Text(
                        '・期限：${goalData?.deadline.toString().substring(0, 10)} ${goalData?.deadline.toString().substring(11, 16)}'),
                    Text(
                        '・目標作成日時：${goalData?.dateCreated.toString().substring(0, 10)} ${goalData?.dateCreated.toString().substring(11, 16)}'),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  int count = 0;
                  Navigator.popUntil(context, (_) => count++ >= 1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAE0103),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'キャンセル',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await httpDelete('goal/delete/${goalNumber}/', jwt: true);
                  int count = 0;
                  Navigator.popUntil(context, (_) => count++ >= 2);
                  // ここに削除の処理書く
                },
                child: const Text(
                  '本当に削除する',
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
            ]
          ],
        )*/


    );
  }
}
