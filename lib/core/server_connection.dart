import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';
import 'package:synchronized/synchronized.dart';
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
      _ws?.listen((data) async {
        if(data is List<int>) {
          debugPrint("Received bytes: $data");
        } else if(data is String) {
          debugPrint("Received string: $data");
        } else {
          debugPrint("Received unknown type: $data");
        }
      }, onDone: (){
        showDialog(context: context, builder: (BuildContext ctx){
          return const AlertDialog(
            title: Text("与服务器的连接已关闭"),
          );
        });
      });

  }

  bool isConnectionReady() {
    if(_ws == null) {
      debugPrint("Connection is not ready");
      return false;
    }
    return true;
  }

  // send data to server
  bool sendData(List<int> utf8EncodedJsonData) {
    if (!isConnectionReady()) {
      return false;
    }

    _lock.synchronized(() {
      debugPrint("Sending message: $utf8EncodedJsonData");
      // _ws?.add(utf8EncodedJsonData);
      _ws?.add("1232132183idjksasa bdakidasdnaskdasdjasdlais");
      debugPrint("Message sent.");
      debugPrint("${_ws?.readyState}");
    });
    return true;
  }


}
