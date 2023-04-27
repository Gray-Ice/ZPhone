import "package:flutter/cupertino.dart";
import "package:provider/provider.dart";

// ConnectModel 用于响应式的显示是否已经连接上服务器
class ConnectModel extends ChangeNotifier {
  bool _connected = false;

  // 设置为连接
  void setConnected(){
    _connected = true;
    notifyListeners();
  }

  // 断开链接
  void disconnect(){
    _connected = false;
    notifyListeners();
  }

  // 返回是否已经连接上服务器
  bool isConnected(){
    return _connected;
  }
}