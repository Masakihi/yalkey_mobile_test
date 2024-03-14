import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImageCropper',
      theme: ThemeData.light().copyWith(primaryColor: Colors.deepOrange),
      home: ImageCropPage(
        title: 'ImageCropper',
      ),
    );
  }
}

class ImageCropPage extends StatefulWidget {
  final String title;
  ImageCropPage({required this.title});
  @override
  _ImageCropPageState createState() => _ImageCropPageState();
}

enum ImageState {
  free,
  picked,
  cropped,
}

class _ImageCropPageState extends State<ImageCropPage> {
  late ImageState state;
  File? imageFile;
  @override
  void initState() {
    super.initState();
    state = ImageState.free;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: imageFile != null ? Image.file(imageFile!) : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () {
          if (state == ImageState.free)
            _pickImage();
          else if (state == ImageState.picked)
            _cropImage();
          else if (state == ImageState.cropped) _clearImage();
        },
        child: _buildButtonIcon(),
      ),
    );
  }

  Widget _buildButtonIcon() {
    if (state == ImageState.free)
      return Icon(Icons.add);
    else if (state == ImageState.picked)
      return Icon(Icons.crop);
    else if (state == ImageState.cropped)
      return Icon(Icons.clear);
    else
      return Container();
  }

  Future<Null> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    imageFile = pickedImage != null ? File(pickedImage.path) : null;
    if (imageFile != null) {
      setState(() {
        state = ImageState.picked;
      });
    }
  }

  Future<Null> _cropImage() async {
    File? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile!.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      imageFile = croppedFile;
      setState(() {
        state = ImageState.cropped;
      });
    }
  }

  void _clearImage() {
    imageFile = null;
    setState(() {
      state = ImageState.free;
    });
  }
}
