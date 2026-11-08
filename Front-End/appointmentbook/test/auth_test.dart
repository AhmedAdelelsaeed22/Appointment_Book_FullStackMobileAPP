import 'package:appointmentbook/models/refresh_token_request.dart';
import 'package:appointmentbook/services/auth_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:appointmentbook/models/login_request.dart';
import 'package:appointmentbook/models/login_response.dart';
import 'package:appointmentbook/repositories/auth_repository.dart';

class MockApiService extends Mock implements AuthApiService {}

class FakeLoginRequest extends Fake implements LoginRequest {}

class FakeRefreshTokenRequest extends Fake implements RefreshTokenRequest {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeLoginRequest());
    registerFallbackValue(FakeRefreshTokenRequest());
  });

  late MockApiService mockApiService;
  late AuthRepository repository;

  setUp(() {
    mockApiService = MockApiService();
    repository = AuthRepository(apiService: mockApiService);
  });

  group('Auth Repository tests', () {
    test('should send the correct LoginRequest to ApiService', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'Password123!';

      when(() => mockApiService.login(any())).thenAnswer((_) async => null);

      // Act
      await repository.login(email: email, password: password);

      // Assert
      final capturedRequest =
          verify(() => mockApiService.login(captureAny())).captured.single
              as LoginRequest;

      expect(capturedRequest.email, email);
      expect(capturedRequest.password, password);
    });

    test('should return the response from ApiService', () async {
      // Arrange
      final expectedResponse = LoginResponse.fromJson({
        'accessToken': 'test-access-token',
        'refreshToken': 'test-refresh-token',
      });

      when(
        () => mockApiService.login(any()),
      ).thenAnswer((_) async => expectedResponse);

      // Act
      final result = await repository.login(
        email: 'test@example.com',
        password: 'Password123!',
      );

      // Assert
      expect(result, same(expectedResponse));

      verify(() => mockApiService.login(any())).called(1);
    });

    test('should propagate an exception from ApiService', () async {
      // Arrange
      when(
        () => mockApiService.login(any()),
      ).thenThrow(Exception('Login failed: 401'));

      // Act and Assert
      expect(
        () => repository.login(
          email: 'test@example.com',
          password: 'WrongPassword!',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test(
      "should send the correct refresh token requset to ApiService",
      () async {
        // Arrange
        const refreshToken = "refresh-token";
        const email = "test@example.com";

        when(
          () => mockApiService.refreshToken(any()),
        ).thenAnswer((_) async => null);

        // Act

        await repository.refreshToken(refreshToken: refreshToken, email: email);

        // Assert

        final captureRequest =
            verify(
                  () => mockApiService.refreshToken(captureAny()),
                ).captured.single
                as RefreshTokenRequest;

        expect(captureRequest.refreshToken, refreshToken);
        expect(captureRequest.email, email);
      },
    );

    test(
      "should return the response from api service for refresh token",
      () async {
        // Arrange
        final expectedResponse = LoginResponse.fromJson({
          'accessToken': 'test-access-token',
          'refreshToken': 'test-refresh-token',
        });

        when(
          () => mockApiService.refreshToken(any()),
        ).thenAnswer((_) async => expectedResponse);

        // Act

        final result = await repository.refreshToken(
          refreshToken: 'test-access-token',
          email: 'test@example.com',
        );

        // Assert

        expect(result, same(expectedResponse));
        verify(() => mockApiService.refreshToken(any())).called(1);
      },
    );
  });
}
