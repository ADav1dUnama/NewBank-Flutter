/// Utility class for formatting currency values as Brazilian Real (BRL).
class CurrencyFormatter {
  const CurrencyFormatter._();

  /// Formats a [valor] as BRL currency string, e.g. `R$ 1.234,56`.
  static String format(double valor) {
    final isNegative = valor < 0;
    final abs = valor.abs();
    final parts = abs.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    // Add thousands separator
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(intPart[i]);
    }

    final formatted = 'R\$ $buffer,$decPart';
    return isNegative ? '- $formatted' : formatted;
  }

  /// Formats a [valor] with a leading sign for display in lists.
  /// Positive → `+ R$ 1.234,56`, Negative → `- R$ 1.234,56`.
  static String formatWithSign(double valor) {
    final abs = valor.abs();
    final formatted = format(abs);
    return valor >= 0 ? '+ $formatted' : '- $formatted';
  }
}
