import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:flutter_code/views/menu_drawer.dart";

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ZPhone"),
        actions: [],
        leading: Builder(builder: (BuildContext build){
          return IconButton(onPressed: ()=>{Scaffold.of(build).openDrawer()}, icon: Icon(Icons.menu));
        },),
      ),
      body: Text("Hello"),
      drawer: Drawer(child: MenuDrawer(),),
    );
  }

}
void main(){
  runApp(MaterialApp(
    title: "ZPhone",
    theme: ThemeData(
      primaryColor: Colors.blue,
    ),
    home: SafeArea(child: Home(),),
  ));
}