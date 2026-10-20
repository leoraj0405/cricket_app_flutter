/// Form field validators shared by the auth screens. Each returns an error
/// message, or null when the value is valid.
class Validators {
  Validators._();

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phonePattern = RegExp(r'^\+?[0-9]{7,15}$');
  static final _otpPattern = RegExp(r'^[0-9]{6}$');

  static const int otpLength = 6;

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email';
    if (!_emailPattern.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  static String? userName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter your name';
    if (name.length < 3) return 'Name must be at least 3 characters';
    if (name.length > 30) return 'Name must be at most 30 characters';
    return null;
  }

  static String? phone(String? value) {
    final phone = value?.replaceAll(RegExp(r'[\s-]'), '') ?? '';
    if (phone.isEmpty) return 'Enter your phone number';
    if (!_phonePattern.hasMatch(phone)) return 'Enter a valid phone number';
    return null;
  }

  static String? otp(String? value) {
    final otp = value?.trim() ?? '';
    if (otp.isEmpty) return 'Enter the code from your email';
    if (!_otpPattern.hasMatch(otp)) return 'The code must be $otpLength digits';
    return null;
  }

  /// Validates a password being chosen (register / reset), against
  /// [passwordRules].
  static String? newPassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Enter a password';
    for (final rule in passwordRules) {
      if (!rule.isMetBy(password)) return 'Password needs ${rule.label}';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }
}

class PasswordRule {
  const PasswordRule(this.label, this.isMetBy);

  /// Reads as "Password needs <label>".
  final String label;
  final bool Function(String password) isMetBy;
}

final List<PasswordRule> passwordRules = [
  PasswordRule('at least 6 characters', (p) => p.length >= 6),
  PasswordRule('at least one letter', (p) => p.contains(RegExp(r'[A-Za-z]'))),
  PasswordRule('at least one number', (p) => p.contains(RegExp(r'[0-9]'))),
  PasswordRule('no spaces', (p) => p.isNotEmpty && !p.contains(' ')),
];
