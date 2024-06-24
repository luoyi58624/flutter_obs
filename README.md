一个很轻量的响应式状态管理，支持声明为全局状态、局部状态，整包源码不超过100行代码，同时，它只有两个概念：

1. Obs -> 声明一个响应式变量
2. ObsBuilder -> 监听内部响应式变量，并重建小部件

> 状态主要分为两种类型，一类为基本数据类型(String、num、bool)，另一类则为对象类型(List、Map)，该库自动触发响应操作
> 逻辑很简单，就是拦截 setter 方法，通常情况下，只要你是通过.value直接修改对象，那么页面就会自动重建，
> 但是当你操作List集合时，使用add、remove等api修改数据页面是不会重建的，因为这些api setter方法无法拦截对象的变更，
> 你必须创建一个新的集合并通过.value直接赋值才能触发 setter 拦截，因此，如果你不通过.value来更新对象，
> 那么你需要手动调用 notify 方法来重建页面。

> 此库借鉴了[Getx](https://github.com/jonataslaw/getx)的响应式逻辑，Obs -> Rx，ObsBuilder -> Obx，
> 只不过在实现上进行了大量的精简，抛弃了众多扩展函数，也抛弃了GetxController控制器，所以，Obs必须通过.value访问，
> 更新时也必须通过.value更新，操作List、Map等对象时，你还必须通过.value赋值新的对象才能自动刷新页面，否则你需要手动
> 调用notify方法来刷新页面，虽然相比getx麻烦了一点，但它的优点在于极为轻量，而且几乎没有任何心智负担。

- [开始使用](#开始使用)
- [定义全局状态](#定义全局状态)
- [定义局部状态](#定义局部状态)
- [模拟Getx控制器](#模拟Getx控制器)

### 开始使用

```
flutter pub add flutter_obs
```

```dart
/// 以最简单的方式介绍 Obs、ObsBuilder 的使用方式，这就是它们的全部概念，
/// 下面的所有内容只不过是运用flutter、dart的基础知识进行扩展。
class SimplePage extends StatelessWidget {
  const SimplePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 如果无状态小部件没有使用const修饰，那么父组件状态发生变更会导致响应式变量重建，这种情况下请将它声明为有状态组件或全局状态
    final count = Obs(0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('入门示例'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => count.value++,
              child: ObsBuilder(builder: (_) => Text('count: ${count.value}')),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 定义全局状态

```dart
/// 声明全局状态，你可以在任意 dart 文件中保存这个值，或者将它封装到 class 中
final count = Obs(0);

class ParentPage extends StatelessWidget {
  const ParentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('父页面'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => count.value++,
              child: ObsBuilder(builder: (_) => Text('count: ${count.value}')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ChildPage()),
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

class ChildPage extends StatelessWidget {
  const ChildPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('子页面'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => count.value++,
              child: ObsBuilder(builder: (_) => Text('count: ${count.value}')),
            ),
          ],
        ),
      ),
    );
  }
}

```

### 定义局部状态

> 为什么局部状态也要用状态管理？我直接用setState不就好了吗？

1. 如果小部件支持const修饰，那么局部状态可以放到StatelessWidget无状态小部件中，这样父组件刷新是不会造成子组件重新build。
2. 细粒度更新小部件，使用setState更新会导致当前整个组件被重建，如果组件较复杂你可能就必须拆分了。

```dart
class LocalStatePage extends StatefulWidget {
  const LocalStatePage({super.key});

  @override
  State<LocalStatePage> createState() => _LocalStatePageState();
}

class _LocalStatePageState extends State<LocalStatePage> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('局部状态示例'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => setState(() => count++),
              child: Text('count: $count'),
            ),
            // 使用const修饰可以防止子组件被重置，但开发环境下热刷新依旧会重置状态
            const _Child(),
            // 不用const修饰父组件每次更新都会导致重置
            _Child(),
            // 有状态小部件可以不加const
            _Child3(),
          ],
        ),
      ),
    );
  }
}

class _Child extends StatelessWidget {
  const _Child();

  @override
  Widget build(BuildContext context) {
    final count = Obs(0);
    return ElevatedButton(
      onPressed: () => count.value++,
      child: ObsBuilder(
        builder: (_) => Text('child component count: ${count.value}'),
      ),
    );
  }
}

class _Child3 extends StatefulWidget {
  const _Child3();

  @override
  State<_Child3> createState() => _Child3State();
}

class _Child3State extends State<_Child3> {
  final count = Obs(0);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => count.value++,
      child: ObsBuilder(
        builder: (_) => Text('child3 component count: ${count.value}'),
      ),
    );
  }
}

```

> 想实现Getx一样的进入某个路由注入控制器，退出页面时销毁控制器？对于这种需要局部跨页面的需求，你也可以完全用纯dart去实现。
> Getx实现的Get.put、Get.find不要想得很复杂，它实际上就是内部维护了一个全局Map，以控制器的类型名字作为key存放，
> 如果设置了tag，就在后面拼接上tag。

### 模拟Getx控制器

- 创建控制器

```dart
/// 定义局部控制器，对于局部跨页面的控制器最好定义为私有，防止其他页面滥用它，如果你的子路由文件是分开的，只需通过part链接即可，
/// 同时，因为是需要等待进入路由才初始化，所以我们需要将它定义为可为空。
_Controller? _controller;

class _Controller {
  final count = Obs(0);
}
```

- 初始化控制器

```dart
class GetxStatePage extends StatefulWidget {
  const GetxStatePage({super.key});

  @override
  State<GetxStatePage> createState() => _GetxStatePageState();
}

class _GetxStatePageState extends State<GetxStatePage> {
  @override
  void initState() {
    super.initState();
    // 初始化控制器
    _controller = _Controller();
  }

  @override
  void dispose() {
    super.dispose();
    // 销毁控制器，你不需要考虑dispose，Obs变量实际上就跟普通变量一样
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('模拟Getx状态管理'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _controller!.count.value++,
              child: ObsBuilder(
                builder: (_) => Text('count: ${_controller!.count.value}'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ChildPage()),
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
```

- 子页面直接使用即可，不需要Get.find()，一切都是纯dart知识

```dart
class ChildPage extends StatelessWidget {
  const ChildPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('子页面'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _controller!.count.value++,
              child: ObsBuilder(
                builder: (_) => Text('count: ${_controller!.count.value}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

> 你还想实现重复跳转这个页面？如果是这样，还是建议你将这部分状态作为局部声明，组件传值使用InheritedWidget或Provider传递，
> 跨路由则请将状态作为参数进行传递。

> 注意：局部声明不是意味着你将全部逻辑都放到widget里面，而是让你定义一个普通的class统一管理状态和业务逻辑，
> 而class实例变量则是放到widget内部。