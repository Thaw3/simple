import 'package:flutter/foundation.dart';

class MqttConnectionProvider with ChangeNotifier {
  String _host = '';
  String _topicName = '';
  String _port = ''; // Default MQTT port
  String _username = '';
  String _password = '';
  String _logfilePath = ''; // Default log file path
  String _status = 'Disconnected'; // Connection status
  String _incomingMessage = 'No message received yet.'; // To store the latest incoming message

  // Getters
  String get host => _host;
  String get topicName => _topicName;
  String get port => _port;
  String get username => _username;
  String get password => _password;
  String get logfilePath => _logfilePath;
  String get status => _status;
  String get incomingMessage => _incomingMessage; // Getter for incoming message

  // Setters
  void setHost(String host) {
    _host = host;
    notifyListeners();
  }

  void setTopicName(String topicName) {
    _topicName = topicName;
    notifyListeners();
  }

  void setPort(String port) {
    _port = port;
    notifyListeners();
  }

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void setLogfilePath(String path) {
    _logfilePath = path;
    notifyListeners();
  }

  void setStatus(String status) {
    _status = status;
    notifyListeners();
  }

  void setIncomingMessage(String message) {
    _incomingMessage = message;
    notifyListeners();
  }

  void reset() {
    _host = '';
    _topicName = '';
    _port = ''; // Reset to default MQTT port
    _username = '';
    _password = '';
    _logfilePath = ''; // Reset to default log path
    _status = 'Settings Reset';
    _incomingMessage = 'No message received yet.'; // Reset incoming message
    notifyListeners();
  }
}