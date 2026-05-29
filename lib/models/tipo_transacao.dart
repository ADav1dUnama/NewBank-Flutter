import 'package:flutter/material.dart';

enum TipoTransacao {
  transferencia,
  deposito,
  saque;

  String toDb() => name;

  static TipoTransacao fromDb(String value) {
    return TipoTransacao.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Tipo de transação inválido: $value'),
    );
  }

  /// Human-readable label for UI display.
  String get label {
    switch (this) {
      case TipoTransacao.transferencia:
        return 'Transferência';
      case TipoTransacao.deposito:
        return 'Depósito';
      case TipoTransacao.saque:
        return 'Saque';
    }
  }

  /// Icon for UI display.
  IconData get icone {
    switch (this) {
      case TipoTransacao.transferencia:
        return Icons.swap_horiz_rounded;
      case TipoTransacao.deposito:
        return Icons.arrow_downward_rounded;
      case TipoTransacao.saque:
        return Icons.arrow_upward_rounded;
    }
  }
}
