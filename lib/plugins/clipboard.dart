import 'dart:convert';
import 'dart:io';

import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code/plugins/base.dart';
import 'package:synchronized/synchronized.dart';
import "package:http/http.dart" as http;
import 'package:http/http.dart' as http;

import '../core/server_connection.dart';

class Clipboard extends StatefulWidget {
  const Clipboard({super.key});

  @override
  _ClipboardState createState() => _ClipboardState();
}

class _ClipboardState extends State<Clipboard> {
  bool lastServerCalled = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // if (beCalled != lastServerCalled) {
    //   debugPrint("Clipboard be called from server");
    // }
  }

  @override
  Widget build(BuildContext context) {
    // String text = Provider.of<ClipboardModel>(context, listen: false).clipboard;

    debugPrint("Rebuild");
    return Row(
      children: [
        TextButton(
            onPressed: () => {debugPrint("Sent clipboard")},
            child: const Text("发送剪切板")),
        TextButton(
            onPressed: () => {debugPrint("Receive clipboard")},
            child: const Text("获取剪切板")),
      ],
    );
  }
}

class ClipboardModel extends ZBaseChangeNotifier {
  String clipboard = "";
  Lock lock = Lock();
  String serverURL = "/clipboard/phone";

  void setClipboardWithServerData(String text) {
    debugPrint("Set clipboard");
    lock.synchronized(() => clipboard = text);
  }

  String getClipboard() {
    String text = "";
    lock.synchronized(() => text = clipboard);
    return text;
  }

  @override
  Future<void> onServerCall(ServerInfo serverInfo) async {
    http.Response rep;
    try{
      rep = await http.get(Uri.parse("http://${serverInfo.ip}:${serverInfo.port}$serverURL"));
    } on SocketException catch (e) {
      debugPrint("SocketException occurred when clipboard plugin {onServerCall} be called. Error info: $e");
      return;
    }
    if(rep.statusCode != 200) {
      debugPrint("clipboard plugin: error: statusCode != 200");
      return;
    }

    Map<String, dynamic> jsonRep;
    try{
      jsonRep = jsonDecode(rep.body);
    } on FormatException catch (e) {
      debugPrint("clipboard plugin: json decode error: $e");
      return;
    }

    debugPrint("$jsonRep");
  }
}
