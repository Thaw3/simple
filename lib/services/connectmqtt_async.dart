import 'dart:async';
import 'dart:convert'; // For potentially decoding JSON payloads
import 'dart:io'; // For file operations if logging to file

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:path_provider/path_provider.dart'; // Needed for getApplicationDocumentsDirectory
import 'package:logging/logging.dart'; // For logging

// Initialize a logger for this service
final Logger _logger = Logger('MqttService');

class MqttService {
  MqttServerClient? client;
  // Generate a unique client ID for each connection attempt
  final String _clientId = 'flutter_mqtt_client_${DateTime.now().millisecondsSinceEpoch}';

  // Callbacks to communicate status and messages back to the UI/Provider
  Function(String)? onStatusChanged;
  Function(String)? onMessageReceived;

  // Constructor to allow passing in callbacks
  MqttService({this.onStatusChanged, this.onMessageReceived}) {
    // Basic logger setup for demonstration purposes
    // In a real app, you might configure logging more robustly
    Logger.root.level = Level.ALL; // Set to ALL for verbose logging
    Logger.root.onRecord.listen((record) {
      // Print log records to console
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  /// Attempts to connect to the MQTT broker and subscribe to a topic.
  Future<void> connect({
    required String host,
    required String port,
    required String username,
    required String password,
    required String topic,
    required String logfilePath, // Path for logging
  }) async {
    _logger.info('Attempting to connect to MQTT broker: $host:$port');
    onStatusChanged?.call('Connecting...'); // Inform UI about connection attempt

    try {
      // Create an MQTT client instance
      client = MqttServerClient.withPort(host, _clientId, int.parse(port));

      // Enable client-side logging (outputs to console)
      client!.logging(on: true);
      // Set the keep-alive period in seconds. If no message is sent/received
      // within this period, a PINGREQ is sent.
      client!.keepAlivePeriod = 20;
      // Set callback handlers
      client!.onDisconnected = _onDisconnected;
      client!.onConnected = _onConnected;
      client!.onSubscribed = _onSubscribed;
      client!.pongCallback = _pong; // Called when a PINGRESP is received

      // Create the connection message.
      final MqttConnectMessage connMessage = MqttConnectMessage()
          .withClientIdentifier(_clientId)
          .withWillTopic('willtopic') // Optional: A message sent if client disconnects unexpectedly
          .withWillMessage('Will message')
          .startClean() // Non-persistent session (clean session)
          .withWillQos(MqttQos.atLeastOnce); // Quality of Service for the will message

      // Add username and password if provided
      if (username.isNotEmpty && password.isNotEmpty) {
        connMessage.authenticateAs(username, password);
      }

      _logger.info('MQTT client connecting....');
      client!.connectionMessage = connMessage;

      // Attempt to connect to the broker
      await client!.connect();
    } catch (e) {
      _logger.severe('Exception during MQTT connection: $e');
      disconnect(); // Ensure client is disconnected on error
      onStatusChanged?.call('Error: $e'); // Inform UI about the error
      return;
    }

    // Check if connection was successful
    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      _logger.info('MQTT client connected to $host');
      onStatusChanged?.call('Connected'); // Update UI status

      // Subscribe to the specified topic
      _logger.info('Subscribing to the topic: $topic');
      client!.subscribe(topic, MqttQos.atLeastOnce);

      // Listen for incoming messages on subscribed topics
      client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        // Convert the payload bytes to a string
        final String payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        _logger.info('Received message: topic is <${c[0].topic}>, payload is <-- $payload -->');
        onMessageReceived?.call(payload); // Send the message back to the UI/Provider

        // Optional: Write received message to a log file
        _writeLogToFile(logfilePath, 'Received message: Topic: ${c[0].topic}, Payload: $payload');
      });
    } else {
      _logger.severe('MQTT client connection failed - disconnecting, status is ${client!.connectionStatus}');
      onStatusChanged?.call('Failed: ${client!.connectionStatus!.state}');
      disconnect(); // Disconnect if connection failed
    }
  }

  /// Disconnects the MQTT client from the broker.
  void disconnect() {
    _logger.info('Disconnecting MQTT client');
    client?.disconnect(); // Disconnect if client exists
    onStatusChanged?.call('Disconnected'); // Update UI status
  }

  /// Callback for when the MQTT client is disconnected.
  void _onDisconnected() {
    _logger.info('MQTT client disconnected');
    onStatusChanged?.call('Disconnected'); // Update UI status
  }

  /// Callback for when the MQTT client is connected.
  void _onConnected() {
    _logger.info('MQTT client connected');
    onStatusChanged?.call('Connected'); // Update UI status
  }

  /// Callback for when the client has successfully subscribed to a topic.
  void _onSubscribed(String topic) {
    _logger.info('Subscribed to topic: $topic');
  }

  /// Callback for when a PINGRESP is received from the broker.
  void _pong() {
    _logger.info('Ping response received from MQTT broker');
  }

  /// Writes log content to a specified file within the application's document directory.
  Future<void> _writeLogToFile(String logFileName, String logContent) async {
    try {
      // Get the application's documents directory
      final directory = await getApplicationDocumentsDirectory();
      // Create a File object for the log file
      final file = File('${directory.path}/$logFileName');
      // Append the log content with a timestamp
      await file.writeAsString('${DateTime.now()}: $logContent\n', mode: FileMode.append);
    } catch (e) {
      _logger.severe('Error writing to log file $logFileName: $e');
    }
  }
}