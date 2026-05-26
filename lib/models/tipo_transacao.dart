enum TipoTransacao {
  transferencia,
  consulta,
  deposito,
  saque;

  String toDb() => name;

  static TipoTransacao fromDb(String value) {
    return TipoTransacao.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Tipo de transação inválido: $value'),
    );
  }
}
