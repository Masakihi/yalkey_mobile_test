import 'package:flutter/material.dart';
import '../app.dart';

class GoalCreatePage extends StatefulWidget {
  const GoalCreatePage({super.key});

  @override
  _GoalCreateState createState() => _GoalCreateState();
}

class _GoalCreateState extends State<GoalCreatePage> {
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
    goalTextController = TextEditingController();
    purposeController = TextEditingController();
    benefitController = TextEditingController();
    lossController = TextEditingController();
    noteController = TextEditingController();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
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

      // 成功メッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('投稿完了しました！'),
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
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: "目標タイトル（必須）",
                          hintText: "（例）東大合格",
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
                        controller: purposeController,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '必須です';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "目的",
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
                        controller: benefitController,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '必須です';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "目標達成時に得られるもの",
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
                        controller: lossController,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '必須です';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "目標達成できなかった場合の損失",
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
                    child: Text("期限"),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => _selectDate(context),
                          child: Text(
                              'Select Date: ${_selectedDate.toString().substring(0, 10)}'),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextButton(
                          onPressed: () => _selectTime(context),
                          child: Text(
                              'Select Time: ${_selectedTime.format(context)}'),
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
                            Navigator.popUntil(context, (_) => count++ >= 4);
                          }
                        },
                        child: const Text(
                          '目標追加',
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
