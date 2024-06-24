import 'package:flutter/material.dart';
import 'package:flutter_obs/flutter_obs.dart';

class _State {
  var count = 0;
  var username = '';
}

class ModelStatePage extends StatelessWidget {
  const ModelStatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Obs(_State());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model对象状态'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  model.value.count++;
                  model.notify();
                },
                child: ObsBuilder(
                  builder: (context) {
                    return Text('count: ${model.value.count}');
                  },
                ),
              ),
              ObsBuilder(builder: (context) {
                return Text('username: ${model.value.username}');
              }),
              TextField(
                onChanged: (v) {
                  model.value.username = v;
                  model.notify();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
