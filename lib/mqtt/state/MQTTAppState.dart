import 'package:flutter/material.dart';

enum MQTTAppConnectionState { connected, disconnected, connecting }

class MQTTAppState with ChangeNotifier {
  MQTTAppConnectionState _appConnectionState =
      MQTTAppConnectionState.disconnected;

  String _receivedText = ''; // Text that has been received by the MQTT client
  String _historyText =
      ''; // Accumulated history of text received from the MQTT client

  void setReceivedText(String text) {
    _receivedText = text;
    _historyText = '\n$_receivedText' + _historyText;
    notifyListeners();
  }

  void setAppConnectionState(MQTTAppConnectionState state) {
    // Set the connection state of the app
    // This allows the UI to update accordingly
    _appConnectionState = state;
    notifyListeners();
  }

  String get receivedText => _receivedText;
  String get historyText => _historyText;
  MQTTAppConnectionState get appConnectionState => _appConnectionState;
}
