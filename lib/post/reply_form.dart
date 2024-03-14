import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../api.dart';
import 'dart:io';
import 'post_detail_page.dart';

class ReplyForm extends StatefulWidget {
  final int postNumber;

  const ReplyForm({Key? key, required this.postNumber}) : super(key: key);

  @override
  _ReplyFormState createState() => _ReplyFormState();
}

class _ReplyFormState extends State<ReplyForm> {
  TextEditingController _textController = TextEditingController();
  late List<String> _selectedImagePaths = [];

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
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '返信内容を入力してください',
            ),
          ),
          SizedBox(height: 16.0),
          TextButton(
            onPressed: _getImages,
            child: const Text('画像を選択'),
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
          ElevatedButton(
            onPressed: () async {
              // 返信をポストする処理
              print('返信します');

              final response = await httpPost(
                  'reply-form/${widget.postNumber}/',
                  {'text': _textController.text},
                  jwt: true,
                  images: _selectedImagePaths);
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('返信しています...（反映には時間がかかる場合があります）'),
                ),
              );
              if (response == 201) {
                print('postしました');
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('返信しました'),
                  ),
                );
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      PostDetailPage(postNumber: widget.postNumber),
                ));
              } else {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('返信に失敗しました')),
                );
              }
            },
            child: Text('送信'),
          ),
        ],
      ),
    );
  }
}
