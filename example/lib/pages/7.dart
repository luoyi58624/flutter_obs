import 'package:flutter/material.dart';
import 'package:flutter_obs/flutter_obs.dart';

class _Provider extends InheritedWidget {
  const _Provider({
    required super.child,
    required this.count,
  });

  final Obs count;

  static _Provider of(BuildContext context) {
    final _Provider? result =
        context.dependOnInheritedWidgetOfExactType<_Provider>();
    assert(result != null, 'No _Provider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(_Provider oldWidget) => true;
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
        child: _Provider(
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
    final data = _Provider.of(context);
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
    final data = _Provider.of(context);
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
