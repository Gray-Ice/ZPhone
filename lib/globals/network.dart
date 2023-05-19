import 'package:grpc/grpc.dart';

bool isConnected = false;
String ip = "";
String connectingHostname = "";
int port = 0;
int defaultServerPort = 8887;  // 默认服务器端口号
int heartbeatInterval = 500;  // 心跳包发送间隔，单位毫秒


class ServerConnect {
}