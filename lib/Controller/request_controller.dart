import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';


class RequestController {
  String path;
  String server;
  http.Response? _res;
  final Map<dynamic, dynamic> _body = {};
  final Map<String, String> _headers = {};
  dynamic _resultData;
  Map<dynamic, dynamic> get requestBody => _body;

  RequestController({required this.path, this.server = "http://192.168.0.117"});

  // Set the request body for JSON requests
  setBody(Map<String, dynamic> data) {
    _body.clear();
    _body.addAll(data);
    _headers["Content-Type"] = "application/json; charset=UTF-8";
  }

  void setFile(String fieldName, Uint8List fileBytes, {String? filename}) {
    _body[fieldName] = http.MultipartFile.fromBytes(
      'image',
      fileBytes,
      filename: filename ?? 'image.jpg',
      contentType: MediaType('application', 'octet-stream'), // Set the content type
    );
  }


  // Set headers to indicate multipart/form-data content
  void setMultipartFormData() {
    _headers.remove("Content-Type");
  }
  Future<void> post() async {
    if (_body.isNotEmpty && _body.values.any((value) => value is http.MultipartFile)) {
      // If there is a file in the request, use MultipartRequest
      var request = http.MultipartRequest('POST', Uri.parse(_getUrl()))
        ..headers.addAll(_headers);

      for (var entry in _body.entries) {
        if (entry.value is http.MultipartFile) {
          var file = entry.value as http.MultipartFile;
          var byteStream = http.ByteStream(file.finalize());
          request.files.add(http.MultipartFile(
            entry.key,
            byteStream,
            file.length,
            filename: file.filename,
          ));
        } else {
          request.fields[entry.key] = entry.value.toString();
        }
      }

      var response = await request.send();
      _res = await http.Response.fromStream(response);
    } else {
      // For JSON requests, use the previous approach
      _res = await http.post(
        Uri.parse(_getUrl()),
        headers: _headers,
        body: jsonEncode(_body),
      );
    }

    _parseResult();
  }

  // Send a GET request
  Future<void> get() async {
    _res = await http.get(
      Uri.parse(server + path),
      headers: _headers,
    );

    if (_res!.statusCode == 200) {
      _parseResult();
    } else {
      print("HTTP Request failed with status: ${_res!.statusCode}");
    }
  }

  // Send a PUT request
  Future<void> put() async {
    _res = await http.put(
      Uri.parse(_getUrl()),
      headers: _headers,
      body: jsonEncode(_body),
    );
    _parseResult();
  }

  // Construct the full URL
  String _getUrl() {
    return (Uri.parse(server + path)).toString();
  }

  // Parse the response result based on content type
  void _parseResult() {
    try {
      if (_res != null) {
        String contentType = _res!.headers['content-type'] ?? '';

        if (contentType.contains('application/json')) {
          final jsonString = _res!.body;
          print("Received JSON String: $jsonString");

          if (jsonString.isEmpty) {
            _resultData = null;
          } else {
            _resultData = jsonDecode(jsonString);
          }
        } else {
          print("Non-JSON response: $contentType");
          _resultData = _res!.bodyBytes;
        }
      } else {
        print("No response received");
        _resultData = null;
      }
    } catch (e, stackTrace) {
      print("Exception in HTTP result parsing: $e");
      print("StackTrace: $stackTrace");
      print("Response body: ${_res?.body}");
      _resultData = null;
    }
  }

  // Get the response result
  dynamic result() {
    return _resultData;
  }

  // Get the response status code
  int status() {
    return _res?.statusCode ?? 0;
  }
}
