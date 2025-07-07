import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple/widgets/mqtt_provider.dart'; 
import 'package:simple/services/connectmqtt_async.dart'; // Changed service import

class MqttClientPage extends StatefulWidget { // Renamed class
  const MqttClientPage({super.key});

  @override
  State<MqttClientPage> createState() => _MqttClientPageState(); // Renamed state class
}

class _MqttClientPageState extends State<MqttClientPage> { // Renamed state class
  // Changed controllers to MQTT specific ones
  final TextEditingController hostController = TextEditingController();
  final TextEditingController topicController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController logfileController = TextEditingController(); // Added logfile controller

  // Changed variable names for MQTT context
  // String? selectedApiType; // Not needed for this UI
  bool isPasswordVisible = false; // Changed from isApiKeyVisible

  // Removed apiTypes as we don't have a dropdown for API types in the sketch
  // final List<String> apiTypes = ['REST', 'GraphQL', 'SOAP'];
  late MqttService _mqttService; // Changed from _apiService

  @override
  void initState() {
    super.initState();
    // Initialize _mqttService and set up its callbacks
    _mqttService = MqttService(
      onStatusChanged: (status) {
        // Use a post-frame callback to update UI after build completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Provider.of<MqttConnectionProvider>(context, listen: false).setStatus(status);
          }
        });
      },
      onMessageReceived: (message) {
        // This callback updates the provider with the latest message.
        // Even if the UI doesn't display it directly anymore,
        // the provider still holds the last received message.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Provider.of<MqttConnectionProvider>(context, listen: false).setIncomingMessage(message);
          }
        });
      },
    );

    // Retrieve saved MQTT settings when the widget initializes
    final provider = Provider.of<MqttConnectionProvider>(context, listen: false); // Changed provider type
    hostController.text = provider.host;
    topicController.text = provider.topicName;
    portController.text = provider.port;
    userController.text = provider.username;
    passwordController.text = provider.password;
    logfileController.text = provider.logfilePath; // Initialize logfile controller
  }

  // Changed method name and parameters for MQTT connection
  Future<void> _connectMqtt() async {
    final provider = Provider.of<MqttConnectionProvider>(context, listen: false); // Changed provider type

    if (hostController.text.isEmpty || topicController.text.isEmpty || portController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in Host, Topic Name, and Port.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Save current values to provider before connecting
    provider.setHost(hostController.text);
    provider.setTopicName(topicController.text);
    provider.setPort(portController.text);
    provider.setUsername(userController.text);
    provider.setPassword(passwordController.text);
    provider.setLogfilePath(logfileController.text);

    await _mqttService.connect( // Call MQTT service connect
      host: hostController.text,
      port: portController.text,
      username: userController.text,
      password: passwordController.text,
      topic: topicController.text,
      logfilePath: logfileController.text,
    );
  }

  // Changed method name
  void _resetSettings() {
    final provider = Provider.of<MqttConnectionProvider>(context, listen: false); // Changed provider type
    hostController.clear();
    topicController.clear();
    portController.text = '1883'; // Reset to default MQTT port
    userController.clear();
    passwordController.clear();
    logfileController.text = 'mqtt_client.log'; // Reset to default log file name
    provider.reset();
  }

  // Changed method name
  void _disconnectMqtt() {
    _mqttService.disconnect(); // Call MQTT service disconnect
    // Status will be updated via the onDisconnected callback in MqttService
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MqttConnectionProvider>(context); // Changed provider type
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Host TextField (formerly Base URL)
            TextField(
              controller: hostController,
              onChanged: provider.setHost,
              decoration: const InputDecoration(labelText: 'Host'),
              keyboardType: TextInputType.text, // Changed to text for hostnames
            ),
            // Topic Name TextField (new)
            TextField(
              controller: topicController,
              onChanged: provider.setTopicName,
              decoration: const InputDecoration(labelText: 'Topic Name'),
              keyboardType: TextInputType.text,
            ),
            // Port TextField (new, formerly part of Base URL)
            TextField(
              controller: portController,
              onChanged: provider.setPort,
              decoration: const InputDecoration(labelText: 'Port'),
              keyboardType: TextInputType.number, // Port is a number
            ),
            // Username TextField (new, formerly part of API Key)
            TextField(
              controller: userController,
              onChanged: provider.setUsername,
              decoration: const InputDecoration(labelText: 'Username'),
              keyboardType: TextInputType.text,
            ),
            // Password TextField (new, formerly part of API Key)
            TextField(
              controller: passwordController,
              onChanged: provider.setPassword, // Update provider directly
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
              keyboardType: TextInputType.text,
            ),
            // Logfile TextField (new)
            TextField(
              controller: logfileController,
              onChanged: provider.setLogfilePath,
              decoration: const InputDecoration(labelText: 'Logfile'),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),

            // Connect/Disconnect Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _connectMqtt, // Call MQTT connect method
                    child: const Text('Connect'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _disconnectMqtt, // Call MQTT disconnect method
                    child: const Text('Disconnect'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetSettings, // Call MQTT reset method
              child: const Text('Reset Settings'),
            ),
            const SizedBox(height: 20),

            // Status Display (using MQTT provider's status)
            Text(
              'Status: ${provider.status}', // Changed from apiStatus
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}