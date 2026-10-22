import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miaged/pages/login_page.dart';

void main() {
  Future<void> openLoginPage(WidgetTester tester) =>
      tester.pumpWidget(const MaterialApp(home: LoginPage()));

  testWidgets(
    'US#1 : titre, champs Login/Password et bouton « Se connecter »',
    (tester) async {
      await openLoginPage(tester);

      expect(find.widgetWithText(AppBar, 'MIAGED'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Login'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
    },
  );

  testWidgets('US#1 : le password est masqué', (tester) async {
    await openLoginPage(tester);

    final password = tester.widget<TextField>(
      find.widgetWithText(TextField, 'Password'),
    );
    expect(password.obscureText, isTrue);
  });

  testWidgets('US#1 : champs vides → message, on reste sur le login', (
    tester,
  ) async {
    await openLoginPage(tester);

    await tester.tap(find.text('Se connecter'));
    await tester.pump();

    expect(find.text('Login et password sont obligatoires'), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
  });
}
