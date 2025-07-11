import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.5:8000/api/';
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> registerUser(
      String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'password2': password,
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error};
      }
    } on FormatException catch (e) {
      return {
        'success': false,
        'error': {'message': 'Invalid server response format'}
      };
    } catch (e) {
      return {
        'success': false,
        'error': {'message': 'Connection error: ${e.toString()}'}
      };
    }
  }
}