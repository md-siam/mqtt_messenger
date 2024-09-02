import 'dart:developer';

import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';

import 'state/MQTT5AppState.dart';

class MQTT5Manager {
  // Private instance of client
  final MQTT5AppState _currentState;
  MqttServerClient? _client;
  final String _identifier;
  final String _host;
  final String _topic;

  // Constructor
  // ignore: sort_constructors_first
  MQTT5Manager({required String host, required String topic, required String identifier, required MQTT5AppState state})
      : _identifier = identifier,
        _host = host,
        _topic = topic,
        _currentState = state;

  void initializeMQTTClient() {
    _client = MqttServerClient(_host, _identifier);
    _client!.port = 1883;
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = onDisconnected;
    _client!.secure = false;
    _client!.logging(on: true);

    /// Add the successful connection callback
    _client!.onConnected = onConnected;

    _client!.onSubscribed = onSubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier)
        .withWillTopic('willtopic') // If you set this you must set a will message
        // .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atMostOnce);

    log('EXAMPLE::Mosquitto client connecting....');
    _client!.connectionMessage = connMess;
  }

  // Connect to the host
  // ignore: avoid_void_async
  void connect() async {
    assert(_client != null);
    try {
      log('EXAMPLE::Mosquitto start client connecting....');
      _currentState.setAppConnectionState(MQTT5AppConnectionState.connecting);
      await _client!.connect();
    } on Exception catch (e) {
      log('EXAMPLE::client exception - $e');
      disconnect();
    }
  }

  void disconnect() {
    log('Disconnected');
    _client!.disconnect();
  }

  void publish(String message) {
    final MqttPayloadBuilder builder = MqttPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(_topic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(MqttSubscription topic) {
    log('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    log('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (_client!.connectionStatus!.disconnectionOrigin == MQTT5AppConnectionState.disconnected) {
      log('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
    _currentState.setAppConnectionState(MQTT5AppConnectionState.disconnected);
  }

  /// The successful connect callback
  void onConnected() {
    _currentState.setAppConnectionState(MQTT5AppConnectionState.connected);
    log('EXAMPLE::Mosquitto client connected....');
    _client!.subscribe(_topic, MqttQos.atLeastOnce);
    _client!.updates.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      // ignore: avoid_as
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      // final MqttPublishMessage recMess = c![0].payload;
      final String pt = MqttUtilities.bytesToStringAsString(recMess.payload.message!);
      _currentState.setReceivedText(pt);
      log('EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      log('');
    });
    log('EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }
}
