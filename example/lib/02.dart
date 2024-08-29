import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_obs/flutter_obs.dart';

class Example2 extends StatefulWidget {
  const Example2({super.key});

  @override
  State<Example2> createState() => _ExampleState();
}

class _ExampleState extends State<Example2> with TickerProviderStateMixin {
  bool flag = false;
  late final count = AnimateObs(
    100.0,
    vsync: this,
    duration: const Duration(
      milliseconds: 500,
    ),
    curve: Curves.fastEaseInToSlowEaseOut,
  );
  late final radius = AnimateObs(
    18.0,
    vsync: this,
    duration: const Duration(
      milliseconds: 500,
    ),
    curve: Curves.fastEaseInToSlowEaseOut,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example'),
        actions: [
          IconButton(
            onPressed: () {
              print(count.builderFunList.length);
            },
            icon: const Icon(Icons.add),
          ),
          Switch(
            value: flag,
            onChanged: (v) {
              setState(() {
                flag = v;
              });
              if (v) {
                count.value = 50;
                radius.value = 0;
              } else {
                count.value = 300;
                radius.value = 50;
              }
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: 10000,
        // cacheExtent: 10000,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(4),
          child: ObsBuilder(
            watch: [count, radius],
            builder: (context) {
              return UnconstrainedBox(
                child: Container(
                  width: count.animation.value,
                  height: count.animation.value,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(radius.animation.value),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      // body: CustomScrollView(
      //   slivers: [
      //     ...List.generate(
      //       10000,
      //       (index) => SliverPadding(
      //         padding: const EdgeInsets.all(4),
      //         sliver: SliverToBoxAdapter(
      //           child: SizedBox(
      //             width: 100,
      //             height: 100,
      //             child: ObsBuilder(
      //               watch: [count],
      //               builder: (context) {
      //                 return UnconstrainedBox(
      //                   child: Container(
      //                     width: count.animateValue,
      //                     height: count.animateValue,
      //                     color: Colors.green,
      //                   ),
      //                 );
      //               },
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      // body: Center(
      //   child: SingleChildScrollView(
      //     child: Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: Wrap(
      //         runSpacing: 4,
      //         spacing: 4,
      //         children: [
      //           ...List.generate(
      //             10000,
      //             (index) => SizedBox(
      //               width: 100,
      //               height: 100,
      //               child: ObsBuilder(
      //                 watch: [count],
      //                 builder: (context) {
      //                   return UnconstrainedBox(
      //                     child: Container(
      //                       width: count.animateValue,
      //                       height: count.animateValue,
      //                       color: Colors.green,
      //                     ),
      //                   );
      //                 },
      //               ),
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
