part of '../flutter_obs.dart';

/// 适配[flutter_hooks]库，相对于[StatelessWidget]，它可以在小部件重建时保存变量状态。
///
/// 提示：它与[useState]作用相同，唯一的区别在于[useState]会重建当前整个小部件，
/// 而[useObs]只重建[ObsBuilder]包裹的组件。
Obs<T> useObs<T>(T initialData) {
  return use(_ObsHook(initialData: initialData));
}

class _ObsHook<T> extends Hook<Obs<T>> {
  const _ObsHook({required this.initialData});

  final T initialData;

  @override
  _ObsHookState<T> createState() => _ObsHookState();
}

class _ObsHookState<T> extends HookState<Obs<T>, _ObsHook<T>> {
  late final _state = Obs<T>(hook.initialData);

  @override
  Obs<T> build(BuildContext context) => _state;

  @override
  Object? get debugValue => _state.value;

  @override
  String get debugLabel => 'useObs<$T>';
}
