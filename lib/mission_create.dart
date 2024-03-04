import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yalkey_0206_test/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'app.dart';
import 'login_page.dart';

class MissionCreatePage extends StatefulWidget {
  const MissionCreatePage({super.key});

  @override
  _MissionCreateState createState() => _MissionCreateState();
}

class _MissionCreateState extends State<MissionCreatePage> {
  final _formKey = GlobalKey<FormState>();//①：定義
  bool _isObscure = true;


  //TextEditingController emailController = TextEditingController(text: 'molcar@yalkey.com');
  //TextEditingController passwordController = TextEditingController(text: 'hogehoge');
  late TextEditingController missionTextController;
  late TextEditingController rewardController;
  late TextEditingController penaltyController;
  late TextEditingController opportunityController;
  late TextEditingController noteController;
  //TextEditingController userProfileController = TextEditingController();
  late DateTime _selectedStartDate;
  late TimeOfDay _selectedStartTime;
  late DateTime _selectedEndDate;
  late TimeOfDay _selectedEndTime;


  @override
  void initState() {
    super.initState();
    missionTextController = TextEditingController();
    rewardController = TextEditingController();
    penaltyController = TextEditingController();
    opportunityController = TextEditingController();
    noteController = TextEditingController();
    _selectedStartDate = DateTime.now();
    _selectedStartTime = TimeOfDay.now();
    _selectedEndDate = DateTime.now();
    _selectedEndTime = TimeOfDay.now();
    // _fetchReportList();
  }



  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedStartDate != null && pickedStartDate != _selectedStartDate)
      setState(() {
        _selectedStartDate = pickedStartDate;
      });
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedStartTime = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );
    if (pickedStartTime != null && pickedStartTime != _selectedStartTime)
      setState(() {
        _selectedStartTime = pickedStartTime;
      });
  }


  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? pickedEndDate = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedEndDate != null && pickedEndDate != _selectedEndDate)
      setState(() {
        _selectedEndDate = pickedEndDate;
      });
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedEndTime = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );
    if (pickedEndTime != null && pickedEndTime != _selectedEndTime)
      setState(() {
        _selectedEndTime = pickedEndTime;
      });
  }



  Future<void> _postMissionData() async {
    try {
      // 日付を文字列に変換
      String formattedStartDate =
          '${_selectedStartDate.year}-${_selectedStartDate.month}-${_selectedStartDate.day}';

      String formattedEndDate =
          '${_selectedEndDate.year}-${_selectedEndDate.month}-${_selectedEndDate.day}';

      // データをAPIに投稿する処理をここに記述
      // テキストデータ
      String missionText = missionTextController.text;
      String reward = rewardController.text;
      String penalty = penaltyController.text;
      String opportunity = opportunityController.text;
      String note = noteController.text;

      // APIに投稿するデータを作成
      var data = {
        'mission_text': missionText,
        'reward': reward,
        'penalty': penalty,
        'opportunity': opportunity,
        'note': note,
        'start_time': formattedStartDate,
        'end_time': formattedEndDate
      };

      print(data);

      // final response = await httpPost('progress-form/', data, jwt: true);


      // 成功メッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ミッションの更新完了しました！'),
        ),
      );

      // ホーム画面に戻る
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AppPage(),
      ));
    } catch (error) {
      // エラーメッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラー: $error'),
        ),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('目標の更新')),
        body: SingleChildScrollView(
            child:
            Form(
              key: _formKey,
              //①：formのkeyプロパティにオブジェクトを持たせる。ここ以下のWidgetを管理できるようになる
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(children: [
                          Padding(
                              padding: const EdgeInsets.all(5.0), //マージン
                              child: TextFormField(
                                controller: missionTextController,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return '必須です';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: "ミッションタイトル",
                                  hintText: "（例）筋トレ",
                                  /*
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width: 2)
                              ),
                               */
                                ),
                              )),
                          Padding(
                              padding: const EdgeInsets.all(5.0), //マージン
                              child: TextFormField(
                                // obscureText: _isObscure,
                                controller: rewardController,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return '必須です';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: "ご褒美",
                                  hintText: "（例）",
                                  /*
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red, width: 2)
                              ),
                              */
                                ),
                              )),
                          Padding(
                              padding: const EdgeInsets.all(5.0), //マージン
                              child: TextFormField(
                                obscureText: _isObscure,
                                controller: penaltyController,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return '必須です';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: "ペナルティ",
                                  hintText: "（例）",
                                  /*
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red, width: 2)
                              ),
                              */
                                ),
                              )),
                          Padding(
                              padding: const EdgeInsets.all(5.0), //マージン
                              child: TextFormField(
                                obscureText: _isObscure,
                                controller: opportunityController,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return '必須です';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: "きっかけ",
                                  hintText: "（例）",
                                  /*
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red, width: 2)
                              ),
                              */
                                ),
                              )),
                          Padding(
                              padding: const EdgeInsets.all(5.0), //マージン
                              child: TextFormField(
                                keyboardType: TextInputType.multiline,
                                maxLines: 3,
                                controller: noteController,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return '必須です';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: "メモ",
                                  hintText: "（例）",
                                  /*
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red, width: 2)
                              ),
                              */
                                ),
                              )),
                          Padding(
                            padding: const EdgeInsets.all(5.0), //マージン
                            child: Text("開始日時"),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => _selectStartDate(context),
                                  child: Text(
                                      'Start Date: ${_selectedStartDate.toString().substring(0, 10)}'),
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: TextButton(
                                  onPressed: () => _selectStartTime(context),
                                  child: Text(
                                      'Start Time: ${_selectedStartTime.format(context)}'),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0), //マージン
                            child: Text("終了日時"),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => _selectEndDate(context),
                                  child: Text(
                                      'End Date: ${_selectedEndDate.toString().substring(0, 10)}'),
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: TextButton(
                                  onPressed: () => _selectEndTime(context),
                                  child: Text(
                                      'End Time: ${_selectedEndTime.format(context)}'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.0),
                          Padding(
                              padding: const EdgeInsets.all(10.0), //マージン
                              child: ElevatedButton(
                                //onPressed: () => login(context),
                                onPressed: () {
                                  //③：formの内容をバリデート(検証)して送信するためのボタンを設置する
                                  if (_formKey.currentState!.validate()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('登録確認中...')),
                                    );
                                    _postMissionData();
                                    // login(context, emailController.text, passwordController.text);
                                    int count = 0;
                                    Navigator.popUntil(context, (_) => count++ >= 4);
                                  }
                                },
                                child: const Text(
                                  'ミッション追加',
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
                              )),
                        ]))
                  ]),)));
  }
}
