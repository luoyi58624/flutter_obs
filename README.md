一个简单的响应式状态管理，它仅仅是对 ValueNotifier 进行的扩展，Api 如下：

1. Obs - 创建响应式变量
2. ObsBuilder - 响应式变量构建器

### 1. 局部使用

- 热刷新会重置状态，当父类引用此组件时，如果没有添加 const 修饰每次刷新也会重置状态，
- 原理很简单，如果触发了 build 方法响应式变量就会被重新创建，状态自然就被重置

```dart
class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    final count = Obs(0);
    return ElevatedButton(
      onPressed: () => count.value++,
      child: ObsBuilder(builder: (context) => Text('count: ${count.value}')),
    );
  }
}
```

### 2. 使用hook，弥补 StatelessWidget 的缺陷

- 为了稳定性，此库不依赖任何第三方库，所以移除掉了 flutter_hook 依赖及其相关代码，但封装的代码很简单，
- 请看[useObs](https://github.com/luoyi58624/flutter_obs/blob/main/use_obs.md)

```dart
class Example extends HookWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    final count = useObs(0);
    return ElevatedButton(
      onPressed: () => count.value++,
      child: ObsBuilder(builder: (context) => Text('count: ${count.value}')),
    );
  }
}
```

### 3. 在 StatefulWidget 中使用

- 通常情况下，你不需要在 dispose 生命周期中手动销毁它，它的工作原理很简单，就是维护了一个数组，存放刷新
  Widget 的方法，
- 当组件被销毁后其内部的变量自然而然会被 dart 垃圾回收器回收，如果你有遇到内存泄漏问题，请告诉我

```dart
class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  final count = Obs(0);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => count.value++,
      child: ObsBuilder(builder: (context) => Text('count: ${count.value}')),
    );
  }
}
```

### 4. 全局状态管理

- 定义一个全局状态非常简单，只需要将响应式变量放到 Widget 外部即可

```dart
// 全局响应式变量
final count = Obs(0);

// 或者使用类进行管理
class GlobalState {
  static final count = Obs(0);
}

// 对于全局状态，你可以放心地使用 StatelessWidget，因为状态已被移到外部
class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => GlobalState.count.value++,
      child: ObsBuilder(builder: (context) => Text('count: ${GlobalState.count.value}')),
    );
  }
}
```

### 5. 当组件被销毁时重置全局状态定义的所有响应式变量

- 先定义一个允许为空的控制器，当组件挂载时进行初始化，被销毁时将其设置为 null 即可

```dart
Controller? controller;

class Controller {
  final count = Obs(0);
}

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  @override
  void initState() {
    super.initState();
    controller = _Controller();
  }

  @override
  void dispose() {
    super.dispose();
    controller = null;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => controller!.count.value++,
      child: ObsBuilder(builder: (context) => Text('count: ${controller!.count.value}')),
    );
  }
}
```

- 总结：这个库的定位就是用于替代 ValueNotifier，它只用于满足一般的状态管理需求，而不是大而全的解决方案，
- 同时，它的核心逻辑实际上是借鉴[Getx](https://github.com/jonataslaw/getx)，我很喜欢 Getx 的简单性、易用性，
- 但我不喜欢它的 router、http 等各种杂七杂八的东西。