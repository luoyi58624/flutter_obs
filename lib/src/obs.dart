import 'package:flutter/widgets.dart';

part 'builder.dart';

/// 监听回调，接收 newValue、oldValue 参数
typedef WatchCallback<T> = void Function(T newValue, T oldValue);

/// 临时 ObsBuilder 小部件重建函数
VoidCallback? _updateBuilderFun;

/// ObsBuilder 内部允许存在多个 Obs 变量，此集合就是在 build 过程中收集多个 Obs 实例
Set<_Notify> _notifyList = {};

/// Obs、ObsBuilder 二者之间的枢纽
class _Notify<T> {
  /// ObsBuilder 更新函数集合
  final List<VoidCallback> builderFunList = [];

  /// 用户手动添加的监听函数集合
  final List<WatchCallback<T>> watchFunList = [];
}

/// [Obs] 继承自 [ValueNotifier]，所以支持多种使用方式：
///
/// ```dart
/// const count = Obs(0);
///
/// ObsBuilder(
///   builder: (context){
///     return Text('${count.value}');
///   },
/// ),
/// ListenableBuilder(
///   listenable: count,
///   builder: (context, child){
///     return Text('${count.value}');
///   },
/// ),
/// ValueListenableBuilder(
///   valueListenable: count,
///   builder: (context, value, child){
///     return Text('$value');
///   },
/// ),
/// ```
class Obs<T> extends ValueNotifier<T> {
  /// 创建一个响应式变量，[ObsBuilder] 会收集内部所有响应式变量，当发生变更时会自动重建小部件。
  /// * auto 当响应式变量发生变化时，是否自动触发所有注册的通知函数，默认true
  /// * watch 设置监听回调函数，接收 newValue、oldValue 回调
  /// * immediate 是否立即执行一次监听函数，默认false
  Obs(
    super.value, {
    this.auto = true,
    WatchCallback<T>? watch,
    bool immediate = false,
  }) {
    this._initialValue = super.value;
    this.oldValue = super.value;
    if (watch != null) {
      _notify.watchFunList.add(watch);
      if (immediate) _notifyWatchFun();
    }
  }

  /// 当小部件被 [ObsBuilder] 包裹时，它会追踪内部的响应式变量
  @override
  T get value {
    if (_updateBuilderFun != null) {
      final fun = _updateBuilderFun!;
      if (!_notify.builderFunList.contains(fun)) {
        _notify.builderFunList.add(fun);
        _notifyList.add(_notify);
      }
    }
    return super.value;
  }

  /// 拦截 setter 方法更新变量通知所有小部件更新
  @override
  set value(T newValue) {
    if (super.value != newValue) {
      oldValue = super.value;
      super.value = newValue;
      if (auto) notify();
    }
  }

  /// 副作用通知实例对象，内部保存了刷新 ObsBuilder 小部件函数集合、以及 watch 监听函数集合
  final _Notify<T> _notify = _Notify<T>();

  /// [_value] 初始值，当执行 [reset] 重置方法时应用它
  late T _initialValue;

  /// 记录上一次 [_value] 值
  late T oldValue;

  /// 当通过 .value 更新时是否自动刷新小部件，如果你需要手动控制，请将其设置为 false，
  /// 你既可以从构造函数中初始化它，也可以在任意代码中动态修改它
  bool auto;

  /// 通知所有依赖此响应式变量的小部件进行刷新，包括注册的监听函数
  void notify() {
    notifyListeners();
    for (var fun in _notify.builderFunList) {
      fun();
    }
    _notifyWatchFun();
  }

  void _notifyWatchFun() {
    for (var fun in _notify.watchFunList) {
      fun(super.value, this.oldValue);
    }
  }

  /// 重置响应式变量到初始状态，你可以在任意位置执行它
  void reset() {
    super.value = _initialValue;
    // 在 dispose 生命周期中执行重置，如果不加延迟会导致 setState 异常
    Future.delayed(const Duration(milliseconds: 1), () {
      notify();
    });
  }

  /// 添加监听函数，接收 newValue、oldValue 两个参数
  void addWatch(WatchCallback<T> fun) {
    if (_notify.watchFunList.contains(fun) == false) {
      _notify.watchFunList.add(fun);
    }
  }

  /// 移除监听函数
  void removeWatch(WatchCallback<T> fun) {
    _notify.watchFunList.remove(fun);
  }

  /// 释放所有监听器，一旦执行此变量将不可再次使用，不可使用的限制是来源于 [ChangeNotifier]。
  ///
  /// 在正常情况下，你并不需要手动调用这个函数，对于自动收集的刷新小部件依赖，小部件被卸载时会自动移除，
  /// 而用户唯一需要考虑的则是手动添加的副作用：
  /// * addListener -> removeListener
  /// * addWatch -> removeWatch
  ///
  /// 如果不想手动移除监听，同时确定不再使用这个响应式变量，你可以调用 dispose 清除全部副作用函数。
  @override
  void dispose() {
    _notify.builderFunList.clear();
    _notify.watchFunList.clear();
    super.dispose();
  }

  /// 如果将响应式变量当字符串使用，你可以省略.value
  @override
  String toString() {
    return value.toString();
  }
}

/// 响应式变量测试工具类
class ObsTest {
  static int getBuilderFunLength<T>(Obs<T> obs) {
    return obs._notify.builderFunList.length;
  }

  static int getWatchFunLength<T>(Obs<T> obs) {
    return obs._notify.watchFunList.length;
  }
}
