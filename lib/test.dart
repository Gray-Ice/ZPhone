import 'package:grpc/grpc.dart';
import "package:flutter_code/rpc/clipboard/clipboard.pbgrpc.dart" as clip_rpc;
import "package:flutter_code/globals/network.dart" as net_globals;

Future<void> main() async {
  // 初始化要发送的数据
  clip_rpc.ClipboardContent clip = clip_rpc.ClipboardContent(text: "123");

  // 创建channel
  final channel = ClientChannel(
    '127.0.0.1',  // 主机地址
    port: 8887,  // 默认端口号
    options: ChannelOptions(
      credentials: ChannelCredentials.insecure(),
      codecRegistry: CodecRegistry(codecs: [GzipCodec(), IdentityCodec()]),
    ),
  );
  print("Hasn't do anything");
  channel.onConnectionStateChanged.listen((state) {
    print("state: $state");
  });

  var client = clip_rpc.ClipboardClient(channel);  // 创建客户端
  try{
    await client.shareClipboard(clip);
  } catch (e) {
    print("Caught error: $e");
  }
  print("Shared");
  await channel.shutdown();
}
