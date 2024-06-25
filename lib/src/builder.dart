part of '../flutter_obs.dart';

class ObsBuilder extends StatelessWidget {
  /// 响应式变量构建器，监听内部的响应式变量，当变量发生变更时，将重建小部件
  const ObsBuilder({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  StatelessElement createElement() => _Element(this);

  @override
  Widget build(BuildContext context) => builder(context);
}

class _Element extends StatelessElement {
  _Element(super.widget);

  /// 保存销毁[Obs]变量的监听函数，当此组件被销毁时，我们需要从[Obs]中移除它的监听函数
  VoidCallback? removeNotifyFun;

  /// 拦截小部件构建的生命周期，为响应式变量建立关联。
  /// 1. 构建页面前将更新页面函数赋值给中转变量
  /// 2. 构建页面，它如果读取到内部的响应式变量 getter 方法，那么会将 _notify 函数保存到监听列表中
  /// 3. Obs变量 getter 方法会同时设置移除监听的中转变量，将此变量保存在组件内部，卸载时将执行
  @override
  Widget build() {
    _notifyFun = _notify;
    var result = super.build();
    _notifyFun = null;
    removeNotifyFun = _removeNotifyFun;
    _removeNotifyFun = null;
    return result;
  }

  @override
  void unmount() {
    if (removeNotifyFun != null) removeNotifyFun!();
    super.unmount();
  }

  void _notify() {
    if (mounted) markNeedsBuild();
  }
}
