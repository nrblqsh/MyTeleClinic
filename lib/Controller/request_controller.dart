import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestController {
  String path;
  String server;
  http.Response? _res;
  final Map<dynamic, dynamic> _body = {};
  final Map<String, String> _headers = {};
  dynamic _resultData;
  Map<dynamic, dynamic> get requestBody => _body;

  RequestController({required this.path, this.server = "http://192.168.8.186"});

  setBody(Map<String, dynamic> data) {
    _body.clear();
    _body.addAll(data);
    _headers["Content-Type"] = "application/json; charset=UTF-8";
  }

  Future<void> post() async {
    _res = await http.post(
      Uri.parse(_getUrl()),
      headers: _headers,
      body: jsonEncode(_body),
    );
    _parseResult();
  }

  Future<void> get() async {
    _res = await http.get(
      Uri.parse(server + path),
      headers: _headers,
    );
    _parseResult();
  }

  Future<void> put() async {
    _res = await http.put(
      Uri.parse(_getUrl()),
      headers: _headers,
      body: jsonEncode(_body),
    );
    _parseResult();
  }

  String _getUrl() {
    return (Uri.parse(server + path)).toString();  // Corrected line
  }
  void _parseResult() {
    try {
      if (_res != null) {
        if (_res!.body.isEmpty) {
          _resultData = null;
        } else {
          _resultData = jsonDecode(_res!.body);
        }
      } else {
        print("No response received");
        _resultData = null;
      }
    } catch (ex, stackTrace) {
      print("Exception in HTTP result parsing: $ex");
      print("StackTrace: $stackTrace");
      print("Response body: ${_res?.body}");
      _resultData = null;
    }
  }

  dynamic result() {
    return _resultData;
  }

  int status() {
    return _res?.statusCode ?? 0;
  }
}
