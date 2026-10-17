import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakina_mobile/app/app.dart';

void main() {
  testWidgets('the app boots and shows the Sakina wordmark', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SakinaApp()));
    await tester.pumpAndSettle();

    expect(find.text('Sakina'), findsOneWidget);
  });
}
