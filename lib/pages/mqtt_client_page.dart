import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple/widgets/mqtt_api_connection_provider.dart';
import 'package:simple/services/mqtt_service.dart';

class MqttClientPage extends StatefulWidget {
  const MqttClientPage({super.key});

  @override
  State<MqttClientPage> createState() => _MqttClientPageState();
}

class _MqttClientPageState extends State<MqttClientPage> {
  final TextEditingController hostController = TextEditingController();
  final TextEditingController topicController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController _keepAliveController = TextEditingController(
    text: '60',
  );
  int _keepAlive = 60;
  int _qos = 0;

  bool isPasswordVisible = false;
  bool isConnecting = false;

  final _apiService = APIService();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<APIConnectionProvider>(context, listen: false);
    hostController.text = provider.host ?? '';
    topicController.text = provider.topicName ?? '';
    portController.text = provider.port ?? '';
    userController.text = provider.username ?? '';
    passwordController.text = provider.password ?? '';
  }

  bool _validateInputs() {
    if (hostController.text.isEmpty ||
        topicController.text.isEmpty ||
        portController.text.isEmpty ||
        userController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> connectApi() async {
    if (!_validateInputs()) return;

    final provider = Provider.of<APIConnectionProvider>(context, listen: false);

    setState(() => isConnecting = true);

    final response = await _apiService.connect(
      host: hostController.text,
      port: portController.text,
      username: userController.text,
      password: passwordController.text,
      topicName: topicController.text,
      keepAlive: _keepAlive,
      qos: _qos,
    );

    setState(() => isConnecting = false);

    final status = response['status'] ?? 'Unknown';
    final message = response['message'] ?? 'No message';
    provider.setStatus('$status: $message');
  }

  void _resetSettings() {
    final provider = Provider.of<APIConnectionProvider>(context, listen: false);
    hostController.clear();
    topicController.clear();
    portController.clear();
    userController.clear();
    passwordController.clear();
    provider.reset();
  }

  void _disconnectMqtt() {
    final provider = Provider.of<APIConnectionProvider>(context, listen: false);
    provider.setStatus("Disconnected");
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<APIConnectionProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField(
              controller: hostController,
              label: 'Host',
              onChanged: provider.setHost,
            ),
            _buildTextField(
              controller: topicController,
              label: 'Topic Name',
              onChanged: provider.setTopicName,
            ),
            _buildTextField(
              controller: portController,
              label: 'Port',
              keyboardType: TextInputType.number,
              onChanged: provider.setPort,
            ),
            _buildTextField(
              controller: userController,
              label: 'Username',
              onChanged: provider.setUsername,
            ),
            _buildTextField(
              controller: passwordController,
              label: 'Password',
              obscureText: !isPasswordVisible,
              onChanged: provider.setPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed:
                    () =>
                        setState(() => isPasswordVisible = !isPasswordVisible),
              ),
            ),

            _buildTextField(
              controller: _keepAliveController,
              label: 'Keep Alive Interval (seconds)',
              keyboardType: TextInputType.number,
              onChanged: (val) {
                setState(() => _keepAlive = int.tryParse(val) ?? 60);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<int>(
                value: _qos,
                decoration: const InputDecoration(
                  labelText: 'QoS',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('QoS 0')),
                  DropdownMenuItem(value: 1, child: Text('QoS 1')),
                  DropdownMenuItem(value: 2, child: Text('QoS 2')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _qos = val);
                },
              ),
            ),

            ElevatedButton(
              onPressed: isConnecting ? null : connectApi,
              child:
                  isConnecting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Connect'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _disconnectMqtt,
              child: const Text('Disconnect'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _resetSettings,
              child: const Text('Reset Settings'),
            ),
            const SizedBox(height: 24),
            Text(
              'Status: ${provider.status}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
