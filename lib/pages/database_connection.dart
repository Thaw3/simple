import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple/widgets/database_provider.dart';

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

  String? selectedDbType;
  bool isPasswordVisible = false;
  String status = "";

  final List<String> dbTypes = ['SQL', 'NoSQL'];

  void connectToDatabase() {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    provider.setHost(hostController.text);
    provider.setPassword(passwordController.text);
    provider.setUsername(userController.text);
    provider.setDatabaseName(dbNameController.text);
    provider.setDatabaseType(selectedDbType);
    provider.setStatus("Connected");
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
              onChanged: (String? newValue) {
                setState(() {
                  selectedDbType = newValue;
                });
              },
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
              controller: userController,
              onChanged: provider.setUsername,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              onChanged: provider.setPassword,
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
              onPressed: connectToDatabase,
              child: Text('Connect'),
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
