// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'package:simple/services/monitor_mqtt_service.dart';
// import 'dart:async';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({Key? key}) : super(key: key);

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   List<ChatMessage> messages = [];

//   Future<void> fetchMessages() async {
//     final response = await http.get(
//       Uri.parse('http://localhost:5000/api/messages'),
//     );
//     if (response.statusCode == 200) {
//       final List<dynamic> jsonData = json.decode(response.body);
//       setState(() {
//         messages = jsonData.map((e) => ChatMessage.fromJson(e)).toList();
//       });
//     } else {
//       throw Exception('Failed to load messages');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchMessages(); // Load initial messages
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 final msg = messages[index];
//                 return Align(
//                   alignment: Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(
//                       horizontal: 8.0,
//                       vertical: 4.0,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.only(
//                             left: 8.0,
//                             bottom: 2.0,
//                           ),
//                           child: Text(
//                             msg.topic, // receiver name
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 13,
//                               color: Colors.blueAccent,
//                             ),
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12.0,
//                             vertical: 7.0,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.blue[100],
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: Colors.blueAccent.withOpacity(0.15),
//                             ),
//                           ),
//                           constraints: const BoxConstraints(maxWidth: 320),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 msg.payload,
//                                 style: const TextStyle(fontSize: 15),
//                               ),
//                               const SizedBox(height: 3),
//                               Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     Icons.access_time,
//                                     size: 13,
//                                     color: Colors.grey[600],
//                                   ),
//                                   const SizedBox(width: 2),
//                                   Text(
//                                     msg.timestamp,
//                                     style: const TextStyle(
//                                       fontSize: 11,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
//             color: Colors.white,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20.0),
//                         borderSide: BorderSide(color: Colors.blueAccent),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 16.0,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8.0),
//                 CircleAvatar(
//                   backgroundColor: Colors.blueAccent,
//                   child: IconButton(
//                     icon: const Icon(Icons.send, color: Colors.white),
//                     onPressed: () {
//                       // TODO: Implement send message logic
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart'; // ✅ Web-compatible MQTT
import 'dart:convert';

import 'package:simple/services/monitor_mqtt_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> messages = [];
  final String clientId = 'flutter_client';
  String? _lastSentText;
  final TextEditingController _controller = TextEditingController();
  late MqttBrowserClient client;

  @override
  void initState() {
    super.initState();
    _connectMqtt();
  }

  // Connect to MQTT broker
  Future<void> _connectMqtt() async {
    // Use the correct broker hostname and credentials
    client = MqttBrowserClient('ws://localhost:9001', 'flutter_client');
    client.port = 9001;
    client.keepAlivePeriod = 60;
    client.logging(on: true);
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;

    // Set the connection message
    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;

    try {
      await client.connect('flutter', 'password');
    } catch (e) {
      print('❌ MQTT connection failed: $e');
      client.disconnect();
      return;
    }

    client.subscribe(
      'simple/topic',
      MqttQos.atLeastOnce,
    ); // ✅ Subscribe to topic

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      ); // ✅ Convert payload to string

      print('⬅️ MQTT message received on topic ${c[0].topic}: $pt');

      try {
        final data = jsonDecode(pt);

        if (data is List) {
          for (final item in data) {
            final sender = item['sender'] ?? '';
            print('⬅️ Parsed JSON list item: $item');
            setState(() {
              messages.add(
                ChatMessage(
                  topic: item['topic'] ?? c[0].topic,
                  payload: item['payload'] ?? '',
                  timestamp:
                      item['timestamp'] ?? DateTime.now().toIso8601String(),
                  sender: sender,
                ),
              );
            });
          }
        } else if (data is Map) {
          final sender = data['sender'] ?? '';
          print('⬅️ Parsed JSON map: $data');
          setState(() {
            messages.add(
              ChatMessage(
                topic: data['topic'] ?? c[0].topic,
                payload: data['payload'] ?? data['msg'] ?? jsonEncode(data),
                timestamp:
                    data['timestamp'] ?? DateTime.now().toIso8601String(),
                sender: sender,
              ),
            );
          });
        }
      } catch (e) {
        print('⬅️ Non-JSON MQTT message: $pt');
        setState(() {
          messages.add(ChatMessage.fromMqtt(c[0].topic, pt, sender: ''));
        });
      }
    });
  }

  void _onConnected() => print('✅ Connected to MQTT broker!');
  void _onDisconnected() => print('🔌 Disconnected from MQTT broker');
  void _onSubscribed(String topic) => print('📡 Subscribed to $topic');
  // Send a message to the MQTT broker
  // This method handles both JSON and plain text messages
  void _sendMessage(String text, {bool asJson = true, bool retain = false}) {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      String payload;

      if (asJson) {
        final now = DateTime.now().toIso8601String();
        final msg = ChatMessage(
          topic: 'simple/topic',
          payload: text,
          timestamp: now,
          sender: clientId,
        );
        payload = jsonEncode({
          'topic': msg.topic,
          'payload': msg.payload,
          'timestamp': msg.timestamp,
          'sender': msg.sender,
        });
        print('➡️ Sending MQTT message (JSON): $payload');
        builder.addString(payload);
      } else {
        payload = text;
        print('➡️ Sending MQTT message (plain): $payload');
        builder.addString(payload);
      }

      client.publishMessage(
        'simple/topic',
        MqttQos.atLeastOnce,
        builder.payload!,
        retain: retain,
      );

      // Debugging log to confirm the message was sent
      print(
        '✅ Message published to topic "simple/topic" with retain=$retain: $payload',
      );

      // Do not add to messages here; will be added when received from broker
      _lastSentText = text;
      _controller.clear();
    } else {
      print('⚠️ Not connected to MQTT broker');
    }
  }

  // Dispose resources
  @override
  void dispose() {
    client.disconnect();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Monitor MQTT")),
      body: Column(
        children: [
          // Chat messages in order, alternating alignment
          Expanded(
            child: ListView.builder(
              reverse: false,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.sender == clientId;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Text(
                            msg.topic,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color.fromARGB(255, 206, 219, 241),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color:
                                isMe
                                    ? const Color.fromARGB(255, 199, 217, 231)
                                    : Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: Column(
                            crossAxisAlignment:
                                isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.payload,
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                msg.timestamp,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Input field for sending messages
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Colors.blueAccent),
                      ),

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      _sendMessage(_controller.text);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
