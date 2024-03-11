import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yalkey_0206_test/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api.dart';
import '../app.dart';
import '../login_page.dart';

class MissionCreatePage extends StatefulWidget {
  const MissionCreatePage({super.key});

  @override
  _MissionCreateState createState() => _MissionCreateState();
}

class _MissionCreateState extends State<MissionCreatePage> {
  final _formKey = GlobalKey<FormState>(); //①：定義
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

  RepeatSettingData? _repeatSettingData;

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

  void _showRepeatForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 画面の9割を覆うようにする
      builder: (context) {
        return FractionallySizedBox(
          // 画面の9割の高さを調整
          heightFactor: 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20), // 適宜間隔を調整してください
              WeekdaySelector(),
            ],
          ),
        );
      },
    ).then((value) {

    });
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

  Future<void> _postMissionDataRepeat(RepeatSettingData repeatSettingData) async {
    try {
      // 日付を文字列に変換
      String formattedStartDate =
          '${_selectedStartDate.year}-${_selectedStartDate.month}-${_selectedStartDate.day} ${_selectedStartTime.hour}:${_selectedStartTime.minute}';

      String formattedEndDate = formattedStartDate;
          // '${_selectedEndDate.year}-${_selectedEndDate.month}-${_selectedEndDate.day}';

      // データをAPIに投稿する処理をここに記述
      // テキストデータ
      String missionText = missionTextController.text;
      String reward = rewardController.text;
      String penalty = penaltyController.text;
      String opportunity = opportunityController.text;
      String note = noteController.text;

      int repeatType = 0;
      String repeatDayWeek = "";
      int repeatStopType = 0;
      String repeatStopDate = repeatSettingData.endDate.toString().substring(0, 10);

      if (repeatSettingData.isRepeat){
        if (repeatSettingData.repeatOption == "日"){
          repeatType = 1;
        }else if (repeatSettingData.repeatOption == "週"){
          repeatType = 2;
        }else if (repeatSettingData.repeatOption == "月"){
          repeatType = 3;
        }else if (repeatSettingData.repeatOption == "年"){
          repeatType = 4;
        }
      }else{
        repeatType = 0;
      }

      for (bool day in repeatSettingData.selectionList){
        if(day){
          repeatDayWeek = repeatDayWeek +"1";
        }else{
          repeatDayWeek = repeatDayWeek +"0";
        }
      }

      print(repeatSettingData.endCondition);

      if (repeatSettingData.endCondition==EndCondition.none){
        repeatStopType = 0;
      }else if(repeatSettingData.endCondition==EndCondition.endDate){
        repeatStopType = 1;
      }else if(repeatSettingData.endCondition==EndCondition.repeatCount){
        repeatStopType = 2;
      }



      // APIに投稿するデータを作成
      var data = {
        'mission_text': missionText,
        'reward': reward,
        'penalty': penalty,
        'opportunity': opportunity,
        'note': note,
        'start_time': formattedStartDate,
        'end_time': formattedEndDate,
        //'parent_mission': null,
        'mission_parent_type': 0,
        // 'required_time': "0000",
        // 'priority': 2,
        'repeat_type': repeatType,
        'repeat_interval': repeatSettingData.repeatInterval,
        'repeat_stop_type': repeatStopType,
        'repeat_stop_date': repeatStopDate, //repeatSettingData.endDate?.substring(0, 10),
        'repeat_number': repeatSettingData.repeatCount,
        'repeat_day_week': repeatDayWeek,
      };


      print(data);

      final response = await httpPost('mission-form/', data, jwt: true);

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

  Future<void> _postMissionData() async {
    try {
      // 日付を文字列に変換
      String formattedStartDate =
          '${_selectedStartDate.year}-${_selectedStartDate.month}-${_selectedStartDate.day} ${_selectedStartTime.hour}:${_selectedStartTime.minute}';

      String formattedEndDate = formattedStartDate;
      // '${_selectedEndDate.year}-${_selectedEndDate.month}-${_selectedEndDate.day}';

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
        'end_time': formattedEndDate,
        //'parent_mission': null,
        'mission_parent_type': 0,
        // 'required_time': "0000",
        // 'priority': 2,
        'repeat_type': 0,
      };


      print(data);

      final response = await httpPost('mission-form/', data, jwt: true);

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


  void _showRepeatSettingModal(BuildContext context) async {
    final result = await showModalBottomSheet<RepeatSettingData>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return RepeatSetting();
      },
    );

    if (result != null) {
      setState(() {
        _repeatSettingData = result;
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title: const Text('ミッションの追加')),
        body: SingleChildScrollView(
            child: Form(
          key: _formKey,
          //①：formのkeyプロパティにオブジェクトを持たせる。ここ以下のWidgetを管理できるようになる
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    child: Text("取り組む日時"),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => _selectStartDate(context),
                          child: Text(
                              '日付: ${_selectedStartDate.toString().substring(0, 10)}'),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextButton(
                          onPressed: () => _selectStartTime(context),
                          child: Text(
                              '時刻: ${_selectedStartTime.format(context)}'),
                        ),
                      ),
                    ],
                  ),
                  /*
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
                   */
                  SizedBox(height: 16.0),
                  Padding(
                      padding: const EdgeInsets.all(10.0), //マージン
                      child: ElevatedButton(
                        onPressed: () {
                          /*
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true, // モーダルの範囲を縦に伸ばす
                            builder: (BuildContext context) {
                              return RepeatSetting();
                            },
                          );
                           */
                          _showRepeatSettingModal(context);
                        },
                        child: Text('繰り返し設定'),
                      ),),
                  _repeatSettingData != null
                      ? Column(
                    children: [
                      Text('繰り返し: ${_repeatSettingData!.isRepeat}'),
                      Text('繰り返し間隔: ${_repeatSettingData!.repeatInterval}'),
                      Text('繰り返し条件: ${_repeatSettingData!.repeatOption}'),
                      Text('繰り返し終了条件: ${_repeatSettingData!.endCondition}'),
                      if (_repeatSettingData!.endCondition == EndCondition.endDate)
                        Text('繰り返し最終日: ${_repeatSettingData!.endDate}'),
                      if (_repeatSettingData!.endCondition == EndCondition.repeatCount)
                        Text('繰り返し回数: ${_repeatSettingData!.repeatCount}'),
                    ],
                  )
                      : SizedBox(),
                  SizedBox(height: 16.0),
                  Padding(
                      padding: const EdgeInsets.all(10.0), //マージン
                      child: ElevatedButton(
                        //onPressed: () => login(context),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('登録確認中...')),
                            );
                            //_postMissionData();
                            print(missionTextController.text);
                            if (_repeatSettingData != null){
                              print('繰り返し: ${_repeatSettingData!.isRepeat}');
                              _postMissionDataRepeat(_repeatSettingData!);
                            }else{
                              _postMissionData();
                            }

                            // login(context, emailController.text, passwordController.text);
                            // int count = 0;
                            // Navigator.popUntil(context, (_) => count++ >= 1);
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
          ]),
        )));
  }
}



