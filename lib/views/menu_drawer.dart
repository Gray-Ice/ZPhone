import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context){
    return ListView(
      padding: EdgeInsets.all(16.0),
      itemExtent: 60,
      children: [
        ListTile(
          title: Text("配对服务器"),
          onTap: (){Scaffold.of(context).closeDrawer();},
        ),
        ListTile(
          title: Text("示例2"),
          onTap: (){debugPrint("hi");},
        ),
      ],
    );
  }
}