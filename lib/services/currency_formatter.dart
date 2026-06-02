/// Utility class for formatting currency values as Brazilian Real (BRL).
/// Values are in centavos (e.g., 1050 = R$ 10,50).
class CurrencyFormatter {
  const CurrencyFormatter._();

  /// Formats [centavos] as BRL currency string, e.g. `R$ 1.234,56`.
  static String format(int centavos) {
    final isNegative = centavos < 0;
    final abs = centavos.abs();
    final reais = abs ~/ 100;
    final cents = (abs % 100).toString().padLeft(2, '0');

    // Add thousands separator
    final intPart = reais.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(intPart[i]);
    }

    final formatted = 'R\$ $buffer,$cents';
    return isNegative ? '- $formatted' : formatted;
  }

  /// Formats [centavos] with a leading sign for display in lists.
  /// Positive → `+ R$ 1.234,56`, Negative → `- R$ 1.234,56`.
  static String formatWithSign(int centavos) {
    final formatted = format(centavos.abs());
    return centavos >= 0 ? '+ $formatted' : '- $formatted';
  }
}
