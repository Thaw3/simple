import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseConnectionService {
  Future<Map<String, dynamic>> connect({
    required String host,
    required String dbName,
    required String port,
    required String username,
    required String password,
    required String dbType,
  }) async {
    final url = Uri.parse('http://0.0.0.0:5000/api/databaseconnrequest'); // Use your Flask server address

    final connectionData = {
      'host': host,
      'dbName': dbName,
      'port': port,
      'username': username,
      'password': password,
      'dbType': dbType,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(connectionData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Connection successful: $responseData');
        return responseData;
      } else {
        final responseData = jsonDecode(response.body);
        print('Connection failed: $responseData');
        return responseData;
      }
    } catch (e) {
      print('Connection error: $e');
      return {
        'status': 'error',
        'message': 'Connection error: $e',
      };
    }
  }
}

