import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple/widgets/database_provider.dart';
import 'package:simple/services/connectdb_async.dart';

class DatabaseConnection extends StatefulWidget {
  const DatabaseConnection({super.key});

  @override
  State<DatabaseConnection> createState() => _DatabaseConnectionState();
}

class _DatabaseConnectionState extends State<DatabaseConnection> {
  final TextEditingController hostController = TextEditingController();
  final TextEditingController dbNameController = TextEditingController();
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController portController = TextEditingController();

  String? selectedDbType;
  bool isPasswordVisible = false;
  String status = "";

  final List<String> dbTypes = ['mysql', 'mariadb'];
  final _dbService = DatabaseConnectionService();

  Future<void> connectToDatabase({
    required String host,
    required String dbName,
    required String port,
    required String username,
    required String password,
    required String dbType,
  }) async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final response = await _dbService.connect(
      host: host,
      dbName: dbName,
      port: port,
      username: username,
      password: password,
      dbType: dbType,
    );
    final status = response['status'] ?? 'error';
    final message = response['message'] ?? 'Unknown error';
    provider.setStatus('$status: $message');
  }

  void resetDatabaseSettings() {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    hostController.clear();
    dbNameController.clear();
    portController.clear();
    userController.clear();
    passwordController.clear();
    provider.reset();
  }
  void disconnectFromDatabase() {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    provider.setStatus("Disconnected");
  }

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    hostController.text = provider.host ?? '';
    dbNameController.text = provider.databaseName ?? '';
    userController.text = provider.username ?? '';
    passwordController.text = provider.password ?? '';
    selectedDbType = provider.databaseType;
    portController.text = provider.port ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Database Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Database Type'),
              value: provider.databaseType,
              onChanged: provider.setDatabaseType,
              items:
                  dbTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
            ),
            TextField(
              controller: hostController,
              onChanged: provider.setHost,
              decoration: InputDecoration(labelText: 'Host IP / Hostname'),
              keyboardType: TextInputType.url,
            ),
            TextField(
              controller: dbNameController,
              onChanged: provider.setDatabaseName,
              decoration: InputDecoration(labelText: 'Database Name'),
            ),
            TextField(
              controller: portController,
              onChanged: provider.setPort,
              decoration: InputDecoration(labelText: 'Port Number'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: userController,
              onChanged: provider.setUsername,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              //onChanged: provider.setPassword,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (hostController.text.isEmpty ||
                    dbNameController.text.isEmpty ||
                    portController.text.isEmpty ||
                    userController.text.isEmpty ||
                    passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in all fields'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  await connectToDatabase(
                    host: hostController.text,
                    dbName: dbNameController.text,
                    port: portController.text,
                    username: userController.text,
                    password: passwordController.text,
                    dbType: provider.databaseType ?? dbTypes.first,
                  );
                }
              },
              child: Text('Connect'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: disconnectFromDatabase,
              child: Text('Disconnect'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetDatabaseSettings,
              child: Text('Reset Settings'),
            ),
            SizedBox(height: 20),
            Text(
              'Status: ${provider.status}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
