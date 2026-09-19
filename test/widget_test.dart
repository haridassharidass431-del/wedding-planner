import 'package:flutter_test/flutter_test.dart';
import 'package:haventra_wedding_planner/main.dart';

void main() {
  testWidgets('App smoke test builds HaventraApp', (WidgetTester tester) async {
    await tester.pumpWidget(const HaventraApp());
    expect(find.byType(HaventraApp), findsOneWidget);
  });
}
