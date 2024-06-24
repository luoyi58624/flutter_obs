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

> As shown in the example above, Obs and ObsBuilder are all its concepts, using Obs is just like
> using normal variables, only the ObsBuilder package is needed to automatically reconstruct the
> page.

