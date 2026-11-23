import 'package:flutter_test/flutter_test.dart';
import 'package:life_loop/main.dart';

void main() {
  testWidgets('LifeLoopApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LifeLoopApp());

    // Verify that login screen is shown.
    expect(find.text('Welcome to LifeLoop'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });
}
