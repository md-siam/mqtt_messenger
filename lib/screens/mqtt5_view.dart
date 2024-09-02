import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../mqtt5/MQTT5Manager.dart';
import '../mqtt5/state/MQTT5AppState.dart';

class MQTT5View extends StatefulWidget {
  const MQTT5View({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MQTT5ViewState();
  }
}

class _MQTT5ViewState extends State<MQTT5View> {
  final TextEditingController _hostTextController = TextEditingController();
  final TextEditingController _messageTextController = TextEditingController();
  final TextEditingController _topicTextController = TextEditingController();
  late MQTT5AppState currentAppState;
  late MQTT5Manager manager;
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
    final MQTT5AppState appState = Provider.of<MQTT5AppState>(context);
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
        'MQTT 5',
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

  Widget _buildTextFieldWith(TextEditingController controller, String hintText, MQTT5AppConnectionState state) {
    bool shouldEnable = false;
    if (controller == _messageTextController && state == MQTT5AppConnectionState.connected) {
      shouldEnable = true;
    } else if ((controller == _hostTextController && state == MQTT5AppConnectionState.disconnected) || (controller == _topicTextController && state == MQTT5AppConnectionState.disconnected)) {
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

  Widget _buildConnectedButtonFrom(MQTT5AppConnectionState state) {
    return Row(
      children: <Widget>[
        Expanded(
          // ignore: deprecated_member_use
          child: ElevatedButton(
            // color: Colors.lightBlueAccent,
            onPressed: state == MQTT5AppConnectionState.disconnected ? _configureAndConnect : null,
            // color: Colors.lightBlueAccent,
            child: const Text('Connect'), //
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          // ignore: deprecated_member_use
          child: ElevatedButton(
            // color: Colors.redAccent,
            onPressed: state == MQTT5AppConnectionState.connected ? _disconnect : null,
            // color: Colors.redAccent,
            child: const Text('Disconnect'), //
          ),
        ),
      ],
    );
  }

  Widget _buildSendButtonFrom(MQTT5AppConnectionState state) {
    // ignore: deprecated_member_use
    return ElevatedButton(
      // color: Colors.green,
      onPressed: state == MQTT5AppConnectionState.connected
          ? () {
              _publishMessage(_messageTextController.text);
            }
          : null,
      // color: Colors.green,
      child: const Text('Send'), //
    );
  }

  // Utility functions
  String _prepareStateMessageFrom(MQTT5AppConnectionState state) {
    switch (state) {
      case MQTT5AppConnectionState.connected:
        return 'Connected';
      case MQTT5AppConnectionState.connecting:
        return 'Connecting';
      case MQTT5AppConnectionState.disconnected:
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
    manager = MQTT5Manager(
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
