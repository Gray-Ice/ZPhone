import 'package:flutter/cupertino.dart';

class HomeTitleModel extends ChangeNotifier {
  String text = "ZPhone";

  void setText(String text) {
    this.text = text;
    notifyListeners();
  }

  void addSuffix(String suffix) {
    text += suffix;
    debugPrint(this.text);
    notifyListeners();
  }

  void setDefault(){
    text = "ZPhone";
    notifyListeners();
  }
}