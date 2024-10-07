import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_test/mqtt/state/MQTTAppState.dart';
import 'package:flutter/material.dart';

//Initialize the MQTT client, connect to the host and publish messages, manages the connection state and updates
class MQTTManager {
  // Private instance of client
  final MQTTAppState _currentState;
  MqttServerClient? _client;
  final String _identifier;
  final String _host;
  final String _topic;
  

  // Constructor
  // ignore: sort_constructors_first
  MQTTManager(
      {required String host,
      required String topic,
      required String identifier,
      required MQTTAppState state})
      : _identifier = identifier,
        _host = host,
        _topic = topic,
        _currentState = state;

  void initializeMQTTClient() {
    _client = MqttServerClient.withPort(_host, _identifier, 1883);
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = onDisconnected;
    _client!.secure = false;
    _client!.logging(on: true);

    // Set the connection notifier
    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;

    // Connection message configuration
    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier)
        .withWillTopic(_topic)
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    print('EXAMPLE::Mosquitto client connecting....');
    _client!.connectionMessage = connMess;
  }

  //Connect to the host
  void connect() async {
    assert(_client != null);
    try {
      print('EXAMPLE::Mosquitto client connecting....');
      print('EXAMPLE::host is $_host');

//client port

      await _client!.connect();
    } on Exception catch (e) {
      print('EXAMPLE::client exception - $e');
      // Retry logic (optional)
      // Future.delayed(Duration(seconds: 5), () => connect());
      disconnect();
    }
  }

  void disconnect() {
    if (_client != null) {
      print('Disconnecting MQTT client...');
      _client!.disconnect();
    } else {
      print('Client is not initialized, cannot disconnect.');
    }
  }

  //Publish something to the topic
  void publish(String message) {
    // we need to create a MqttClientPayloadBuilder to send a payload
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    // Add the message to payload
    builder.addString(message);
    // Publish it to the topic
    _client!.publishMessage(_topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void onDisconnected() {
    print('Client disconected');
    _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
  }

  void onConnected() {
    // sets the connection state to connected
    _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
    print('EXAMPLE::Mosquitto client connected....');

    // Subscribe to the topic
    _client!.subscribe(_topic, MqttQos.atLeastOnce);

    //adds a listener to listen to the updates
    _client!.updates!.listen(
      (List<MqttReceivedMessage<MqttMessage>>? c) {
        final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
        final String pt =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message!);
        print(
            'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
        _currentState.setReceivedText(pt);
      },
    );
  }

  void onSubscribed(String topic) {
    print('Subscribed to $topic');
  }
}
