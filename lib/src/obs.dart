part of '../flutter_obs.dart';

/// 临时变量 - [ObsBuilder]重建页面函数
VoidCallback? _notifyFun;

/// 临时变量 - 一个 [ObsBuilder] 小部件可以存在多个[Obs]，此集合就是临时保存多个 [Obs] 通知实例
Set<_Notify> _dependNotifyList = {};

/// 响应式变量监听回调
typedef ObsWatchCallback<T> = void Function(T newValue, T oldValue);

/// 通知小部件刷新函数集合，它是 [Obs]、[ObsBuilder] 之间的枢纽
class _Notify<T> {
  final List<VoidCallback> list = [];
}

class _WatchFunNotify<T> {
  final List<ObsWatchCallback<T>> list = [];
}

/// 声明一个响应式变量，它会收集所有依赖此变量的 [ObsBuilder] 刷新方法，
/// 当你通过.value更新时会自动重建小部件，但操作 List、Map 等对象时，
/// 如果不传递完整的对象实例 setter 方法将无法拦截更新，在这种情况下，
/// 你可以手动调用 [notify] 方法通知小部件更新。
///
/// 它因为继承[ValueNotifier]，所以支持多种使用方式：
///
/// ```dart
/// const count = Obs(0);
///
/// ObsBuilder(
///   builder: (context){
///     return Text(count.value);
///   },
/// ),
/// ListenableBuilder(
///   listenable: count,
///   builder: (context, child){
///     return Text(count.value);
///   },
/// ),
/// ValueListenableBuilder(
///   valueListenable: count,
///   builder: (context, value, child){
///     return Text(value);
///   },
/// ),
/// ```
class Obs<T> extends ValueNotifier<T> {
  /// 创建一个响应式变量
  /// * watch 创建响应式变量的同时注入监听回调函数
  /// * immediate 是否立即执行注册的监听函数，默认false
  ///
  /// 注意：由于 Dart 的限制，如果你的监听函数依赖 oldValue，那么你一定要确保此响应式变量是自动刷新，
  /// 不能通过手动执行 notify 方法来逃避 setting 方法拦截，否则 oldValue 的值不会发生更改。
  Obs(
    this._value, {
    List<ObsWatchCallback<T>>? watch,
    bool immediate = false,
  }) : super(_value) {
    this._initialValue = _value;
    this._oldValue = _value;
    if (watch != null && watch.isNotEmpty) {
      _watchFunNotify.list.addAll(watch);
      if (immediate) _notifyWatchFun();
    }
  }

  /// 通知 [ObsBuilder] 小部件更新实例
  final _Notify _notify = _Notify();

  /// 响应式变量监听函数
  final _WatchFunNotify<T> _watchFunNotify = _WatchFunNotify();

  /// 保存 [_value] 的初始值，当执行 [reset] 重置方法时应用它
  late T _initialValue;

  /// 上一次 [_value] 值
  late T _oldValue;

  /// 响应式对象
  T _value;

  /// 当小部件被 [ObsBuilder] 包裹时，它会追踪内部的响应式变量
  @override
  T get value {
    if (_notifyFun != null) {
      final fun = _notifyFun!;
      if (!_notify.list.contains(fun)) {
        _notify.list.add(fun);
        _dependNotifyList.add(_notify);
      }
    }
    return _value;
  }

  /// 拦截 setter 方法更新变量通知所有小部件更新
  @override
  set value(T newValue) {
    if (_value != newValue) {
      _oldValue = _value;
      _value = newValue;
      notify();
    }
  }

  /// 通知所有依赖此响应式变量的小部件进行刷新
  void notify() {
    notifyListeners();
    for (var fun in _notify.list) {
      fun();
    }
    _notifyWatchFun();
  }

  void _notifyWatchFun() {
    for (var fun in _watchFunNotify.list) {
      fun(this._value, this._oldValue);
    }
  }

  /// 重置响应式变量到初始状态，你可以在任意位置执行它
  void reset() {
    _value = _initialValue;
    // 一般会在 dispose 生命周期中执行重置，如果不加延迟会导致 setState 异常
    Future.delayed(const Duration(milliseconds: 1), () {
      notify();
    });
  }

  void addWatch(ObsWatchCallback<T> fun) {
    if (_watchFunNotify.list.contains(fun) == false) {
      _watchFunNotify.list.add(fun);
    }
  }

  void removeWatch(ObsWatchCallback<T> fun) {
    _watchFunNotify.list.remove(fun);
  }

  /// 添加监听器，如果响应式变量是局部变量，当小部件被销毁时它的所有监听器会自动回收，
  /// 但如果是全局状态，当不再使用时你必须手动移除添加的监听器，或者调用 [dispose] 方法销毁所有副作用。
  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
  }

  /// 释放所有监听器，一旦执行此变量将不可再次使用
  @override
  void dispose() {
    _notify.list.clear();
    _watchFunNotify.list.clear();
    super.dispose();
  }

  /// 如果将响应式变量当字符串使用，你可以省略.value
  @override
  String toString() {
    return value.toString();
  }
}
