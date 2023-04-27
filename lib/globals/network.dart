import 'package:grpc/grpc.dart';

bool isConnected = false;
String ip = "";
String connectingHostname = "";
int port = 0;
int defaultServerPort = 8887;

// 连接上GRPC服务器的时候该变量会被自动设置。多个Client用同一条连接不会报错，ChatGPT说的, 准确性无法保证，但是暂时当做是正确的...
ClientChannel? conn;