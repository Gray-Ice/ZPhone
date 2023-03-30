import 'package:flutter/material.dart';
import 'dart:io';

class ScanNetOptions extends StatelessWidget {
  ScanNetOptions({Key? key}) : super(key: key);
  bool useDefaultSetting = true;
  int port = 0;
  String ip = "";

  void portOnChanged(String value) {
    port = int.parse(value);
  }

  void ipOnChanged(String value) {
    ip = value;
  }

  @override
  Widget build(BuildContext context) {
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
  const ScanServerWidget({Key? key}) : super(key: key);

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


  Future<String> scanLocalAreaNetworkService()async {
    debugPrint("In");
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
      return "";
    }

    // Scan
    for(int i=0; i<255; i++){
      ipSlices[3] = i.toString();
      String ip = ipSlices.join(".");
      try{
        final result = await InternetAddress.lookup(ip);
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          serverIP = ip;
          break;
        }
      } on SocketException catch (_) {
        debugPrint("Can't find server at $ip");
      }
    }
    return serverIP;
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
            ScanNetOptions(),
            TextButton(onPressed: ()=>scanLocalAreaNetworkService(), child: Text("开始扫描")),
          ],
        ),
        )
      );
  }
}
