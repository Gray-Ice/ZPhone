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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: ChangeNotifierProvider(create: (context) => menu_models.HomeTitleModel(),
          child: Consumer<menu_models.HomeTitleModel>(builder: (context, titleModel, child){debugPrint("This is title: ${titleModel.text}");return Text("${titleModel.text}");},)),
      ),
      navigatorKey: project_globals.navigatorKey,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  Widget title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    connectToLastConnectedServer();
    return Scaffold(
      appBar: AppBar(
        title: widget.title,
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
Future<void> connectToLastConnectedServer() async {
  var sharedPref = await SharedPreferences.getInstance();
  var ip = sharedPref.getString(keys.lastIpString);
  var port = sharedPref.getInt(keys.lastPortInt);
  if(ip == null || port == null) {
    return;
  }
  bool connectSuccess = false;

  showDialog(
      context: global_project.navigatorKey.currentContext!,
      builder: (BuildContext build) {
        return AlertDialog(
          title: Text("正在扫描服务器"),
          content: Text("请稍等"),
        );
      });

  debugPrint("Trying to connect last connected server: $ip:$port");
  final channel = ClientChannel(
    ip,
    port: port,
    options: const ChannelOptions(
      credentials: ChannelCredentials.insecure(),
      connectionTimeout: Duration(seconds: 1),
    ),
  );

  var auth = auth_rpc.AuthClient(channel);

  empty.Empty em = empty.Empty();
  try {
    await auth.heartBeat(em);
    connectSuccess = true;
    debugPrint("going to add suffix");
    var menuModel = Provider.of<menu_models.HomeTitleModel>(global_project.navigatorKey.currentContext!);
    debugPrint("got model");
    menuModel.addSuffix("suffix");
    debugPrint("Added suffix");
  } catch (e) {
    debugPrint("Connect to last connected server failed. $ip:$port");
    debugPrint("$e");
  } finally {
    var title = connectSuccess ? "自动连接成功" : "自动连接失败";
    var content = connectSuccess ? "自动连接之前的服务器成功" : "自动连接之前的服务器失败";
    Navigator.of(global_project.navigatorKey.currentContext!).pop(); // 退出扫描IP窗口
    showDialog(
        context: global_project.navigatorKey.currentContext!,
        builder: (BuildContext build) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
          );
        });
  }
  await Future.delayed(const Duration(milliseconds: 500));
  Navigator.of(global_project.navigatorKey.currentContext!).pop(); // 退出扫描IP窗口
  await channel.shutdown();
}
