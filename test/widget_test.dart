import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:racing_car_game/main.dart';
import 'package:racing_car_game/models/car.dart';
import 'package:racing_car_game/screens/car_selection_screen.dart';
import 'package:racing_car_game/screens/game_screen.dart';

Future<void> pumpFrames(WidgetTester tester, {int count = 5}) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Car catalog has three selectable cars', () {
    expect(Car.all, hasLength(3));
    expect(Car.all.map((c) => c.id).toSet(), {
      'red_racer',
      'white_speeder',
      'blue_hyper',
    });
  });

  testWidgets('selection screen shows brand and start CTA', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const RacingCarApp());
    await pumpFrames(tester);

    expect(find.text('LANE RUSH'), findsOneWidget);
    expect(find.text('START RACE'), findsOneWidget);
    expect(find.text('Premium 32'), findsOneWidget);
  });

  testWidgets('starting race opens the game screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const RacingCarApp());
    await pumpFrames(tester);

    await tester.tap(find.text('START RACE'));
    await pumpFrames(tester, count: 10);

    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.text('SCORE'), findsOneWidget);
  });

  testWidgets('car selection screen can be constructed directly', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: CarSelectionScreen()),
    );
    await pumpFrames(tester);

    expect(find.byType(CarSelectionScreen), findsOneWidget);
  });
}
