import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:newbank/transferencia_screen.dart';
import 'models/usuario.dart';

class CotacaoScreen extends StatefulWidget {
  final Usuario usuario;

  const CotacaoScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  State<CotacaoScreen> createState() => _CotacaoScreenState();
}

class _CotacaoScreenState extends State<CotacaoScreen> {
  // Controllers
  final TextEditingController _amountController = TextEditingController();

  // Estados
  String _moedaOrigem = 'BRL';
  String _moedaDestino = 'USD';
  bool _isLoading = false;
  ConversionResult? _resultado;
  String? _erro;
  int _selectedIndex = 1;

  // Lista de moedas disponíveis
  final List<String> _moedas = [
    'BRL',
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CAD',
    'AUD',
    'CHF',
    'CNY',
    'INR',
    'MXN',
    'ARS',
  ];

  final Map<String, String> _moedaIcons = {
    'BRL': '🇧🇷',
    'USD': '🇺🇸',
    'EUR': '🇪🇺',
    'GBP': '🇬🇧',
    'JPY': '🇯🇵',
    'CAD': '🇨🇦',
    'AUD': '🇦🇺',
    'CHF': '🇨🇭',
    'CNY': '🇨🇳',
    'INR': '🇮🇳',
    'MXN': '🇲🇽',
    'ARS': '🇦🇷',
  };

  final Map<String, Color> _moedaCores = {
    'BRL': Colors.green,
    'USD': Colors.blue,
    'EUR': Colors.amber,
    'GBP': Colors.purple,
    'JPY': Colors.red,
    'CAD': Colors.cyan,
    'AUD': Colors.orange,
    'CHF': Colors.red,
    'CNY': Colors.red,
    'INR': Colors.orange,
    'MXN': Colors.pink,
    'ARS': Colors.indigo,
  };

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _buscarCotacao() async {
    if (_amountController.text.isEmpty) {
      _mostrarErro('Por favor, digite um valor');
      return;
    }

    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _mostrarErro('Digite um valor válido');
      return;
    }

    if (_moedaOrigem == _moedaDestino) {
      _mostrarErro('Escolha moedas diferentes');
      return;
    }

    setState(() {
      _isLoading = true;
      _erro = null;
      _resultado = null;
    });

    try {
      final resultado = await _convertCurrency(
        fromCurrency: _moedaOrigem,
        toCurrency: _moedaDestino,
        amount: amount,
      );

      setState(() {
        _resultado = resultado;
        _isLoading = false;
      });
    } catch (e) {
      _mostrarErro(e.toString().replaceFirst('Exception: ', ''));
      setState(() => _isLoading = false);
    }
  }

  Future<ConversionResult> _convertCurrency({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    const String baseUrl = 'https://open.er-api.com/v6/latest';

    final url = Uri.parse('$baseUrl/$fromCurrency');

    final response = await http.get(url).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception('Timeout na requisição'),
        );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      if (json['result'] == 'error') {
        throw Exception('Moeda não encontrada: $fromCurrency');
      }

      final rates = json['rates'] as Map<String, dynamic>;
      if (!rates.containsKey(toCurrency)) {
        throw Exception('Moeda de destino não encontrada: $toCurrency');
      }

      final rate = (rates[toCurrency] as num).toDouble();
      final convertedAmount = amount * rate;

      return ConversionResult(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        originalAmount: amount,
        convertedAmount: convertedAmount,
        exchangeRate: rate,
      );
    } else {
      throw Exception('Erro ao buscar taxas: ${response.statusCode}');
    }
  }

  void _mostrarErro(String mensagem) {
    setState(() => _erro = mensagem);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _trocarMoedas() {
    setState(() {
      final temp = _moedaOrigem;
      _moedaOrigem = _moedaDestino;
      _moedaDestino = temp;
      _resultado = null;
    });
  }

  void _onBottomNavTapped(int index) async {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pop(context);
        break;

      case 1:
        break;

      case 2:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransferenciaScreen(
              usuario: widget.usuario,
            ),
          ),
        );
        break;

      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tela de extrato em desenvolvimento'),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF1B7A3E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Conversor de Moedas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Converta entre moedas com as melhores taxas',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 24),
              _buildInputCard(),
              const SizedBox(height: 16),
              _buildCurrencyCard(
                label: 'De (Moeda de Origem)',
                moedaSelecionada: _moedaOrigem,
                onChanged: (newValue) {
                  setState(() => _moedaOrigem = newValue!);
                  _resultado = null;
                },
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.swap_vert, color: Color(0xFF1B7A3E)),
                    onPressed: _trocarMoedas,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildCurrencyCard(
                label: 'Para (Moeda de Destino)',
                moedaSelecionada: _moedaDestino,
                onChanged: (newValue) {
                  setState(() => _moedaDestino = newValue!);
                  _resultado = null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _buscarCotacao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1B7A3E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Buscar Cotação',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              if (_resultado != null) _buildResultCard(),
              if (_erro != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _erro!,
                          style:
                              TextStyle(color: Colors.red[900], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Taxas atualizadas em tempo real',
                        style: TextStyle(color: Colors.blue[900], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
              icon: Icon(Icons.currency_exchange), label: 'Conversor'),
          BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz), label: 'Transferência'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Extrato'),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Valor a Converter',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: '0,00',
              prefixText: 'R\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onChanged: (_) {
              setState(() => _resultado = null);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyCard({
    required String label,
    required String moedaSelecionada,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: moedaSelecionada,
            items: _moedas.map((moeda) {
              return DropdownMenuItem(
                value: moeda,
                child: Row(
                  children: [
                    Text(_moedaIcons[moeda] ?? '',
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(moeda),
                  ],
                ),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600]),
              const SizedBox(width: 8),
              Text(
                'Conversão Realizada',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResultRow(
            'Valor Original',
            '${_resultado!.originalAmount.toStringAsFixed(2)} ${_resultado!.fromCurrency}',
            Colors.grey[700],
          ),
          const SizedBox(height: 12),
          Center(
            child: Icon(Icons.arrow_downward, color: Colors.green[600]),
          ),
          const SizedBox(height: 12),
          _buildResultRow(
            'Valor Convertido',
            '${_resultado!.convertedAmount.toStringAsFixed(2)} ${_resultado!.toCurrency}',
            Colors.green[700],
            isBold: true,
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.green[300]),
          const SizedBox(height: 12),
          _buildResultRow(
            'Taxa de Câmbio',
            '1 ${_resultado!.fromCurrency} = ${_resultado!.exchangeRate.toStringAsFixed(4)} ${_resultado!.toCurrency}',
            Colors.grey[600],
            fontSize: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    String value,
    Color? color, {
    bool isBold = false,
    double fontSize = 14,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: fontSize, color: color)),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
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
}
