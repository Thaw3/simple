import 'package:flutter/foundation.dart';

class DatabaseProvider with ChangeNotifier {
  String? _databaseType;
  String _host = '';
  String _databaseName = '';
  String _username = '';
  String _password = '';
  String _status = 'Not Connected';

  // Getters
  String? get databaseType => _databaseType;
  String get host => _host;
  String get databaseName => _databaseName;
  String get username => _username;
  String get password => _password;
  String get status => _status;

  // Setters
  void setDatabaseType(String? type) {
    _databaseType = type;
    notifyListeners();
  }

  void setHost(String host) {
    _host = host;
    notifyListeners();
  }

  void setDatabaseName(String name) {
    _databaseName = name;
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

  void setStatus(String status) {
    _status = status;
    notifyListeners();
  }

  // Reset method if needed
  void reset() {
    _databaseType = null;
    _host = '';
    _databaseName = '';
    _username = '';
    _password = '';
    _status = '';
    notifyListeners();
  }
}
