import 'package:flutter/material.dart';

enum MQTT5AppConnectionState { connected, disconnected, connecting }

class MQTT5AppState with ChangeNotifier {
  MQTT5AppConnectionState _appConnectionState = MQTT5AppConnectionState.disconnected;
  String _receivedText = '';
  String _historyText = '';

  void setReceivedText(String text) {
    _receivedText = text;
    _historyText = '$_historyText\n$_receivedText';
    notifyListeners();
  }

  void setAppConnectionState(MQTT5AppConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  String get getReceivedText => _receivedText;
  String get getHistoryText => _historyText;
  MQTT5AppConnectionState get getAppConnectionState => _appConnectionState;
}
