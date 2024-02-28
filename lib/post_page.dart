import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'constant.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late List<String> _selectedImagePaths = [];
  late TextEditingController _textEditingController;
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  late DateTime _selectedDate;
  late List<Report> _reportList = [];
  Report? _selectedReport = null;
  bool _hasData = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _hoursController = TextEditingController();
    _minutesController = TextEditingController();
    _selectedDate = DateTime.now();
    _fetchReportList();
  }

  Future<void> _fetchReportList() async {
    setState(() {
      _loading = true; // データのロード中フラグをtrueに設定
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cachedReportList = prefs.getStringList('user_report_list');
    if (cachedReportList != null && cachedReportList.isNotEmpty) {
      setState(() {
        _reportList = cachedReportList
            .map((jsonString) => Report.fromJson(jsonDecode(jsonString)))
            .toList();
      });
    }
    ReportListResponse reportListResponse =
        await ReportListResponse.fetchReportListResponse(59);
    print(reportListResponse.reportList);
    if (mounted) {
      setState(() {
        _reportList.addAll(reportListResponse.reportList); // 新しいデータをリストに追加
        _loading = false; // データのロード中フラグをfalseに設定
      });
    }
    prefs.setStringList('user_report_list',
        _reportList.map((repost) => jsonEncode(repost.toJson())).toList());
    // print(_reportList);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  Future<void> _postFormData() async {
    // 日付を文字列に変換
    String formattedDate =
        '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}';

    // データをAPIに投稿する処理をここに記述
    // テキストデータ
    String text = _textEditingController.text;
    // 時間データ
    int? hours = _hoursController.text.isNotEmpty
        ? int.parse(_hoursController.text)
        : null;
    // 分データ
    int? minutes = _minutesController.text.isNotEmpty
        ? int.parse(_minutesController.text)
        : null;

    // APIに投稿するデータを作成
    var data = {
      'text': text,
      'types': {},
      'units': {},
      'report_date': formattedDate,
      'report': [],
      if (hours != null && minutes != null) 'hours': [hours],
      if (hours != null && minutes != null) 'minutes': [minutes],
      if (hours != null && minutes != null) 'todo': ['off'],
      'custom_data': [0],
      'custom_float_data': [0.0],
    };

    // APIにデータを投稿する処理を実行
    // http.post('https://yalkey.com/api/v1/progress-form/', body: data);
    // データの送信結果などの処理を追加する
  }

  Future<void> _getImages() async {
    final imagePicker = ImagePicker();
    final pickedFiles = await imagePicker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _selectedImagePaths = pickedFiles.map((file) => file.path).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton(
                onPressed: _getImages,
                child: const Text('画像を選択'),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _textEditingController,
                decoration: const InputDecoration(labelText: '本文（省略可）'),
                maxLines: null,
              ),
              if (_selectedImagePaths.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImagePaths.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.file(
                          File(_selectedImagePaths[index]),
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Checkbox(
                    value: _hasData,
                    onChanged: (value) {
                      setState(() {
                        _hasData = value!;
                      });
                    },
                  ),
                  const Text('データあり'),
                ],
              ),
              if (_hasData) ...[
                DropdownButtonFormField<Report>(
                    value: _selectedReport,
                    onChanged: (Report? newValue) {
                      setState(() {
                        _selectedReport = newValue!;
                      });
                    },
                    items: _reportList
                        .map<DropdownMenuItem<Report>>((Report report) {
                      return DropdownMenuItem<Report>(
                        value: report,
                        child: Text(report.reportName),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'レポートの種類を選択してください',
                      border: OutlineInputBorder(),
                    )),
                if (_selectedReport != null) ...[
                  if (_selectedReport!.reportType == 0) ...[
                    // 時間入力フォーム
                    // 例: TextFormField(
                    //   decoration: InputDecoration(labelText: '時間'),
                    // ),
                  ],
                  if (_selectedReport!.reportType == 2) ...[
                    // 整数入力フォーム
                    // 例: TextFormField(
                    //   decoration: InputDecoration(labelText: '整数'),
                    //   keyboardType: TextInputType.number,
                    // ),
                  ],
                  if (_selectedReport!.reportType == 3) ...[
                    // 小数入力フォーム
                    // 例: TextFormField(
                    //   decoration: InputDecoration(labelText: '小数'),
                    //   keyboardType: TextInputType.numberWithOptions(decimal: true),
                    // ),
                  ],
                  if (_selectedReport!.reportType == 4) ...[
                    // 達成、未達成のbool入力フォーム
                    // 例: CheckboxListTile(
                    //   title: Text('達成'),
                    //   value: _isAchieved,
                    //   onChanged: (newValue) {
                    //     setState(() {
                    //       _isAchieved = newValue!;
                    //     });
                    //   },
                    // ),
                  ],
                ],
              ],
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _postFormData,
                child: const Text('投稿'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
