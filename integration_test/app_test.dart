import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sistema_portoes_app/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Fluxo Completo: Login -> Abrir Portão', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({}); 

    app.main();
    await tester.pumpAndSettle();

    final emailField = find.widgetWithText(TextField, 'Email');
    final passField = find.widgetWithText(TextField, 'Senha');
    final btnEntrar = find.widgetWithText(ElevatedButton, 'ENTRAR');

    expect(emailField, findsOneWidget);
    expect(passField, findsOneWidget);

    await tester.enterText(emailField, 'marcos@teste.com');
    await tester.enterText(passField, '123456');
    await tester.pump();

    await tester.tap(btnEntrar);
    
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.text('Meus Portões'), findsOneWidget);
    
    final btnAcao = find.byType(ElevatedButton).last;
    
    await tester.tap(btnAcao);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}