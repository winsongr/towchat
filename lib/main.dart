import 'package:flutter/material.dart';

import 'package:towchat/moduls/chat.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Chat App',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: Chat(),
  ));
}
