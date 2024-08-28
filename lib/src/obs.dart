import 'package:flutter/widgets.dart';

part 'builder.dart';

/// 响应式变量监听回调，接收 newValue、oldValue 参数
typedef ObsWatchCallback<T> = void Function(T newValue, T oldValue);

/// 响应式变量通知模式，多种模式触发优先级：all > none > obs、watch、isolateWatch、listenable
enum ObsNotifyMode {
  /// 触发所有通知
  all,

  /// 不触发任何通知
  none,

  /// 仅触发 [ObsBuilder] 自动重建
  obs,

  /// 仅触发 watch 所有监听函数
  watch,

  /// 仅触发被隔离的 watch 监听函数
  isolateWatch,

  /// 仅触发 [ChangeNotifier] 中的所有监听函数
  listeners,
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
  /// * isolate 构造函数绑定的监听函数是否与普通监听函数隔离，默认false，若为true，它将不会放置在数组中
  Obs(
    super.value, {
    this.notifyMode = const [ObsNotifyMode.all],
    ObsWatchCallback<T>? watch,
    bool immediate = false,
    bool isolate = false,
  }) {
    this._initialValue = super.value;
    this.oldValue = super.value;
    if (watch != null) {
      if (isolate) {
        this._notify = _Notify<T>(watch);
        if (immediate) notifyIsolateWatch();
      } else {
        this._notify = _Notify<T>(null);
        _notify.watchFunList.add(watch);
        if (immediate) notifyWatch();
      }
    } else {
      this._notify = _Notify<T>(null);
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
      if (notifyMode.contains(ObsNotifyMode.all)) {
        notify();
      } else if (notifyMode.contains(ObsNotifyMode.none)) {
        return;
      } else {
        if (notifyMode.contains(ObsNotifyMode.obs)) notifyObsBuilder();
        if (notifyMode.contains(ObsNotifyMode.watch)) notifyWatch();
        if (notifyMode.contains(ObsNotifyMode.isolateWatch)) {
          notifyIsolateWatch();
        }
        if (notifyMode.contains(ObsNotifyMode.listeners)) {
          notifyListeners();
        }
      }
    }
  }

  /// 副作用通知实例对象，内部保存了刷新 ObsBuilder 小部件函数集合、以及 watch 监听函数集合
  late final _Notify<T> _notify;

  /// [_value] 初始值，当执行 [reset] 重置方法时应用它
  late T _initialValue;

  /// 记录上一次 [_value] 值
  late T oldValue;

  /// 当响应式变量 setter 方法成功拦截时应用的通知模式，它接收一个数组，默认 [ObsNotifyMode.all]，
  /// 意味着变量发生更改时通知所有注册的监听函数执行，如果你想手动控制 UI 更改或精确化触发监听函数，
  /// 只需调整数组中的参数即可，你既可以从构造函数中初始化它，也可以在任意代码中动态修改它。
  ///
  /// 例如只监听 watch、 ChangeNotifier 注册的副作用函数：
  /// ```
  /// obs.notifyMode = [ ObsNotifyMode.watch, ObsNotifyMode.listeners ];
  /// ```
  ///
  /// 或者只想手动刷新界面：
  /// ```
  /// obs.notifyMode = [ ObsNotifyMode.none ];
  /// obs.notify(); // 通知所有副作用函数
  /// obs.notifyObsBuilder(); // 只通知 ObsBuilder 刷新
  /// ```
  List<ObsNotifyMode> notifyMode;

  /// 重置响应式变量到初始状态
  void reset() {
    super.value = _initialValue;
    // 在 dispose 生命周期中执行重置，如果不加延迟会导致 setState 异常
    Future.delayed(const Duration(milliseconds: 1), () {
      notify();
    });
  }

  /// 添加监听函数，接收 newValue、oldValue 两个参数
  void addWatch(ObsWatchCallback<T> fun) {
    if (_notify.watchFunList.contains(fun) == false) {
      _notify.watchFunList.add(fun);
    }
  }

  /// 移除监听函数
  void removeWatch(ObsWatchCallback<T> fun) {
    _notify.watchFunList.remove(fun);
  }

  /// 通知所有监听函数的执行
  void notify() {
    notifyObsBuilder();
    notifyWatch();
    notifyIsolateWatch();
    notifyListeners();
  }

  /// 通知所有 [ObsBuilder] 刷新
  notifyObsBuilder() {
    for (var fun in _notify.builderFunList) {
      fun();
    }
  }

  /// 通知所有 watch 监听函数执行
  notifyWatch() {
    for (var fun in _notify.watchFunList) {
      fun(super.value, this.oldValue);
    }
  }

  /// 通知隔离的 watch 监听函数执行
  notifyIsolateWatch() {
    if (_notify.isolateWatchFun != null) {
      _notify.isolateWatchFun!(super.value, this.oldValue);
    }
  }

  /// 暴露 [ChangeNotifier] 中的通知方法
  @override
  notifyListeners() {
    super.notifyListeners();
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

/// 临时 ObsBuilder 小部件重建函数
VoidCallback? _updateBuilderFun;

/// ObsBuilder 内部允许存在多个 Obs 变量，此集合就是在 build 过程中收集多个 Obs 实例
Set<_Notify> _notifyList = {};

/// Obs、ObsBuilder 二者之间的枢纽
class _Notify<T> {
  /// ObsBuilder 更新函数集合
  final List<VoidCallback> builderFunList = [];

  /// 用户手动添加的监听函数集合
  final List<ObsWatchCallback<T>> watchFunList = [];

  /// 隔离的监听函数
  final ObsWatchCallback<T>? isolateWatchFun;

  _Notify(this.isolateWatchFun);
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
