import 'package:flutter/foundation.dart';

import 'private.dart';

/// 响应式变量监听回调
typedef ObsWatchCallback<T> = void Function(T newValue, T oldValue);

/// [Obs] 继承自 [ValueNotifier]，但核心实现完全不依赖 [ValueNotifier]，继承它是为了支持多种使用方式：
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
///
/// 提示：当你将 [Obs] 作为局部状态时，正常情况下你不需要执行 dispose 方法进行销毁，
/// 执行 dispose 只是清空 [ChangeNotifier] 中 List 数组，无论是使用 [ObsBuilder]，
/// 还是 [ValueListenableBuilder]，当这些小部件被卸载时都会自动移除监听方法。
class Obs<T> extends ValueNotifier<T> {
  /// 创建一个响应式变量，[ObsBuilder] 会收集内部所有响应式变量，当发生变更时会自动重建小部件。
  /// * auto 当响应式变量发生变化时，是否自动触发所有注册的通知函数，默认true
  /// * watch 设置监听回调函数，接收 newValue、oldValue 回调
  /// * immediate 是否立即执行一次监听函数，默认false
  Obs(
    this._value, {
    this.auto = true,
    ObsWatchCallback<T>? watch,
    bool immediate = false,
  }) : super(_value) {
    this._initialValue = _value;
    this.oldValue = _value;
    if (watch != null) {
      notifyInstance.watchFunList.add(watch);
      if (immediate) _notifyWatchFun();
    }
  }

  /// 响应式变量的原始值
  T _value;

  /// 当小部件被 [ObsBuilder] 包裹时，它会追踪内部的响应式变量
  @override
  T get value {
    if (tempUpdateFun != null) {
      final fun = tempUpdateFun!;
      if (!notifyInstance.builderFunList.contains(fun)) {
        notifyInstance.builderFunList.add(fun);
        tempNotifyList.add(notifyInstance);
      }
    }
    return _value;
  }

  /// 拦截 setter 方法更新变量通知所有小部件更新
  @override
  set value(T newValue) {
    if (_value != newValue) {
      oldValue = _value;
      _value = newValue;
      if (auto) notify();
    }
  }

  /// 副作用通知实例对象，内部保存了刷新 ObsBuilder 小部件函数集合、以及 watch 监听函数集合。
  ///
  /// 此变量本来是内部私有的，但之所以公开是为了测试用例的执行，所以，在业务逻辑中请不要操作此对象。
  final NotifyInstance<T> notifyInstance = NotifyInstance<T>();

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
    for (var fun in notifyInstance.builderFunList) {
      fun();
    }
    _notifyWatchFun();
  }

  void _notifyWatchFun() {
    for (var fun in notifyInstance.watchFunList) {
      fun(this._value, this.oldValue);
    }
  }

  /// 重置响应式变量到初始状态，你可以在任意位置执行它
  void reset() {
    _value = _initialValue;
    // 在 dispose 生命周期中执行重置，如果不加延迟会导致 setState 异常
    Future.delayed(const Duration(milliseconds: 1), () {
      notify();
    });
  }

  /// 添加监听函数，提示：它和 [addListener] 本质上完全一样，
  /// 不过此回调可以接收 newValue、oldValue 两个参数
  void addWatch(ObsWatchCallback<T> fun) {
    if (notifyInstance.watchFunList.contains(fun) == false) {
      notifyInstance.watchFunList.add(fun);
    }
  }

  /// 移除监听函数
  void removeWatch(ObsWatchCallback<T> fun) {
    notifyInstance.watchFunList.remove(fun);
  }

  /// 释放所有监听器，一旦执行此变量将不可再次使用，不可使用的限制是来源于 [ChangeNotifier]。
  ///
  /// 在正常情况下，你并不需要手动调用这个函数，对于自动收集的刷新小部件依赖，小部件被卸载时会自动移除，
  /// 而用户唯一需要考虑的则是手动添加的副作用：
  /// * addListener -> removeListener
  /// * addWatch -> removeWatch
  ///
  /// 当然，如果绑定了太多监听函数，你可以直接调用 dispose 一劳永逸地全部清除。
  @override
  void dispose() {
    notifyInstance.builderFunList.clear();
    notifyInstance.watchFunList.clear();
    super.dispose();
  }

  /// 如果将响应式变量当字符串使用，你可以省略.value
  @override
  String toString() {
    return value.toString();
  }
}
