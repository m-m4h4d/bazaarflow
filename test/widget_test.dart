import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bazaarflow/core/providers/navigation_provider.dart';
import 'package:bazaarflow/core/theme/theme_provider.dart';
import 'package:bazaarflow/core/utils/validators.dart';
import 'package:bazaarflow/features/auth/providers/auth_provider.dart';
import 'package:bazaarflow/features/cart/providers/cart_provider.dart';
import 'package:bazaarflow/features/catalog/providers/product_provider.dart';
import 'package:bazaarflow/main.dart';

import 'helpers/fake_cart_store.dart';

Widget buildApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => ProductProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ChangeNotifierProvider(create: (_) => CartProvider(database: FakeCartStore())),
    ],
    child: const BazaarFlowApp(),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FormValidators', () {
    test('validateEmail', () {
      expect(FormValidators.validateEmail(null), isNotNull);
      expect(FormValidators.validateEmail(''), isNotNull);
      expect(FormValidators.validateEmail('not-an-email'), isNotNull);
      expect(FormValidators.validateEmail('jane.doe@example.com'), isNull);
    });

    test('validatePassword', () {
      expect(FormValidators.validatePassword(''), isNotNull);
      expect(FormValidators.validatePassword('Short1'), isNotNull);
      expect(FormValidators.validatePassword('alllowercase1'), isNotNull);
      expect(FormValidators.validatePassword('NoNumbersHere'), isNotNull);
      expect(FormValidators.validatePassword('Password123'), isNull);
    });

    test('validateRequired', () {
      expect(FormValidators.validateRequired('   ', 'Name'), 'Name is required.');
      expect(FormValidators.validateRequired('Jane', 'Name'), isNull);
    });
  });

  testWidgets('App starts on the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to BazaarFlow'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.text('Browse as Guest'), findsOneWidget);
  });

  testWidgets('Login shows validation errors for empty fields', (WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Email address is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
  });

  group('AuthGate', () {
    testWidgets('signed-in users skip the login screen', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'is_guest': false,
        'has_session': true,
        'user_name': 'Jane Doe',
        'user_email': 'jane@example.com',
      });
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Welcome to BazaarFlow'), findsNothing);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('users saved before sessions existed stay signed in', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'is_guest': false,
        'user_email': 'jane@example.com',
      });
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('a returning guest goes straight to the dashboard', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'is_guest': true, 'has_session': true});
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('logging in shows the dashboard', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'jane@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'Password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      // Login simulates a one-second network request
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('logging out returns to the login screen', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'is_guest': false,
        'has_session': true,
        'user_name': 'Jane Doe',
        'user_email': 'jane@example.com',
      });
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profile').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to BazaarFlow'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_session'), isFalse);
    });
  });
}