class RepeatSetting extends StatefulWidget {
  @override
  _RepeatSettingState createState() => _RepeatSettingState();
}

class _RepeatSettingState extends State<RepeatSetting> {
  bool _isRepeated = false;
  int _repeatInterval = 1;
  String _repeatOption = '日';
  EndCondition _endCondition = EndCondition.none;
  DateTime _endDate = DateTime.now();
  int _repeatCount = 10;
  List<bool> _selections = List.generate(7, (_) => true);





  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // スクロール可能なビューを作成
      padding: EdgeInsets.all(20),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9, // 画面の90%にする
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '繰り返し設定',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                DropdownButton<int>(
                  value: _repeatInterval,
                  onChanged: (int? value) {
                    setState(() {
                      _repeatInterval = value!;
                    });
                  },
                  items: List.generate(99, (index) => index + 1)
                      .map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _repeatOption,
                  onChanged: (String? value) {
                    setState(() {
                      _repeatOption = value!;
                    });
                  },
                  items: <String>['日', '週', '月', '年']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          Text(value),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // WeekdaySelector(),
                  Wrap(
                  spacing: 4.0, // ボタン間の間隔
                  children: List.generate(7, (index) {
                    return ChoiceChip(
                      label: Text(['月', '火', '水', '木', '金', '土', '日'][index]),
                      selected: _selections[index],
                      onSelected: (selected) {
                        setState(() {
                          _selections[index] = selected;
                        });
                      },
                      backgroundColor: _selections[index] ? const Color(0xFFAE0103) : null,
                      selectedColor: const Color(0xFFAE0103),
                      labelStyle: TextStyle(color: _selections[index] ? Colors.white : const Color(0xFFAE0103)),
                      selectedShadowColor: Colors.transparent, // 選択時の影を非表示にする
                      showCheckmark: false, // チェックマークを非表示にする
                    );
                  }),
                ),
              ],
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text('終了条件'),
            ),
            RadioListTile<EndCondition>(
              title: Text('指定しない'),
              value: EndCondition.none,
              groupValue: _endCondition,
              onChanged: (EndCondition? value) {
                setState(() {
                  _endCondition = value!;
                });
              },
            ),
            RadioListTile<EndCondition>(
              title: Text('終了日'),
              value: EndCondition.endDate,
              groupValue: _endCondition,
              onChanged: (EndCondition? value) {
                setState(() {
                  _endCondition = value!;
                });
              },
              secondary: _endCondition == EndCondition.endDate
                  ? IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (pickedDate != null && pickedDate != _endDate) {
                    setState(() {
                      _endDate = pickedDate;
                    });
                  }
                },
              )
                  : null,
            ),
            RadioListTile<EndCondition>(
              title: Text('繰り返し回数'),
              value: EndCondition.repeatCount,
              groupValue: _endCondition,
              onChanged: (EndCondition? value) {
                setState(() {
                  _endCondition = value!;
                });
              },
              secondary: _endCondition == EndCondition.repeatCount
                  ? SizedBox(
                width: 100,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '回数',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _repeatCount = int.tryParse(value)!;
                    });
                  },
                ),
              )
                  : null,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 保存ボタンの処理を追加
                    _isRepeated = false;
                    final result = RepeatSettingData(
                      isRepeat: _isRepeated,
                      repeatInterval: _repeatInterval,
                      repeatOption: _repeatOption,
                      endCondition: _endCondition,
                      endDate: _endDate,
                      repeatCount: _repeatCount,
                      selectionList: _selections,
                    );
                    print(result);
                    Navigator.pop(context, result);

                  },
                  child: Text('繰り返さない'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 保存ボタンの処理を追加
                    _isRepeated = true;
                    final result = RepeatSettingData(
                        isRepeat: _isRepeated,
                        repeatInterval: _repeatInterval,
                        repeatOption: _repeatOption,
                        endCondition: _endCondition,
                        endDate: _endDate,
                        repeatCount: _repeatCount,
                        selectionList: _selections,
                    );
                    print(result.selectionList);
                    Navigator.pop(context, result);

                  },
                  child: const Text(
                    '繰り返し保存',
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
            ),
          ],
        ),
      ),
    );
  }
}

