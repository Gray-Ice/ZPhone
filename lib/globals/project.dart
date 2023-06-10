import 'package:flutter/material.dart';
import 'package:flutter_code/plugins/base.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// the data in this variable should not be remove, or it will cause crash.
Map<String, ZBaseChangeNotifier> PWMap = <String, ZBaseChangeNotifier>{};