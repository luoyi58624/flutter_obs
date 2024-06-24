import 'package:flutter/material.dart';
import 'package:flutter_obs/flutter_obs.dart';

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
            // 即使你将响应式变量移到build函数外，也会被重置，
            // 因为当父组件刷新时会重新创建新的子组件实例
            _Child2(),
            // 将子组件变成有状态可以防止状态重置，无论你是否添加了const，
            // 所以，如果你的组件依赖外部状态，你要么使用有状态组件构建，
            // 要么将响应式变量变成全局。
            // 在有状态组件下使用响应式变量有以下好处：
            // 1. 无需执行setState，直接通过.value即可刷新小部件
            // 2. 细粒度更新小部件，使用setState更新会导致当前整个组件被重建
            // 3. 无需手动销毁，当组件被移除时响应式变量会像普通变量一样直接从内存回收
            _Child3(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const LocalStatePage()),
                );
              },
              child: const Text('下一个局部状态页面'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 你可以在无状态小部件中直接声明响应式变量，但是，父组件使用它时
/// 必须使用const修饰，否则父组件刷新页面会重建该组件导致状态被重置，
/// 还有，开发环境下热更新会强制刷新所有小部件，导致状态被重置
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

class _Child2 extends StatelessWidget {
  _Child2();

  final count = Obs(0);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        count.value++;
      },
      child: ObsBuilder(builder: (context) {
        return Text('child2 component count: ${count.value}');
      }),
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
