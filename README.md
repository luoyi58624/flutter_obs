一个简单的响应式状态管理，它仅仅是对 ValueNotifier 进行的扩展，Api 如下：

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

### 2. 使用hook，弥补 StatelessWidget 的缺陷

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

通常情况下，你不需要在 dispose 生命周期中手动销毁它，它的工作原理很简单，就是维护了一个数组，存放刷新
Widget 的方法，当组件被销毁后其内部的变量自然而然会被 dart 垃圾回收器回收，如果你有遇到内存泄漏问题，请告诉我

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
    controller = Controller();
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

### 6. 手动刷新

Obs 提供了 auto 选项，用于控制当响应式变量发生变更时是否自动执行 notify 方法刷新页面，如果你需要手动刷新，请将其设置为false，
同时，它没有被设计为 final，所以你可以在任意位置修改它，用于精确控制修改变量时是否要自动刷新页面。

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

        count.auto = false; // 手动禁止自动刷新
        count.value++;
        // ...
        count.auto = true; // 还原
      },
      child: ObsBuilder(builder: (context) => Text('count: ${count.value}')),
    );
  }
}
```

### 7. 添加监听函数

Obs提供了 watch 选项，它可以在创建响应式变量的同时绑定监听逻辑，你还可以设置 immediate 选项触发立即执行一次监听函数，
它的触发时机便是执行了 notify 函数。

注意：oldValue 依赖于 setter 方法的执行，当你的响应式变量值是一个对象时，你最好通过 .value 进行更新，
而非手动调用 notify 方法去刷新页面，否则 oldValue 不会同步上一次值，当然，你也可以手动修改 oldValue。

对于局部绑定，你可以手动调用 addWatch、removeWatch，由于 Obs 继承 ValueNotifier，
所以你也可以使用 addListener、removeListener 等api，区别在于前者会传递两个参数：newValue、oldValue。

```dart
class GlobalState {
  // 开启重采样机制，开启此功能可以让高刷手机拥有更平滑的触控，但缺点是会带来一点延迟
  static final enableResampling = Obs(
    true,
    immediate: true,
    watch: (newValue, oldValue) {
      GestureBinding.instance.resamplingEnabled = newValue;
    },
  );
}
```

### 7. ObsBuilder监听其他响应式变量

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

### 8. 响应式变量 - 对象

为什么修改 List、Map 等对象时不会触发自动刷新？这是 dart 的缺陷，dart 只能通过 setter 方法拦截对象的更改，
当你使用对象的api时，setter 方法无法拦截，自然无法触发自动刷新，这种情况下你有两个选择：

1. 通过 .value 进行整个对象的修改
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

这个库的定位就是用于替代 ValueNotifier，整包源码除去注释只有200行左右，它的目的只用于满足一般的状态管理需求，
而不是大而全的解决方案，它的核心逻辑是借鉴[Getx](https://github.com/jonataslaw/getx)。