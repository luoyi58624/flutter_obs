part of 'obs.dart';

class AnimateObs<T> extends Obs<T> {
  AnimateObs(
    super.value, {
    required this.vsync,
    this.duration = Duration.zero,
    this.curve = Curves.linear,
  }) : super(notifyMode: const [ObsNotifyMode.watchList]) {
    addWatch(_watchAnimateFun);
    controller = AnimationController(vsync: vsync, duration: duration)
      ..addListener(() {
        notifyObsBuilder();
      });
    tween = Tween(begin: oldValue, end: _value);
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

  @override
  T get value {
    _bindObsBuilder();
    return animation.value;
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
