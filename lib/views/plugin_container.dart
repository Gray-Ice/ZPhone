import "package:flutter/cupertino.dart";
import "package:flutter_code/models/network.dart" as net_models;

class PluginContainer extends StatefulWidget {
  const PluginContainer({super.key});

  @override
  State<PluginContainer> createState() => _PluginContainerState();
}

class _PluginContainerState extends State<PluginContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("PluginContainer"),
    );
  }
}