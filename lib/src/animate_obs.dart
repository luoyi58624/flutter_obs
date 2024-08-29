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
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.linear,
    Tween<T>? tween,
  }) {
    this.controller = AnimationController(
      vsync: vsync,
      duration: duration,
    )..addListener(() {
        notifyBuilders();
      });

    if (tween == null) {
      assert(value is double,
          'AnimateObs value is not double type, Please set custom Tween');
      this.tween = Tween(begin: getValue(), end: getValue());
    } else {
      this.tween = tween;
      this.tween.begin = getValue();
      this.tween.end = getValue();
    }

    animation = this.tween.animate(
          CurvedAnimation(
            parent: this.controller,
            curve: curve,
          ),
        );
  }

  /// 动画控制器
  late final AnimationController controller;

  /// 动画持续时间
  Duration duration;

  /// 动画曲线
  Curve curve;

  /// 动画值区间
  late Tween<T> tween;

  /// 通过 animation.value 可以访问动画值，在 [ObsBuilder] 中使用可能需要手动添加 watch 监听，
  /// 因为只有 .value 才会自动绑定。
  late Animation<T> animation;

  /// 修改响应式变量值，如果想应用动画请使用 [setAnimateValue]
  @override
  set value(T value) {
    if (getValue() != value) {
      oldValue = getValue();
      setValue(value);
      controller.duration = Duration.zero;
      this.tween.begin = animation.value;
      this.tween.end = value;
      animation = this.tween.animate(
            CurvedAnimation(
              parent: controller,
              curve: this.curve,
            ),
          );
      controller.forward(from: 0);
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
      controller.duration = duration ?? this.duration;
      this.tween.begin = animation.value;
      this.tween.end = value;
      animation = this.tween.animate(
            CurvedAnimation(
              parent: controller,
              curve: curve ?? this.curve,
            ),
          );
      controller.forward(from: 0);
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
    controller.dispose();
    super.dispose();
  }
}
