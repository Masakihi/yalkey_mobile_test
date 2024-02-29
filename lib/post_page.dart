import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'constant.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'app.dart';

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
  late TextEditingController _integerController;
  late TextEditingController _floatController;
  bool _todoCompleted = false;
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
    _integerController = TextEditingController();
    _floatController = TextEditingController();
    _selectedDate = DateTime.now();
    _fetchReportList();
  }

  Future<void> _fetchReportList() async {
    setState(() {
      _loading = true; // データのロード中フラグをtrueに設定
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cachedReportList =
        prefs.getStringList('user_report_list')?.toSet().toList();
    if (cachedReportList != null && cachedReportList.isNotEmpty) {
      setState(() {
        _reportList = cachedReportList
            .map((jsonString) => Report.fromJson(jsonDecode(jsonString)))
            .toSet()
            .toList();
      });
    }
    ReportListResponse reportListResponse =
        await ReportListResponse.fetchReportListResponse(59);
    if (mounted) {
      setState(() {
        reportListResponse.reportList.forEach((newReport) => {
              if (!_reportList.any((existingReport) =>
                  existingReport.reportName == newReport.reportName))
                {_reportList.add(newReport)}
            });
        _loading = false; // データのロード中フラグをfalseに設定
      });
    }
    prefs.setStringList('user_report_list',
        _reportList.map((repost) => jsonEncode(repost.toJson())).toList());
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  Future<void> _postFormData() async {
    try {
      if (!_hasData) {
        String text = _textEditingController.text;
        var data = {
          'text': text,
        };
        final response = await httpPost('post-form/', data,
            jwt: true, images: _selectedImagePaths);
      } else {
        // 日付を文字列に変換
        String formattedDate =
            '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}';

        // データをAPIに投稿する処理をここに記述
        // テキストデータ
        String text = _textEditingController.text;
        // 時間データ
        int? hours = _hoursController.text.isNotEmpty
            ? int.parse(_hoursController.text)
            : 0;
        // 分データ
        int? minutes = _minutesController.text.isNotEmpty
            ? int.parse(_minutesController.text)
            : 0;
        // 整数データ
        int? integerForm = _integerController.text.isNotEmpty
            ? int.parse(_integerController.text)
            : 0;
        // 小数データ
        double? floatForm = _floatController.text.isNotEmpty
            ? double.parse(_floatController.text)
            : 0;

        // ToDo達成フラグ
        bool todoCompleted = _todoCompleted;

        // APIに投稿するデータを作成
        var data = {
          'text': text,
          'reports': [
            {
              'type': _selectedReport?.reportType,
              'unit': _selectedReport?.reportUnit,
              'report_name': _selectedReport?.reportName,
              "hour": hours,
              "minute": minutes,
              "todo": todoCompleted,
              'custom_data': integerForm,
              'custom_float_data': floatForm,
              'report_date': formattedDate
            },
          ]
        };

        final response = await httpPost('progress-form/', data,
            jwt: true, images: _selectedImagePaths);
      }

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
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _hoursController,
                          decoration: const InputDecoration(labelText: '時間'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: TextFormField(
                          controller: _minutesController,
                          decoration: const InputDecoration(labelText: '分'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ])
                  ],
                  if (_selectedReport!.reportType == 2) ...[
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _integerController,
                          decoration: const InputDecoration(labelText: '整数値'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(_selectedReport!.reportUnit), // 単位
                    ])
                  ],
                  if (_selectedReport!.reportType == 3) ...[
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _floatController,
                          decoration: const InputDecoration(labelText: '小数値'),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(_selectedReport!.reportUnit), // 単位
                    ])
                  ],
                  if (_selectedReport!.reportType == 4) ...[
                    Row(
                      children: [
                        Text('ToDo達成：'),
                        Row(
                          children: [
                            Radio(
                              value: true,
                              groupValue: _todoCompleted,
                              onChanged: (value) {
                                setState(() {
                                  _todoCompleted = value as bool;
                                });
                              },
                            ),
                            Text('達成'),
                          ],
                        ),
                        Row(
                          children: [
                            Radio(
                              value: false,
                              groupValue: _todoCompleted,
                              onChanged: (value) {
                                setState(() {
                                  _todoCompleted = value as bool;
                                });
                              },
                            ),
                            Text('未達成'),
                          ],
                        ),
                      ],
                    ),
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
