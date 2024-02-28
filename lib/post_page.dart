import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'api.dart';

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
  bool _hasData = false;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _hoursController = TextEditingController();
    _minutesController = TextEditingController();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  Future<void> _postFormData() async {
    if (!_hasData) {
      String text = _textEditingController.text;
      var data = {
        'text': text,
      };
      final response = httpPost('post-form/', data, jwt: true);
      print(response);
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
                Row(
                  children: [
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
                  ],
                ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        _selectedDate = selectedDate;
                      });
                    }
                  },
                  child: Text(
                    '日付を選択: ${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}',
                  ),
                ),
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
