import 'package:flutter/material.dart';
import 'mission_model.dart';

class MissionDeletePage extends StatefulWidget {
  // 画面遷移元からのデータを受け取る変数
  final int value;
  const MissionDeletePage({Key? key, required this.value}) : super(key: key);

  @override
  _MissionDeletePageState createState() => _MissionDeletePageState();
}

class _MissionDeletePageState extends State<MissionDeletePage> {
  // 状態を管理する変数
  late int missionNumber;
  Mission? missionData;
  bool loading = false; // データをロード中かどうかを示すフラグ

  @override
  void initState() {
    super.initState();
    // 受け取ったデータを状態を管理する変数に格納
    missionNumber = widget.value;
    _fetchMissionData();
  }

  Future<void> _fetchMissionData() async {
    setState(() {
      loading = true; // データのロード中フラグをtrueに設定
    });

    MissionResponse missionResponse =
        await MissionResponse.fetchMissionResponse(missionNumber);
    if (mounted) {
      setState(() {
        missionData = missionResponse.mission; // 新しいデータをリストに追加
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
          title: const Text('Mission削除'),
        ),
        body: Column(
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
                    Text(
                      '以下のミッションを削除します。ミッション達成の記録も全て削除されますが、よろしいですか？',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 12.0),
                    Text('・ミッションタイトル：${missionData?.missionText}'),
                    Text('・ご褒美：${missionData?.reward}'),
                    Text('・ペナルティ：${missionData?.penalty}'),
                    Text(
                        '・開始日時：${missionData?.starTime.toString().substring(0, 10)} ${missionData?.starTime.toString().substring(11, 16)}'),
                    Text(
                        '・終了日時：${missionData?.endTime.toString().substring(0, 10)} ${missionData?.endTime.toString().substring(11, 16)}'),
                    Text('・きっかけ：${missionData?.opportunity}'),
                    Text('・メモ：${missionData?.note}'),
                    Text(
                        '・ミッション作成日時：${missionData?.dateCreated.toString().substring(0, 10)} ${missionData?.dateCreated.toString().substring(11, 16)}'),
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
              ),
            ]
          ],
        ));
  }
}
