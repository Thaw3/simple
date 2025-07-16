// Custom MessageBubble Widget for better chat UI
import 'package:flutter/material.dart';
import 'package:simple/services/monitor_mqtt_service.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key? key,
    required this.chat,
    required this.isMe,
    required this.userName,
  }) : super(key: key);

  final Chat chat;
  final bool isMe;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15.0),
            topRight: const Radius.circular(15.0),
            bottomLeft:
                isMe ? const Radius.circular(15.0) : const Radius.circular(0),
            bottomRight:
                isMe ? const Radius.circular(0) : const Radius.circular(15.0),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              userName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              chat.content, // Message text
              style: TextStyle(color: isMe ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 4.0),
            Text(
              chat.time, // Real time
              style: TextStyle(
                fontSize: 10.0,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
