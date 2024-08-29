import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_obs/flutter_obs.dart';

class Example3 extends StatefulWidget {
  const Example3({super.key});

  @override
  State<Example3> createState() => _ExampleState();
}

class _ExampleState extends State<Example3> with TickerProviderStateMixin {
  bool flag = false;
  late final size = AnimateObs(
    const Size(50, 50),
    vsync: this,
    duration: const Duration(milliseconds: 500),
    curve: const Cubic(.48, .99, .49, .99),
    tween: SizeTween(),
  );
  late final radius = AnimateObs(
    8.0,
    vsync: this,
    duration: const Duration(milliseconds: 600),
    curve: const Cubic(.48, .99, .49, .99),
  );

  late final color = AnimateObs(
    Colors.green,
    vsync: this,
    duration: const Duration(milliseconds: 800),
    curve: const Cubic(.48, .99, .49, .99),
    tween: ColorTween(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example'),
        actions: [
          IconButton(
            onPressed: () {
              print(size.builderFunList.length);
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
                size.setAnimateValue(const Size(300, 150));
                radius.setAnimateValue(50);
                color.setAnimateValue(Colors.red);
              } else {
                size.setAnimateValue(const Size(50, 50));
                radius.setAnimateValue(4);
                color.setAnimateValue(Colors.green);
              }
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: 100,
        cacheExtent: 10000,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(4),
          child: ObsBuilder(
            watch: [size],
            builder: (context) {
              // print(radius.animation.value);
              // print(radius.animation.status);
              return UnconstrainedBox(
                child: Container(
                  width: size.animation.value!.width,
                  height: size.animation.value!.height,
                  decoration: BoxDecoration(
                    color: color.animation.value,
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
