import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiRemovebg {
  Future<Uint8List> removeBgApi(String imagePath) async {
    var request = http.MultipartRequest(
        "POST",
        Uri.parse(
            'http://hydrohealth.dev.smartgreenovation.com/upload/classify'));
    request.files
        .add(await http.MultipartFile.fromPath("image_file", imagePath));
    // request.headers.addAll({"X-API-Key": "zwmopzCkb13TyhJQn2DXfjTE"});
    final response = await request.send();
    if (response.statusCode == 200) {
      http.Response imgRes = await http.Response.fromStream(response);
      return imgRes.bodyBytes;
    } else {
      throw Exception("Failed to remove background ${response.statusCode}");
    }
  }
}
