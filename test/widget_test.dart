import 'package:flutter_test/flutter_test.dart';
import 'package:shirt_shop/main.dart';

void main() {
  testWidgets('แอปเปิดขึ้นมาแล้วเจอชื่อร้าน ShirtShop', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ShirtShopApp());
    expect(find.text('ShirtShop'), findsOneWidget);
  });
}
