import 'package:flutter/material.dart';
import 'package:flutter_obs/flutter_obs.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

/// 模拟复杂的应用场景，检测是否存在内存泄漏，检测是否泄漏的核心点就是判断 ObsBuilder
/// 刷新方法集合是否被正确移除，对于继承的 [ValueNotifier]、以及用户手动添加的 watchFunList，
/// 它们不在考虑范围内，手动添加的副作用你必须自己手动处理。
void memoryLeakTest() {
  testWidgets('内存泄漏测试1', (tester) async {
    GlobalState state = GlobalState();
    // 对于嵌套 ObsBuilder，更新内部响应式变量不会影响外部
    await tester.pumpWidget(_MainApp(
      state: state,
      child: const _NestBuilder(),
    ));
    expect(find.text('parentUpdateCount: 0'), findsOneWidget);
    await tester.tap(find.text('count1: 0'));
    await tester.pump();
    expect(find.text('parentUpdateCount: 0'), findsOneWidget);
    expect(state.count.notifyInstance.builderFunList.length, 1);
    // 移除、重新建立连接
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('parentUpdateCount: 2'), findsOneWidget);
    // 点击count1，测试外部 ObsBuilder 构建情况
    await tester.tap(find.text('count1: 1'));
    await tester.pump();
    // 外部 ObsBuilder 发生构建，这是一个已知的bug，当内部的响应式构造器重新建立连接时，
    // 外部监听器没有移除（待修复）
    expect(find.text('parentUpdateCount: 3'), findsOneWidget);
    expect(state.count.notifyInstance.builderFunList.length, 2);
  });

  testWidgets('内存泄漏测试2', (tester) async {
    // 模拟反复销毁 count1-1 的 ObsBuilder，检测 count 依赖的构建函数集合是否正确
    GlobalState state = GlobalState();
    await tester.pumpWidget(_MainApp(
      state: state,
      child: const _StateTestWidget(),
    ));

    expect(state.count.notifyInstance.builderFunList.length, 2);

    await tester.tap(find.text('count1-1: 0'));
    await tester.pump();
    expect(find.text('count1-1: 1'), findsOneWidget);
    expect(find.text('count1-2: 1'), findsOneWidget);
    expect(find.text('count2: 0'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(state.count.notifyInstance.builderFunList.length, 1);

    await tester.tap(find.text('count2: 0'));
    await tester.pump();
    expect(find.text('count1-2: 1'), findsOneWidget);
    expect(find.text('count2: 1'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(state.count.notifyInstance.builderFunList.length, 2);

    await tester.tap(find.text('count1-1: 1'));
    await tester.pump();
    expect(find.text('count1-1: 2'), findsOneWidget);
    expect(find.text('count1-2: 2'), findsOneWidget);
    expect(find.text('count2: 1'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(state.count.notifyInstance.builderFunList.length, 1);
  });
}

class GlobalState {
  final count = Obs(0);
  final count2 = Obs(0);
  final show = Obs(false);
}

class _MainApp extends StatelessWidget {
  const _MainApp({required this.state, required this.child});

  final GlobalState state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
        child: _StateProvider(
          state,
          child: child,
        ),
      ),
    );
  }
}

class _StateProvider extends InheritedWidget {
  const _StateProvider(
    this.state, {
    required super.child,
  });

  final GlobalState state;

  static _StateProvider of(BuildContext context) {
    final _StateProvider? result =
        context.dependOnInheritedWidgetOfExactType<_StateProvider>();
    assert(result != null, 'No _StateProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(_StateProvider oldWidget) => true;
}

class _NestBuilder extends StatefulWidget {
  const _NestBuilder();

  @override
  State<_NestBuilder> createState() => _NestBuilderState();
}

class _NestBuilderState extends State<_NestBuilder> {
  int parentUpdateCount = -1;
  bool flag = true;

  @override
  Widget build(BuildContext context) {
    final state = _StateProvider.of(context).state;
    return Column(
      children: [
        // 模拟比较恶心的写法，虽然不实用，但实际业务可能会存在比这更隐蔽、复杂的使用
        ObsBuilder(builder: (context) {
          parentUpdateCount++;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: flag,
                onChanged: (v) => setState(() {
                  flag = v;
                }),
              ),
              ElevatedButton(
                onPressed: () {
                  state.count.value++;
                },
                child: flag
                    ? ObsBuilder(builder: (context) {
                        return Text('count1: ${state.count.value}');
                      })
                    : Text('count1: ${state.count.value}'),
              ),
              Text('parentUpdateCount: $parentUpdateCount'),
              ElevatedButton(
                onPressed: () {
                  state.count2.value++;
                },
                child: Text('count2: ${state.count2.value}'),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _StateTestWidget extends StatefulWidget {
  const _StateTestWidget();

  @override
  State<_StateTestWidget> createState() => _StateTestWidgetState();
}

class _StateTestWidgetState extends State<_StateTestWidget> {
  bool flag = true;

  @override
  Widget build(BuildContext context) {
    final state = _StateProvider.of(context).state;
    return Column(
      children: [
        Switch(
          value: flag,
          onChanged: (v) => setState(() {
            flag = v;
          }),
        ),
        ObsBuilder(builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (flag)
                ElevatedButton(
                  onPressed: () {
                    state.count.value++;
                  },
                  child: ObsBuilder(builder: (context) {
                    return Text('count1-1: ${state.count.value}');
                  }),
                ),
              ElevatedButton(
                onPressed: () {
                  state.count.value++;
                },
                child: Text('count1-2: ${state.count.value}'),
              ),
              ElevatedButton(
                onPressed: () {
                  state.count2.value++;
                },
                child: Text('count2: ${state.count2.value}'),
              ),
            ],
          );
        }),
        ElevatedButton(
          onPressed: () {
            push(context, const _ChildPage());
          },
          child: const Text('子页面'),
        ),
      ],
    );
  }
}

class _ChildPage extends StatefulWidget {
  const _ChildPage();

  @override
  State<_ChildPage> createState() => _ChildPageState();
}

class _ChildPageState extends State<_ChildPage> {
  @override
  Widget build(BuildContext context) {
    final state = _StateProvider.of(context).state;
    return Scaffold(
      body: Column(
        children: [],
      ),
    );
  }
}
