import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';
import "package:flutter_code/rpc/clipboard/clipboard.pbgrpc.dart" as clip_rpc;
import "package:flutter_code/rpc/google/protobuf/empty.pb.dart" as google_empty;
import "package:flutter_code/globals/network.dart" as net_globals;


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

class ClipboardServer extends clip_rpc.ClipboardServiceBase{
  @override
  Future<google_empty.Empty> shareClipboard(ServiceCall call, clip_rpc.ClipboardContent content) async {
    debugPrint("Received clipboard: ${content.text}");
    return google_empty.Empty();
  }
}