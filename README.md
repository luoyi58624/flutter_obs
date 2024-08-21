一个简单的响应式状态管理，它是对 ValueNotifier 进行的扩展：

1. Obs - 创建响应式变量
2. ObsBuilder - 响应式变量构建器

### 1. 局部使用

热刷新会重置状态，当父类引用此组件时，如果没有添加 const 修饰每次刷新也会重置状态，
原理很简单，如果触发了 build 方法响应式变量就会被重新创建，状态自然就被重置

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

### 2. 使用 hook，弥补 StatelessWidget 的缺陷

为了稳定性，此库不依赖任何第三方库，所以移除掉了 flutter_hook 依赖及其相关代码，封装的代码很简单，
请看[useObs](https://github.com/luoyi58624/flutter_obs/blob/main/use_obs.md)

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

提示：你不需要在 dispose 生命周期中销毁它

```dart
class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  final count = Obs(0);

  @override
  void dispose() {
    super.dispose();
    // count.dispose();
  }

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

定义一个全局状态非常简单，只需要将响应式变量放到 Widget 外部即可

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

先定义一个允许为空的控制器，当组件挂载时进行初始化，被销毁时将其设置为 null 即可

```dart
Controller? _controller;

Controller get controller {
  assert(_controller != null, 'Controller 还未初始化');
  return _controller!;
}

class Controller {
  final count = Obs(0);
  final flag = Obs(false);
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
    _controller = Controller();
  }

  @override
  void dispose() {
    super.dispose();
    controller = null;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => controller.count.value++,
      child: ObsBuilder(builder: (context) => Text('count: ${controller.count.value}')),
    );
  }
}
```

### 6. 依赖注入

Obs可以轻松和 InheritedWidget 或 Provider 进行集成，以下是 InheritedWidget 的使用示例，
Provider 是对 InheritedWidget 进行的封装，用法都是一样

```dart
/// 创建依赖注入小部件
class ProviderData extends InheritedWidget {
  const ProviderData({
    required super.child,
    required this.count,
  });

  final Obs count;

  static ProviderData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ProviderData>()!;

  @override
  bool updateShouldNotify(ProviderData oldWidget) => true;
}

class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    final count = Obs(0);
    return Scaffold(
      // 注入依赖
      body: ProviderData(
        count: count,
        child: Column(
          children: [
            ObsBuilder(builder: (context) {
              return Text('parent count: ${data.count.value}');
            }),
            const Child(),
          ],
        ),
      ),
    );
  }
}

class Child extends StatelessWidget {
  const Child({super.key});

  @override
  Widget build(BuildContext context) {
    // 子组件获取祖先注入的依赖
    final data = ProviderData.of(context);
    return ElevatedButton(
      onPressed: () {
        data.count.value++;
      },
      child: ObsBuilder(builder: (context) {
        return Text('child count: ${data.count.value}');
      }),
    );
  }
}
```

### 7. 手动刷新

Obs 提供了 auto 变量用于控制是否自动刷新页面

```dart
class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    final count = Obs(0, auto: false);
    return ElevatedButton(
      onPressed: () {
        count.value++;
        count.notify(); // 手动刷新

        count.auto = false; // 你可以随时控制是否要自动刷新页面
        count.value++;
        // 处理其他逻辑...
        count.notify();
        count.auto = true;
      },
      child: ObsBuilder(builder: (context) => Text('count: ${count.value}')),
    );
  }
}
```

### 8. 添加监听函数

Obs提供了 watch 选项，在创建响应式变量的同时绑定监听逻辑，你还可以设置 immediate 选项触发立即执行一次监听函数，
它的触发时机便是执行了 notify 函数。

注意：oldValue 依赖于 setter 方法的执行，当你的响应式变量值是一个对象时，如果没有进行整个对象的赋值，
那么 setter 方法将无法拦截，会导致 oldValue 不会更新，这时，你需要手动修改 oldValue。

```dart
class GlobalState {
  static final enableResampling = Obs(
    true,
    immediate: true,
    watch: (newValue, oldValue) {
      GestureBinding.instance.resamplingEnabled = newValue;
    },
  );
}
```

### 9. ObsBuilder监听其他响应式变量

ObsBuilder 也提供了 watch 选项，与 Obs 不同的是，它接收 Obs 数组，当监听的任意一个变量发生变化时，都会重新构建小部件

```dart
class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    final count1 = Obs(0);
    final count2 = Obs(0);
    return ElevatedButton(
      onPressed: () => count2.value++,
      child: ObsBuilder(
        // 当 count2 更新时，也会重建小部件，即使小部件构建函数中没有使用 count2 变量
        watch: [count2],
        builder: (context) => Text('count: ${count1.value}'),
      ),
    );
  }
}
```

### 10. 响应式变量 - 对象

之所以修改 List、Map 等对象时不会触发自动刷新，是因为 dart 只能通过 setter 方法拦截对象的更改，
如果你没有将整个对象进行赋值，那么 setter 方法无法拦截，所以自然无法触发自动刷新，这种情况下你有两个选择：

1. 将整个对象进行赋值给 .value
2. 手动执行 notify 方法触发刷新

```dart
class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Obs({
      'name': 'hihi',
      'age': 20,
    });
    return ElevatedButton(
      onPressed: () {
        // 设置完整对象，List、DataModel 同理
        user.value = {
          ...user.value,
          'name': 'xx',
        };

        // 或者手动刷新
        user.value['name'] = 'xx';
        user.notify();
      },
      child: ObsBuilder(
        builder: (context) => Text('user name: ${user.value["name"]}'),
      ),
    );
  }
}
```