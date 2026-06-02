import 'package:newbank/database/app_database.dart';
import 'package:newbank/database/database_constants.dart';
import 'package:newbank/models/transacao.dart';
import 'package:newbank/models/tipo_transacao.dart';

class TransacaoRepository {
  TransacaoRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> insert(Transacao transacao) async {
    if (transacao.valor <= 0) {
      throw ArgumentError('O valor da transação deve ser maior que zero.');
    }

    if (transacao.tipo == TipoTransacao.transferencia) {
      if (transacao.destinatarioId == null) {
        throw ArgumentError(
          'Transferências exigem um destinatário (destinatarioId).',
        );
      }
      if (transacao.destinatarioId == transacao.usuarioId) {
        throw TransacaoAutoTransferenciaException();
      }
    }

    final db = await _database.database;

    return db.transaction((txn) async {
      // ── Validar remetente ──
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

      final int saldoAtual =
          (userRows.first[DatabaseConstants.colSaldo] as num).toInt();
      int novoSaldo = saldoAtual;

      if (transacao.tipo == TipoTransacao.deposito) {
        novoSaldo += transacao.valor;
      } else if (transacao.tipo == TipoTransacao.saque ||
          transacao.tipo == TipoTransacao.transferencia) {
        if (saldoAtual < transacao.valor) {
          throw SaldoInsuficienteException(
            saldoAtual: saldoAtual,
            valorSolicitado: transacao.valor,
          );
        }
        novoSaldo -= transacao.valor;
      }

      // ── Atualizar saldo do remetente ──
      await txn.update(
        DatabaseConstants.tableUsuarios,
        {DatabaseConstants.colSaldo: novoSaldo},
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [transacao.usuarioId],
      );

      // ── Creditar destinatário (transferências) ──
      if (transacao.tipo == TipoTransacao.transferencia) {
        final destRows = await txn.query(
          DatabaseConstants.tableUsuarios,
          columns: [DatabaseConstants.colId, DatabaseConstants.colSaldo],
          where: '${DatabaseConstants.colId} = ?',
          whereArgs: [transacao.destinatarioId],
          limit: 1,
        );

        if (destRows.isEmpty) {
          throw TransacaoDestinatarioNotFoundException(
            transacao.destinatarioId!,
          );
        }

        final int saldoDest =
            (destRows.first[DatabaseConstants.colSaldo] as num).toInt();

        await txn.update(
          DatabaseConstants.tableUsuarios,
          {DatabaseConstants.colSaldo: saldoDest + transacao.valor},
          where: '${DatabaseConstants.colId} = ?',
          whereArgs: [transacao.destinatarioId],
        );
      }

      // ── Inserir registro da transação ──
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
      where: '${DatabaseConstants.colUsuarioId} = ? OR ${DatabaseConstants.colDestinatarioId} = ?',
      whereArgs: [usuarioId, usuarioId],
      orderBy: '${DatabaseConstants.colDataHora} DESC',
    );
    return rows.map(Transacao.fromMap).toList();
  }

  /// Calcula o total de entradas (depósitos + transferências recebidas)
  /// e saídas (saques + transferências enviadas) de um usuário.
  Future<Map<String, int>> calcularResumo(int usuarioId) async {
    final db = await _database.database;

    // Entradas: depósitos feitos pelo usuário
    final depositoRows = await db.rawQuery(
      'SELECT COALESCE(SUM(${DatabaseConstants.colValor}), 0) as total '
      'FROM ${DatabaseConstants.tableTransacoes} '
      'WHERE ${DatabaseConstants.colUsuarioId} = ? '
      "AND ${DatabaseConstants.colTipo} = 'deposito'",
      [usuarioId],
    );
    final totalDepositos = (depositoRows.first['total'] as num).toInt();

    // Entradas: transferências recebidas (onde o usuário é destinatário)
    final recebidoRows = await db.rawQuery(
      'SELECT COALESCE(SUM(${DatabaseConstants.colValor}), 0) as total '
      'FROM ${DatabaseConstants.tableTransacoes} '
      'WHERE ${DatabaseConstants.colDestinatarioId} = ? '
      "AND ${DatabaseConstants.colTipo} = 'transferencia'",
      [usuarioId],
    );
    final totalRecebido = (recebidoRows.first['total'] as num).toInt();

    // Saídas: saques + transferências enviadas pelo usuário
    final saidaRows = await db.rawQuery(
      'SELECT COALESCE(SUM(${DatabaseConstants.colValor}), 0) as total '
      'FROM ${DatabaseConstants.tableTransacoes} '
      'WHERE ${DatabaseConstants.colUsuarioId} = ? '
      "AND ${DatabaseConstants.colTipo} IN ('saque', 'transferencia')",
      [usuarioId],
    );
    final totalSaidas = (saidaRows.first['total'] as num).toInt();

    return {
      'entradas': totalDepositos + totalRecebido,
      'saidas': totalSaidas,
    };
  }

  Future<int> delete(int id) async {
    final db = await _database.database;

    return db.transaction((txn) async {
      // 1. Buscar a transação antes de deletar
      final rows = await txn.query(
        DatabaseConstants.tableTransacoes,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return 0;

      final transacao = Transacao.fromMap(rows.first);

      // 2. Reverter saldo do remetente
      final userRows = await txn.query(
        DatabaseConstants.tableUsuarios,
        columns: [DatabaseConstants.colSaldo],
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [transacao.usuarioId],
        limit: 1,
      );

      if (userRows.isNotEmpty) {
        final int saldoAtual =
            (userRows.first[DatabaseConstants.colSaldo] as num).toInt();
        int novoSaldo = saldoAtual;

        if (transacao.tipo == TipoTransacao.deposito) {
          novoSaldo -= transacao.valor;
        } else if (transacao.tipo == TipoTransacao.saque ||
            transacao.tipo == TipoTransacao.transferencia) {
          novoSaldo += transacao.valor;
        }

        await txn.update(
          DatabaseConstants.tableUsuarios,
          {DatabaseConstants.colSaldo: novoSaldo},
          where: '${DatabaseConstants.colId} = ?',
          whereArgs: [transacao.usuarioId],
        );
      }

      // 3. Reverter saldo do destinatário (transferências)
      if (transacao.tipo == TipoTransacao.transferencia &&
          transacao.destinatarioId != null) {
        final destRows = await txn.query(
          DatabaseConstants.tableUsuarios,
          columns: [DatabaseConstants.colSaldo],
          where: '${DatabaseConstants.colId} = ?',
          whereArgs: [transacao.destinatarioId],
          limit: 1,
        );

        if (destRows.isNotEmpty) {
          final int saldoDest =
              (destRows.first[DatabaseConstants.colSaldo] as num).toInt();
          await txn.update(
            DatabaseConstants.tableUsuarios,
            {DatabaseConstants.colSaldo: saldoDest - transacao.valor},
            where: '${DatabaseConstants.colId} = ?',
            whereArgs: [transacao.destinatarioId],
          );
        }
      }

      // 4. Deletar a transação
      return await txn.delete(
        DatabaseConstants.tableTransacoes,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [id],
      );
    });
  }
}

class TransacaoUsuarioNotFoundException implements Exception {
  TransacaoUsuarioNotFoundException(this.usuarioId);

  final int usuarioId;

  @override
  String toString() => 'Usuário não encontrado: $usuarioId';
}

class TransacaoDestinatarioNotFoundException implements Exception {
  TransacaoDestinatarioNotFoundException(this.destinatarioId);

  final int destinatarioId;

  @override
  String toString() => 'Destinatário não encontrado: $destinatarioId';
}

class TransacaoAutoTransferenciaException implements Exception {
  @override
  String toString() => 'Não é possível transferir para si mesmo.';
}

class SaldoInsuficienteException implements Exception {
  SaldoInsuficienteException({
    required this.saldoAtual,
    required this.valorSolicitado,
  });

  final int saldoAtual;
  final int valorSolicitado;

  @override
  String toString() => 'Saldo insuficiente';
}
