import 'package:flutter/material.dart';
import 'package:flutter_obs/flutter_obs.dart';

/// 以最简单的方式介绍 Obs、ObsBuilder 的使用方式，这就是它们的全部概念
class SimplePage extends StatelessWidget {
  const SimplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final count = Obs(0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('入门示例'),
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
