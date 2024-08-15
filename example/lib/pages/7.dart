import 'package:flutter/material.dart';
import 'package:flutter_obs/flutter_obs.dart';

class ProviderData extends InheritedWidget {
  const ProviderData({
    super.key,
    required super.child,
    required this.count,
  });

  final Obs count;

  static ProviderData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ProviderData>()!;

  @override
  bool updateShouldNotify(ProviderData oldWidget) => true;
}

class ProviderPage extends StatelessWidget {
  const ProviderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final count = Obs(0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider注入状态'),
      ),
      body: Center(
        child: ProviderData(
          count: count,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    count.value++;
                  },
                  child: ObsBuilder(
                    builder: (context) {
                      return Text('count: ${count.value}');
                    },
                  ),
                ),
                const _Child(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Child extends StatelessWidget {
  const _Child();

  @override
  Widget build(BuildContext context) {
    final data = ProviderData.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: ObsBuilder(builder: (context) {
            return Text('child, count: ${data.count.value}');
          }),
        ),
        ...List.generate(5, (index) => const _Button()),
      ],
    );
  }
}

class _Button extends StatelessWidget {
  const _Button();

  @override
  Widget build(BuildContext context) {
    final data = ProviderData.of(context);
    return ObsBuilder(builder: (context) {
      return ElevatedButton(
        onPressed: () {
          data.count.value++;
        },
        child: Text('deep count: ${data.count.value}'),
      );
    });
  }
}
