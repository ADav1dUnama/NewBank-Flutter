enum TipoConta {
  corrente,
  poupanca;

  String toDb() => name;

  static TipoConta fromDb(String value) {
    return TipoConta.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Tipo de conta inválido: $value'),
    );
  }
}
