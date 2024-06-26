import 'package:flutter/material.dart';

import 'pages/home.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
      home: const HomePage(),
    );
  }
}