import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MqttPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MqttPage extends StatefulWidget {
  const MqttPage({super.key});

  @override
  State<MqttPage> createState() => _MqttPageState();
}

class _MqttPageState extends State<MqttPage> {
  final String broker = 'test.mosquitto.org';
  final int port = 1883;
  final String topic = 'RepairShop/Username';
  final String clientId = 'flutter_client_test';

  late MqttServerClient client;
  String connectionStatus = 'Disconnected';
  final TextEditingController messageController = TextEditingController();

  Future<void> connect() async {
    client = MqttServerClient(broker, clientId);
    client.port = port;
    client.keepAlivePeriod = 20;
    client.logging(on: true);
    client.setProtocolV311();
    client.onConnected = () {
      setState(() {
        connectionStatus = '✅ Connected';
      });
    };
    client.onDisconnected = () {
      setState(() {
        connectionStatus = '🔌 Disconnected';
      });
    };

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client.connectionMessage = connMessage;

    try {
      setState(() {
        connectionStatus = '🔄 Connecting...';
      });
      await client.connect();
    } catch (e) {
      setState(() {
        connectionStatus = '❌ Failed: $e';
      });
      client.disconnect();
    }
  }

  void publishMessage(String text) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(text);
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("📤 Message Sent: $text")),
    );
  }

  @override
  void dispose() {
    client.disconnect();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MQTT Flutter Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Status: $connectionStatus'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: connect,
              child: const Text('🔌 Connect to MQTT'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message to send',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                if (client.connectionStatus?.state == MqttConnectionState.connected) {
                  publishMessage(messageController.text.trim());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("❗ Not connected")),
                  );
                }
              },
              child: const Text('📤 Publish Message'),
            ),
          ],
        ),
      ),
    );
  }
}
