import 'package:flutter/material.dart';
import 'package:flutter_obs/flutter_obs.dart';

/// 以最简单的方式介绍 Obs、ObsBuilder 的使用方式，这就是它们的全部概念
class SimplePage extends StatelessWidget {
  const SimplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final countList = List.generate(500, (index) {
      final count = Obs(0);
      count.addListener(() {
        debugPrint('count$index更新');
      });
      return count;
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('入门示例'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ...countList.map(
                (count) => Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => count.value++,
                      child: ObsBuilder(
                        builder: (_) =>
                            Text('ObsBuilder count: ${count.value}'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => count.value++,
                      child: ListenableBuilder(
                        listenable: count,
                        builder: (context, child) =>
                            Text('ListenableBuilder count: ${count.value}'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
