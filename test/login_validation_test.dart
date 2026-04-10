import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Email Validator', () {
    String? emailValidator(String? value) {
      if (value == null || value.isEmpty) {
        return 'Email is required';
      }
      if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}').hasMatch(value)) {
        return 'Please enter a valid email';
      }
      return null;
    }

    test('should pass when email is valid', () {
      expect(emailValidator('test@example.com'), isNull);
    });

    test('should return error when email is null', () {
      expect(emailValidator(null), 'Email is required');
    });

    test('should return error when email is empty', () {
      expect(emailValidator(''), 'Email is required');
    });

    test('should return error for whitespace-only email', () {
      expect(emailValidator('   '), 'Please enter a valid email');
    });

    test('should return error for missing @', () {
      expect(emailValidator('testexample.com'), 'Please enter a valid email');
    });

    test('should return error for missing domain', () {
      expect(emailValidator('test@'), 'Please enter a valid email');
    });

    test('should return error for very short input', () {
      expect(emailValidator('a@b.c'), 'Please enter a valid email');
    });

    test('should pass for very long valid email', () {
      final longEmail = 'a' * 50 + '@example.com';
      expect(emailValidator(longEmail), isNull);
    });
  });

  group('Password Validator', () {
    String? passwordValidator(String? value) {
      if (value == null || value.isEmpty) {
        return 'Password is required';
      }
      return null;
    }

    test('should pass when password is valid', () {
      expect(passwordValidator('password123'), isNull);
    });

    test('should return error when password is null', () {
      expect(passwordValidator(null), 'Password is required');
    });

    test('should return error when password is empty', () {
      expect(passwordValidator(''), 'Password is required');
    });

    test('should pass for very long password', () {
      final longPassword = 'a' * 100;
      expect(passwordValidator(longPassword), isNull);
    });

    test('should pass for whitespace-only password (since not trimmed)', () {
      expect(passwordValidator('   '), isNull);
    });
  });
}
