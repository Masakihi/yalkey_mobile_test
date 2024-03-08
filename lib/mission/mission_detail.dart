import 'package:flutter/material.dart';
import 'mission_model.dart';
import 'task_edit_page.dart';
import 'mission_delete.dart';

class MissionDetailPage extends StatefulWidget {
  // 画面遷移元からのデータを受け取る変数
  final int value;
  const MissionDetailPage({Key? key, required this.value}) : super(key: key);

  @override
  _MissionDetailPageState createState() => _MissionDetailPageState();
}

class _MissionDetailPageState extends State<MissionDetailPage> {
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
          title: const Text('Mission Detail'),
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskEditPage(
                            value: int.parse('${missionData?.missionNumber}')),
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
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MissionDeletePage(
                            value: int.parse('${missionData?.missionNumber}')),
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
            ]
          ],
        ));
  }
}
