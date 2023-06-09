import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code/plugins/base.dart';
import 'package:synchronized/synchronized.dart';
import 'package:provider/provider.dart';
import "package:http/http.dart" as http;

class Clipboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String text = Provider.of<ClipboardModel>(context, listen: false).clipboard;
    return Row(
      children: [
        TextButton(onPressed: ()=>{debugPrint("Sent clipboard")}, child: Text("发送剪切板")),
        TextButton(onPressed: ()=>{debugPrint("Receive clipboard")}, child: Text(text)),
      ],
    );
  }
}

class ClipboardModel extends ZBaseChangeNotifier {
  String clipboard = "";
   Lock lock = Lock();
  void setClipboard(String text) {
    lock.synchronized(() => clipboard = text);
    notifyListeners();
  }

  String getClipboard() {

    await http.get(url);
    String text = "";
    lock.synchronized(() => text = clipboard);
    return text;
  }

}