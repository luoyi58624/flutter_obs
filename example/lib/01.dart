import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_obs/flutter_obs.dart';

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> with TickerProviderStateMixin {
  double size = 100;
  bool flag = false;
  int dur = 2000;
  int updateValue = 300;
  late final count = AnimateObs(
    100.0,
    vsync: this,
    duration: Duration(
      milliseconds: dur,
    ),
    curve: const Cubic(.48, .99, .49, .99),
  );

  @override
  void dispose() {
    count.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example'),
        actions: [
          Switch(
            value: flag,
            onChanged: (v) {
              setState(() {
                flag = v;
              });
              // setState(() {
              //   flag = v;
              //   if (v) {
              //     size = 300;
              //   } else {
              //     size = 100;
              //   }
              // });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 80,
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              count.setAnimateValue(count.value + updateValue);
                            },
                            child: const Text('加50'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              count.setAnimateValue(
                                  max(0, count.value - updateValue));
                            },
                            child: const Text('减50'),
                          ),
                          ObsBuilder(
                            builder: (context) {
                              return Text('count: ${count.value}');
                            },
                          ),
                          const SizedBox(width: 8),
                          ObsBuilder(
                            watch: [count],
                            builder: (context) {
                              return Text(
                                  'count: ${count.animation.value.toStringAsFixed(2)}');
                            },
                          ),
                        ],
                      ),
                    ),
                    ObsBuilder(
                      watch: [count],
                      builder: (context) {
                        return Container(
                          width: count.animation.value,
                          height: count.animation.value,
                          color: Colors.green,
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 80,
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                size += updateValue;
                              });
                            },
                            child: const Text('加50'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                size = max(0, size - updateValue);
                              });
                            },
                            child: const Text('减50'),
                          ),
                          Text('count: $size'),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: dur),
                      curve: const Cubic(.48, .99, .49, .99),
                      width: size,
                      height: size,
                      color: Colors.green.shade500,
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
