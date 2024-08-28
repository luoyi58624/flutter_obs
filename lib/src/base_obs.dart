part of 'obs.dart';

/// 临时 ObsBuilder 小部件重建函数
VoidCallback? _builderNotifyFun;

/// ObsBuilder 内部允许存在多个 Obs 变量，此集合就是在 build 过程中收集多个 Obs 实例
Set<Set<VoidCallback>> _builderObsList = {};

abstract class _BaseObs<T> extends ValueNotifier<T> {
  _BaseObs(this._value) : super(_value) {
    this._initialValue = _value;
    this.oldValue = _value;
  }

  /// [_value] 初始值，当执行 [reset] 重置方法时应用它
  late T _initialValue;

  /// 记录上一次 [_value] 值
  late T oldValue;

  /// 刷新 ObsBuilder 函数集合
  final Set<VoidCallback> _builderFunList = {};

  T _value;

  /// 当小部件被 [ObsBuilder] 包裹时，它会追踪内部的响应式变量
  @override
  T get value {
    _bindObsBuilder();
    return _value;
  }

  /// 拦截 setter 方法，根据通知策略触发监听函数
  @override
  set value(T newValue) {
    if (_value != newValue) {
      oldValue = _value;
      _value = newValue;
      notify();
    }
  }

  /// 绑定刷新小部件
  void _bindObsBuilder() {
    if (_builderNotifyFun != null) {
      final fun = _builderNotifyFun!;
      if (!_builderFunList.contains(fun)) {
        _builderFunList.add(fun);
        _builderObsList.add(_builderFunList);
      }
    }
  }

  /// 通知所有监听函数的执行
  void notify() {
    notifyObsBuilder();
    notifyListeners();
  }

  /// 触发所有 [ObsBuilder] 小部件刷新
  notifyObsBuilder() {
    for (var fun in _builderFunList) {
      fun();
    }
  }

  /// 暴露 [ChangeNotifier] 中的通知方法
  @override
  notifyListeners() {
    super.notifyListeners();
  }

  @override
  void dispose() {
    _builderFunList.clear();
    super.dispose();
  }
}
