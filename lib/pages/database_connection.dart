import 'package:flutter/material.dart';

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
    // Simulate connection logic
    setState(() {
      status = 'Connecting...';
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        status = 'Connected to ${selectedDbType ?? 'Database'}';
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Database Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Database Type'),
              value: selectedDbType,
              onChanged: (String? newValue) {
                setState(() {
                  selectedDbType = newValue;
                });
              },
              items: dbTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
            ),
            TextField(
              controller: hostController,
              decoration: InputDecoration(labelText: 'Host IP / Hostname'),
              keyboardType: TextInputType.url,
            ),
            TextField(
              controller: dbNameController,
              decoration: InputDecoration(labelText: 'Database Name'),
            ),
            TextField(
              controller: userController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
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
              'Status: $status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}