import 'package:flutter_test/flutter_test.dart';
import 'package:haventra_wedding_planner/main.dart';
import 'package:haventra_wedding_planner/ui/screens/auth/login_screen.dart';
import 'package:haventra_wedding_planner/ui/screens/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('App smoke test builds HaventraApp', (WidgetTester tester) async {
    await tester.pumpWidget(const HaventraApp());
    expect(find.byType(HaventraApp), findsOneWidget);
  });

  testWidgets('Splash redirects to login without showing onboarding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HaventraApp());
    await tester.pumpAndSettle(const Duration(milliseconds: 3500));

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
  });
}
