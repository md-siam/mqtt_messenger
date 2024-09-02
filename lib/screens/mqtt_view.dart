import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../mqtt/MQTTManager.dart';
import '../mqtt/state/MQTTAppState.dart';

class MQTTView extends StatefulWidget {
  const MQTTView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MQTTViewState();
  }
}

class _MQTTViewState extends State<MQTTView> {
  final TextEditingController _hostTextController = TextEditingController();
  final TextEditingController _messageTextController = TextEditingController();
  final TextEditingController _topicTextController = TextEditingController();
  late MQTTAppState currentAppState;
  late MQTTManager manager;
  //
  final String _uuid = "Samsung";

  @override
  void initState() {
    super.initState();
    _hostTextController.text = "test.mosquitto.org";
    _topicTextController.text = "flutter/amp/cool";

    /*
    _hostTextController.addListener(_printLatestValue);
    _messageTextController.addListener(_printLatestValue);
    _topicTextController.addListener(_printLatestValue);

     */
  }

  @override
  void dispose() {
    _hostTextController.dispose();
    _messageTextController.dispose();
    _topicTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    // Keep a reference to the app state.
    currentAppState = appState;
    final Scaffold scaffold = Scaffold(
      appBar: _buildAppBar(context),
      body: _buildColumn(),
    );
    return scaffold;
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'MQTT',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.blue,
    );
  }

  Widget _buildColumn() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _buildConnectionStateText(_prepareStateMessageFrom(currentAppState.getAppConnectionState)),
          _buildEditableColumn(),
          _buildScrollableTextWith(currentAppState.getHistoryText),
        ],
      ),
    );
  }

  Widget _buildEditableColumn() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[_buildTextFieldWith(_hostTextController, 'Enter broker address', currentAppState.getAppConnectionState), const SizedBox(height: 10), _buildTextFieldWith(_topicTextController, 'Enter a topic to subscribe or listen', currentAppState.getAppConnectionState), const SizedBox(height: 10), _buildPublishMessageRow(), const SizedBox(height: 10), _buildConnectedButtonFrom(currentAppState.getAppConnectionState)],
      ),
    );
  }

  Widget _buildPublishMessageRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: _buildTextFieldWith(_messageTextController, 'Enter a message', currentAppState.getAppConnectionState),
        ),
        _buildSendButtonFrom(currentAppState.getAppConnectionState)
      ],
    );
  }

  Widget _buildConnectionStateText(String status) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            color: status == "Connected" ? Colors.green : Colors.deepOrangeAccent,
            child: Text(
              status,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldWith(TextEditingController controller, String hintText, MQTTAppConnectionState state) {
    bool shouldEnable = false;
    if (controller == _messageTextController && state == MQTTAppConnectionState.connected) {
      shouldEnable = true;
    } else if ((controller == _hostTextController && state == MQTTAppConnectionState.disconnected) || (controller == _topicTextController && state == MQTTAppConnectionState.disconnected)) {
      shouldEnable = true;
    }
    return TextField(
        enabled: shouldEnable,
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
          labelText: hintText,
        ));
  }

  Widget _buildScrollableTextWith(String text) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: 400,
        height: 200,
        child: SingleChildScrollView(
          child: Text(text),
        ),
      ),
    );
  }

  Widget _buildConnectedButtonFrom(MQTTAppConnectionState state) {
    return Row(
      children: <Widget>[
        Expanded(
          // ignore: deprecated_member_use
          child: ElevatedButton(
            // color: Colors.lightBlueAccent,
            onPressed: state == MQTTAppConnectionState.disconnected ? _configureAndConnect : null,
            // color: Colors.lightBlueAccent,
            child: const Text('Connect'), //
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          // ignore: deprecated_member_use
          child: ElevatedButton(
            // color: Colors.redAccent,
            onPressed: state == MQTTAppConnectionState.connected ? _disconnect : null,
            // color: Colors.redAccent,
            child: const Text('Disconnect'), //
          ),
        ),
      ],
    );
  }

  Widget _buildSendButtonFrom(MQTTAppConnectionState state) {
    // ignore: deprecated_member_use
    return ElevatedButton(
      // color: Colors.green,
      onPressed: state == MQTTAppConnectionState.connected
          ? () {
              _publishMessage(_messageTextController.text);
            }
          : null,
      // color: Colors.green,
      child: const Text('Send'), //
    );
  }

  // Utility functions
  String _prepareStateMessageFrom(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return 'Connected';
      case MQTTAppConnectionState.connecting:
        return 'Connecting';
      case MQTTAppConnectionState.disconnected:
        return 'Disconnected';
    }
  }

  void _configureAndConnect() {
    // ignore: flutter_style_todos
    // TODO: Use UUID
    // String osPrefix = 'Flutter_iOS';
    // if (Platform.isAndroid) {
    //   osPrefix = 'Flutter_Android';
    // }
    manager = MQTTManager(
      host: _hostTextController.text,
      topic: _topicTextController.text,
      identifier: _uuid,
      state: currentAppState,
    );
    manager.initializeMQTTClient();
    manager.connect();
  }

  void _disconnect() {
    manager.disconnect();
  }

  void _publishMessage(String text) {
    String osPrefix = _uuid;
    // if (Platform.isAndroid) {
    //   osPrefix = 'Flutter_Android';
    // }
    final String message = '$osPrefix says: $text';
    manager.publish(message);
    _messageTextController.clear();
  }
}
