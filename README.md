A simple state manager, it's similar to ValueNotifier, but the core is to borrow
from [Getx](https://github.com/jonataslaw/getx).

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

