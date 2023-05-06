import 'package:flutter/material.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:grpc/grpc.dart';
import "package:flutter_code/rpc/google/protobuf/empty.pb.dart" as empty;
import "package:flutter_code/globals/storage/keys.dart" as keys;
import "package:flutter_code/globals/project.dart" as global_project;
import "package:flutter_code/rpc/auth/auth.pbgrpc.dart" as auth_rpc;
import "package:shared_preferences/shared_preferences.dart";

class ZAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String defaultTitle = "ZPhone";
  const ZAppBar({Key? key})
      : super(key: key);

  @override
  ZAppBarState createState() => ZAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ZAppBarState extends State<ZAppBar> {
  late Future<String> _titleFuture;
  String _title = '';

  @override
  void initState() {
    super.initState();
    connectToLastConnectedServer();
    // _titleFuture = widget.getTitle();
    // _titleFuture.then((title) {
    //   setState(() {
    //     _title = title;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(_title.isNotEmpty ? _title : widget.defaultTitle),
      centerTitle: false,
    );
  }

  // 连接到上一次连接的服务器(如果可以的话), 并修改App的Title
  Future<void> connectToLastConnectedServer() async {
    var sharedPref = await SharedPreferences.getInstance();
    var ip = sharedPref.getString(keys.lastIpString);
    var port = sharedPref.getInt(keys.lastPortInt);
    if (ip == null || port == null) {
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
      setState(() {
        _title = "${widget.defaultTitle} $ip";
      });
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
}
