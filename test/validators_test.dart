import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    group('Email Validation', () {
      test('Returns error when email is null or empty', () {
        expect(Validators.validateEmail(null), 'Email is required');
        expect(Validators.validateEmail(''), 'Email is required');
        expect(Validators.validateEmail('   '), 'Email is required');
      });

      test('Returns error when email format is invalid', () {
        expect(Validators.validateEmail('plainaddress'), 'Enter a valid email address');
        expect(Validators.validateEmail('missingatsign.com'), 'Enter a valid email address');
        expect(Validators.validateEmail('user@'), 'Enter a valid email address');
        expect(Validators.validateEmail('@domain.com'), 'Enter a valid email address');
        expect(Validators.validateEmail('user@domain'), 'Enter a valid email address');
      });

      test('Returns null when email format is valid', () {
        expect(Validators.validateEmail('shopper@example.com'), isNull);
        expect(Validators.validateEmail('john.doe@sub.company.org'), isNull);
        expect(Validators.validateEmail('test_user+tag@gmail.com'), isNull);
      });
    });

    group('Password Validation', () {
      test('Returns error when password is null or empty', () {
        expect(Validators.validatePassword(null), 'Password is required');
        expect(Validators.validatePassword(''), 'Password is required');
      });

      test('Returns error when password is less than 8 characters', () {
        expect(
          Validators.validatePassword('Abc!1'),
          'Password must be at least 8 characters long',
        );
        expect(
          Validators.validatePassword('Pass@1'),
          'Password must be at least 8 characters long',
        );
      });

      test('Returns error when password lacks an uppercase letter', () {
        expect(
          Validators.validatePassword('password@123'),
          'Password must contain at least one uppercase letter',
        );
        expect(
          Validators.validatePassword('alllower!#9'),
          'Password must contain at least one uppercase letter',
        );
      });

      test('Returns error when password lacks a digit', () {
        expect(
          Validators.validatePassword('Password@abc'),
          'Password must contain at least one digit',
        );
        expect(
          Validators.validatePassword('MyP#ssword'),
          'Password must contain at least one digit',
        );
      });

      test('Returns error when password lacks a special character', () {
        expect(
          Validators.validatePassword('Password123'),
          'Password must contain at least one special character',
        );
        expect(
          Validators.validatePassword('ALLUPPER1234'),
          'Password must contain at least one special character',
        );
      });

      test('Returns null when all password conditions are fulfilled', () {
        // At least 8 characters, at least one uppercase, at least one digit, at least one special character
        expect(Validators.validatePassword('Password@123'), isNull);
        expect(Validators.validatePassword('Secur!ty2026'), isNull);
        expect(Validators.validatePassword('MyP#ssword1'), isNull);
        expect(Validators.validatePassword('Welcome_99'), isNull);
        expect(Validators.validatePassword('Dart&Flutter1!'), isNull);
      });
    });
  });
}
