import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'const.dart';

final constant = Const(debugAPI: true);

void logResponse(dynamic response) {
  log(response.toString(), name: 'Response');
}

Future<void> checkInternetConnection() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      // インターネット接続が確立している場合
      return;
    }
  } on SocketException catch (_) {
    // インターネット接続が確立していない場合
    throw Exception('No internet connection');
  }
}

Future httpGet(String path, {bool jwt = false}) async {
  if (!kIsWeb) {
    await checkInternetConnection(); // インターネット接続を確認
  }

  if (jwt) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Token does not exist');
    } else {
      final response = await http.get(
        Uri.parse('${constant.getUrl()}api/v1/$path'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token'
        },
      );
      if (path.contains('detail')) {
        // logResponse(json.decode(utf8.decode(response.bodyBytes)));
      }
      return json.decode(utf8.decode(response.bodyBytes));
    }
  }
  final response = await http.get(
    Uri.parse('${constant.getUrl()}api/v1/$path'),
    headers: {'Content-Type': 'application/json'},
  );
  return json.decode(utf8.decode(response.bodyBytes));
}

Future httpDelete(String path, {bool jwt = false}) async {
  if (!kIsWeb) {
    await checkInternetConnection(); // インターネット接続を確認
  }

  if (jwt) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Token does not exist');
    } else {
      final response = await http.delete(
        Uri.parse('${constant.getUrl()}api/v1/$path'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token'
        },
      );
      logResponse(response);
      if (response.bodyBytes.isNotEmpty) {
        //print(response.bodyBytes);
        logResponse(json.decode(utf8.decode(response.bodyBytes)));
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        return response.statusCode;
      }
    }
  }
  final response = await http.get(
    Uri.parse('${constant.getUrl()}api/v1/$path'),
    headers: {'Content-Type': 'application/json'},
  );
  return json.decode(utf8.decode(response.bodyBytes));
}

// Post（画像投稿可能）
Future<dynamic> httpPost(String path, Map<String, dynamic>? body,
    {bool jwt = false,
    List<String> images = const [],
    String imageFieldName = 'postimage'}) async {
  if (jwt) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Token does not exist');
    } else {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${constant.getUrl()}api/v1/$path'),
      );
      // ヘッダーにトークンを追加
      request.headers['Authorization'] = 'JWT $token';
      // 画像をリクエストに追加
      for (var imagePath in images) {
        request.files
            .add(await http.MultipartFile.fromPath(imageFieldName, imagePath));
      }
      // ボディを追加
      if (body != null) {
        body.forEach((key, value) {
          request.fields[key] = value.toString();
        });
      }
      // logResponse(request.fields);
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      logResponse(responseBody);
      return json.decode(responseBody);
    }
  } else {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${constant.getUrl()}api/v1/$path'),
    );

    // 画像をリクエストに追加
    for (var imagePath in images) {
      request.files
          .add(await http.MultipartFile.fromPath(imageFieldName, imagePath));
    }

    // ボディを追加
    if (body != null) {
      body.forEach((key, value) {
        request.fields[key] = value.toString();
      });
    }
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    return json.decode(responseBody);
  }
}

Future<dynamic> httpPut(String path, Map<String, dynamic>? body,
    {bool jwt = false,
    List<String> images = const [],
    String imageFieldName = 'postimage'}) async {
  if (!kIsWeb) {
    await checkInternetConnection(); // インターネット接続を確認
  }

  if (jwt) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Token does not exist');
    } else {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${constant.getUrl()}api/v1/$path'),
      );
      // ヘッダーにトークンを追加
      request.headers['Authorization'] = 'JWT $token';

      // 画像をリクエストに追加
      for (var imagePath in images) {
        request.files
            .add(await http.MultipartFile.fromPath(imageFieldName, imagePath));
      }

      // ボディを追加
      if (body != null) {
        body.forEach((key, value) {
          request.fields[key] = value.toString();
        });
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      logResponse(responseBody);

      return responseBody;
    }
  } else {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('${constant.getUrl()}api/v1/$path'),
    );

    // 画像をリクエストに追加
    for (var imagePath in images) {
      request.files
          .add(await http.MultipartFile.fromPath(imageFieldName, imagePath));
    }

    // ボディを追加
    if (body != null) {
      body.forEach((key, value) {
        request.fields[key] = value.toString();
      });
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    return responseBody;
  }
}

