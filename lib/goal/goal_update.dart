import 'package:flutter/material.dart';
import '../api.dart';
import '../app.dart';
import 'goal_model.dart';

class GoalUpdatePage extends StatefulWidget {
  final Goal oldGoal;
  final int goalNumber;
  const GoalUpdatePage({super.key, required this.oldGoal, required this.goalNumber});

  @override
  _GoalUpdateState createState() => _GoalUpdateState();
}

class _GoalUpdateState extends State<GoalUpdatePage> {
  late int goalNumber;
  Goal? oldGoalData;
  final _formKey = GlobalKey<FormState>(); //①：定義
  bool _isObscure = true;

  //TextEditingController emailController = TextEditingController(text: 'molcar@yalkey.com');
  //TextEditingController passwordController = TextEditingController(text: 'hogehoge');
  late TextEditingController goalTextController;
  late TextEditingController purposeController;
  late TextEditingController benefitController;
  late TextEditingController lossController;
  late TextEditingController noteController;
  //TextEditingController userProfileController = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    oldGoalData = widget.oldGoal;
    goalNumber = widget.goalNumber;
    goalTextController = TextEditingController(text: oldGoalData?.goalText);
    purposeController = TextEditingController(text: oldGoalData?.purpose);
    benefitController = TextEditingController(text: oldGoalData?.benefit);
    lossController = TextEditingController(text: oldGoalData?.loss);
    noteController = TextEditingController(text: oldGoalData?.note);
    DateTime dt = DateTime.parse(oldGoalData!.deadline.substring(0,10)+" "+oldGoalData!.deadline.substring(11,16));
    _selectedDate = DateTime(dt.year, dt.month, dt.day);
    _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
    // _fetchReportList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate)
      setState(() {
        _selectedDate = pickedDate;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime)
      setState(() {
        _selectedTime = pickedTime;
      });
  }

  Future<void> _postGoalData() async {
    try {
      // 日付を文字列に変換
      String formattedDate =
          '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}';

      // データをAPIに投稿する処理をここに記述
      // テキストデータ
      String goalText = goalTextController.text;
      String purpose = purposeController.text;
      String benefit = benefitController.text;
      String loss = benefitController.text;
      String note = noteController.text;

      // APIに投稿するデータを作成
      var data = {
        'goal_text': goalText,
        'purpose': purpose,
        'benefit': benefit,
        'loss': loss,
        'note': note,
        'deadline': formattedDate
      };

      print(data);

      // final response = await httpPost('progress-form/', data, jwt: true);
      final response = await httpPut('goal/update/${goalNumber}/', data, jwt: true);

      // 成功メッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('目標の更新完了しました！'),
        ),
      );

      /*
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AppPage(),
      ));
       */
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
                        controller: goalTextController,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '必須です';
                          }
                          if (50 < value!.length) {
                            return 'タイトルは50文字以下で入力してください';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: "目標タイトル（必須）",
                          hintText: "（例）シックスパックの筋肉を手にいれる",
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
                        controller: purposeController,
                        validator: (value) {
                          if (200 < value!.length) {
                            return '200文字以下で入力してください';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "目的",
                          hintText: "（例）モテるため",
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
                        controller: benefitController,
                        validator: (value) {
                          if (200 < value!.length) {
                            return '200文字以下で入力してください';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "目標達成時に得られるもの",
                          hintText: "（例）強靭な肉体、自信、周囲からの賞賛・羨望の眼差し",
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
                        controller: lossController,
                        validator: (value) {
                          if (200 < value!.length) {
                            return '200文字以下で入力してください';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "目標達成できなかった場合の損失",
                          hintText: "（例）挫折感を味わう、恋人ができずに一生を終えるかもしれない",
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
                          if (500 < value!.length) {
                            return '500文字以下で入力してください';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "メモ",
                          hintText: "（例）プロテインも忘れない",
                          /*
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red, width: 2)
                              ),
                              */
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(5.0), //マージン
                    child: Text("達成期限"),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => _selectDate(context),
                          child: Text(
                              '日付: ${_selectedDate.toString().substring(0, 10)}'),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextButton(
                          onPressed: () => _selectTime(context),
                          child: Text(
                              '時刻: ${_selectedTime.format(context)}'),
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
                            _postGoalData();
                            // login(context, emailController.text, passwordController.text);
                            int count = 0;
                            Navigator.popUntil(context, (_) => count++ >= 2);
                          }
                        },
                        child: const Text(
                          '更新',
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
