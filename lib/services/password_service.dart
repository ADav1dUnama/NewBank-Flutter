import 'package:bcrypt/bcrypt.dart';

class PasswordService {
  const PasswordService();

  String hash(String plainPassword) {
    return BCrypt.hashpw(plainPassword, BCrypt.gensalt());
  }

  bool verify(String plainPassword, String storedHash) {
    return BCrypt.checkpw(plainPassword, storedHash);
  }
}
