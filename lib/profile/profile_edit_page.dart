import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
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
  final _formKey = GlobalKey<FormState>();
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
  bool _nameError = false;
  bool _userIdError = false;
  bool _profileError = false;

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
    _imageFile = NetworkImage(widget.profileData['login_user_profile']
            ['iconimage'] ??
        'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/static/img/user.png');
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
      // "user_id": _userIdController.text,
      "user_id": "hogehoge",
      "profile": _profileController.text,
      "private": _private
    };
    // logResponse(data);
    final response = await httpPut('profile/update/', data,
        jwt: true,
        images: _editImagePath != null ? [_editImagePath!] : [],
        imageFieldName: 'iconimage');
    print("responseです");
    logResponse(response);
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('修正が完了しました'),
      ),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Future<CroppedFile?> _cropImage(String imagePath) async {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: imagePath,
          aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
          compressQuality: 50,
          maxWidth: 4096,
          maxHeight: 4096,
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: '画像の切り抜き',
                toolbarColor: Colors.deepOrange,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            IOSUiSettings(
              title: '画像の切り抜き',
            ),
            WebUiSettings(
              context: context,
            ),
          ],
        );
        return croppedFile;
      }

      CroppedFile? croppedImage = await _cropImage(pickedFile.path);

      setState(() {
        if(croppedImage!=null) _imageFile = FileImage(File(croppedImage.path));
        if(croppedImage!=null) _editImagePath = croppedImage.path;
      });
    }
  }

  Widget _buildAvatarIcon() {
    return Stack(
      children: [
        CircleAvatar(
          backgroundImage: _imageFile,
          radius: 40,
          backgroundColor: Colors.white,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: IconButton(
            onPressed: _selectImage,
            icon: Icon(Icons.add_a_photo),
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool _hasError = _nameError || _userIdError || _profileError;
    return Scaffold(
      appBar: AppBar(
        title: Text('プロフィール編集'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always, // リアルタイムでバリデーションを実行
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatarIcon(),
                // キャンセルボタンと保存ボタンのロウ...
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '名前',
                    prefixIcon: _nameError
                        ? Icon(Icons.error_outline, color: Colors.red)
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _nameError = _nameController.text.isEmpty ||
                          _nameController.text.length > 15;
                    });
                  },
                ),
                if (_nameError)
                  Text('表示名は1～15文字で設定してください',
                      style: TextStyle(color: Colors.red)),
                Text('ユーザーIDは変更できません'),
                /*
                TextFormField(
                  controller: _userIdController,
                  decoration: InputDecoration(
                    labelText: 'ユーザーID',
                    prefixIcon: _userIdError
                        ? Icon(Icons.error_outline, color: Colors.red)
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _userIdError = _userIdController.text.isEmpty ||
                          _userIdController.text.length <= 5 ||
                          _userIdController.text.length > 30 ||
                          !RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value);
                    });
                  },
                ),
                if (_userIdError)
                  Text('ユーザーIDは6～30文字の半角英数字で設定してください',
                      style: TextStyle(color: Colors.red)),
                 */
                TextFormField(
                  controller: _profileController,
                  decoration: InputDecoration(
                    labelText: 'プロフィール',
                    prefixIcon: _profileError
                        ? Icon(Icons.error_outline, color: Colors.red)
                        : null,
                  ),
                  maxLines: null,
                  onChanged: (value) {
                    setState(() {
                      _profileError = _profileController.text.length > 1000;
                    });
                  },
                ),
                if (_profileError)
                  Text('プロフィールは1000文字以下で設定してください',
                      style: TextStyle(color: Colors.red)),
                // 非公開にするチェックボックス...
                ElevatedButton(
                  onPressed: _hasError
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _saveProfileChanges();
                          }
                        },
                  child: const Text('保存'),
                  style: ButtonStyle(
                    backgroundColor: _hasError
                        ? MaterialStateProperty.all(
                            Colors.grey) // エラーがある場合はグレーアウト
                        : null, // エラーがない場合はテーマのプライマリカラーを使用
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
