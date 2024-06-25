import 'package:flutter/material.dart';
import 'package:flutter_obs/flutter_obs.dart';

/// 声明全局状态，你可以在任意 dart 文件中保存这个值，也可以将它封装到 class 中
var count = Obs(0);

class GlobalStatePage extends StatefulWidget {
  const GlobalStatePage({super.key});

  @override
  State<GlobalStatePage> createState() => _GlobalStatePageState();
}

class _GlobalStatePageState extends State<GlobalStatePage> {
  @override
  void initState() {
    super.initState();
    count = Obs(0);
    count.addListener(() {
      debugPrint('count更新：$count');
    });
  }

  @override
  void dispose() {
    super.dispose();
    count.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('全局状态示例'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => count.value++,
              child: ObsBuilder(builder: (_) => Text('count: ${count.value}')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ChildPage()),
                );
              },
              child: const Text('子页面'),
            ),
          ],
        ),
      ),
    );
  }
}

class ChildPage extends StatelessWidget {
  const ChildPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('子页面'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => count.value++,
              child: ObsBuilder(builder: (_) => Text('count: ${count.value}')),
            ),
          ],
        ),
      ),
    );
  }
}
