part of '../flutter_obs.dart';

/// 临时变量 - [ObsBuilder]重建页面函数
VoidCallback? _notifyFun;

/// 临时变量 - 保存 [ObsBuilder] 依赖的响应式变量列表
Set<_NotifyWidget> _dependNotifyList = {};

/// 通知小部件刷新函数集合，它只包含一个集合，保存刷新 [ObsBuilder] 小部件方法，
/// 它是 [Obs]、[ObsBuilder] 之间的枢纽，二者都会相互保存之间的所有依赖。
class _NotifyWidget {
  final List<VoidCallback> notifyList = [];
}

/// 声明一个响应式变量，它会收集所有依赖此变量的 [ObsBuilder] 刷新方法，
/// 当你通过.value更新时会自动重建小部件，但操作 List、Map 等对象时，
/// 如果不传递完整的对象实例 setter 方法是无法拦截更新的，在这种情况下，
/// 你可以调用 [notify] 方法以手动形式通知小部件更新。
///
/// 它虽然继承[ValueNotifier]，但核心逻辑并不依赖它，继承它只是为了扩展性，
/// 你可以将 [Obs] 当作 [ValueNotifier] 的增强版，以下是三种使用示例：
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
  /// 创建一个响应式变量，你可以在任意位置声明它
  Obs(this._value) : super(_value) {
    this._initialValue = _value;
  }

  /// 保存更新 [ObsBuilder] 重建方法，[ChangeNotifier]保存的是用户自定义添加的监听器，
  /// 将其分开来是为了执行 [reset] 方法时不会影响到用户添加的监听器
  final _NotifyWidget _notifyWidget = _NotifyWidget();

  /// 保存 [_value] 的初始值，当执行 [reset] 重置方法时应用它
  late T _initialValue;

  /// 响应式对象
  T _value;

  /// 当小部件被 [ObsBuilder] 包裹时，它会追踪内部的响应式变量
  @override
  T get value {
    if (_notifyFun != null) {
      final fun = _notifyFun!;
      if (!_notifyWidget.notifyList.contains(fun)) {
        _notifyWidget.notifyList.add(fun);
        _dependNotifyList.add(_notifyWidget);
      }
    }
    return _value;
  }

  /// 拦截 setter 方法更新变量通知所有小部件更新
  @override
  set value(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      notify();
    }
  }

  /// 通知所有依赖此响应式变量的小部件进行刷新
  void notify() {
    notifyListeners();
    for (var fun in _notifyWidget.notifyList) {
      fun();
    }
  }

  /// 重置响应式变量状态，你可以在任意位置执行它，它和 [dispose] 不同，后者一旦执行该变量将不可再次使用，
  /// 所以重置后它会触发一次所有监听器，然后清空保存的所有刷新函数列表，由于刷新页面函数会等到下一帧执行，
  /// 所以清空后会再次和依赖它的小部件重新建立联系。
  void reset() {
    _value = _initialValue;
    notify();
    _notifyWidget.notifyList.clear();
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
    _notifyWidget.notifyList.clear();
  }
}
