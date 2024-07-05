part of '../flutter_obs.dart';

/// [ObsBuilder]重建页面函数
VoidCallback? _notifyFun;

/// 此临时变量保存 [ObsBuilder] 依赖的响应式变量列表
Set<Obs> _dependObsList = {};

/// 声明一个响应式变量，它会收集所有依赖此变量的[ObsBuilder]，通过.value更新会自动重建小部件，
/// 你也可以手动调用 [notify] 方法通知小部件更新。
///
/// 你不需要考虑 dispose 的问题，如果你将它用于 Widget 内部，它会跟随小部件一起被自动销毁，
/// 如果你将它用于全局变量，则可以调用 [reset] 函数重置它的状态。
class Obs<T> {
  Obs(this._value, {this.manual = false}) {
    this._initialValue = _value;
  }

  /// 初始值
  late T _initialValue;

  /// 是否手动刷新，默认false，若为 true 当变量发生更改时不会自动调用 [notify] 方法
  final bool manual;

  /// 保存依赖此变量的小部件刷新方法集合
  final List<VoidCallback> _notifyFunList = [];

  T _value;

  /// 当小部件被 [ObsBuilder] 包裹时，它会追踪内部的响应式变量
  T get value {
    if (_notifyFun != null) {
      final fun = _notifyFun!;
      if (!_notifyFunList.contains(fun)) {
        addListener(fun);
        _dependObsList.add(this);
      }
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

  /// 重置响应式变量状态。
  ///
  /// 注意：在已有依赖情况下将其重置需要考虑 [addListener] 手动添加的副作用，重置后它们会丢失，
  /// 尽量在无任何副作用的情况下执行重置状态。
  void reset() {
    _value = _initialValue;
    // 清空监听器列表前通知所有页面刷新，由于是等到下一帧执行，所以它的作用是与已存在的构建器重新建立关联
    notify();
    _notifyFunList.clear();
  }

  void addListener(VoidCallback listener) {
    _notifyFunList.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _notifyFunList.remove(listener);
  }
}
