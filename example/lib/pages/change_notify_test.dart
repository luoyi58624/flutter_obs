import 'package:flutter/material.dart';

class Model with ChangeNotifier {
  int count = 0;

  void addCount() {
    count++;
    notifyListeners();
  }
}

class ChangeNotifyTestPage extends StatefulWidget {
  const ChangeNotifyTestPage({super.key});

  @override
  State<ChangeNotifyTestPage> createState() => _ChangeNotifyTestPageState();
}

class _ChangeNotifyTestPageState extends State<ChangeNotifyTestPage> {
  Model model = Model();
  final count = ValueNotifier(0);

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
            ValueListenableBuilder(
              valueListenable: count,
              builder: (context, value, child) {
                return ElevatedButton(
                  onPressed: () => count.value++,
                  child: Text('count: $value'),
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => _ChildPage(model: model)),
                );
              },
              child: const Text('子页面'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildPage extends StatefulWidget {
  const _ChildPage({super.key, required this.model});

  final Model model;

  @override
  State<_ChildPage> createState() => _ChildPageState();
}

class _ChildPageState extends State<_ChildPage> {
  final con = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.model.addListener(update);
  }

  @override
  void dispose() {
    super.dispose();
    widget.model.removeListener(update);
  }

  void update() {
    print('child build');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('子页面'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: widget.model.addCount,
          child: Text('count: ${widget.model.count}'),
        ),
      ),
    );
  }
}
