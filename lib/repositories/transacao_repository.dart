import 'package:newbank/database/app_database.dart';
import 'package:newbank/database/database_constants.dart';
import 'package:newbank/models/transacao.dart';
import 'package:newbank/models/tipo_transacao.dart';

class TransacaoRepository {
  TransacaoRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> insert(Transacao transacao) async {
    if (transacao.valor <= 0 && transacao.tipo != TipoTransacao.consulta) {
      throw ArgumentError('O valor da transação deve ser maior que zero.');
    }

    final db = await _database.database;

    return db.transaction((txn) async {
      final userRows = await txn.query(
        DatabaseConstants.tableUsuarios,
        columns: [DatabaseConstants.colId, DatabaseConstants.colSaldo],
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [transacao.usuarioId],
        limit: 1,
      );

      if (userRows.isEmpty) {
        throw TransacaoUsuarioNotFoundException(transacao.usuarioId);
      }

      final double saldoAtual =
          (userRows.first[DatabaseConstants.colSaldo] as num).toDouble();
      double novoSaldo = saldoAtual;

      if (transacao.tipo == TipoTransacao.deposito) {
        novoSaldo += transacao.valor;
      } else if (transacao.tipo == TipoTransacao.saque ||
          transacao.tipo == TipoTransacao.transferencia) {
        if (saldoAtual < transacao.valor) {
          throw Exception('Saldo insuficiente');
        }
        novoSaldo -= transacao.valor;
      }

      if (transacao.tipo != TipoTransacao.consulta) {
        await txn.update(
          DatabaseConstants.tableUsuarios,
          {DatabaseConstants.colSaldo: novoSaldo},
          where: '${DatabaseConstants.colId} = ?',
          whereArgs: [transacao.usuarioId],
        );
      }

      final data = transacao.toMap()..remove('id');
      return await txn.insert(DatabaseConstants.tableTransacoes, data);
    });
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
