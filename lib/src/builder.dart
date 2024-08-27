part of 'obs.dart';

class ObsBuilder extends StatefulWidget {
  /// 响应式变量构建器，监听内部的响应式变量，当变量发生变更时，将重建小部件
  const ObsBuilder({
    super.key,
    required this.builder,
    this.watch = const [],
  });

  /// 必须通过函数构建小部件，否则无法延迟拦截读取内部的响应式变量
  final WidgetBuilder builder;

  /// 设置监听的响应式变量，监听的任意一个变量发生更改都会刷新此小部件，使用场景：
  /// * ObsBuilder 依赖响应式变量触发变更，但 [builder] 函数中却不使用它
  /// * ObsBuilder 内部的响应式变量被各种 [Builder] 又进行了一次转发，导致收集不到
  final List<Obs> watch;

  @override
  State<ObsBuilder> createState() => _ObsBuilderState();
}

class _ObsBuilderState extends State<ObsBuilder> {
  /// 保存绑定的响应式变量集合，[Obs] 和 [ObsBuilder] 是多对多关系，
  /// [Obs] 保存的是多个 [ObsBuilder] 的刷新方法，而 [ObsBuilder] 可以引用多个 [Obs] 变量，
  /// 当组件被销毁时，需要通知所有引用此 [ObsBuilder] 的响应式变量移除它的刷新方法。
  final Set<_Notify> _obsNotifyList = {};

  /// 是否更新了 watch 依赖
  bool isUpdateWatch = false;

  /// 当更新了 watch 依赖，需要进行添加或移除绑定的响应式变量
  @override
  void didUpdateWidget(covariant ObsBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.watch != oldWidget.watch) {
      isUpdateWatch = true;
      if (oldWidget.watch.isEmpty) {
        _addWatch(widget.watch);
      } else if (widget.watch.isEmpty) {
        _removeWatch(oldWidget.watch);
      } else {
        final List<Obs> hasObsList = [];
        final List<Obs> addObsList = [];
        final List<Obs> removeObsList = [];
        for (var value in widget.watch) {
          if (oldWidget.watch.contains(value)) {
            hasObsList.add(value);
          } else {
            addObsList.add(value);
          }
        }
        for (var value in oldWidget.watch) {
          if (!hasObsList.contains(value)) {
            removeObsList.add(value);
          }
        }
        _addWatch(addObsList);
        _removeWatch(removeObsList);
      }
    }
  }

  /// 小部件被销毁时移除副作用
  @override
  void dispose() {
    for (var obs in _obsNotifyList) {
      obs.builderFunList.remove(_notify);
    }
    _obsNotifyList.clear();
    super.dispose();
  }

  void _addWatch(List<Obs> watch) {
    for (final item in watch) {
      if (!item._notify.builderFunList.contains(_notify)) {
        item._notify.builderFunList.add(_notify);
        _obsNotifyList.add(item._notify);
      }
    }
  }

  void _removeWatch(List<Obs> watch) {
    for (final item in watch) {
      item._notify.builderFunList.remove(_notify);
      _obsNotifyList.remove(item._notify);
    }
  }

  /// 响应式变量发生变更就是执行此函数通知页面刷新
  void _notify() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // 1.设置刷新页面函数到临时变量
    _updateBuilderFun = _notify;
    // 2.构建页面，触发响应式变量的 getter 方法，将 _notify 函数添加到监听器中
    var result = widget.builder(context);
    // 3.销毁临时变量
    _updateBuilderFun = null;
    // 4.在构建器中保存依赖的响应式变量集合
    _obsNotifyList.addAll(_notifyList);
    // 5.销毁依赖的响应式变量集合
    _notifyList.clear();
    // 6.如果设置了watch，则需要将监听的响应式变量添加到集合中
    if (widget.watch.isNotEmpty) {
      // 7.排除更新 watch 依赖，didUpdateWidget生命周期中已处理
      if (isUpdateWatch) {
        isUpdateWatch = false;
      }
      // 8.添加监听依赖，如果已添加会自动跳过
      else {
        _addWatch(widget.watch);
      }
    }
    return result;
  }
}
