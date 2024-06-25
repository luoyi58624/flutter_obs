import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_obs/flutter_obs.dart';

class HooksPage extends HookWidget {
  const HooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final count = Obs(0);
    // 当小部件重建时它会保留状态，原始Api则会重置
    final count2 = useObs(0);
    final count3 = useState(0);
    useValueChanged(count3.value, (oldValue, newValue) {
      debugPrint('旧值: $oldValue');
      debugPrint('新值: $newValue');
      return newValue;
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('flutter hooks示例'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () => count.value++,
                child: ObsBuilder(
                  builder: (_) => Text('Obs count: ${count.value}'),
                ),
              ),
              ElevatedButton(
                onPressed: () => count2.value++,
                child: ObsBuilder(
                  builder: (_) => Text('useObs count: ${count2.value}'),
                ),
              ),
              ElevatedButton(
                onPressed: () => count3.value++,
                child: Text('useState count: ${count3.value}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
