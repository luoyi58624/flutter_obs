import 'package:flutter/material.dart';
import 'package:flutter_obs/flutter_obs.dart';

/// 使用响应式变量你可以轻松实现表单双向绑定
class InputPage extends StatelessWidget {
  const InputPage({super.key});

  @override
  Widget build(BuildContext context) {
    final inputValue = Obs('');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input双向绑定示例'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ObsBuilder(builder: (context) {
          return Column(
            children: [
              InputWidget(
                value: inputValue.value,
                modelValue: inputValue,
              ),
              InputWidget(
                value: inputValue.value,
                modelValue: inputValue,
              ),
            ],
          );
        }),
      ),
    );
  }
}

class InputWidget extends StatefulWidget {
  const InputWidget({super.key, this.value, this.modelValue});

  final String? value;
  final Obs<String>? modelValue;

  @override
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  late final TextEditingController controller =
      TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(covariant InputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String newText = widget.value ?? '';
    if (newText != '') {
      controller.value = controller.value.copyWith(
        text: widget.value ?? '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: (v) {
        if (widget.modelValue != null) widget.modelValue!.value = v;
      },
    );
  }
}
