import 'dart:async' as async;

import "package:flutter_code/rpc/google/protobuf/empty.pb.dart" as empty;
import 'package:grpc/grpc.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:synchronized/synchronized.dart';
import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_code/rpc/auth/auth.pbgrpc.dart" as auth_rpc;
import "package:flutter_code/globals/network.dart" as global_network;
import "package:flutter_code/globals/project.dart" as global_project;

class _availableServer {
  _availableServer();

  List<String> ips = <String>[];
  Lock lock = Lock();
}

class ServerInfo {
  final String ip;
  final int port;

  ServerInfo(this.ip, this.port);
}

class ScanNetOptions extends StatelessWidget {
  // TODO: 将展示可用服务器的控件设置为ListView
  ScanNetOptions({Key? key}) : super(key: key);
  BuildContext? bcontext;
  bool useDefaultSetting = true;
  int port = 0;
  String ip = "";
  bool snackBarShowing = false;

  void portOnChanged(String value) {
    if (value == "") {
      return;
    }
    try {
      port = int.parse(value);
      useDefaultSetting = false;
    } on FormatException catch (_) {
      snackBarShowing = true;
      ScaffoldMessenger.of(bcontext!)
          .showSnackBar(const SnackBar(content: Text("端口号只能是数字")))
          .closed
          .then((SnackBarClosedReason reason) {
        snackBarShowing = false;
      });
    }
  }

  void ipOnChanged(String value) {
    ip = value;
    useDefaultSetting = false;
  }

  @override
  Widget build(BuildContext context) {
    bcontext = context;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: Wrap(
            children: [
              TextButton(
                  onPressed: () => useDefaultSetting = true,
                  child: const Text("使用默认方式扫描")),
              Row(
                children: [
                  // 必须用SizedBox包裹TextField，否则Row会报错
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: TextField(
                      onChanged: ipOnChanged,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'IP',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: TextField(
                      onChanged: portOnChanged,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Port',
                      ),
                    ),
                  ),
                ],
              ),
              // TextField(
              //   onChanged: portOnChanged,
              //   decoration: const InputDecoration(
              //     border: OutlineInputBorder(),
              //     labelText: '端口',
              //   ),
              // ),
            ],
          ),
        )
      ],
    );
  }
}

