import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // Should show login screen with app title
    expect(find.text('JLPT Mono'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });
}
