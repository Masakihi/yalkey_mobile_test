import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

void logResponse(dynamic response) {
  log(response.toString(), name: 'Response');
}

Future httpGet(String path, {bool jwt = false}) async {
  if (jwt) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Token does not exist');
    } else {
      final response = await http.get(
        Uri.parse('https://yalkey.com/api/v1/$path'),
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
    Uri.parse('https://yalkey.com/api/v1/$path'),
    headers: {'Content-Type': 'application/json'},
  );
  return json.decode(utf8.decode(response.bodyBytes));
}

Future httpDelete(String path, {bool jwt = false}) async {
  if (jwt) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Token does not exist');
    } else {
      final response = await http.delete(
        Uri.parse('https://yalkey.com/api/v1/$path'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token'
        },
      );
      logResponse(response);
      if (response.bodyBytes.isNotEmpty) {
        print(response.bodyBytes);
        logResponse(json.decode(utf8.decode(response.bodyBytes)));
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        return response.statusCode;
      }
    }
  }
  final response = await http.get(
    Uri.parse('https://yalkey.com/api/v1/$path'),
    headers: {'Content-Type': 'application/json'},
  );
  return json.decode(utf8.decode(response.bodyBytes));
}

// Post（画像投稿可能）
Future<dynamic> httpPost(String path, Map<String, dynamic>? body,
    {bool jwt = false, List<String> images = const []}) async {
  if (jwt) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Token does not exist');
    } else {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://yalkey.com/api/v1/$path'),
      );
      // ヘッダーにトークンを追加
      request.headers['Authorization'] = 'JWT $token';

      // 画像をリクエストに追加
      for (var imagePath in images) {
        request.files
            .add(await http.MultipartFile.fromPath('postimage', imagePath));
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
      return json.decode(responseBody);
    }
  } else {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://yalkey.com/api/v1/$path'),
    );

    // 画像をリクエストに追加
    for (var imagePath in images) {
      request.files
          .add(await http.MultipartFile.fromPath('postimage', imagePath));
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


// Post（プロフィール画像追加可能）
Future<dynamic> httpPostWithIcon(String path, Map<String, dynamic>? body, String? image,
    {bool jwt = false}) async {
  if (jwt) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Token does not exist');
    } else {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://yalkey.com/api/v1/$path'),
      );
      // ヘッダーにトークンを追加
      request.headers['Authorization'] = 'JWT $token';

      // 画像をリクエストに追加
      if (image!=null) request.files.add(await http.MultipartFile.fromPath('iconimage', image));
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
      Uri.parse('https://yalkey.com/api/v1/$path'),
    );


    // 画像をリクエストに追加
    if (image!=null) request.files.add(await http.MultipartFile.fromPath('iconimage', image));
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

    print(responseBody);

    return json.decode(responseBody);
  }
}
