```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_obs/flutter_obs.dart';

Obs<T> useObs<T>(T initialData, {
  bool auto = true,
  ObsWatchCallback<T>? watch,
  bool immediate = false,
}) {
  return use(_ObsHook(
    initialData: initialData,
    auto: auto,
    watch: watch,
    immediate: immediate,
  ));
}

class _ObsHook<T> extends Hook<Obs<T>> {
  const _ObsHook({
    required this.initialData,
    required this.auto,
    this.watch,
    required this.immediate,
  });

  final T initialData;
  final bool auto;
  final ObsWatchCallback<T>? watch;
  final bool immediate;

  @override
  _ObsHookState<T> createState() => _ObsHookState();
}

class _ObsHookState<T> extends HookState<Obs<T>, _ObsHook<T>> {
  late final _state = Obs<T>(
    hook.initialData,
    auto: hook.auto,
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
