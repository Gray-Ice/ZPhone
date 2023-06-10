import 'package:flutter/cupertino.dart';

class ZBaseChangeNotifier extends ChangeNotifier {
  int serverCalled = 0;
 void serverCallPlugin(){
   serverCalled = 1;
   notifyListeners();
 }
}