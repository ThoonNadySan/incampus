import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incampus/features/auth/login_screen.dart';

void main() {
  testWidgets('shows error when password is empty', (WidgetTester tester) async {
    // Pump the LoginScreen widget
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen(enableAuth: false))),
    );

    // Enter email but leave password empty
    await tester.enterText(find.byKey(const Key('email_field')), 'test@test.com');

    // Tap the login button
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();

    // Verify error message appears
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('shows error for password with only spaces', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen(enableAuth: false))),
    );
    await tester.enterText(find.byKey(const Key('email_field')), 'test@test.com');
    await tester.enterText(find.byKey(const Key('password_field')), '     ');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('shows error for email with weird unicode characters', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen(enableAuth: false))),
    );
    await tester.enterText(find.byKey(const Key('email_field')), 'тест@例子.公司');
    await tester.enterText(find.byKey(const Key('password_field')), 'password123');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();
    expect(find.text('Please enter a valid email'), findsOneWidget);
  });

  testWidgets('shows error for extremely long password', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen(enableAuth: false))),
    );
    await tester.enterText(find.byKey(const Key('email_field')), 'test@test.com');
    await tester.enterText(find.byKey(const Key('password_field')), 'a' * 1000);
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();
    // Should not show error if only length is not restricted
    expect(find.text('Password is required'), findsNothing);
  });
}