// Post（プロフィール画像追加可能）
Future<dynamic> httpPostWithIcon(
    String path, Map<String, dynamic>? body, String? image,
    {bool jwt = false}) async {
  if (jwt) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Token does not exist');
    } else {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${constant.getUrl()}api/v1/$path'),
      );
      // ヘッダーにトークンを追加
      request.headers['Authorization'] = 'JWT $token';

      // 画像をリクエストに追加
      if (image != null)
        request.files
            .add(await http.MultipartFile.fromPath('iconimage', image));
      /*
      for (var imagePath in images) {
        request.files
            .add(await http.MultipartFile.fromPath('iconimage', imagePath));
      }
       */

      // ボディを追加
      if (body != null) {
        body.forEach((key, value) {
          request.fields[key] = value.toString();
        });
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      logResponse(responseBody);
      return json.decode(responseBody);
    }
  } else {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${constant.getUrl()}api/v1/$path'),
    );

    // 画像をリクエストに追加
    if (image != null)
      request.files.add(await http.MultipartFile.fromPath('iconimage', image));
    /*
      for (var imagePath in images) {
        request.files
            .add(await http.MultipartFile.fromPath('iconimage', imagePath));
      }
       */

    // ボディを追加
    if (body != null) {
      body.forEach((key, value) {
        request.fields[key] = value.toString();
      });
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    //print(responseBody);

    return json.decode(responseBody);
  }
}

// Post（プロフィール画像追加可能）
Future<dynamic> httpPutWithIcon(
    String path, Map<String, dynamic>? body, String? image,
    {bool jwt = false}) async {
  if (jwt) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Token does not exist');
    } else {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${constant.getUrl()}api/v1/$path'),
      );
      // ヘッダーにトークンを追加
      request.headers['Authorization'] = 'JWT $token';

      // 画像をリクエストに追加
      if (image != null)
        request.files
            .add(await http.MultipartFile.fromPath('iconimage', image));
      /*
      for (var imagePath in images) {
        request.files
            .add(await http.MultipartFile.fromPath('iconimage', imagePath));
      }
       */

      // ボディを追加
      if (body != null) {
        body.forEach((key, value) {
          request.fields[key] = value.toString();
        });
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      logResponse(responseBody);
      return json.decode(responseBody);
    }
  } else {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('${constant.getUrl()}api/v1/$path'),
    );

    // 画像をリクエストに追加
    if (image != null)
      request.files.add(await http.MultipartFile.fromPath('iconimage', image));
    /*
      for (var imagePath in images) {
        request.files
            .add(await http.MultipartFile.fromPath('iconimage', imagePath));
      }
       */

    // ボディを追加
    if (body != null) {
      body.forEach((key, value) {
        request.fields[key] = value.toString();
      });
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    //print(responseBody);

    return json.decode(responseBody);
  }
}

// Post（画像投稿可能）
Future<dynamic> httpPostInWeb(String path, Map<String, dynamic>? body,
    {bool jwt = false,
    List<String> imagePaths = const [],
    String imageFieldName = 'postimage'}) async {
  final dio = Dio();
  // JWTトークンを取得する
  String? token;
  if (jwt) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Token does not exist');
    }
  }
  // リクエストボディを構築する
  FormData formData = FormData();
  // その他のパラメータがあれば追加する
  if (body != null) {
    formData = FormData.fromMap(
        body.map((key, value) => MapEntry(key, value.toString())));
  }
// 画像を追加する
  Map<String, MultipartFile> imageFilesMap = {};
  for (var imagePath in imagePaths) {
    XFile image = XFile(imagePath);
    Uint8List imageBytes = await image.readAsBytes();
    MultipartFile imageFile = MultipartFile.fromBytes(imageBytes,
        filename: imagePath.split('/').last);
    imageFilesMap[imageFieldName] = imageFile;
  }
// 画像が存在する場合、リクエストボディに追加する
  if (imageFilesMap.isNotEmpty) {
    formData.files.addAll(imageFilesMap.entries);
  }
  // リクエストヘッダーを設定する
  Options options = Options(headers: {"Content-Type": "multipart/form-data"});
  if (jwt && token != null) {
    options.headers!["Authorization"] = "JWT $token";
  }
  // APIにリクエストを送信する
  Response response = await dio.post(
    '${constant.getUrl()}api/v1/$path',
    data: formData,
    options: options,
  );
  // レスポンスをログに出力する
  print(response.data);
}
