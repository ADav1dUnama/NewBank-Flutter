import 'package:newbank/database/app_database.dart';
import 'package:newbank/database/database_constants.dart';
import 'package:newbank/models/transacao.dart';
class TransacaoRepository {
  TransacaoRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> insert(Transacao transacao) async {
    final db = await _database.database;
    final userExists = await db.query(
      DatabaseConstants.tableUsuarios,
      columns: [DatabaseConstants.colId],
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [transacao.usuarioId],
      limit: 1,
    );
    if (userExists.isEmpty) {
      throw TransacaoUsuarioNotFoundException(transacao.usuarioId);
    }

    final data = transacao.toMap()..remove('id');
    return db.insert(DatabaseConstants.tableTransacoes, data);
  }

  Future<Transacao?> findById(int id) async {
    final db = await _database.database;
    final rows = await db.query(
      DatabaseConstants.tableTransacoes,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return Transacao.fromMap(rows.first);
  }

  Future<List<Transacao>> findByUsuarioId(int usuarioId) async {
    final db = await _database.database;
    final rows = await db.query(
      DatabaseConstants.tableTransacoes,
      where: '${DatabaseConstants.colUsuarioId} = ?',
      whereArgs: [usuarioId],
      orderBy: '${DatabaseConstants.colDataHora} DESC',
    );
    return rows.map(Transacao.fromMap).toList();
  }

  Future<int> delete(int id) async {
    final db = await _database.database;
    return db.delete(
      DatabaseConstants.tableTransacoes,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
  }
}

class TransacaoUsuarioNotFoundException implements Exception {
  TransacaoUsuarioNotFoundException(this.usuarioId);

  final int usuarioId;

  @override
  String toString() => 'Usuário não encontrado: $usuarioId';
}
