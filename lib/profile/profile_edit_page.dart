import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import '../api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditPage extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const ProfileEditPage({Key? key, required this.profileData})
      : super(key: key);

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _userIdController;
  late TextEditingController _profileController;
  ImageProvider<Object>? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
        text: widget.profileData['login_user_profile']['name']);
    _userIdController = TextEditingController(
        text: widget.profileData['login_user_profile']['user_id']);
    _profileController = TextEditingController(
        text: widget.profileData['login_user_profile']['profile']);
    _imageFile =
        NetworkImage(widget.profileData['login_user_profile']['iconimage']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userIdController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  void _saveProfileChanges() async {
    // ここでプロフィールの変更を保存する処理を実装します
    // 保存が成功したら前の画面に戻ります

    Navigator.pop(context); // 前の画面に戻る
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = FileImage(File(pickedFile.path));
      });
    }
  }

  Widget _buildAvatarIcon() {
    return Stack(
      children: [
        CircleAvatar(
          backgroundImage: _imageFile,
          radius: 40,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: IconButton(
            onPressed: _selectImage,
            icon: Icon(Icons.add_a_photo),
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('プロフィール編集'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // キャンセルボタンが押されたら前の画面に戻る
                    },
                    child: Text('キャンセル', style: TextStyle(color: Colors.black)),
                  ),
                  TextButton(
                    onPressed: _saveProfileChanges,
                    child: Text('保存', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildAvatarIcon(),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '名前'),
              ),
              TextFormField(
                controller: _userIdController,
                decoration: InputDecoration(labelText: 'ユーザーID'),
              ),
              TextFormField(
                controller: _profileController,
                decoration: InputDecoration(labelText: 'プロフィール'),
                maxLines: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
