import 'package:flutter_test/flutter_test.dart';
import 'package:lifeloops/create_page.dart';
import 'package:lifeloops/main.dart';

void main() {
  testWidgets('LifeLoop opens the Create page', (tester) async {
    await tester.pumpWidget(const LifeLoopApp());

    expect(find.byType(CreatePage), findsOneWidget);
  });
}