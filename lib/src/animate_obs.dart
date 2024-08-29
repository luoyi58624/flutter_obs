

import 'package:flutter/widgets.dart';

import 'base_obs.dart';

class AnimateObs<T> extends BaseObs<T> {
  AnimateObs(
    super.value, {
    required this.vsync,
    this.duration = Duration.zero,
    this.curve = Curves.linear,
  }) {
    controller = AnimationController(vsync: vsync, duration: duration)
      ..addListener(() {
        notifyBuilders();
      });
    tween = Tween(begin: getValue(), end: getValue());
    animation = tween.animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }

  late T _newValue;
  final TickerProvider vsync;
  final Duration duration;
  final Curve curve;
  late Tween<T> tween;
  late Animation<T> animation;
  late final AnimationController controller;

  T get animationValue => animation.value;

  @override
  set value(T v) {

  }

  void _watchAnimateFun(newValue, oldValue) {
    _newValue = newValue;
    tween = Tween(begin: value, end: newValue + (oldValue - value));
    animation = tween.animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
    controller.forward(from: 0);
  }

  /// 当移除小部件时必须执行 dispose 回收动画控制器
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
