import 'package:example/pages/test.dart';
import 'package:flutter/material.dart';
import '1.dart';
import '10.dart';
import '11.dart';
import '2.dart';
import '3.dart';
import '4.dart';
import '5.dart';
import '6.dart';
import '7.dart';
import '8.dart';
import '9.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SimplePage()),
                );
              },
              child: const Text('1.入门示例'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const GlobalStatePage()),
                );
              },
              child: const Text('2.全局状态'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const LocalStatePage()),
                );
              },
              child: const Text('3.局部状态'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const InputPage()),
                );
              },
              child: const Text('4.Input双向绑定'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ListPage()),
                );
              },
              child: const Text('5.响应式列表'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const ControllerPage()),
                );
              },
              child: const Text('6.使用Class管理状态'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProviderPage()),
                );
              },
              child: const Text('7.Provider注入状态'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const ModelStatePage()),
                );
              },
              child: const Text('8.Model对象状态'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const GetxStatePage()),
                );
              },
              child: const Text('9.模拟Getx状态管理'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DemoPage()),
                );
              },
              child: const Text('10.DemoPage'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const HooksPage()),
                );
              },
              child: const Text('11.配合Hooks示例'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => TestPage()),
                );
              },
              child: const Text('测试页面'),
            ),
          ],
        ),
      ),
    );
  }
}
