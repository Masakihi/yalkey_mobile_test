import 'package:flutter/material.dart';
import '../api.dart';
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
          title: const Text('ミッション削除'),
        ),
        body: Container(
            width: double.infinity, //横幅いっぱいを意味する
            // color: Colors.red, //広がっているか色をつけて確認
            child:
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
                        Text(
                          '以下のミッションを削除します。ミッション達成の記録も全て削除されますが、よろしいですか？',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 12.0),
                        Text('・ミッションタイトル：${missionData?.missionText}'),

                        if (missionData?.reward!="" && missionData?.reward!=null) Text('・ご褒美：${missionData?.reward}'),
                        if (missionData?.penalty!="" && missionData?.penalty!=null) Text('・ペナルティ：${missionData?.penalty}'),
                        Text('・開始日時：${missionData?.starTime.toString().substring(0, 10)} ${missionData?.starTime.toString().substring(11, 16)}'),
                        if (missionData?.opportunity!="" && missionData?.opportunity!=null) Text('・きっかけ：${missionData?.opportunity}'),
                        if (missionData?.note!="" && missionData?.note!=null) Text('・メモ：${missionData?.note}'),

                        Text('・ミッション作成日時：${missionData?.dateCreated.toString().substring(0, 10)} ${missionData?.dateCreated.toString().substring(11, 16)}'),
                        if (missionData?.parentMission!=null) Text('・親ミッション：${missionData?.parentMission}'),
                        Text('・親？子？：${missionData?.missionParentType}'),
                        Text('・所要時間：${missionData?.requiredTime}'),
                        if (missionData?.penalty!=null) Text('・優先度：${missionData?.penalty}'),

                        // Text('・繰り返しパターン：${missionData?.repeatType}'),

                        if (missionData?.repeatType==0) ...[
                          Text('・繰り返しパターン：繰り返しなし'),
                        ],

                        if (missionData?.repeatType==1) ...[
                          Text('・繰り返しパターン：${missionData?.repeatInterval}日'),
                          Text('・繰り返し曜日：${missionData?.repeatDayWeek}'),
                        ],

                        if (missionData?.repeatType==2) ...[
                          Text('・繰り返しパターン：${missionData?.repeatInterval}週'),
                          Text('・繰り返し曜日：${missionData?.repeatDayWeek}'),
                        ],

                        if (missionData?.repeatType==3) ...[
                          Text('・繰り返しパターン：${missionData?.repeatInterval}月'),
                          Text('・繰り返し曜日：${missionData?.repeatDayWeek}'),
                        ],

                        if (missionData?.repeatType==4) ...[
                          Text('・繰り返しパターン：${missionData?.repeatInterval}年'),
                          Text('・繰り返し曜日：${missionData?.repeatDayWeek}'),
                        ],

                        if (missionData?.repeatStopType==0) ...[
                          Text('・繰り返し終了条件：指定なし'),
                        ],

                        if (missionData?.repeatStopType==1) ...[
                          Text('・繰り返し終了条件：終了日を指定'),
                          Text('・繰り返し終了日：${missionData?.repeatStopDate}'),
                        ],

                        if (missionData?.repeatStopType==2) ...[
                          Text('・繰り返し終了条件：回数を指定'),
                          Text('・繰り返し回数：${missionData?.repeatNumber}回'),
                        ],



                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
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
                              int count = 0;
                              Navigator.popUntil(context, (_) => count++ >= 2);
                              await httpDelete('mission/delete/${missionNumber}', jwt: true);
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
                    ),
                  )
                ]
              ],
            )
        )
    );
  }
}
