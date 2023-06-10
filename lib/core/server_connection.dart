import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';

int unSupportedCode          = 1003;
int hearBeatCode             = 4001;
int phoneCallbackCode        = 4002;
int authCode                 = 4003;
int errorCode                = 4004;
int createConnectionCode     = 4005;
int phoneHandleResultCode    = 4006;
int refuseConnectionCode     = 4007;
int queryPluginsCode         = 4008; // query plugins
int disConnectCode           = 4009;
int notFindAnotherDeviceCode = 4010;
int deviceOnlineCode         = 4011;
int deviceOfflineCode        = 4012;

class ServerConnection {
  ServerConnection(this.ip, this.port, this.url, this.context);

  String ip;
  int port;
  String url;
  final _lock = Lock();
  BuildContext context;
  WebSocket? _ws; // websocket

  Future<void> init() async {
    _ws = await WebSocket.connect("ws://$ip:$port$url");
    // waiting for connection be ready
    while(_ws!.readyState == WebSocket.connecting) {
    }
    if(_ws!.readyState == WebSocket.open) {
      _ws!.add('{"code": $createConnectionCode, "message": "Hello, Server"}');
    }
      _ws?.listen((data) async {
        if(data is List<int>) {
          debugPrint("Received bytes: $data");
          debugPrint("Unsupported type: byte. Will do nothing");
          return;
        }

        debugPrint("Received string:$data");

      }, onDone: (){
        showDialog(context: context, builder: (BuildContext ctx){
          return const AlertDialog(
            title: Text("与服务器的连接已关闭"),
          );
        });
      });

  }

  void createConnection() {
    sendData('{"message":"hello","code":4005,"call-back-url":"callback","call-back-method":"post","call-back-plugin-name":"callbackpligin"}');
  }

  bool isConnectionReady() {
    if(_ws == null) {
      debugPrint("Connection is not ready");
      return false;
    }
    return true;
  }

  // send data to server
  bool sendData(String jsonText) {
    if (!isConnectionReady()) {
      return false;
    }

    _lock.synchronized(() {
      debugPrint("Sending message: $jsonText");
      // _ws?.add(utf8EncodedJsonData);
      // _ws?.add('{"message":"hello","code":4005,"call-back-url":"callback","call-back-method":"post","call-back-plugin-name":"callbackpligin"}');
      _ws?.add(jsonText);
      // _ws?.add("1232132183idjksasa bdakidasdnaskdasdjasdlais");
      // debugPrint("Message sent.");
      debugPrint("${_ws?.readyState}");
    });
    return true;
  }


}
