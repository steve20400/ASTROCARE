import 'package:flutter_test/flutter_test.dart';
import 'package:astrocare/main.dart';
import 'package:astrocare/providers/astrocare_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('AstroCare app smoke test', (WidgetTester tester) async {
    final provider = AstroCareProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const AstroCareApp(),
      ),
    );
    expect(find.byType(AstroCareApp), findsOneWidget);
  });
}
