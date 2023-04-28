import "package:flutter_code/rpc/auth/auth.pbgrpc.dart" as auth_rpc;
import 'package:grpc/grpc.dart';
import "package:flutter_code/rpc/google/protobuf/empty.pb.dart" as empty;
import "package:flutter_code/globals/storage/keys.dart" as keys;
import "package:flutter_code/globals/project.dart" as global_project;
import "package:shared_preferences/shared_preferences.dart";
import 'package:flutter/material.dart';


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
  } catch (e) {
    debugPrint("Connect to last connected server failed. $ip:$port");
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
  await channel.shutdown();
}
