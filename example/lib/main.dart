import 'package:flutter/material.dart';

import '01.dart';
import '02.dart';
import '03.dart';
import '04.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example测试示例'),
      ),
      body: ListView(
        children: [
          ElevatedButton(
             onPressed: () {
               setState(() {
                 count++;
               });
             },
             child: Text('count: $count'),
          ),
          ListTile(
            title: const Text('01'),
            onTap: () {
              push(const Example());
            },
          ),
          ListTile(
            title: const Text('02'),
            onTap: () {
              push(const Example2());
            },
          ),
          ListTile(
            title: const Text('03'),
            onTap: () {
              push(const Example3());
            },
          ),
          ListTile(
            title: const Text('SingleRenderTestPage'),
            onTap: () {
              push(SingleRenderTestPage());
            },
          ),
        ],
      ),
    );
  }

  Future<dynamic> push(Widget child) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => child),
    );
  }
}
