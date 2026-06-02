import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeRateService {
  static const String _baseUrl = 'https://open.er-api.com/v6/latest';

  static Future<Map<String, double>> getExchangeRates(
      String fromCurrency) async {
    try {
      final url = Uri.parse('$_baseUrl/$fromCurrency');

      final response = await http.get(url).timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout na requisição'),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // Verificar se houve erro
        if (json['result'] == 'error') {
          throw Exception('Moeda não encontrada: $fromCurrency');
        }

        final rates = json['rates'] as Map<String, dynamic>;
        return rates.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        );
      } else {
        throw Exception('Erro ao buscar taxas: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Erro de conexão: ${e.message}');
    } catch (e) {
      throw Exception('Erro desconhecido: $e');
    }
  }

  static Future<ConversionResult> convertCurrency({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    try {
      if (amount <= 0) {
        throw Exception('O valor deve ser maior que zero');
      }

      final rates = await getExchangeRates(fromCurrency);

      if (!rates.containsKey(toCurrency)) {
        throw Exception('Moeda de destino não encontrada: $toCurrency');
      }

      final rate = rates[toCurrency]!;
      final convertedAmount = amount * rate;

      return ConversionResult(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        originalAmount: amount,
        convertedAmount: convertedAmount,
        exchangeRate: rate,
      );
    } catch (e) {
      rethrow;
    }
  }
}

class ConversionResult {
  final String fromCurrency;
  final String toCurrency;
  final double originalAmount;
  final double convertedAmount;
  final double exchangeRate;

  ConversionResult({
    required this.fromCurrency,
    required this.toCurrency,
    required this.originalAmount,
    required this.convertedAmount,
    required this.exchangeRate,
  });

  @override
  String toString() =>
      '$originalAmount $fromCurrency = $convertedAmount $toCurrency (Taxa: 1 $fromCurrency = $exchangeRate $toCurrency)';
}
