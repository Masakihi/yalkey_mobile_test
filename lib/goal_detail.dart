import 'package:flutter/material.dart';
import 'constant.dart';
import 'goal_delete.dart';
import 'goal_update.dart';
import 'mission/task_edit_page.dart';

class GoalDetailPage extends StatefulWidget {
  // 画面遷移元からのデータを受け取る変数
  final int value;
  const GoalDetailPage({Key? key, required this.value}) : super(key: key);

  @override
  _GoalDetailPageState createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends State<GoalDetailPage> {
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
          title: const Text('目標 詳細'),
        ),
        body: SingleChildScrollView(
          child: Column(
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '目標タイトル',
                                  style: const TextStyle(
                                      fontSize: 12.0,
                                      color: const Color(0xFFAE0103)),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  '${goalData?.goalText}',
                                  style: const TextStyle(fontSize: 18.0),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '目的',
                                  style: const TextStyle(
                                      fontSize: 12.0,
                                      color: const Color(0xFFAE0103)),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  '${goalData?.purpose}',
                                  style: const TextStyle(fontSize: 18.0),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '目標達成時に得られるもの',
                                  style: const TextStyle(
                                      fontSize: 12.0,
                                      color: const Color(0xFFAE0103)),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  '${goalData?.benefit}',
                                  style: const TextStyle(fontSize: 18.0),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '目標達成できなかった場合の損失',
                                  style: const TextStyle(
                                      fontSize: 12.0,
                                      color: const Color(0xFFAE0103)),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  '${goalData?.loss}',
                                  style: const TextStyle(fontSize: 18.0),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'メモ',
                                  style: const TextStyle(
                                      fontSize: 12.0,
                                      color: const Color(0xFFAE0103)),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  '${goalData?.note}',
                                  style: const TextStyle(fontSize: 18.0),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '期限',
                                  style: const TextStyle(
                                      fontSize: 12.0,
                                      color: const Color(0xFFAE0103)),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  '${goalData?.deadline.toString().substring(0, 10)} ${goalData?.deadline.toString().substring(11, 16)}',
                                  style: const TextStyle(fontSize: 18.0),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '目標作成日時',
                                  style: const TextStyle(
                                      fontSize: 12.0,
                                      color: const Color(0xFFAE0103)),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  '${goalData?.dateCreated.toString().substring(0, 10)} ${goalData?.dateCreated.toString().substring(11, 16)}',
                                  style: const TextStyle(fontSize: 18.0),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10.0),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GoalUpdatePage(),
                                //builder: (context) => TaskEditPage(value: int.parse('352'))
                              ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFAE0103),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          '編集',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GoalDeletePage(
                                    value:
                                        int.parse('${goalData?.goalNumber}')),
                                //builder: (context) => TaskDeletePage(value: int.parse('352'))
                              ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFAE0103),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          '削除',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ));
  }
}
