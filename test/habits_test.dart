import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/main.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late DateTime now;

  setUp(() {
    now = DateTime(2026, 11, 25, 23, 59);
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Habits(now: () => now)));
    await tester.pumpAndSettle();
  }

  Future<void> add(WidgetTester tester, String name) async {
    await tester.enterText(find.byType(TextField), name);
    await tester.tap(find.byTooltip('Add habit'));
    await tester.pumpAndSettle();
  }

  testWidgets('adds unique nonblank habits and toggles progress', (
    tester,
  ) async {
    await mount(tester);
    await add(tester, '  Read  ');
    await add(tester, 'Read');
    await add(tester, '   ');
    expect(find.text('Read'), findsOneWidget);
    expect(find.text('0 / 1 completed today'), findsOneWidget);
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    expect(find.text('1 / 1 completed today'), findsOneWidget);
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    expect(find.text('0 / 1 completed today'), findsOneWidget);
  });

  testWidgets('loads persisted completion and keeps deletion after remount', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'habits': '{"Read":"2026-11-25"}'});
    await mount(tester);
    expect(find.text('1 / 1 completed today'), findsOneWidget);
    await tester.tap(find.byTooltip('Delete habit'));
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('habits'), '{}');
    await tester.pumpWidget(const SizedBox.shrink());
    await mount(tester);
    expect(find.text('Read'), findsNothing);
    expect(find.text('0 / 0 completed today'), findsOneWidget);
  });

  testWidgets(
    'persists additions and resets completion on the next local date',
    (tester) async {
      await mount(tester);
      await add(tester, 'Read');
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await mount(tester);
      expect(find.text('1 / 1 completed today'), findsOneWidget);
      now = now.add(const Duration(minutes: 1));
      await tester.pump(const Duration(minutes: 1));
      expect(find.text('0 / 1 completed today'), findsOneWidget);
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        isFalse,
      );
    },
  );
}
