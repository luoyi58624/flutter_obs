import 'package:flutter/material.dart';
import 'package:flutter_obs/flutter_obs.dart';

class _Controller {
  final count = Obs(0);

  int get doubleCount => count.value * 2;

  void addCount() {
    count.value++;
  }
}

class ControllerPage extends StatelessWidget {
  const ControllerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = _Controller();
    return Scaffold(
      appBar: AppBar(
        title: const Text('使用Class管理状态'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: c.addCount,
              child: ObsBuilder(
                builder: (context) {
                  return Text('count: ${c.count.value}');
                },
              ),
            ),
            ObsBuilder(builder: (context) {
              return Text('double count: ${c.doubleCount}');
            }),
          ],
        ),
      ),
    );
  }
}
