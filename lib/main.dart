import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:flutter_code/views/menu_drawer.dart";

import 'core/server_connection.dart';

class Home extends StatelessWidget {
  ServerConnection? sc;
  @override
  Widget build(BuildContext context) {
    sc  = ServerConnection("192.168.1.107", 8080, "/phoneConnection", context);
    sc!.init();

    var flag = ByteData(2);
    flag.setInt16(0, 1, Endian.big);
    List<int> l = <int>[];
    l.addAll(flag.buffer.asInt8List());
    l.addAll(utf8.encode('{"code":123,"message":"hello","call-back-url":"hello","call-back-method":"soemthing","call-back-plugin-name":"This is a plugin name"}'));

    // l.addAll(utf8.encode("{\"code\": 4005,"
    //     " \"message\": \"hello, this is phone\","
    //     "\"call-back-url\": \"\", "
    //     "\"call-back-method\": \"\","
    //     "\"call-back-plugin-name\": \"\"}"));
    debugPrint("$l");
    sc?.sendData(l);
    return Scaffold(
      appBar: AppBar(
        title: Text("ZPhone"),
        actions: [
        ],
        leading: Builder(builder: (BuildContext build){
          // return IconButton(onPressed: ()=>{Scaffold.of(build).openDrawer()}, icon: Icon(Icons.menu));
          return IconButton(onPressed: ()=>{sc?.sendData(l)}, icon: Icon(Icons.menu));
        },),
      ),
      body: Text("Hello"),
      drawer: Drawer(child: MenuDrawer(),),
    );
  }

}
void main(){
  runApp(MaterialApp(
    title: "ZPhone",
    theme: ThemeData(
      primaryColor: Colors.blue,
    ),
    home: SafeArea(child: Home(),),
  ));
}