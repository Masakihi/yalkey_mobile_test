import 'package:flutter/material.dart';
import 'constant.dart';


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
        body:
        Column(
          children: <Widget>[
            if (loading) Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16.0),
              child: const CircularProgressIndicator(
                strokeWidth: 3.0,
              ),
            ),
            if (!loading)...[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('・目標タイトル：${goalData?.goalText}'),
                    Text('・目的：${goalData?.purpose}'),
                    Text('・目標達成時に得られるもの：${goalData?.benefit}'),
                    Text('・目標達成できなかった場合の損失：${goalData?.loss}'),
                    Text('・メモ：${goalData?.note}'),
                    Text('・期限：${goalData?.deadline.toString().substring(0, 10)} ${goalData?.deadline.toString().substring(11, 16)}'),
                    Text('・目標作成日時：${goalData?.dateCreated.toString().substring(0, 10)} ${goalData?.dateCreated.toString().substring(11, 16)}'),
                  ],
                ),),
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
                onPressed: () {
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
              ),            ]],
        ));
  }
}

