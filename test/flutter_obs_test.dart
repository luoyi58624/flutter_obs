import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_obs/flutter_obs.dart';

void main() {
  testWidgets('simple state test', (tester) async {
    final count = Obs(0);

    await tester.pumpWidget(
      MaterialApp(
        home: GestureDetector(
          onTap: () {
            count.value++;
          },
          child: ObsBuilder(builder: (context) {
            return Text('count: ${count.value}');
          }),
        ),
      ),
    );

    await tester.tap(find.byType(GestureDetector));
    await tester.pump();
    expect(find.text('count: 1'), findsOneWidget);
  });
}
