import 'src/base_obs_test.dart';
import 'src/simple_test.dart';
import 'src/memory_leak_test.dart';
import 'src/watch_test.dart';

void main() {
  baseObsTest(); // Obs 父类测试
  simpleTest(); // 简单状态测试
  memoryLeakTest(); // 内存泄漏测试
  watchTest(); // 监听测试
}
