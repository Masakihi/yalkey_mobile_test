import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../profile/report_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../api.dart';
import '../app.dart';
import '../home_page.dart';
import 'package:intl/intl.dart';
import 'image_cropper.dart';

enum ReportType { time, custom_int, custom_double, bool }

Map<ReportType, dynamic> reportType2NameAndId = {
  ReportType.time: ['時間型', 0],
  ReportType.custom_int: ['整数型', 2],
  ReportType.custom_double: ['小数型', 3],
  ReportType.bool: ['達成型', 4],
};

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
  bool _posting = false;
  List<DropdownMenuItem<Report?>> _dropdownItems = [];
  String? loginUserName;
  String? loginUserIconImage;
  String? loginUserId;
  int? loginUserNumber;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: "");
    _hoursController = TextEditingController();
    _minutesController = TextEditingController();
    _integerController = TextEditingController();
    _floatController = TextEditingController();
    _selectedDate = DateTime.now();
    _getLoginUserData();
    _fetchReportList();
  }

  var hoge = {
    "login_user": {
      "is_active": true,
      "date_joined": "2024-03-16T14:09:33.167809+09:00",
      "user_number": 99,
      "name": "テストユーザー1",
      "iconimage": "",
      "user_id": "hogehoge",
      "profile": "テストユーザー1",
      "profile_number": 99,
      "private": false,
      "super_hard_worker": false,
      "hard_worker": false,
      "regular_customer": false,
      "super_early_bird": false,
      "early_bird": false
    },
    "post_form": {
      "text": "テスト",
      "type": "0",
      "unit": "",
      "report_name": "テスト",
      "hour": "1",
      "minute": "1",
      "todo": "false",
      "custom_data": "0",
      "custom_float_data": "0.0",
      "report_date": "2024-03-16"
    },
    "progress_form": {
      "text": "テスト",
      "type": "0",
      "unit": "",
      "report_name": "テスト",
      "hour": "1",
      "minute": "1",
      "todo": "false",
      "custom_data": "0",
      "custom_float_data": "0.0",
      "report_date": "2024-03-16"
    },
    "report_types": {"レポートを選択してください": 0},
    "custom_data_types": {},
    "post_form_error": {},
    "progress_form_error": {
      "unit": ["この項目は空にできません。"]
    }
  };

  Future<void> _getLoginUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _loginUserName = prefs.getString('login_user_name');
    var _loginUserIconImage = prefs.getString('login_user_iconimage');
    var _loginUserId = prefs.getString('login_user_id');
    var _loginUserNumber = prefs.getInt('login_user_number');
    setState(() => {
          loginUserName = _loginUserName,
          loginUserIconImage = _loginUserIconImage,
          loginUserId = _loginUserId,
          loginUserNumber = _loginUserNumber,
        });
  }

  Future<void> _fetchReportList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? _loginUserNumber = prefs.getInt('login_user_number');
    setState(() {
      _loading = true; // データのロード中フラグをtrueに設定
    });
    ReportListResponse reportListResponse =
        await ReportListResponse.fetchReportListResponse(_loginUserNumber!);
    // logResponse(reportListResponse.reportList[0].graphType);
    if (mounted) {
      setState(() {
        reportListResponse.reportList.forEach((newReport) => {
              if (!_reportList.any((existingReport) =>
                  existingReport.reportName == newReport.reportName))
                {_reportList.add(newReport)}
            });
        _rebuildDropdownItems();
        _loading = false; // データのロード中フラグをfalseに設定
      });
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  Future<void> _postFormData() async {
    if (_selectedImagePaths.length > 10) {
      // エラーメッセージを表示して処理を終了
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('画像は最大10件までです。'),
        ),
      );
      return; // 早期リターン
    }
    setState(() => _posting = true);

    // 成功メッセージを表示
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('投稿しています...（反映には時間がかかる場合があります）'),
      ),
    );
    try {
      if (!_hasData) {
        String text = _textEditingController.text;
        var data = {
          'text': text,
        };
        logResponse(data);
        final response = await httpPost('post-form/', data,
            jwt: true, images: _selectedImagePaths);
      } else {
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
          'type': _selectedReport?.reportType,
          'unit': _selectedReport?.reportUnit,
          'report_name': _selectedReport?.reportName,
          'hour': hours,
          'minute': minutes,
          'todo': todoCompleted,
          'custom_data': integerForm,
          'custom_float_data': floatForm,
          'report_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        };


        print("data");
        print(data);
        logResponse(data);

        final response = await httpPost('progress-form/', data,
            jwt: true, images: _selectedImagePaths);
        logResponse(response);
      }

      // 成功メッセージを表示
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('投稿完了しました！'),
        ),
      );
    } catch (error) {
      print(error);
      // エラーメッセージを表示
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラー: $error'),
        ),
      );
    } finally {
      setState(() => _posting = false);
      Navigator.of(context).pop(MaterialPageRoute(
        builder: (context) => const HomePage(),
      ));
    }
  }

  Future<void> _getImages() async {
    final imagePicker = ImagePicker();
    final pickedFiles = await imagePicker.pickMultiImage();

    if (pickedFiles != null) {
      // 新たに選択された画像と既存の画像を合わせたリストを作成
      List<String> newImagePaths =
          pickedFiles.map((file) => file.path).toList();
      List<String> combinedImagePaths = List.from(_selectedImagePaths)
        ..addAll(newImagePaths);

      if (combinedImagePaths.length <= 10) {
        // 合計が10件以下の場合は、新たに選択された画像を追加
        setState(() {
          _selectedImagePaths = combinedImagePaths;
        });
      } else {
        // 合計が10件を超える場合はエラーメッセージを表示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('画像は最大10件までです。'),
          ),
        );
      }
    }
  }

  void _showAddReportDialog() {
    TextEditingController _newReportNameController = TextEditingController();
    TextEditingController _newReportUnitController = TextEditingController();
    ReportType _selectedType = ReportType.time;
    bool _isNameEmptyError = false;
    bool _isNameDuplicateError = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('新規レポート'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: _newReportNameController,
                      decoration: InputDecoration(
                        hintText: "レポート名を入力",
                        errorText: _isNameEmptyError ? 'レポート名を入力してください' : null,
                      ),
                    ),
                    if (_isNameDuplicateError)
                      Text(
                        '同じ名前のレポートが既に存在します',
                        style: TextStyle(color: Colors.red),
                      ),
                    DropdownButton<ReportType>(
                      value: _selectedType,
                      onChanged: (ReportType? newValue) {
                        setState(() {
                          _selectedType = newValue!;
                        });
                      },
                      items: ReportType.values.map((ReportType classType) {
                        return DropdownMenuItem<ReportType>(
                          value: classType,
                          child: Text(
                            reportType2NameAndId[classType][0],
                          ),
                        );
                      }).toList(),
                    ),
                    if (_selectedType == ReportType.custom_double ||
                        _selectedType == ReportType.custom_int)
                      TextField(
                        controller: _newReportUnitController,
                        decoration: InputDecoration(hintText: "単位を入力"),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('キャンセル'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                // TextButton(
                //   child: Text('クロップ'),
                //   onPressed: (() {
                //     Navigator.of(context).push(MaterialPageRoute(
                //       builder: (context) => ImageCropPage(title: 'test'),
                //     ));
                //   }),
                // ),
                TextButton(
                  child: Text('保存'),
                  onPressed: () {
                    String name = _newReportNameController.text.trim();
                    if (name.isEmpty) {
                      setState(() {
                        _isNameEmptyError = true;
                        _isNameDuplicateError = false;
                      });
                    } else if (_reportList
                        .any((report) => report.reportName == name)) {
                      setState(() {
                        _isNameEmptyError = false;
                        _isNameDuplicateError = true;
                      });
                    } else {
                      Report newReport = Report(
                        reportName: name,
                        reportUnit: _selectedType == ReportType.time
                            ? '分'
                            // : '分'
                            : _newReportUnitController.text,
                        graphType: '棒',
                        userId: loginUserNumber!,
                        reportType: reportType2NameAndId[_selectedType][1],
                      );
                      setState(() {
                        _reportList.insert(0, newReport);
                        _selectedReport = newReport;
                        _isNameEmptyError = false;
                        _isNameDuplicateError = false;
                      });
                      print(newReport.reportUnit);
                      _rebuildDropdownItems();
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _rebuildDropdownItems() {
    setState(() {
      _dropdownItems = [
        DropdownMenuItem<Report?>(
          value: Report(
            reportName: '',
            reportType: -1,
            reportUnit: '',
            graphType: '',
            userId: -1,
          ),
          child: Text('＋新規レポートで投稿'),
        )
      ]..addAll(_reportList.map<DropdownMenuItem<Report?>>((Report report) {
          return DropdownMenuItem<Report?>(
            value: report,
            child: Text(report.reportName),
          );
        }).toList());
    });
  }

  Future<void> _showDatePicker() async {
    final selectedDate = await showDatePicker(
      locale: const Locale("ja"),
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('投稿'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _textEditingController,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return '必須です';
                  }
                  if (5000 < value!.length) {
                    return '本文は5000文字以下で入力してください';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: '本文（必須、5000文字まで）',
                ),
                maxLines: null,
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: _getImages,
                child: const Text('画像を選択（10枚まで）'),
              ),
              if (_selectedImagePaths.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImagePaths.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.file(
                              File(_selectedImagePaths[index]),
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                // この画像をリストから削除する
                                setState(() {
                                  _selectedImagePaths.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
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
                TextButton(
                  onPressed: _showDatePicker,
                  child: Text(
                      '日付を選択：${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                ),
                DropdownButtonFormField<Report?>(
                    value: _selectedReport,
                    onChanged: (Report? newValue) {
                      if (newValue!.reportType == -1) {
                        _showAddReportDialog();
                      } else {
                        setState(() {
                          _selectedReport = newValue;
                        });
                      }
                    },
                    items: _dropdownItems,
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
                child: const Text(
                  '投稿',
                  style: const TextStyle(fontSize: 18.0, color: Colors.white),
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
        ),
      ),
    );
  }
}
