import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api.dart';

class ReplyForm extends StatefulWidget {
  final int postNumber;

  const ReplyForm({Key? key, required this.postNumber}) : super(key: key);

  @override
  _ReplyFormState createState() => _ReplyFormState();
}

class _ReplyFormState extends State<ReplyForm> {
  TextEditingController _textController = TextEditingController();

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
          ElevatedButton(
            onPressed: () async {
              // 返信をポストする処理
              print('返信します');

              final response = await httpPost(
                  'reply-form/${widget.postNumber}/',
                  {'text': _textController.text},
                  jwt: true);

              if (response == 201) {
                print('postしました');
                Navigator.pop(context, 'replyPosted'); // モーダルを閉じる
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
