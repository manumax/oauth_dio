import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/oauth_dio.dart';

void main() {
  test("Scope parameter should not be present in the request if no scopes were provided", () async {
    PasswordGrant passwordGrant = PasswordGrant(username: "username", password: "password");
    final requestOptions = RequestOptions();

    final request = passwordGrant.handle(requestOptions);
    expect(request.data, isNot(contains("scope")));
  });

  test("Scope parameter should be present in the request if scopes were provided", () async {
    PasswordGrant passwordGrant = PasswordGrant(username: "username", password: "password", scope: ['Scope 1', 'Scope 2']);
    final requestOptions = RequestOptions();
    
    final request = passwordGrant.handle(requestOptions);
    expect(request.data, contains("scope"));
  });
}