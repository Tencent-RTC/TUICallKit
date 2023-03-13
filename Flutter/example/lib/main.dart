import 'package:flutter/material.dart';
import 'package:tencent_calls_uikit/tuicall_kit.dart';
import 'package:tuicall_kit_example/login_page.dart';
import 'package:tuicall_kit_example/store.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _callsUIKitPlugin = TUICallKit.instance;
  UserInfo userInfo = UserInfo();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPageRoute(
          callsUIKitPlugin: _callsUIKitPlugin, userInfo: userInfo),
    );
  }
}
