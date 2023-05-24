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
    sc  = ServerConnection("10.0.2.2", 8080, "/phoneConnection", context);
    sc!.init();

    // sc?.sendData(l);
    return Scaffold(
      appBar: AppBar(
        title: Text("ZPhone"),
        actions: [
        ],
        leading: Builder(builder: (BuildContext build){
          // return IconButton(onPressed: ()=>{Scaffold.of(build).openDrawer()}, icon: Icon(Icons.menu));
          return IconButton(onPressed: ()=>{sc?.createConnection()}, icon: Icon(Icons.menu));
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