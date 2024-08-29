import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'base_obs.dart';

class AnimateObs<T> extends BaseObs<T> {
  /// 支持对响应式变量进行线性插值，以实现动画效果
  /// * vsync 动画帧同步信号指示器，在状态类中混入[TickerProviderStateMixin]，然后传递 this 即可
  /// * duration 动画默认持续时间
  /// * curve 动画曲线
  /// * tween 动画值区间，如果 value 不是 double 类型，你必须手动设置 Tween，例如：ColorTween
  AnimateObs(
    super.value, {
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linear,
    Tween<T>? tween,
  }) {
    this._duration = duration;
    this._curve = curve;

    this._controller = AnimationController(
      vsync: vsync,
      duration: _duration,
    )..addListener(() {
        notifyBuilders();
      });

    if (tween == null) {
      assert(value is double,
          'AnimateObs value is not double type, Please set custom Tween');
      _tween = Tween(begin: getValue(), end: getValue());
    } else {
      _tween = tween;
      _tween.begin = getValue();
      _tween.end = getValue();
    }

    animation = _tween.animate(
      CurvedAnimation(
        parent: this._controller,
        curve: _curve,
      ),
    );
  }

  /// 动画控制器
  late final AnimationController _controller;

  /// 动画持续时间
  late Duration _duration;

  /// 动画曲线
  late final Curve _curve;

  /// 动画值区间
  late final Tween<T> _tween;

  /// 通过 animation.value 可以访问动画值，在 [ObsBuilder] 中使用可能需要手动添加 watch 监听，
  /// 因为只有 .value 才会自动绑定。
  late Animation<T> animation;

  /// 修改响应式变量值，如果想应用动画请使用 [setAnimateValue]
  @override
  set value(T value) {
    if (getValue() != value) {
      oldValue = getValue();
      setValue(value);
      _controller.duration = Duration.zero;
      _tween.begin = animation.value;
      _tween.end = value;
      animation = _tween.animate(
        CurvedAnimation(
          parent: _controller,
          curve: this._curve,
        ),
      );
      _controller.forward(from: 0);
    }
  }

  /// 以动画的形式设置新值
  /// * curve 自定义动画曲线
  /// * duration 自定义动画持续时间
  void setAnimateValue(
    T value, {
    Curve? curve,
    Duration? duration,
  }) {
    if (getValue() != value) {
      oldValue = getValue();
      setValue(value);
      _controller.duration = duration ?? this._duration;
      _tween.begin = animation.value;
      _tween.end = value;
      animation = _tween.animate(
        CurvedAnimation(
          parent: _controller,
          curve: curve ?? this._curve,
        ),
      );
      _controller.forward(from: 0);
    }
  }

  @protected
  @override
  void notify() {
    super.notify();
  }

  @protected
  @override
  void notifyBuilders() {
    super.notifyBuilders();
  }

  @protected
  @override
  void reset() {
    super.reset();
  }

  /// 当移除小部件时必须执行 dispose 回收动画控制器，执行 dispose 的时机必须在 super.dispose 之前
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
