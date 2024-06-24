import 'package:flutter/material.dart';
import 'package:flutter_obs/flutter_obs.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final listData = Obs<List<String>>(
      List.generate(10, (index) => '列表 - ${index + 1}'),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('响应式列表示例'),
        actions: [
          IconButton(
            onPressed: () {
              listData.value = [
                ...listData.value,
                '列表 - ${listData.value.length + 1}'
              ];
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ObsBuilder(
        builder: (context) {
          return ListView.builder(
            itemCount: listData.value.length,
            itemBuilder: (context, index) => ListTile(
              onTap: () {
                listData.value[index] = '点击了';
                listData.notify();
              },
              title: Text(listData.value[index]),
            ),
          );
        },
      ),
    );
  }
}
