import 'package:flutter_test/flutter_test.dart';
import 'package:newbank/services/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('format formats centavos as BRL', () {
      expect(CurrencyFormatter.format(0), r'R$ 0,00');
      expect(CurrencyFormatter.format(1), r'R$ 0,01');
      expect(CurrencyFormatter.format(100), r'R$ 1,00');
      expect(CurrencyFormatter.format(1050), r'R$ 10,50');
      expect(CurrencyFormatter.format(123456), r'R$ 1.234,56');
      expect(CurrencyFormatter.format(10000000), r'R$ 100.000,00');
    });

    test('format handles negative values', () {
      expect(CurrencyFormatter.format(-1050), r'- R$ 10,50');
    });

    test('formatWithSign adds sign prefix', () {
      expect(CurrencyFormatter.formatWithSign(1050), r'+ R$ 10,50');
      expect(CurrencyFormatter.formatWithSign(-1050), r'- R$ 10,50');
      expect(CurrencyFormatter.formatWithSign(0), r'+ R$ 0,00');
    });
  });
}
