import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';
import "package:flutter_code/rpc/clipboard/clipboard.pbgrpc.dart" as clip_rpc;
import "package:flutter_code/globals/network.dart" as net_globals;

class ScanServer extends StatelessWidget {
  const ScanServer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("扫描服务器"),
      ),
      body: const Center(
        child: Text("扫描服务器"),
      ),
    );
  }
}


class Clipboard extends StatelessWidget {
  Clipboard({Key? key}): super(key: key);
  BuildContext? context;

  // 发送剪切板
  Future<void> sendClipboard() async {
    // 初始化要发送的数据
    clip_rpc.ClipboardContent clip = clip_rpc.ClipboardContent(text: "123");

    // 创建channel
    final channel = ClientChannel(
      'localhost',  // 主机地址
      port: net_globals.defaultServerPort,  // 默认端口号
      options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        // codecRegistry: CodecRegistry(codecs: [GzipCodec(), IdentityCodec()]),
      ),
    );

    var client = clip_rpc.ClipboardClient(channel);  // 创建客户端
    try{
      await client.shareClipboard(clip);
    } catch (e) {
      print("Caught error: $e");
    }
    await channel.shutdown();
  }
  Row _buildRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(onPressed: ()=>{sendClipboard()}, child: Text("发送剪切板")),
        TextButton(onPressed: ()=>{}, child: Text("接收剪切板")),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    this.context=context;
    return Container(
      child: _buildRow(context),
      decoration: BoxDecoration(
        // color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
