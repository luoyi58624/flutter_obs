import 'package:flutter/material.dart';
import 'package:flutter_obs/flutter_obs.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: const Center(
          child: Example(),
        ),
      ),
    );
  }
}

class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    final count = Obs(0);
    return ElevatedButton(
      onPressed: () => count.value++,
      child: ObsBuilder(builder: (context) => Text('count: ${count.value}')),
    );
  }
}
