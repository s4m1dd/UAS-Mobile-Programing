import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasir_app/main.dart';
import 'package:kasir_app/screens/login_screen.dart';

void main() {
  testWidgets('Shows login after splash when no session is saved', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const KasirApp());
    expect(find.text('Kelola Toko Anda dengan Mudah'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Masuk ke akun Anda'), findsOneWidget);
  });
}