class ScanServerWidget extends StatelessWidget {
  ScanServerWidget({Key? key, required this.context}) : super(key: key);
  ScanNetOptions scanNetOptions = ScanNetOptions();
  BuildContext context;
  List<ServerInfo> livingServer = [];
  bool isShowingSwitchServer = false;

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
    return ip ?? "";
  }

  Future<List<String>> _scanLivingHosts(String currentIP) async {
    List<String> ipSlices = currentIP.split(".");
    debugPrint("Start scan");
    List<String> availableIPs = [];
    for (int i = 1; i < 255; i++) {
      ipSlices[3] = i.toString();
      String ip = ipSlices.join(".");
      try {
        final result = await InternetAddress.lookup(ip);
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          availableIPs.add(ip);
        }
      } on SocketException catch (_) {}
    }
    return availableIPs;
  }

  // 确认Server是否是可用的，如果是，加入livingServer列表
  Future<void> _confirmServer(String ip, _availableServer list) async {
    final channel = ClientChannel(
      ip,
      port: global_network.defaultServerPort,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectionTimeout: Duration(seconds: 1),
      ),
    );

    var auth = auth_rpc.AuthClient(channel);

    empty.Empty em = empty.Empty();
    try {
      await auth.heartBeat(em);
      await list.lock.synchronized(() => list.ips.add(ip));
    } catch (e) {
      debugPrint("IP $ip not a server");
    }
    await channel.shutdown();
  }

  // 二次扫描, 返回真正可用的服务器IP列表
  Future<List<String>> _scanLivingServer(List<String> availableIPs) async {
    debugPrint("Start second scan");
    List<Future> asyncTasks = [];
    _availableServer availableServers = _availableServer();
    for (int i = 0; i < availableIPs.length; i++) {
      String ip = availableIPs[i];
      var task = _confirmServer(ip, availableServers);
      asyncTasks.add(_confirmServer(ip, availableServers));
    }
    // 等待检测服务器任务全部执行完毕
    await Future.wait(asyncTasks);
    debugPrint("Second scan finished");

    return availableServers.ips;
  }

  Future<bool> scanTargetIP(String ip, int port) async {
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
      await channel.shutdown();
      return true;
    } catch (e) {
      debugPrint("IP $ip not a server");
      await channel.shutdown();
      return false;
    }
  }

  Future<List<String>> defaultScanMethod(context) async {
    debugPrint("Running defaultScanMethod");
    List<String> ips = <String>[];

    // 检查是否连接WiFi
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.wifi) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("你没有连接wifi")));
      return ips;
    }

    var currentIP = await getCurrentIP();
    debugPrint("CurrentIP: $currentIP");
    // Can't find server
    if (currentIP == "") {
      return ips;
    }

    // Find server
    List<String> ipSlices = currentIP.split(".");
    // Not a valid IP
    if (ipSlices.length != 4) {
      debugPrint("Not a valid IP");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("你的IP太怪了, 我不知道怎么搞了")));
      return ips;
    }

    // 初次扫描，仅扫描局域网内的机器作为初筛结果
    List<String> availableIPs = await _scanLivingHosts(currentIP);
    debugPrint("$availableIPs");
    // 没有找到服务器
    if (availableIPs.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("没有找到服务器")));
      return ips;
    }

    // 二次扫描，对初筛结果进行二次筛选，找到服务器
    ips = await _scanLivingServer(availableIPs);
    return ips;
  }

  // 扫描局域网内的服务器
  Future<List<String>> scanLocalAreaNetworkService(context) async {
    livingServer.clear();
    // 没有设置IP和端口，使用默认方式扫描
    if (scanNetOptions.useDefaultSetting) {
      debugPrint("${scanNetOptions.useDefaultSetting}");
      var ips = await defaultScanMethod(context);
      for (var ip in ips) {
        livingServer.add(ServerInfo(ip, global_network.defaultServerPort));
      }
      return ips;
    }

    var ip = scanNetOptions.ip;
    var port = scanNetOptions.port;
    // 虽然设置了IP或端口但是最后删除了，所以还是使用默认方式扫描
    if (ip == "" && port == 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("使用默认方式扫描")));
      return await defaultScanMethod(context);
    }
    debugPrint("Using custom scan method, ip: $ip, port: $port");
    var scanTargetIpResult = await scanTargetIP(ip, port);
    if (scanTargetIpResult) {
      livingServer.add(ServerInfo(ip, port));
      return <String>["$ip:$port"];
    }

    return <String>[];
  }

  // 展示选择服务器列表
  Future<void> popUpServerSwitchList(BuildContext context) async {
    if (isShowingSwitchServer) {
      return;
    }
    isShowingSwitchServer = true;
    List<String> ips = await scanLocalAreaNetworkService(context);
    // List<String> ips = <String>[];
    // ips.add("127.0.0.1:8000");
    // ips.add("127.0.0.1:8001");
    showDialog(
        context: global_project.navigatorKey.currentContext!,
        builder: (BuildContext build) {
          var rows = <Row>[];
          for (var i = 0; i < ips.length; i++) {
            var column = Row(
              children: [
                Text(ips[i]),
                ElevatedButton(
                    onPressed: () {
                      // 输出ip
                      debugPrint("${ips[i]}");
                      debugPrint("Printed");

                      // 设置全局ip和port
                      // String ip = ips[i].split(":")[0];
                      // int port = int.parse(ips[i].split(":")[0]);
                      // global_network.ip = ip;
                      // global_network.port = port;
                      //
                      // Navigator.of(build).pop(); // 退出Dialog窗口
                      // Navigator.of(context).pop(); // 退出扫描IP窗口
                    },
                    child: const Text("确定"))
              ],
            );
            rows.add(column);
          }
          return AlertDialog(
            title: Text("选择一个服务器"),
            content: Wrap(
              children: [
                Column(
                  children: rows,
                )
              ],
            ),
          );
        });
    this.isShowingSwitchServer = false;
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
              TextButton(
                  onPressed: () => popUpServerSwitchList(context),
                  child: Text("开始扫描")),
            ],
          ),
        ));
  }
}
