import 'package:flutter/material.dart';
import 'package:flutter_obs/flutter_obs.dart';

/// 使用响应式变量你可以轻松实现表单双向绑定
class InputPage extends StatelessWidget {
  const InputPage({super.key});

  @override
  Widget build(BuildContext context) {
    final inputValue = Obs('');
    final inputValue2 = Obs('初始值');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input双向绑定示例'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ObsBuilder(builder: (context) {
              return Text('input: ${inputValue.value}');
            }),
            InputWidget(modelValue: inputValue),
            const SizedBox(height: 50),
            ObsBuilder(builder: (context) {
              return Text('input2: ${inputValue2.value}');
            }),
            InputWidget(modelValue: inputValue2),
          ],
        ),
      ),
    );
  }
}

class InputWidget extends StatelessWidget {
  const InputWidget({super.key, required this.modelValue});

  final Obs<String> modelValue;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: modelValue.value,
      onChanged: (v) => modelValue.value = v,
    );
  }
}
