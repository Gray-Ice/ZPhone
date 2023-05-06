import 'dart:io';

import "package:flutter_code/rpc/auth/auth.pbgrpc.dart" as auth_rpc;
import 'package:grpc/grpc.dart';
import "package:flutter_code/rpc/google/protobuf/empty.pb.dart" as empty;
import "package:flutter_code/globals/storage/keys.dart" as keys;
import "package:flutter_code/globals/project.dart" as global_project;
import "package:shared_preferences/shared_preferences.dart";
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code/plugins/clipboard.dart' as clipboard;
import "package:flutter_code/views/scan_server.dart" as views;
import "package:flutter_code/models/network.dart" as net_models;
import "package:flutter_code/globals/project.dart" as project_globals;
import 'package:provider/provider.dart';
import "package:flutter_code/models/menubar.dart" as menu_models;
import "package:flutter_code/views/zmenubar.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZPhone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<menu_models.HomeTitleModel>(
            create: (context) => menu_models.HomeTitleModel(),
          ),
        ],
        child: const MyHomePage(),
      ),
      navigatorKey: project_globals.navigatorKey,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var model = menu_models.HomeTitleModel();
    return Scaffold(
      appBar: ZAppBar(
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
                onPressed: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => views.ScanServerWidget(
                            context: context,
                          )))
                },
                child: Text("扫描服务器")),
            clipboard.Clipboard(),
            TextButton(
                onPressed: () async {
                  FilePickerResult? result =
                  await FilePicker.platform.pickFiles();
                  // if(result != null) {
                  //   String? path = result.files.single.path;
                  //   if (path != null) {
                  //     File file = File(path);
                  //   }
                  // }
                  if (result != null) {
                    File? file = result.files.single.path == null
                        ? null
                        : File(result.files.single.path!);
                  }
                },
                child: const Text("Something"))
          ],
        ),
      ),
    );
  }
}


