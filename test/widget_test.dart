import 'package:flutter_test/flutter_test.dart';

import 'package:thapovana/app.dart';

void main() {
  testWidgets('renders Tapovana splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TapovanaApp());

    expect(find.text('Tapovana'), findsOneWidget);
    expect(find.text('A Sacred Pause Between Journeys'), findsOneWidget);
  });
}
