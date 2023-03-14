import 'dart:async';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttController {
  MqttController({required this.topic});

  String topic;

  final client = MqttServerClient('broker.hivemq.com', '1883');

  Future<int> connect() async {
    client.logging(on: false);
    client.keepAlivePeriod = 60;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('dart_client')
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    print('Client connecting....');
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      print('Client exception: $e');
      client.disconnect();
    } on SocketException catch (e) {
      print('Socket exception: $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('Client connected');
    } else {
      print(
          'Client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      exit(-1);
    }
    return 0;
  }

  void publishMessage(String message) async {
    connect().whenComplete(() async {
      client.published!.listen((MqttPublishMessage message) {
        print(
            'Published topic: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
      });

      final builder = MqttClientPayloadBuilder();
      builder.addString(message);

      print('Subscribing to the $topic topic');
      client.subscribe(topic, MqttQos.exactlyOnce);

      print('Publishing our topic');
      client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);

      print('Unsubscribing');
      client.unsubscribe(topic);

      await MqttUtilities.asyncSleep(2);
      print('Disconnecting');
      client.disconnect();
    });
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      print('OnDisconnected callback is solicited, this is correct');
    }
    exit(-1);
  }

  /// The successful connect callback
  void onConnected() {
    print('OnConnected client callback - Client connection was sucessful');
  }

  /// Pong callback
  void pong() {
    print('Ping response client callback invoked');
  }
}
