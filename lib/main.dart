// ignore_for_file: depend_on_referenced_packages, prefer_const_constructors, avoid_unnecessary_containers, use_key_in_widget_constructors, use_build_context_synchronously

import 'package:dongastonn/login.dart';
import 'package:flutter/material.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
    );
  }
}


