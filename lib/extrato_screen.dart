import 'package:flutter/material.dart';
import 'package:newbank/transferencia_screen.dart';
import 'package:newbank/cotacao_screen.dart';
import 'package:newbank/models/usuario.dart';

class ExtratoScreen extends StatefulWidget {
  final Usuario usuario;

  const ExtratoScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  State<ExtratoScreen> createState() => _ExtratoScreenState();
}

class _ExtratoScreenState extends State<ExtratoScreen> {
  int _selectedIndex = 3;

  String _filtroSelecionado = 'Todos';
  final List<String> _filtros = ['Todos', 'Entrada', 'Saída', 'Transferência'];

  List<Map<String, dynamic>> get _transacoes {
    return widget.usuario.extrato;
  }

  List<Map<String, dynamic>> get _transacoesFiltradas {
    if (_filtroSelecionado == 'Todos') return _transacoes;
    return _transacoes.where((t) => t['tipo'] == _filtroSelecionado).toList();
  }

  void _onBottomNavTapped(int index) async {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      case 1:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CotacaoScreen(usuario: widget.usuario),
          ),
        );
        break;
      case 2:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransferenciaScreen(usuario: widget.usuario),
          ),
        );
        break;
      case 3:
        break;
    }
  }

  Color _corPorTipo(String tipo) {
    switch (tipo) {
      case 'Entrada':
        return Colors.green;
      case 'Saída':
        return Colors.red;
      case 'Transferência':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _iconePorTipo(String tipo) {
    switch (tipo) {
      case 'Entrada':
        return Icons.arrow_downward_rounded;
      case 'Saída':
        return Icons.arrow_upward_rounded;
      case 'Transferência':
        return Icons.swap_horiz_rounded;
      default:
        return Icons.attach_money;
    }
  }

  String _formatarValor(double valor, String tipo) {
    final sinal = tipo == 'Entrada' ? '+' : '-';
    return '$sinal R\$ ${valor.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final transacoes = _transacoesFiltradas;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Extrato',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSaldoHeader(),

          _buildFiltros(),
          
          Expanded(
            child: transacoes.isEmpty
                ? _buildEstadoVazio()
                : _buildListaTransacoes(transacoes),
          ),
        ],
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

  Widget _buildSaldoHeader() {
    return Container(
      width: double.infinity,
      color: Colors.green,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olá, ${widget.usuario.nomeCompleto}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'R\$ ${widget.usuario.saldo.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Saldo disponível',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar por',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filtros.map((filtro) {
                final isSelected = _filtroSelecionado == filtro;
                return GestureDetector(
                  onTap: () => setState(() => _filtroSelecionado = filtro),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.grey[300]!,
                      ),
                    ),
                    child: Text(
                      filtro,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoVazio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 56,
                color: Colors.green[300],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma transação encontrada',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _filtroSelecionado == 'Todos'
                  ? 'Suas transações aparecerão aqui assim que você movimentar sua conta.'
                  : 'Não há transações do tipo "$_filtroSelecionado".',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaTransacoes(List<Map<String, dynamic>> transacoes) {
    final Map<String, List<Map<String, dynamic>>> agrupadas = {};
    for (final t in transacoes) {
      final data = t['data'] as String;
      agrupadas.putIfAbsent(data, () => []).add(t);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${transacoes.length} transaç${transacoes.length == 1 ? 'ão' : 'ões'}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        ...agrupadas.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Separador de data
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Divider(color: Colors.grey[300], height: 1),
                    ),
                  ],
                ),
              ),
              // Cards de transação
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  children: entry.value.asMap().entries.map((e) {
                    final isLast = e.key == entry.value.length - 1;
                    return _buildTransacaoItem(e.value, isLast);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        }),
        const SizedBox(height: 8),
        // Info rodapé
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
                  'Exibindo todas as movimentações da conta',
                  style: TextStyle(color: Colors.blue[900], fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTransacaoItem(Map<String, dynamic> transacao, bool isLast) {
    final tipo = transacao['tipo'] as String;
    final cor = _corPorTipo(tipo);
    final icone = _iconePorTipo(tipo);
    final valor = (transacao['valor'] as num).toDouble();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Ícone
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icone, color: cor, size: 22),
              ),
              const SizedBox(width: 12),
              // Descrição
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transacao['descricao'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tipo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
        
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatarValor(valor, tipo),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: tipo == 'Entrada'
                          ? Colors.green[700]
                          : Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transacao['hora'] as String,
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 72,
            endIndent: 16,
            color: Colors.grey[100],
          ),
      ],
    );
  }
}
