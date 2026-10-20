import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cricket_app_flutter/core/network/api_service.dart';
import 'package:cricket_app_flutter/main.dart';
import 'package:cricket_app_flutter/services/auth_service.dart';

const _loginSuccessBody = {
  'statusCode': 200,
  'message': '',
  'isArray': false,
  'result': {
    'tokenType': 'Bearer',
    'accessToken': 'access-token',
    'expiresIn': 900,
    'refreshTokenExpiresAt': '2026-11-01T11:08:44.782Z',
    'user': {
      'id': '5f843dab61680ab79f8a336be89d2d3d',
      'email': 'roshan@gmail.com',
      'userName': 'roshan',
      'phone': '1234567890',
      'profileImage': null,
      'battingStyle': 'right',
      'bowlingStyle': 'right_arm_fast',
      'playerRole': 'all_rounder',
      'bio': 'roshan dasss',
      'createdAt': '2026-07-05T17:43:20.000Z',
      'updatedAt': '2026-07-05T17:43:20.000Z',
      'deletedAt': null,
    },
    'refreshToken': 'refresh-token',
  },
};

AuthService _authWith(MockClientHandler handler) =>
    AuthService(api: ApiService(client: MockClient(handler)));

Future<void> _fillAndSubmit(WidgetTester tester) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Email'),
    'roshan@gmail.com',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Password'),
    'secret123',
  );
  final signIn = find.widgetWithText(FilledButton, 'Sign in');
  await tester.ensureVisible(signIn);
  await tester.pumpAndSettle();
  await tester.tap(signIn);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Login screen shows form fields and actions', (tester) async {
    await tester.pumpWidget(
      CricketApp(authService: _authWith((_) async => http.Response('', 500))),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
    expect(find.text('Create new account'), findsOneWidget);
  });

  testWidgets('Successful login sends mobile header and opens home', (
    tester,
  ) async {
    late http.Request sent;
    final auth = _authWith((request) async {
      sent = request;
      return http.Response(jsonEncode(_loginSuccessBody), 200);
    });

    await tester.pumpWidget(CricketApp(authService: auth));
    await _fillAndSubmit(tester);

    expect(sent.method, 'POST');
    expect(sent.url.path, '/api/auth/login');
    expect(sent.headers['x-client-type'], 'mobile');
    expect(jsonDecode(sent.body), {
      'email': 'roshan@gmail.com',
      'password': 'secret123',
    });
    expect(auth.session?.accessToken, 'access-token');
    expect(find.text('Hi, roshan'), findsOneWidget);
  });

  testWidgets('Failed login shows the server error message', (tester) async {
    final auth = _authWith(
      (_) async => http.Response(
        jsonEncode({'statusCode': 401, 'message': 'Invalid credentials'}),
        401,
      ),
    );

    await tester.pumpWidget(CricketApp(authService: auth));
    await _fillAndSubmit(tester);

    expect(find.text('Invalid credentials'), findsOneWidget);
    expect(auth.session, isNull);
  });

  group('Forgot password', () {
    http.Response ok(String message) => http.Response(
      jsonEncode({'statusCode': 200, 'message': message, 'result': null}),
      200,
    );

    Future<void> tapButton(WidgetTester tester, String label) async {
      final button = find.widgetWithText(FilledButton, label);
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    testWidgets('email -> otp -> new password resets and returns to login', (
      tester,
    ) async {
      final requests = <http.Request>[];
      final auth = _authWith((request) async {
        requests.add(request);
        return ok(
          request.url.path.endsWith('reset-password') ? 'Password reset' : '',
        );
      });

      await tester.pumpWidget(CricketApp(authService: auth));
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'leo@gmail.com',
      );
      await tapButton(tester, 'Send code');
      expect(find.text('Check your email'), findsOneWidget);

      // Entering all 6 digits submits automatically.
      await tester.enterText(find.byType(TextFormField), '936686');
      await tester.pumpAndSettle();
      expect(find.text('Set a new password'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'New password'),
        'abc123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm password'),
        'abc124',
      );
      await tapButton(tester, 'Reset password');
      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(requests, hasLength(2));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm password'),
        'abc123',
      );
      await tapButton(tester, 'Reset password');

      expect(requests.map((r) => r.url.path), [
        '/api/user/forgot-password',
        '/api/user/verify-otp',
        '/api/user/reset-password',
      ]);
      expect(jsonDecode(requests[0].body), {'email': 'leo@gmail.com'});
      expect(jsonDecode(requests[1].body), {
        'email': 'leo@gmail.com',
        'otp': '936686',
      });
      expect(jsonDecode(requests[2].body), {
        'email': 'leo@gmail.com',
        'otp': '936686',
        'newPassword': 'abc123',
      });
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Password reset'), findsOneWidget);
    });

    testWidgets('Page Down in the empty code field does not throw', (
      tester,
    ) async {
      await tester.pumpWidget(
        CricketApp(authService: _authWith((_) async => ok(''))),
      );
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'leo@gmail.com',
      );
      await tapButton(tester, 'Send code');

      // Numpad 3 with Num Lock off arrives as Page Down.
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Check your email'), findsOneWidget);
    });

    testWidgets('wrong otp shows the server error and stays put', (
      tester,
    ) async {
      final auth = _authWith((request) async {
        if (request.url.path.endsWith('verify-otp')) {
          return http.Response(
            jsonEncode({'statusCode': 400, 'message': 'Invalid OTP'}),
            400,
          );
        }
        return ok('');
      });

      await tester.pumpWidget(CricketApp(authService: auth));
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'leo@gmail.com',
      );
      await tapButton(tester, 'Send code');
      await tester.enterText(find.byType(TextFormField), '111111');
      await tester.pumpAndSettle();

      expect(find.text('Invalid OTP'), findsOneWidget);
      expect(find.text('Check your email'), findsOneWidget);
      expect(find.textContaining('Resend in'), findsOneWidget);
    });
  });

  testWidgets('Register validates fields then creates the account', (
    tester,
  ) async {
    late http.Request sent;
    final auth = _authWith((request) async {
      sent = request;
      return http.Response(
        jsonEncode({'statusCode': 201, 'message': 'User created'}),
        201,
      );
    });

    await tester.pumpWidget(CricketApp(authService: auth));
    await tester.ensureVisible(find.text('Create new account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create new account'));
    await tester.pumpAndSettle();

    Future<void> tapCreate() async {
      final create = find.widgetWithText(FilledButton, 'Create account');
      await tester.ensureVisible(create);
      await tester.pumpAndSettle();
      await tester.tap(create);
      await tester.pumpAndSettle();
    }

    await tapCreate();
    expect(find.text('Enter your name'), findsOneWidget);
    expect(find.text('Enter a password'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Leo');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'leo@gmail.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone'),
      '9876543210',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      '123456',
    );
    await tapCreate();
    expect(find.text('Password needs at least one letter'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'abc123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm password'),
      'abc123',
    );
    await tapCreate();

    expect(sent.url.path, '/api/user/create');
    expect(jsonDecode(sent.body), {
      'userName': 'Leo',
      'email': 'leo@gmail.com',
      'phone': '9876543210',
      'password': 'abc123',
    });
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('User created'), findsOneWidget);
    expect(find.text('leo@gmail.com'), findsOneWidget);
  });
}
