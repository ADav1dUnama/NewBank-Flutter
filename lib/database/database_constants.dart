/// SQLite table and column names for the NewBank local database.
abstract final class DatabaseConstants {
  static const int version = 2;
  static const String databaseName = 'newbank.db';

  static const String tableUsuarios = 'usuarios';
  static const String tableTransacoes = 'transacoes';

  // usuarios columns
  static const String colId = 'id';
  static const String colEmail = 'email';
  static const String colSenha = 'senha';
  static const String colNomeCompleto = 'nome_completo';
  static const String colSaldo = 'saldo';
  static const String colTipoConta = 'tipo_conta';
  static const String colDataCriacao = 'data_criacao';
  static const String colAgencia = 'agencia';
  static const String colNumeroConta = 'numero_conta';

  // transacoes columns
  static const String colUsuarioId = 'usuario_id';
  static const String colDestinatarioId = 'destinatario_id';
  static const String colTipo = 'tipo';
  static const String colValor = 'valor';
  static const String colDataHora = 'data_hora';
  static const String colDescricao = 'descricao';
}
