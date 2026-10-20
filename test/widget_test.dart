import 'dart:convert';

import 'package:flutter/material.dart';
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
}
