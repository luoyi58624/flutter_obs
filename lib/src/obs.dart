part of '../flutter_obs.dart';

/// 临时保存[ObsBuilder]更新函数，此变量仅为一个中转变量
VoidCallback? _notifyFun;

/// 保存移除[_notifyFunList]的更新函数，此变量仅为一个中转变量
VoidCallback? _disposeNotifyFun;

/// 响应式对象，它会收集所有依赖此变量的[ObsBuilder]，当更新此变量时将会重建所有依赖该变量的小部件，
/// 但是，对于List、Map等对象，如果你不是通过.value进行对象覆盖，而是通过 add、remove 等 api 操作原有对象，
/// 那么你必须使用[notify]方法手动进行更新，因为自动更新实际上只是拦截了 setter 方法。
///
/// 提示：[Obs]本身逻辑是不依赖[ValueNotifier]和[ChangeNotifier]的，选择继承它们只是为了扩展性。
class Obs<T> extends ValueNotifier<T> {
  Obs(
    super._value, {
    this.manual = false,
  }) {
    this._initialValue = super.value;
  }

  /// 是否手动刷新，默认false，若为 true 当变量发生更改时不会自动调用[notify]方法
  final bool manual;

  /// 当小部件被[ObsBuilder]包裹时，它会追踪内部的响应式变量，而 getter 方法则是与其建立联系
  @override
  T get value {
    if (_notifyFun != null) {
      final fun = _notifyFun!;
      _notifyFunList.add(fun);
      _disposeNotifyFun = () {
        _notifyFunList.remove(fun);
      };
    }
    return super.value;
  }

  /// 拦截 setter 方法更新变量通知所有小部件更新
  @override
  set value(T newValue) {
    if (super.value != newValue) {
      super.value = newValue;
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

  /// 重置响应式变量状态，它会清空当前响应式变量保存的所有[ObsBuilder]依赖，并重置响应式变量的默认值
  void reset() {
    _notifyFunList.clear();
    super.value = _initialValue;
  }

  /// 完全销毁响应式变量，一旦执行此方法，该响应式变量将不可使用，除非你重新赋值
  @override
  void dispose() {
    reset();
    super.dispose();
  }
}
