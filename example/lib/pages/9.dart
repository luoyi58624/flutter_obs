import 'package:flutter/material.dart';
import 'package:flutter_obs/flutter_obs.dart';

/// 定义局部控制器，对于局部跨页面的控制器最好定义为私有，防止其他页面滥用它，如果你的子路由文件是分开的，只需通过part链接即可，
/// 同时，因为是需要等待进入路由才初始化，所以我们需要将它定义为可为空。
_Controller? _controller;

class _Controller {
  final count = Obs(0);
}

class GetxStatePage extends StatefulWidget {
  const GetxStatePage({super.key});

  @override
  State<GetxStatePage> createState() => _GetxStatePageState();
}

class _GetxStatePageState extends State<GetxStatePage> {
  @override
  void initState() {
    super.initState();

    /// 初始化控制器
    _controller = _Controller();
  }

  @override
  void dispose() {
    super.dispose();

    /// 销毁控制器，你不需要考虑dispose，Obs变量实际上就跟普通变量一样
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('模拟Getx状态管理'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _controller!.count.value++,
              child: ObsBuilder(
                builder: (_) => Text('count: ${_controller!.count.value}'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ChildPage()),
                );
              },
              child: const Text('子页面'),
            ),
          ],
        ),
      ),
    );
  }
}

class ChildPage extends StatelessWidget {
  const ChildPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('子页面'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _controller!.count.value++,
              child: ObsBuilder(
                builder: (_) => Text('count: ${_controller!.count.value}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
