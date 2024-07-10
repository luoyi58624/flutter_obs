import 'package:flutter/material.dart';
import 'package:flutter_obs/flutter_obs.dart';

final count1 = Obs(0);
final count2 = Obs(0);

class ManualBindPage extends StatefulWidget {
  const ManualBindPage({super.key});

  @override
  State<ManualBindPage> createState() => _ManualBindPageState();
}

class _ManualBindPageState extends State<ManualBindPage> {
  int buildCount = 0;

  @override
  void dispose() {
    super.dispose();
    count1.reset();
    count2.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('手动绑定响应式变量'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () => count1.value++,
                child: ObsBuilder(
                  builder: (_) => Text('count1: ${count1.value}'),
                ),
              ),
              ElevatedButton(
                onPressed: () => count2.value++,
                child: ObsBuilder(
                  builder: (_) => Text('count2: ${count2.value}'),
                ),
              ),
              // ObsBuilder(
              //   watch: [count1, count2],
              //   builder: (_) => Text('count1和count2 build次数: ${buildCount++}'),
              // ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const _ChildPage()),
                  );
                },
                child: const Text('下一页'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildPage extends StatefulWidget {
  const _ChildPage();

  @override
  State<_ChildPage> createState() => _ChildPageState();
}

class _ChildPageState extends State<_ChildPage> {
  @override
  void dispose() {
    super.dispose();
    count1.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('子页面 - 返回重置count1'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => count1.value++,
              child: ObsBuilder(builder: (context) {
                return Text('count1: ${count1.value}');
              }),
            ),
            ElevatedButton(
              onPressed: () => count1.value++,
              child: ListenableBuilder(
                listenable: count1,
                builder: (context, child) {
                  return Text('Listenable count1: ${count1.value}');
                },
              ),
            ),
            ElevatedButton(
              onPressed: count1.reset,
              child: ObsBuilder(builder: (context) {
                return const Text('重置count1');
              }),
            ),
          ],
        ),
      ),
    );
  }
}
