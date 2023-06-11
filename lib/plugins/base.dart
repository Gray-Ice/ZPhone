import 'package:flutter/cupertino.dart';
import 'package:flutter_code/core/server_connection.dart';

abstract class ZBaseChangeNotifier extends ChangeNotifier {
 Future<void> onServerCall(ServerInfo serverInfo);
}