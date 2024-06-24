part of '../flutter_obs.dart';

/// 临时保存[ObsBuilder]更新函数，此变量仅为一个中转变量
VoidCallback? _notifyFun;

/// 保存移除[_notifyFunList]的更新函数，此变量仅为一个中转变量
VoidCallback? _disposeNotifyFun;

/// 响应式对象，它会收集所有依赖此变量的[ObsBuilder]，当更新此变量时将会重建所有依赖该变量的小部件，
/// 但是，对于List、Map等对象，如果你不是通过.value进行对象覆盖，而是通过 add、remove 等 api 操作原有对象，
/// 那么你必须使用[update]方法手动进行更新，因为自动更新实际上只是拦截了 setter 方法。
class Obs<T> {
  Obs(
    this._value, {
    this.manual = false,
  }) {
    this._initialValue = _value;
  }

  /// 是否手动刷新，默认false，若为 true 当变量发生更改时不会自动调用[notify]方法
  final bool manual;

  T _value;

  /// 当小部件被[ObsBuilder]包裹时，它会追踪内部的响应式变量，而 getter 方法则是与其建立联系
  T get value {
    if (_notifyFun != null) {
      final fun = _notifyFun!;
      _notifyFunList.add(fun);
      _disposeNotifyFun = () {
        _notifyFunList.remove(fun);
      };
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

  /// 保存初始值，当调用[dispose]方法时会清空[_notifyFunList]，并重置初始值
  late T _initialValue;

  /// 保存依赖此变量的小部件刷新方法集合
  final Set<VoidCallback> _notifyFunList = {};

  /// 通知所有依赖此响应式变量的小部件进行刷新
  void notify() {
    for (var fun in _notifyFunList) {
      fun();
    }
  }

  /// 重置响应式变量状态，只有当你使用全局变量时才可能会用到，局部变量不需要你做任何额外操作
  void reset() {
    _notifyFunList.clear();
    _value = _initialValue;
  }
}
