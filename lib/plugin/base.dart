import 'package:flutter/cupertino.dart';

abstract class PluginBase extends Widget {
  final String name = "";

  const PluginBase({super.key});
  void handleServerCall(String callBackMethod, callBackUrl);
  void callServer();
  void reset();
}