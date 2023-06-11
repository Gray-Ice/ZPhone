import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code/globals/project.dart';
import 'package:flutter_code/plugins/clipboard.dart';
import 'package:grpc/grpc.dart';
import 'package:provider/provider.dart';
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

class ServerInfo {
  ServerInfo(this.ip, this.port);
 String ip = "";
 int port = 0;
}

class NetMessage {
  NetMessage(this.code, this.message, this.pluginName);
  int code;
  String message;
  String pluginName;

  Map<String, dynamic> toJson() {
    return {"code": code, "message": message, "call-back-name": pluginName};
  }
}

class ServerConnection {
  ServerConnection(this.ip, this.port, this.url, this.context);

  String ip;
  int port;
  String url;
  final _lock = Lock();
  BuildContext context;
  WebSocket? _ws; // websocket

  Future<void> init() async {
    try{
      _ws = await WebSocket.connect("ws://$ip:$port$url").timeout(Duration(seconds: 1));
    } catch(e) {
      // Provider.of<ClipboardModel>(context, listen: false).setClipboard("This is clip");
      return;
    }
    while(_ws!.readyState == WebSocket.connecting) {
    }
    if(_ws!.readyState == WebSocket.open) {
      _ws!.add('{"code": $createConnectionCode, "message": "Hello, Server"}');
    }
      _ws?.listen((data) async {

        // Handle unexpected data
        if(data is List<int>) {
          debugPrint("Received bytes: $data");
          debugPrint("Unsupported type: byte. Will do nothing");
          return;
        }

        debugPrint("Received string:$data");
        Map<String, dynamic> jsonRep;
        try{
          jsonRep = jsonDecode(data);
        } on FormatException catch (e) {
          debugPrint("core.server_connection: json format error occurred when decoding response from server: $e");
          return;
        }

        int? code = jsonRep['code'] is int ? jsonRep['code'] : null;
        String? message = jsonRep['message'] is String ? jsonRep['message'] : null;
        String? pluginName = jsonRep['call-back-name'] is String ? jsonRep['call-back-name'] : null;
        if (code == null || message == null || pluginName == null) {
          debugPrint("core.server_connection: error: can not find specify key.\n$jsonRep");
          return;
        }
        debugPrint("$jsonRep");

        if(code == phoneCallbackCode) {
          debugPrint("An phone callback method was trigger, target plugin: $pluginName");
           var plugin = PWMap[pluginName];
           debugPrint("$plugin");
           ServerInfo info = ServerInfo(ip, port);
           plugin?.onServerCall(info);
        }

      }, onDone: (){
        showDialog(context: context, builder: (BuildContext ctx){
          return const AlertDialog(
            title: Text("与服务器的连接已关闭"),
          );
        });
      });

  }

  Future<void> keepWebsocketConnection(WebSocket ws) async {
    while(ws.readyState == WebSocket.open) {
      await Future.delayed(const Duration(seconds: 1));
    }
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
