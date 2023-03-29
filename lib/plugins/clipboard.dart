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
class Clipboard extends StatelessWidget {
  Clipboard({Key? key}): super(key: key);

  Row _buildRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(onPressed: ()=>{Navigator.push(context, MaterialPageRoute(builder: (context)=>ScanServer()))}, child: Text("发送剪切板")),
        TextButton(onPressed: ()=>{}, child: Text("接收剪切板")),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildRow(context),
      decoration: BoxDecoration(
        // color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
