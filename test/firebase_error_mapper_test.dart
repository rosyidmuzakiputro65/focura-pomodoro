import 'package:flutter_application_1/core/errors/app_exception.dart';
import 'package:flutter_application_1/core/firebase/firebase_error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('kode error Firebase dipetakan ke AppError', () {
    expect(mapFirebaseErrorCode('email-already-in-use'), AppError.emailAlreadyRegistered);
    expect(mapFirebaseErrorCode('invalid-credential'), AppError.wrongCredentials);
    expect(mapFirebaseErrorCode('wrong-password'), AppError.wrongCredentials);
    expect(mapFirebaseErrorCode('too-many-requests'), AppError.tooManyAttempts);
    expect(mapFirebaseErrorCode('network-request-failed'), AppError.networkOffline);
    expect(mapFirebaseErrorCode('permission-denied'), AppError.permissionDenied);
    expect(mapFirebaseErrorCode('operation-not-allowed'), AppError.authProviderDisabled);
    expect(mapFirebaseErrorCode('sesuatu-yang-aneh'), AppError.unknown);
  });
}
