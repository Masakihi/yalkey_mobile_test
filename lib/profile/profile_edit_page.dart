import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import '../api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_page.dart';

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
  late bool _private;
  ImageProvider<Object>? _imageFile;
  String? _editImagePath = null;
  String? loginUserName;
  String? loginUserIconImage;
  String? loginUserId;
  int? loginUserNumber;

  @override
  void initState() {
    super.initState();
    print(widget.profileData);
    _nameController = TextEditingController(
        text: widget.profileData['login_user_profile']['name']);
    _userIdController = TextEditingController(
        text: widget.profileData['login_user_profile']['user_id']);
    _profileController = TextEditingController(
        text: widget.profileData['login_user_profile']['profile']);
    _private = widget.profileData['login_user']['private'];
    _imageFile =
        NetworkImage(widget.profileData['login_user_profile']['iconimage']);
    _getLoginUserData();
  }

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

  @override
  void dispose() {
    _nameController.dispose();
    _userIdController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  void _saveProfileChanges() async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('プロフィールを更新します'),
      ),
    );
    final data = {
      "name": _nameController.text,
      "user_id": _userIdController.text,
      "profile": _profileController.text,
      "private": _private
    };
    logResponse(data);
    final response = httpPut(
        'profile/update/${widget.profileData['login_user_profile']['profile_number']}',
        data,
        jwt: true,
        images: _editImagePath != null ? [_editImagePath!] : [],
        imageFieldName: 'iconimage');
    logResponse(response);
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('修正が完了しました'),
      ),
    );
    Navigator.pop(context); // 前の画面に戻る
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = FileImage(File(pickedFile.path));
        _editImagePath = pickedFile.path;
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
                    child: const Text(
                      'キャンセル',
                    ),
                  ),
                  TextButton(
                    onPressed: _saveProfileChanges,
                    child: const Text(
                      '保存',
                    ),
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
              CheckboxListTile(
                title: Text('非公開にする'),
                value: _private,
                onChanged: (value) {
                  setState(() {
                    _private = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
