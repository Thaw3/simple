import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:simple/services/monitor_mqtt_service.dart';
import 'package:simple/widgets/monitor_mqtt_widget.dart';

class MonitorMqttUi extends StatefulWidget {
  const MonitorMqttUi({super.key});

  @override
  State<MonitorMqttUi> createState() => _MonitorMqttUiState();
}

class _MonitorMqttUiState extends State<MonitorMqttUi> {
  final List<Chat> _messages = [];
  final Logger _logger = Logger();
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/api/subcam01_messages'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _messages.clear();
          _messages.addAll(
            data.map(
              (msg) => Chat(
                content: msg['payload'],
                time: '', // Add time if available
                senderName: msg['topic'],
              ),
            ),
          );
          _isConnected = true;
        });
      } else {
        _logger.e('Failed to fetch messages: ${response.statusCode}');
        setState(() {
          _isConnected = false;
        });
      }
    } catch (e) {
      _logger.e('Error fetching messages: $e');
      setState(() {
        _isConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tunnel Status'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Container(
                  width: 10.0,
                  height: 10.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _isConnected
                            ? Colors.green
                            : Colors.red, // Red/Green indicator
                  ),
                ),
                const SizedBox(width: 4.0),
                Text(
                  _isConnected ? 'Connected' : 'Disconnected', // Text status
                  style: TextStyle(
                    fontSize: 14.0,
                    color: _isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchMessages,
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final Chat message = _messages[index];
                  return MessageBubble(
                    chat: message,
                    isMe: false,
                    userName: message.senderName,
                  );
                },
              ),
            ),
          ),
          // Removed chat input and send buttons
        ],
      ),
    );
  }
}
