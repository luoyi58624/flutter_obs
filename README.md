A simple state manager, source code only 100 lines.

### Install

```
flutter pub add flutter_obs
```

### Use

```dart
class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    final count = Obs(0);
    return ElevatedButton(
      onPressed: () => count.value++,
      child: ObsBuilder(builder: (_) => Text('count: ${count.value}')),
    );
  }
}
```

### Done

