part of '../flutter_obs.dart';

/// 临时保存[ObsBuilder]更新函数，此变量是一个中转变量
VoidCallback? _notifyFun;

/// 保存移除[_notifyFunList]的更新函数，此变量是一个中转变量
VoidCallback? _removeNotifyFun;

/// 响应式对象，它会收集所有依赖此变量的[ObsBuilder]，通过.value更新会自动重建[ObsBuilder]，
/// 否则你需要手动调用[notify]方法通知小部件更新。
///
/// 提示：[Obs]本身并不需要[ValueNotifier]，继承它只是方便用户复用[ChangeNotifier]体系api。
class Obs<T> extends ValueNotifier<T> {
  Obs(
    this._value, {
    this.manual = false,
  }) : super(_value) {
    this._initialValue = _value;
  }

  /// 是否手动刷新，默认false，若为 true 当变量发生更改时不会自动调用[notify]方法
  final bool manual;

  T _value;

  /// 当小部件被[ObsBuilder]包裹时，它会追踪内部的响应式变量
  @override
  T get value {
    if (_notifyFun != null) {
      final fun = _notifyFun!;
      _notifyFunList.add(fun);
      _removeNotifyFun = () => _notifyFunList.remove(fun);
    }
    return _value;
  }

  /// 拦截 setter 方法更新变量通知所有小部件更新
  @override
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
    notifyListeners();
  }

  /// 重置响应式变量状态，它会清空当前响应式变量保存的所有[ObsBuilder]依赖，并重置响应式变量的默认值
  void reset() {
    _notifyFunList.clear();
    _value = _initialValue;
  }

  /// 完全销毁响应式变量，一旦执行此方法，该响应式变量将不可使用，除非你重新赋值
  @override
  void dispose() {
    reset();
    super.dispose();
  }

  /// 重写 toString 方法，让你在字符串中可以省略.value
  @override
  String toString() => value.toString();
}
