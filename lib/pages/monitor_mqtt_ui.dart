import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:simple/services/monitor_mqtt_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> messages = [];

  Future<void> fetchMessages() async {
    final response = await http.get(
      Uri.parse('http://localhost:5000/api/messages'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        messages = jsonData.map((e) => ChatMessage.fromJson(e)).toList();
      });
    } else {
      throw Exception('Failed to load messages');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMessages();
    // Optional: poll every 5 seconds
    // Timer.periodic(Duration(seconds: 5), (_) => fetchMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MQTT Chat')),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          return ListTile(
            title: Text(msg.payload),
            subtitle: Text('${msg.topic} @ ${msg.timestamp}'),
          );
        },
      ),
    );
  }
}
