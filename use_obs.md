```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_obs/flutter_obs.dart';

/// 适配[flutter_hooks]库，相对于在[StatelessWidget]中直接使用[Obs]，它可以在小部件重建时保存当前状态
Obs<T> useObs<T>(T initialData, {
  List<ObsNotifyMode> notifyMode = const [ObsNotifyMode.all],
  WatchCallback<T>? watch,
  bool immediate = false,
}) {
  return use(_ObsHook(
    initialData: initialData,
    notifyMode: notifyMode,
    watch: watch,
    immediate: immediate,
  ));
}

class _ObsHook<T> extends Hook<Obs<T>> {
  const _ObsHook({
    required this.initialData,
    required this.notifyMode,
    this.watch,
    required this.immediate,
  });

  final T initialData;
  final List<ObsNotifyMode> notifyMode;
  final WatchCallback<T>? watch;
  final bool immediate;

  @override
  _ObsHookState<T> createState() => _ObsHookState();
}

class _ObsHookState<T> extends HookState<Obs<T>, _ObsHook<T>> {
  late final _state = Obs<T>(
    hook.initialData,
    notifyMode: hook.notifyMode,
    watch: hook.watch,
    immediate: hook.immediate,
  );

  @override
  Obs<T> build(BuildContext context) => _state;

  @override
  void dispose() {
    super.dispose();
    _state.dispose();
  }

  @override
  Object? get debugValue => _state.value;

  @override
  String get debugLabel => 'useObs<$T>';
}

```
