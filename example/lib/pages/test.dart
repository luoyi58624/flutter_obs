import 'package:flutter/material.dart';
import 'package:flutter_obs/flutter_obs.dart';

class TestPage extends StatelessWidget {
  TestPage({super.key});

  final count = Obs(0);
  final count2 = Obs(0);
  final count3 = Obs(0);
  final flag = Obs(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('简单状态管理'),
        actions: [
          ObsBuilder(builder: (context) {
            return Switch(
              value: flag.value,
              onChanged: (v) => flag.value = v,
            );
          }),
        ],
      ),
      body: ObsBuilder(
        builder: (context) {
          return Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  count.value++;
                },
                // child: ObsBuilder(
                //   builder: (context) {
                //     i('count1更新');
                //     return Text('count: ${count.value}');
                //   },
                // ),
                child: Text('count: ${count.value}'),
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      count2.value++;
                    },
                    child: ObsBuilder(
                      builder: (context) {
                        return Text('count2: ${count2.value}');
                      },
                    ),
                  ),
                ],
              ),
              // SizedBox(
              //   height: 200,
              //   child: SingleChildScrollView(
              //       child: Column(
              //     children: [...List.generate(10, (index) => buttonWidget())],
              //   )),
              // ),
              // SizedBox(
              //   height: 200,
              //   child: SingleChildScrollView(
              //       child: Column(
              //         children: [...List.generate(10, (index) => const _Child())],
              //       )),
              // ),
              ElevatedButton(
                onPressed: () {
                  count3.value++;
                },
                child: Text('count3: ${count3.value}'),
                // child: ObsBuilder(() => Text('count2: ${count2.value}')),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buttonWidget() {
    return ElevatedButton(
      onPressed: () {
        count.value++;
      },
      child: ObsBuilder(builder: (context) => Text('count: ${count.value}')),
    );
  }
}

class _Child extends StatefulWidget {
  const _Child({super.key});

  @override
  State<_Child> createState() => _ChildState();
}

class _ChildState extends State<_Child> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          count++;
        });
      },
      child: ObsBuilder(builder: (context) => Text('count: $count')),
    );
  }
}
