/// Reusable form validation utilities for email and password fields.
class Validators {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _uppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp _digitRegex = RegExp(r'[0-9]');

  /// Matches any non-alphanumeric and non-whitespace character (standard punctuation and symbols)
  static final RegExp _specialCharRegex = RegExp(
    r'[!@#\$%^&*()_\-+=\[\]{}|;:",.<>?/~`\\|]|[^a-zA-Z0-9\s]',
  );

  /// Validates email address field.
  /// Returns null if valid, or an error message if invalid.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final trimmed = value.trim();
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates password field against security criteria:
  /// - At least 8 characters long
  /// - At least one uppercase letter
  /// - At least one digit (0-9)
  /// - At least one special character
  /// Returns null if all conditions are met, or the first failing condition's error.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!_uppercaseRegex.hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!_digitRegex.hasMatch(value)) {
      return 'Password must contain at least one digit';
    }
    if (!_specialCharRegex.hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }
}
