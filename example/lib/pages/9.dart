import 'package:flutter/material.dart';
import 'package:flutter_obs/flutter_obs.dart';

Controller? _controller;

Controller get controller {
  assert(_controller != null);
  return _controller!;
}

class Controller {
  final count = Obs(0);
}

class TempGlobalStatePage extends StatefulWidget {
  const TempGlobalStatePage({super.key});

  @override
  State<TempGlobalStatePage> createState() => _TempGlobalStatePageState();
}

class _TempGlobalStatePageState extends State<TempGlobalStatePage> {
  @override
  void initState() {
    super.initState();
    _controller = Controller();
  }

  @override
  void dispose() {
    super.dispose();
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('退出此页面全局状态将销毁'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => controller.count.value++,
              child: ObsBuilder(
                builder: (_) => Text('count: ${controller.count.value}'),
              ),
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
              onPressed: () => controller.count.value++,
              child: ObsBuilder(
                builder: (_) => Text('count: ${controller.count.value}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
