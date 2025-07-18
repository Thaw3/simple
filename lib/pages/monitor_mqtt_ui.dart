import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
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
  @override
  socket_io.Socket? socket;
  final TextEditingController _messageController = TextEditingController();
  final List<Chat> _messages = [];
  final String _currentUserName = 'Me';

  final Logger _logger = Logger();

  bool _isConnected = false; // New state variable for connection status

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  void _connectSocket() {
    socket = socket_io.io(
      'http://127.0.0.1:5001',
      socket_io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );
    _setupListeners();
  }

  @override
  void dispose() {
    _messageController.dispose();
    socket?.disconnect(); // Disconnect socket when the widget is disposed
    socket?.dispose(); // Dispose socket
    super.dispose();
  }

  void _setupListeners() {
    socket?.on('connect', (_) {
      _logger.i('Connected');
      setState(() {
        _isConnected = true; // Update status to connected
      });
    });
    socket?.on('disconnect', (_) {
      _logger.e('Disconnected');
      setState(() {
        _isConnected = false; // Update status to disconnected
      });
    });
    socket?.on('error', (err) {
      _logger.e('Socket Error: $err');
      setState(() {
        _isConnected = false; // Assume disconnected on error
      });
    });

    socket?.on('chat', (data) {
      try {
        final Chat incomingChat = Chat.fromJson(data);
        setState(() {
          _messages.insert(0, incomingChat); // Add new messages to the top
        });
      } catch (e) {
        _logger.e('Error parsing incoming chat: $e');
      }
    });
  }

  void _sendChat() {
    if (_messageController.text.isNotEmpty) {
      final String messageContent = _messageController.text;
      final String currentTime = DateFormat(
        'hh:mm a',
      ).format(DateTime.now()); // Format time

      final Chat chat = Chat(
        content: messageContent,
        time: currentTime,
        senderName: _currentUserName, // Set senderName for outgoing messages
      );

      socket?.emit(
        'chat_message',
        chat.toJson(),
      ); // Emit the message to the server

      _messageController.clear();
    }
  }

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
            child: ListView.builder(
              reverse: true, // Show latest messages at the bottom
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final Chat message = _messages[index];
                // Determine if the message is from the current user
                final bool isMe =
                    message.senderName ==
                    _currentUserName; // Now, 'isMe' is determined by comparing the message's senderName
                return MessageBubble(
                  chat: message,
                  isMe: isMe,
                  userName: message.senderName, // Display the actual senderName
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Send Data To tunnel >',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                    ),
                    onSubmitted: (_) => _sendChat(), // Send on enter
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: () {},
                  child: Icon(Icons.attach_file),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _sendChat,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
