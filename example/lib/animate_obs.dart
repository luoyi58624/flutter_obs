import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_obs/flutter_obs.dart';

/// 适配[flutter_hooks]库，相对于在[StatelessWidget]中直接使用[Obs]，它可以在小部件重建时保存当前状态
AnimateObs<T> useAnimateObs<T>(
  T initialData, {
  Duration duration = const Duration(milliseconds: 250),
  Curve curve = Curves.linear,
  Tween<T>? tween,
}) {
  return use(_ObsHook(
    initialData,
    useSingleTickerProvider(),
    duration,
    curve,
    tween,
  ));
}

class _ObsHook<T> extends Hook<AnimateObs<T>> {
  const _ObsHook(
    this.initialData,
    this.vsync,
    this.duration,
    this.curve,
    this.tween, {
    super.keys,
  });

  final T initialData;
  final TickerProvider vsync;
  final Duration duration;
  final Curve curve;
  final Tween<T>? tween;

  @override
  _ObsHookState<T> createState() => _ObsHookState();
}

class _ObsHookState<T> extends HookState<AnimateObs<T>, _ObsHook<T>> {
  late final _state = AnimateObs<T>(
    hook.initialData,
    vsync: hook.vsync,
    duration: hook.duration,
    curve: hook.curve,
    tween: hook.tween,
  );

  @override
  void didUpdateHook(_ObsHook<T> oldHook) {
    super.didUpdateHook(oldHook);
    print('发生更新');
    if (hook.vsync != oldHook.vsync) {
      _state.controller.resync(hook.vsync);
    }
    if (hook.duration != oldHook.duration) {
      _state.duration = hook.duration;
    }
    if (hook.curve != oldHook.curve) {
      _state.curve = hook.curve;
    }
    if (hook.tween != oldHook.tween) {
      _state.tween = hook.tween;
    }
  }

  @override
  AnimateObs<T> build(BuildContext context) => _state;

  @override
  void dispose() {
    _state.dispose();
  }

  @override
  String get debugLabel => 'useAnimateObs<$T>';
}
