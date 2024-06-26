part of '../flutter_obs.dart';

/// 临时保存[ObsBuilder]更新函数，此变量是一个中转变量
VoidCallback? _notifyFun;

/// 保存移除[_notifyFunList]的更新函数，此变量是一个中转变量
VoidCallback? _removeNotifyFun;

/// 响应式对象，它会收集所有依赖此变量的[ObsBuilder]，通过.value更新会自动重建小部件，
/// 否则你需要手动调用[notify]方法通知小部件更新。
class Obs<T> implements Listenable {
  Obs(
    this._value, {
    this.manual = false,
  }) {
    this._initialValue = _value;
  }

  /// 初始值
  late T _initialValue;

  /// 是否手动刷新，默认false，若为 true 当变量发生更改时不会自动调用[notify]方法
  final bool manual;

  /// 保存依赖此变量的小部件刷新方法集合
  final Set<VoidCallback> _notifyFunList = {};

  T _value;

  /// 当小部件被[ObsBuilder]包裹时，它会追踪内部的响应式变量
  T get value {
    if (_notifyFun != null) {
      final fun = _notifyFun!;
      addListener(fun);
      _removeNotifyFun = () => removeListener(fun);
    }
    return _value;
  }

  /// 拦截 setter 方法更新变量通知所有小部件更新
  set value(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      if (!manual) notify();
    }
  }

  /// 通知所有依赖此响应式变量的小部件进行刷新
  void notify() {
    for (var fun in _notifyFunList) {
      fun();
    }
  }

  /// 重置响应式变量状态，它会清空所有监听，并重置状态
  void reset() {
    _notifyFunList.clear();
    _value = _initialValue;
  }

  @override
  void addListener(VoidCallback listener) {
    _notifyFunList.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _notifyFunList.remove(listener);
  }
}
