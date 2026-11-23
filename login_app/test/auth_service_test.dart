import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:login_app/app/data/models/user_model.dart';
import 'package:login_app/app/data/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  FlutterSecureStorage.setMockInitialValues({});

  final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();

  final user = UserModel(
    name: 'Test User',
    username: 'test_$uniqueId',
    email: 'test_$uniqueId@example.com',
    phone: '9${uniqueId.substring(uniqueId.length - 9)}',
  );

  test(
    'Login requires credentials, phone number and OTP verification',
    () async {
      final client = MockClient((request) async {
        final requestBody = request.body.isEmpty
            ? <String, dynamic>{}
            : jsonDecode(request.body) as Map<String, dynamic>;
        final responseUser = user.toJson()..['id'] = 1;

        if (request.url.path.endsWith('/auth/register')) {
          return http.Response(jsonEncode({'user': responseUser}), 201);
        }

        if (request.url.path.endsWith('/auth/login')) {
          if (requestBody['password'] != 'Password123' ||
              requestBody['phone'] != user.phone) {
            return http.Response(
              jsonEncode({'message': 'Invalid credentials'}),
              401,
            );
          }

          return http.Response(jsonEncode({'message': 'OTP generated'}), 200);
        }

        if (request.url.path.endsWith('/otp/verify')) {
          return http.Response(
            jsonEncode({'token': 'test-token', 'user': responseUser}),
            200,
          );
        }

        if (request.method == 'DELETE' &&
            request.url.path.endsWith('/users/profile')) {
          expect(request.headers['authorization'], 'Bearer test-token');
          return http.Response(jsonEncode({'message': 'Account deleted'}), 200);
        }

        return http.Response(
          jsonEncode({'message': 'Unexpected request'}),
          404,
        );
      });
      final service = AuthService(client: client);

      final registeredUser = await service.register(
        name: user.name,
        username: user.username,
        email: user.email,
        phone: user.phone,
        password: 'Password123',
      );

      expect(registeredUser.username, user.username);

      expect(
        await service.requestLoginOtp(
          username: user.username,
          password: 'Password123',
          phone: user.phone,
        ),
        isTrue,
      );

      final loggedInUser = await service.verifyOtp(
        phone: user.phone,
        otp: '123456',
      );

      expect(loggedInUser.username, user.username);
      expect(loggedInUser.email, user.email);

      await expectLater(
        service.requestLoginOtp(
          username: user.username,
          password: 'wrong-password',
          phone: user.phone,
        ),
        throwsException,
      );

      expect(await service.deleteAccount(), isTrue);
      client.close();
    },
  );
}
