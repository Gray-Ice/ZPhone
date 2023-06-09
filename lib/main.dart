import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code/globals/project.dart';
import 'package:flutter_code/plugins/clipboard.dart';
import "package:flutter_code/views/menu_drawer.dart";
import 'package:provider/provider.dart';

import 'core/server_connection.dart';

class Home extends StatelessWidget {
  ServerConnection? sc;

  @override
  Widget build(BuildContext context) {
    sc = ServerConnection("10.0.2.2", 8080, "/phoneConnection", context);
    sc!.init();

    // sc?.sendData(l);
    return Scaffold(
      appBar: AppBar(
        title: const Text("ZPhone"),
        actions: [],
        leading: Builder(
          builder: (BuildContext build) {
            // return IconButton(onPressed: ()=>{Scaffold.of(build).openDrawer()}, icon: Icon(Icons.menu));
            return IconButton(
                onPressed: () => {sc?.createConnection()},
                icon: const Icon(Icons.menu));
          },
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            Clipboard(),
          ],
        ),
      ),
      drawer: Drawer(
        child: MenuDrawer(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // You should initialize the provider model and pass it into multiProvider.providers
    // then your widget could be called from server side.
    ClipboardModel clipboardModel =ClipboardModel();
    // You should add plugin widgets into this map, so that core.server_connection could know which model shall be call
    PWMap['clipboard'] = clipboardModel;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => clipboardModel),
      ],
      child: MaterialApp(
        title: "ZPhone",
        theme: ThemeData(
          primaryColor: Colors.blue,
        ),
        home: SafeArea(
          child: Home(),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
