import 'package:flutter/foundation.dart';

class APIConnectionProvider with ChangeNotifier {
  // Private fields
  String _host = '';
  String _topicName = '';
  String _port = '';
  String _username = '';
  String _password = '';
  String _status = 'Disconnected';
  String _incomingMessage = 'No message received yet.';

  // Getters
  String get host => _host;
  String get topicName => _topicName;
  String get port => _port;
  String get username => _username;
  String get password => _password;
  String get status => _status;
  String get incomingMessage => _incomingMessage;

  // Setters with notifyListeners
  void setHost(String value) {
    _host = value;
    notifyListeners();
  }

  void setTopicName(String value) {
    _topicName = value;
    notifyListeners();
  }

  void setPort(String value) {
    _port = value;
    notifyListeners();
  }

  void setUsername(String value) {
    _username = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setStatus(String value) {
    _status = value;
    notifyListeners();
  }

  void setIncomingMessage(String value) {
    _incomingMessage = value;
    notifyListeners();
  }

  // Reset all fields to default state
  void reset() {
    _host = '';
    _topicName = '';
    _port = '';
    _username = '';
    _password = '';
    _status = 'Settings Reset';
    _incomingMessage = 'No message received yet.';
    notifyListeners();
  }
}
