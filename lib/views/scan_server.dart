import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:synchronized/synchronized.dart';
import "package:connectivity_plus/connectivity_plus.dart";

int _defaultPort = 8080;

class ServerInfo{
  final String ip;
  final int port;
  ServerInfo(this.ip, this.port);
}


class ScanNetOptions extends StatelessWidget {
  ScanNetOptions({Key? key}) : super(key: key);
  BuildContext? bcontext;
  bool useDefaultSetting = true;
  int port = 0;
  String ip = "";
  bool snackBarShowing = false;

  void portOnChanged(String value) {
    try{
      port = int.parse(value);
    } on FormatException catch (_) {
      snackBarShowing = true;
      ScaffoldMessenger.of(bcontext!)
          .showSnackBar(const SnackBar(content: Text("端口号只能是数字")))
          .closed.then((SnackBarClosedReason reason){snackBarShowing = false;});
    }
  }

  void ipOnChanged(String value) {
    port = int.parse(value);
  }

  @override
  Widget build(BuildContext context) {
    bcontext = context;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(onPressed: ()=>useDefaultSetting=true, child: const Text("使用默认方式扫描")),
        Flexible(child: TextField(
          onChanged: ipOnChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'IP',
          ),
        )),
        Flexible(child: TextField(
          onChanged: portOnChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Port',
          ),
        )),
        // TextField(
        //   onChanged: portOnChanged,
        //   decoration: const InputDecoration(
        //     border: OutlineInputBorder(),
        //     labelText: '端口',
        //   ),
        // ),
      ],
    );
  }
}
class ScanServerWidget extends StatelessWidget {
  ScanServerWidget({Key? key, required this.context}) : super(key: key);
  ScanNetOptions scanNetOptions = ScanNetOptions();
  final Lock _lock = Lock();
  BuildContext context;
  List<ServerInfo> livingServer = [];


  // 返回IP或空字符串
  Future<String> getCurrentIP() async {
    final interfaces = await NetworkInterface.list();
    String? ip;
    interfaces.forEach((interface) {
      interface.addresses.forEach((address) {
        if (address.type == InternetAddressType.IPv4) {
          ip = address.address;
          // print('IP: ${address.address}');
          // print('Subnet mask: ${address.rawAddress}');
        }
      });
    });
    return ip??"";
  }


  Future<List<String>> _scanLiveHosts(String currentIP) async {
    List<String> ipSlices = currentIP.split(".");
    debugPrint("Start scan");
    List<String> availableIPs = [];
    for(int i=0; i<255; i++){
      ipSlices[3] = i.toString();
      String ip = ipSlices.join(".");
      try{
        final result = await InternetAddress.lookup(ip);
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          availableIPs.add(ip);
        }
      } on SocketException catch (_) {
      }
    }
    return availableIPs;
  }

  void showAvailableServers(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("可用服务器"),
          content: SingleChildScrollView(
            child: ListBody(
              children: livingServer.map((e) => Text("${e.ip}:${e.port}")).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("确定"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  // 确认Server是否是可用的，如果是，加入livingServer列表
  Future<void> _confirmServer(String ip) async {
    try{
      Socket socket = await Socket.connect(ip, _defaultPort, timeout: const Duration(milliseconds: 100));
      socket.setOption(SocketOption.tcpNoDelay, true);
      socket.write("ping");
      // 设置Listen超时
      socket.timeout(const Duration(milliseconds: 100), onTimeout: (EventSink sink) {
        socket.close();
      });
      // 等待返回数据或超时
      var stream = socket.listen((data){
        String response = data.toString();
        // 期望的返回数据，加入服务器列表
        if(response == "pong"){
          _lock.synchronized(() async {
            livingServer.add(ServerInfo(ip, _defaultPort));
            socket.close();
          });
        } else {
          // 不期望的返回数据，直接关闭
          socket.close();
        }
      });

      // 等待Listen执行完毕
      await stream.asFuture<void>();
    } on SocketException catch (_) {
      return;
    }
  }
  Future<void> _scanLivingServer(List<String> availableIPs) async {
    debugPrint("Start second scan");
    List<Future> asyncTasks = [];
    for(int i=0; i<availableIPs.length; i++){
      String ip = availableIPs[i];
      try{
        asyncTasks.add(_confirmServer(ip));
      } on SocketException catch (_) {
        continue;
      } on ArgumentError catch (_) {
        debugPrint("错误的主机名或端口");
      }
    }
    await Future.wait(asyncTasks);
  }
  Future<String> defaultScanMethod(context) async {
    debugPrint("In");

    // 检查是否连接WiFi
    var connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult != ConnectivityResult.wifi){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("你没有连接wifi")));
      return "";
    }

    var currentIP = await getCurrentIP();
    String serverIP = "";
    // Can't find server
    if(currentIP == ""){
      return "";
    }

    // Find server
    List<String> ipSlices = currentIP.split(".");
    // Not a valid IP
    if(ipSlices.length != 4){
      debugPrint("Not a valid IP");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("你的IP太怪了, 我不知道怎么搞了")));
      return "";
    }

    // 初次扫描，仅扫描局域网内的机器作为初筛结果
    List<String> availableIPs = await _scanLiveHosts(currentIP);
    // 没有找到服务器
    if(availableIPs.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("没有找到服务器")));
      return "";
    }

    // 二次扫描，对初筛结果进行二次筛选，找到服务器
    await _scanLivingServer(availableIPs);
    debugPrint("This is $serverIP");
    return serverIP;

  }

  // 扫描局域网内的服务器
  Future<String> scanLocalAreaNetworkService(context)async {
    livingServer.clear();
    // 没有设置IP和端口，使用默认方式扫描
    if(scanNetOptions.useDefaultSetting){
      return defaultScanMethod(context);
    }

    var ip = scanNetOptions.ip;
    var port = scanNetOptions.port;
    // 虽然设置了IP或端口但是最后删除了，所以还是使用默认方式扫描
    if(ip == "" && port == 0){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("使用默认方式扫描")));
      return defaultScanMethod(context);
    }
    return "";
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("扫描服务器"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            scanNetOptions,
            TextButton(onPressed: ()=>scanLocalAreaNetworkService(context), child: Text("开始扫描")),
          ],
        ),
        )
      );
  }
}
