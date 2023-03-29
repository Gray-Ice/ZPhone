import 'package:flutter/material.dart';

class ScanServer extends StatelessWidget {
  const ScanServer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("扫描服务器"),
      ),
      body: const Center(
        child: Text("扫描服务器"),
      ),
    );
  }
}