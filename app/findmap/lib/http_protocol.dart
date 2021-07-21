import 'dart:io';
import 'package:http/http.dart' as http;

String base = 'jsonplaceholder.typicode.com';

httpGet(String path, {Map<String, dynamic> ?argument}) async {
  return await http.get(
    Uri.http(base, path, argument),
    headers: {
      HttpHeaders.authorizationHeader: "Basic your_api_token_here",
      // HttpHeaders.contentTypeHeader: "application/json"
    },
  );
}
