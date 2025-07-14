import 'dart:convert';
import 'package:http/http.dart' as http;

// Initialize a logger for this service

class APIService {
  Future<Map<String, dynamic>> connect({
    required String host,
    required String topicName,
    required String port,
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('http://localhost:5000/api/subcam01_request');

    final connectionData = {
      'host': host,
      'topicName': topicName,
      'port': int.tryParse(port) ?? 0, // Send port as int
      'username': username,
      'password': password,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(connectionData),
      );

      final responseData = jsonDecode(response.body);
      return {
        ...responseData,
        'data': response.body.toString(), // Add raw string response
      };
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }
}
