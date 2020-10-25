import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../lib/oauth_dio.dart';

class MockDio extends Mock implements Dio {}

void main() {
  MockDio mockDio;
  OAuth oauth;

  const tokenRequestUrl = "http://www.example.com";
  final initialOAuthToken = OAuthToken(accessToken: "some_access_token", refreshToken: "some_refresh_token");

  void mockNextToken(OAuthToken token) {
    when(mockDio.request(tokenRequestUrl, data: anyNamed("data"), options: anyNamed("options")))
    .thenAnswer((_) => 
      Future.value(Response(data: {"access_token": token.accessToken, "refresh_token": token.refreshToken}))
    );
  }  

  Future<OAuthToken> requestInitialToken() {
    mockNextToken(initialOAuthToken);
    return oauth.requestToken(PasswordGrant(username: 'foo', password: 'bar'));
  }

  setUp(() {
    mockDio = MockDio();
    oauth = OAuth(tokenUrl: tokenRequestUrl, dio: mockDio);
  });

  test('Request AccessToken using password grantType', () async {
    OAuthToken token = await requestInitialToken();

    expect(token.accessToken, equals(initialOAuthToken.accessToken));
    expect(token.refreshToken, equals(initialOAuthToken.refreshToken));
  });

  test('Refresh AccessToken using refresh_token grantType', () async {
    await requestInitialToken();

    OAuthToken refreshedToken = OAuthToken(accessToken: "some_other_access_token", refreshToken: "some_other_refresh_token");
    mockNextToken(refreshedToken);

    final newToken = await oauth.refreshAccessToken();
    expect(newToken.accessToken, refreshedToken.accessToken);
    expect(newToken.refreshToken, refreshedToken.refreshToken);
  });

  test('Clear tokens from storage', () async {
    await requestInitialToken();

    expect(await oauth.storage.fetch(), isNot(equals(null)));
    await oauth.storage.clear();
    expect(await oauth.storage.fetch(), equals(null));
  });
}
