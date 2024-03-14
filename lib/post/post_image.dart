import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class ImageDisplay extends StatefulWidget {
  final List<String> imageURLs;

  ImageDisplay({required this.imageURLs});

  @override
  _ImageDisplayState createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {
  @override
  Widget build(BuildContext context) {
    switch (widget.imageURLs.length) {
      case 0:
        return SizedBox(width: 0, height: 0);
      case 1:
        return GestureDetector(
            onTap: () {
              _showImageDialog(context, 0);
            },
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  "https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/postimage/${widget.imageURLs[0]}",
                  fit: BoxFit.cover,
                )));
      case 2:
        return SingleChildScrollView(
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
                childAspectRatio: 0.75),
            itemCount: widget.imageURLs.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  _showImageDialog(context, index);
                },
                child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                          index == 0 ? 10.0 : 0.0), // index 0の場合は左上の角を丸める
                      bottomLeft: Radius.circular(
                          index == 0 ? 10.0 : 0.0), // index 0の場合は左下の角を丸める
                      topRight: Radius.circular(
                          index == 1 ? 10.0 : 0.0), // index 1の場合は右上の角を丸める
                      bottomRight: Radius.circular(
                          index == 1 ? 10.0 : 0.0), // index 1の場合は右下の角を丸める
                    ),
                    child: Image.network(
                      "https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/postimage/${widget.imageURLs[index]}",
                      fit: BoxFit.fitWidth,
                      height: 160,
                    )),
              );
            },
          ),
        );
      case 3:
        return SingleChildScrollView(
            child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
              childAspectRatio: 0.75),
          itemCount: 2,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              // 一番目の要素を左側に配置
              return GestureDetector(
                  onTap: () {
                    _showImageDialog(context, index);
                  },
                  child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      child: Image.network(
                        "https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/postimage/${widget.imageURLs[0]}",
                        fit: BoxFit.cover,
                      )));
            } else {
              return GridView.count(
                crossAxisCount: 1,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
                childAspectRatio: 1.5,
                children: [
                  GestureDetector(
                      onTap: () {
                        _showImageDialog(context, 1);
                      },
                      child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                          ),
                          child: Image.network(
                            "https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/postimage/${widget.imageURLs[1]}",
                            fit: BoxFit.cover,
                          ))),
                  GestureDetector(
                      onTap: () {
                        _showImageDialog(context, 2);
                      },
                      child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(10),
                          ),
                          child: Image.network(
                            "https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/postimage/${widget.imageURLs[2]}",
                            fit: BoxFit.cover,
                          )))
                ],
              );
            }
          },
        ));
      case 4:
        return SingleChildScrollView(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
                childAspectRatio: 1.5),
            itemCount: widget.imageURLs.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                  onTap: () {
                    _showImageDialog(context, index);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                          index == 0 ? 10.0 : 0.0), // index 0の場合は左上の角を丸める
                      topRight: Radius.circular(
                          index == 1 ? 10.0 : 0.0), // index 1の場合は右上の角を丸める
                      bottomLeft: Radius.circular(
                          index == 2 ? 10.0 : 0.0), // index 2の場合は左下の角を丸める
                      bottomRight: Radius.circular(
                          index == 3 ? 10.0 : 0.0), // index 3の場合は右下の角を丸める
                    ),
                    child: Image.network(
                      "https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/postimage/${widget.imageURLs[index]}",
                      fit: BoxFit.fitWidth,
                    ),
                  ));
            },
          ),
        );
      default:
        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.imageURLs.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _showImageDialog(context, index);
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      "https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/postimage/${widget.imageURLs[index]}",
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              );
            },
          ),
        );
    }
  }

  Future<void> _saveImage(BuildContext context, int index) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    late String message;
    final _url =
        "https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/postimage/${widget.imageURLs[index]}";
    var random = Random();
    try {
      // Download image
      final http.Response response = await http.get(Uri.parse(_url));

      // Get temporary directory
      final dir = await getTemporaryDirectory();

      // Create an image name
      var filename = '${dir.path}/SaveImage${random.nextInt(100)}.png';

      // Save to filesystem
      final file = File(filename);
      await file.writeAsBytes(response.bodyBytes);

      // Ask the user to save it
      final params = SaveFileDialogParams(sourceFilePath: file.path);
      final finalPath = await FlutterFileDialog.saveFile(params: params);

      if (finalPath != null) {
        message = 'Image saved to disk';
      }
    } catch (e) {
      message = e.toString();
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFe91e63),
      ));
    }

    if (message != null) {
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFe91e63),
      ));
    }
  }

  void _showImageDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.delta.dy > 20) {
                Navigator.pop(context);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      height: 300.0,
                      width: 300.0,
                      child: PageView.builder(
                        itemCount: widget.imageURLs.length,
                        controller: PageController(initialPage: index),
                        itemBuilder: (BuildContext context, int pageIndex) {
                          return Center(
                            child: InteractiveViewer(
                              minScale: 1,
                              maxScale: 7,
                              child: Image.network(
                                "https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/postimage/${widget.imageURLs[pageIndex]}",
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.download),
                      onPressed: () {
                        _saveImage(context, index);
                        // _downloadImage(
                        //     "https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/postimage/${widget.imageURLs[index]}");
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
