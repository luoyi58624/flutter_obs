part of '../flutter_obs.dart';

/// 临时保存[ObsBuilder]更新函数，此变量仅为一个中转变量
VoidCallback? _notifyFun;

/// 保存移除[_notifyFunList]的更新函数，此变量仅为一个中转变量
VoidCallback? _disposeNotifyFun;

/// 响应式对象，它会收集所有依赖此变量的[ObsBuilder]，当更新此变量时将会重建所有依赖该变量的小部件，
/// 但是，对于List、Map等对象，如果你不是通过.value进行对象覆盖，而是通过 add、remove 等 api 操作原有对象，
/// 那么你必须使用[notify]方法手动进行更新，因为自动更新实际上只是拦截了 setter 方法。
///
/// 注意：使用[ObsBuilder]包裹的小部件被移除时会自动释放，但如果你使用[addListener]添加
/// 的副作用请务必手动移除，除非你是在创建当前响应式变量的小部件中添加的监听，当小部件被销毁
/// 响应式变量和其副作用都会被 GC 回收。
class Obs<T> extends ValueNotifier<T> {
  Obs(super._value);

  /// 当小部件被[ObsBuilder]包裹时，它会追踪内部的响应式变量
  @override
  T get value {
    if (_notifyFun != null) {
      final fun = _notifyFun!;
      addListener(fun);
      _disposeNotifyFun = () => removeListener(fun);
    }
    return super.value;
  }

  /// 通知所有依赖此响应式变量的小部件进行刷新，该方法只是暴露
  void notify() => notifyListeners();
}
