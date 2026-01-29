// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music4all/main.dart';

void main() {
  testWidgets('Music4All app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MusicApp()));

    // Verify the app builds without errors.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
