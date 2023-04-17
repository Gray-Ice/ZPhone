import 'dart:async';

import "package:flutter_code/rpc/google/protobuf/empty.pb.dart" as empty;
import 'package:grpc/grpc.dart';
import 'dart:io';
import 'package:synchronized/synchronized.dart';
import "package:flutter_code/rpc/auth/auth.pbgrpc.dart" as auth_rpc;


class _availableServer {
  _availableServer();
  List<String> ips = <String>[];
  Lock lock = Lock();
}

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
  print("Start scan");
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

Future<void> _confirmServer(String ip, _availableServer list) async {
  final channel = ClientChannel(
    ip,
    port: 8887,
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
    print("IP $ip not a server");
  }
  await channel.shutdown();
}

Future<List<String>> _scanLivingServer(List<String> availableIPs) async {
  print("Start second scan");
  List<Future> asyncTasks = [];
  _availableServer availableServers = _availableServer();
  for (int i = 0; i < availableIPs.length; i++) {
    String ip = availableIPs[i];
    try {
      asyncTasks.add(_confirmServer(ip, availableServers));
    } on SocketException catch (_) {
      continue;
    } on ArgumentError catch (_) {
      print("错误的主机名或端口");
    }
  }
  await Future.wait(asyncTasks);

  return availableServers.ips;
}
void main () async {
  // var currentIP = await getCurrentIP();
  var currentIP = "127.0.0.1";
  var availableIPs = await _scanLivingHosts(currentIP);
  for (int i = 0; i < availableIPs.length; i++) {
    print(availableIPs[i]);
  }
  var availableServers = await _scanLivingServer(availableIPs);
  print(availableServers);

}