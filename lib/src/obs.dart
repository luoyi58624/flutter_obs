part of '../flutter_obs.dart';

/// 临时变量 - [ObsBuilder]重建页面函数
VoidCallback? _notifyFun;

/// 临时变量 - 保存 [ObsBuilder] 依赖的响应式变量列表
Set<_NotidyWidget> _dependObsList = {};

/// 通知小部件刷新函数集合，它只包含一个集合，保存刷新 [ObsBuilder] 小部件方法，
/// 它是 [Obs]、[ObsBuilder] 之间的枢纽，二者都会相互保存之间的所有依赖。
class _NotidyWidget {
  final List<VoidCallback> notifys = [];
}

/// 声明一个响应式变量，它会收集所有依赖此变量的 [ObsBuilder] 刷新方法，
/// 当你通过.value更新时会自动重建小部件，但操作 List、Map 等对象时，
/// 如果不传递完整的对象实例 setter 方法是无法拦截更新的，在这种情况下，
/// 你可以调用 [notify] 方法以手动形式通知小部件更新。
///
/// 它虽然继承[ValueNotifier]，但核心逻辑并不依赖它，继承它只是为了增强扩展性，
/// 你可以将 [Obs] 当作 [ValueNotifier] 的增强版，[ValueNotifier]作为 Flutter 官方提供的响应式Api，
/// 其使用并不方便，[ValueListenableBuilder]需要编写大量的样板代码，对比示例：
///
/// ```dart
/// ObsBuilder(
///   builder: (context){
///     return Text(count.value);
///   },
/// ),
/// ```
/// ```dart
/// ListenableBuilder(
///   listenable: count,
///   builder: (context, child){
///     return Text(count.value);
///   },
/// ),
/// ```
/// ```dart
/// ValueListenableBuilder(
///   valueListenable: count,
///   builder: (context, value, child) {
///     return Text(value);
///   },
/// ),
/// ```
///
/// 实际上，官方提供的 Api 还有一个致命缺陷就是如果你依赖多个响应式变量，你必须去嵌套这些样板代码，
/// 而使用 [ObsBuilder] 则会自动搜集内部所有的响应式变量，令代码结构更加简洁。
class Obs<T> extends ValueNotifier<T> {
  /// 创建一个响应式变量，你可以在任意位置声明它
  Obs(this._value, {this.manual = false}) : super(_value) {
    this._initialValue = _value;
  }

  /// 是否手动刷新
  final bool manual;

  final _NotidyWidget _notifyWidget = _NotidyWidget();

  late T _initialValue;

  T _value;

  /// 当小部件被 [ObsBuilder] 包裹时，它会追踪内部的响应式变量
  @override
  T get value {
    if (_notifyFun != null) {
      final fun = _notifyFun!;
      if (!_notifyWidget.notifys.contains(fun)) {
        _notifyWidget.notifys.add(fun);
        _dependObsList.add(_notifyWidget);
      }
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

  /// 通知所有依赖此响应式变量的小部件进行刷新
  void notify() {
    for (var fun in _notifyWidget.notifys) {
      fun();
    }
    notifyListeners();
  }

  /// 重置响应式变量状态，它会触发一次所有监听器，和 [dispose] 不同，
  /// 后者会清空 [addListener] 添加的监听，而且此变量将不能再次使用。
  void reset() {
    _value = _initialValue;
    notify();
    notifyListeners();
    _notifyWidget.notifys.clear();
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
    super.dispose();
    _notifyWidget.notifys.clear();
  }
}
