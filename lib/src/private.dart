import 'package:flutter/foundation.dart';

import 'obs.dart';

/// 临时 ObsBuilder 小部件重建函数
VoidCallback? tempUpdateFun;

/// ObsBuilder 内部允许存在多个 Obs 变量，此集合就是在 build 过程中收集多个 Obs 实例
Set<NotifyInstance> tempNotifyList = {};

/// Obs、ObsBuilder 实例枢纽
class NotifyInstance<T> {
  /// ObsBuilder 更新函数集合
  final List<VoidCallback> obsUpdateList = [];

  /// 用户手动添加的监听函数集合
  final List<ObsWatchCallback<T>> watchFunList = [];
}
