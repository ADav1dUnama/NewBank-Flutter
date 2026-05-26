import 'package:newbank/database/app_database.dart';
import 'package:newbank/database/database_constants.dart';
import 'package:newbank/models/usuario.dart';
import 'package:newbank/services/password_service.dart';
import 'package:sqflite/sqflite.dart';

class UsuarioRepository {
  UsuarioRepository({
    AppDatabase? database,
    PasswordService? passwordService,
  })  : _database = database ?? AppDatabase.instance,
        _passwordService = passwordService ?? const PasswordService();

  final AppDatabase _database;
  final PasswordService _passwordService;

  Future<int> insert(Usuario usuario, {required String plainPassword}) async {
    final db = await _database.database;
    final data = usuario.toMap()
      ..remove('id')
      ..[DatabaseConstants.colSenha] = _passwordService.hash(plainPassword)
      ..[DatabaseConstants.colDataCriacao] =
          usuario.dataCriacao.toUtc().millisecondsSinceEpoch;

    try {
      return await db.insert(DatabaseConstants.tableUsuarios, data);
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw UsuarioDuplicateEmailException(usuario.email);
      }
      rethrow;
    }
  }

  Future<Usuario?> findById(int id) async {
    final db = await _database.database;
    final rows = await db.query(
      DatabaseConstants.tableUsuarios,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return Usuario.fromMap(rows.first);
  }

  Future<Usuario?> findByEmail(String email) async {
    final db = await _database.database;
    final rows = await db.query(
      DatabaseConstants.tableUsuarios,
      where: '${DatabaseConstants.colEmail} = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return Usuario.fromMap(rows.first);
  }

  Future<int> update(Usuario usuario) async {
    if (usuario.id == null) {
      throw ArgumentError('Usuario.id é obrigatório para atualização.');
    }

    final db = await _database.database;
    final data = usuario.toMap()
      ..remove('id')
      ..remove(DatabaseConstants.colSenha)
      ..remove(DatabaseConstants.colDataCriacao);

    return db.update(
      DatabaseConstants.tableUsuarios,
      data,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [usuario.id],
    );
  }

  Future<int> updatePassword(int id, String plainPassword) async {
    final db = await _database.database;
    return db.update(
      DatabaseConstants.tableUsuarios,
      {DatabaseConstants.colSenha: _passwordService.hash(plainPassword)},
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateSaldo(int id, double saldo) async {
    final db = await _database.database;
    return db.update(
      DatabaseConstants.tableUsuarios,
      {DatabaseConstants.colSaldo: saldo},
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _database.database;
    return db.delete(
      DatabaseConstants.tableUsuarios,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  bool verifyPassword(Usuario usuario, String plainPassword) {
    return _passwordService.verify(plainPassword, usuario.senha);
  }
}

class UsuarioDuplicateEmailException implements Exception {
  UsuarioDuplicateEmailException(this.email);

  final String email;

  @override
  String toString() => 'Email já cadastrado: $email';
}
