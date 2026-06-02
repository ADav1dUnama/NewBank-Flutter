/// Reusable form validators for the NewBank app.
class Validators {
  const Validators._();

  static final _emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');

  /// Validates an email address field.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o email';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Email inválido';
    }
    return null;
  }

  /// Validates a password field (minimum 6 characters).
  static String? senha(String? value) {
    if (value == null || value.length < 6) {
      return 'A senha deve ter no mínimo 6 caracteres';
    }
    return null;
  }

  /// Validates a full name field (requires at least first and last name).
  static String? nomeCompleto(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe seu nome';
    }
    if (value.trim().split(RegExp(r'\s+')).length < 2) {
      return 'Informe nome e sobrenome';
    }
    return null;
  }
}
