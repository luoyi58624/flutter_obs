part of '../flutter_obs.dart';

/// 响应式变量构建器
class ObsBuilder extends StatelessWidget {
  /// 监听内部的响应式变量，当变量发生变更时，将自动重建小部件，
  /// 你可以嵌套多个构建器，将包裹的响应式变量以最小细粒度进行重建，
  /// 当构建器内部包含多个响应式变量时，同时更改多个变量不会触发多次构建，
  /// 因为 Flutter 是根据帧来刷新小部件的，每次执行 setState 只是将当前组件标记为脏，
  /// 如果一个组件已经标记过了会直接返回，然后将需要刷新的小部件放入更新队列中，
  /// 等下一帧到来时统一更新，所以它并不会因为你执行了几次更新操作就触发几次更新。
  const ObsBuilder({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  StatelessElement createElement() => _Element(this);

  @override
  Widget build(BuildContext context) => builder(context);
}

class _Element extends StatelessElement {
  _Element(super.widget);

  VoidCallback? disposeNotifyFun;

  @override
  Widget build() {
    _notifyFun = _notify;
    var result = super.build();
    _notifyFun = null;
    disposeNotifyFun = _disposeNotifyFun;
    _disposeNotifyFun = null;
    return result;
  }

  @override
  void unmount() {
    if (disposeNotifyFun != null) disposeNotifyFun!();
    super.unmount();
  }

  void _notify() {
    if (mounted) markNeedsBuild();
  }
}
