import 'package:flutter/material.dart';

class Model with ChangeNotifier {
  int count = 0;

  void addCount() {
    count++;
    notifyListeners();
  }
}

Model model = Model();

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  @override
  void initState() {
    super.initState();
    model.addListener(() {
      print('build');
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    model.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Page'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: model.addCount,
              child: Text('count: ${model.count}'),
            ),
          ],
        ),
      ),
    );
  }
}
