import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
      return json.decode(utf8.decode(response.bodyBytes));
    }
  }
  final response = await http.get(
    Uri.parse('https://yalkey.com/api/v1/$path'),
    headers: {'Content-Type': 'application/json'},
  );
  return json.decode(utf8.decode(response.bodyBytes));
}

Future httpPost(String path, Map<String, dynamic>? body,
    {bool jwt = false}) async {
  if (jwt) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Token does not exist');
    } else {
      final response = await http.post(
        Uri.parse('https://yalkey.com/api/v1/$path'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token'
        },
        body: body != null ? jsonEncode(body) : null, // bodyがnullの場合はnullを設定
      );
      return json.decode(utf8.decode(response.bodyBytes));
    }
  }
  final response = await http.post(
    Uri.parse('https://yalkey.com/api/v1/$path'),
    headers: {'Content-Type': 'application/json'},
    body: body != null ? jsonEncode(body) : null, // bodyがnullの場合はnullを設定
  );
  return json.decode(utf8.decode(response.bodyBytes));
}
