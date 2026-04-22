import 'package:flutter_application_1/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Splash page appears as startup screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
      ),
    );
    await tester.pump();

    expect(find.text('Smart Ad-Tech'), findsOneWidget);
    expect(find.text('Manajemen Aset & Pemasangan Reklame'), findsOneWidget);
  });
}
