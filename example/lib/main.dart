import 'package:flutter/material.dart';
import 'package:flutter_obs/flutter_obs.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Example());
  }
}

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> with SingleTickerProviderStateMixin {
  late final count = AnimateObs(0.0,
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              count.value+=100;
            },
            child: ObsBuilder(builder: (context) {
              return Text('count: ${count.value}');
            }),
          ),
        ],
      ),
    );
  }
}
