
import 'package:flutter/cupertino.dart';
import 'package:flutter_code/plugin/base.dart';
import "package:synchronized/synchronized.dart";

class ZPlugins {
  final lock = Lock();
  Map<String, PluginBase> plugins = <String, PluginBase>{};
  List<PluginBase> _list_plugins = <PluginBase>[];

  void addPlugin(PluginBase plugin) {
    lock.synchronized(() {
      plugins[plugin.name] = plugin;
      _list_plugins.add(plugin);
    });
  }
  
  PluginBase? getPlugin(String name) {
    PluginBase? p;
    lock.synchronized(() => p = plugins[name]);
    return p;
  }
  List<Widget> getPlugins() {
    return _list_plugins;
  }
}

ZPlugins plugins = ZPlugins();
