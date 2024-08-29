import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_obs/flutter_obs.dart';

import 'animate_obs.dart';

class Example5 extends HookWidget {
  const Example5({super.key});

  @override
  Widget build(BuildContext context) {
    // final width = useAnimateObs(100.0);
    // final height = useAnimateObs(100.0);
    final size = useAnimateObs(
      const Size(100, 100),
      tween: SizeTween(),
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastEaseInToSlowEaseOut,
    );

    final flag = useState(false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example'),
        actions: [
          Switch(
            value: flag.value,
            onChanged: (v) {
              flag.value = v;
              if (v) {
                size.setAnimateValue(const Size(300, 300));
                // width.setAnimateValue(300);
                // height.setAnimateValue(300);
              } else {
                size.setAnimateValue(const Size(100, 100));
                // width.setAnimateValue(100);
                // height.setAnimateValue(100);
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          ObsBuilder(
              watch: [size],
              builder: (context) {
                print('${size.controller.value}  ${size.animation.value}');
                return Container(
                  width: size.animation.value!.width,
                  height: size.animation.value!.height,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                  ),
                );
              }),
          // const SizedBox(height: 8),
          // ObsBuilder(
          //     watch: [width],
          //     builder: (context) {
          //       return Container(
          //         width: width.animation.value,
          //         height: height.animation.value,
          //         decoration: const BoxDecoration(
          //           color: Colors.red,
          //         ),
          //       );
          //     }),
        ],
      ),
    );
  }
}
