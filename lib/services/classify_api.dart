import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://hydrohealth.dev.smartgreenovation.com';

  Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload/classify'),
    );
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));
    request.headers.addAll({"accept": "application/json"});

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return json.decode(responseBody);
    } else {
      throw Exception(
          'Failed to upload image. Status code: ${response.statusCode}');
    }
  }

  Future<String> getClassifiedImage() async {
    final response = await http.get(
      Uri.parse('$baseUrl/classifiedImage'),
      headers: {"accept": "application/json"},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
          'Failed to get classified image. Status code: ${response.statusCode}');
    }
  }
}
