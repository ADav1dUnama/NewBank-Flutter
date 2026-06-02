import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newbank/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreen()),
    );

    // Verifica elementos essenciais da tela de login
    expect(find.text('NewBank'), findsOneWidget);
    expect(find.text('Acesse sua conta'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Entrar'), findsOneWidget);
  });
}