class WeekdaySelector extends StatefulWidget {
  @override
  _WeekdaySelectorState createState() => _WeekdaySelectorState();
}

class _WeekdaySelectorState extends State<WeekdaySelector> {
  List<bool> _selections = List.generate(7, (_) => true);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4.0, // ボタン間の間隔
      children: List.generate(7, (index) {
        return ChoiceChip(
          label: Text(['月', '火', '水', '木', '金', '土', '日'][index]),
          selected: _selections[index],
          onSelected: (selected) {
            setState(() {
              _selections[index] = selected;
            });
          },
          backgroundColor: _selections[index] ? const Color(0xFFAE0103) : null,
          selectedColor: const Color(0xFFAE0103),
          labelStyle: TextStyle(color: _selections[index] ? Colors.white : const Color(0xFFAE0103)),
          selectedShadowColor: Colors.transparent, // 選択時の影を非表示にする
          showCheckmark: false, // チェックマークを非表示にする
        );
      }),
    );
  }
}

enum EndCondition {
  none,
  endDate,
  repeatCount,
}

class RepeatSettingData {
  final bool isRepeat;
  final int repeatInterval;
  final String repeatOption;
  final EndCondition endCondition;
  final DateTime? endDate;
  final int? repeatCount;
  List<bool> selectionList;

  RepeatSettingData({
    required this.isRepeat,
    required this.repeatInterval,
    required this.repeatOption,
    required this.endCondition,
    this.endDate,
    this.repeatCount,
    required this.selectionList,
  });
}

