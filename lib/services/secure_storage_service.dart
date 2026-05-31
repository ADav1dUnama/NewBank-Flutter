import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  static final SecureStorageService _instance = SecureStorageService._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyUserId = 'last_logged_user_id';

  Future<void> saveLastLoggedUserId(int id) async {
    await _storage.write(key: _keyUserId, value: id.toString());
  }

  Future<int?> getLastLoggedUserId() async {
    final value = await _storage.read(key: _keyUserId);
    if (value != null) {
      return int.tryParse(value);
    }
    return null;
  }

  Future<void> clearLastLoggedUserId() async {
    await _storage.delete(key: _keyUserId);
  }
}
