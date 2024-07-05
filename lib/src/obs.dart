part of '../flutter_obs.dart';

/// 当构建 [ObsBuilder] 时，执行 build 前会将重建函数设置到此临时变量，如果构建器中存在响应式变量，
/// 那么一定会触发 getter 函数，getter函数则将构建器的重建函数保存到监听器中，同时追加移除函数，
/// 当响应式变量更改时会执行内部所有的监听函数，从而实现响应式自动更新页面的逻辑。
VoidCallback? _notifyFun;

/// 每个 [ObsBuilder] 构建器可以依赖多个响应式变量，在执行 build 方法时，会触发多个响应式变量的 getter 方法，
/// 每个响应式变量添加监听函数的同时，都需要往此数组中追加移除函数，build方法执行完后 [ObsBuilder] 会将此变量保存到内部，
/// 并清空临时变量，当 [ObsBuilder] 卸载时，会执行数组中的所有移除函数，防止泄漏。
Set<VoidCallback> _removeNotifyFunList = {};

/// 声明一个响应式变量，它会收集所有依赖此变量的[ObsBuilder]，通过.value更新会自动重建小部件，
/// 你也可以手动调用 [notify] 方法通知小部件更新。
///
/// 它实现了 [ValueListenable] 接口，但并不继承[ChangeNotifier]，作为一个响应式变量，
/// 你不需要考虑 dispose 的问题，如果你将它用于 Widget 内部，它会跟随小部件一起被自动销毁，
/// 同时处理所有副作用，如果你将它用于全局变量，则可以手动调用 [reset] 函数重置它的状态，
/// 重置后你依旧可以正常并依赖使用响应式变量，这是和 [ChangeNotifier] 最大的不同点。
class Obs<T> implements ValueListenable {
  Obs(
    this._value, {
    this.manual = false,
  }) {
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
  @override
  T get value {
    if (_notifyFun != null) {
      final fun = _notifyFun!;
      if (!_notifyFunList.contains(fun)) {
        addListener(fun);
        _removeNotifyFunList.add(() => removeListener(fun));
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

  /// 重置响应式变量状态，它会先将状态重置，然后再触发全部页面状态更新，最后再清空所有监听器。
  ///
  /// 提示：第二步触发全部页面更新会等到下一帧再执行，在清理完所有的监听器后如果还存在其他[ObsBuilder]，
  /// 会再次重建它们并重新绑定响应式变量。
  ///
  /// 请注意一点，通过 [addListener] 手动添加副作用执行了 [reset] 后它们会失效，例如：
  /// * 当前页面你添加了副作用，进入下一页后你重置了响应式变量，返回上一页后你的副作用将不再生效
  /// * 使用 [ListenableBuilder] 之类的小部件构建，如果重置会导致它们无法再次更新
  ///
  /// 实际上，重置响应式变量最正确的做法是在所有相关联的页面都不再使用时才调用。
  void reset() {
    _value = _initialValue;
    notify();
    _notifyFunList.clear();
  }

  @override
  void addListener(VoidCallback listener) {
    _notifyFunList.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _notifyFunList.remove(listener);
  }
}
