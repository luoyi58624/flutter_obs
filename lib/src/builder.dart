part of '../flutter_obs.dart';

class ObsBuilder extends StatelessWidget {
  /// 响应式变量构建器，监听内部的响应式变量，当变量发生变更时，将重建小部件
  const ObsBuilder({super.key, required this.builder, this.binding});

  /// 必须通过函数构建小部件，否则无法延迟拦截读取内部的响应式变量
  final WidgetBuilder builder;

  /// 手动绑定响应式变量与其建立关联
  final List<Obs>? binding;

  @override
  StatelessElement createElement() {
    print('xx');
    return _Element(this, binding);
  }

  @override
  Widget build(BuildContext context) => builder(context);
}

class _Element extends StatelessElement {
  _Element(super.widget, this.binding);

  final List<Obs>? binding;

  /// 保存销毁[Obs]变量的监听函数集合，一个构建器可以存在多个响应式变量，该组件被销毁时，
  /// 需要通知所有的响应式变量移除此构建器的更新函数
  final Set<VoidCallback> removeNotifyFunList = {};

  /// 拦截小部件构建的生命周期，为响应式变量建立关联
  @override
  Widget build() {
    if (binding != null && binding!.isNotEmpty) {
      print(binding);
      for (final obs in binding!) {
        if (!obs._notifyFunList.contains(_notify)) {
          obs.addListener(_notify);
          removeNotifyFunList.add(() => obs.removeListener(_notify));
        }
      }
    }
    _notifyFun = _notify;
    var result = super.build();
    _notifyFun = null;
    removeNotifyFunList.addAll(_removeNotifyFunList);
    _removeNotifyFunList.clear();
    return result;
  }

  /// 卸载时移除监听
  @override
  void unmount() {
    for (var fun in removeNotifyFunList) {
      fun();
    }
    removeNotifyFunList.clear();
    super.unmount();
  }

  /// 更新函数，响应式变量发生变更就是执行它们让页面刷新
  void _notify() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) markNeedsBuild();
    });
  }
}
