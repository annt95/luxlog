import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:supabase_flutter/supabase_flutter.dart' as supa show AuthException;
import 'package:luxlog/features/auth/presentation/signup_screen.dart';
import 'package:luxlog/features/auth/providers/auth_provider.dart';
import 'package:luxlog/features/auth/data/repositories/auth_repository.dart';
import 'package:luxlog/features/auth/data/datasources/auth_remote_datasource.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockUser extends Mock implements User {}

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(null);
    when(() => mockAuth.onAuthStateChange).thenAnswer(
      (_) => const Stream<AuthState>.empty(),
    );
  });

  Widget buildApp() {
    return ProviderScope(
      child: MaterialApp(
        home: const SignupScreen(),
      ),
    );
  }

  group('SignupScreen', () {
    testWidgets('renders all form fields', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Join Luxlog'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Display Name'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Confirm Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
    });

    testWidgets('shows error for empty display name', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Leave all fields empty and tap Sign Up
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      expect(find.text('Vui lòng nhập tên hiển thị'), findsOneWidget);
    });

    testWidgets('shows error for invalid email format', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Display Name'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'not-an-email',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      expect(find.text('Định dạng email không hợp lệ'), findsOneWidget);
    });

    testWidgets('shows error for short password', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Display Name'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'short',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      expect(find.text('Mật khẩu phải có ít nhất 8 ký tự'), findsOneWidget);
    });

    testWidgets('shows error for password without uppercase', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Display Name'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'alllowercase1',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      expect(
        find.text('Mật khẩu phải chứa ít nhất một chữ hoa'),
        findsOneWidget,
      );
    });

    testWidgets('shows error for password without digit', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Display Name'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'NoDigitsHere',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      expect(
        find.text('Mật khẩu phải chứa ít nhất một chữ số'),
        findsOneWidget,
      );
    });

    testWidgets('shows error for password mismatch', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Display Name'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'Valid1234',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Confirm Password'),
        'Different1234',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      expect(find.text('Mật khẩu xác nhận không khớp'), findsOneWidget);
    });

    testWidgets('has Sign In link', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Already have an account? '), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });
  });
}
