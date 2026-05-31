import 'package:flutter/material.dart';
import 'package:newbank/transferencia_screen.dart';
import 'package:newbank/cotacao_screen.dart';
import 'package:newbank/models/usuario.dart';
import 'package:newbank/models/transacao.dart';
import 'package:newbank/repositories/transacao_repository.dart';

class ExtratoScreen extends StatefulWidget {
  final Usuario usuario;

  const ExtratoScreen({super.key, required this.usuario});

  @override
  State<ExtratoScreen> createState() => _ExtratoScreenState();
}

class _ExtratoScreenState extends State<ExtratoScreen> {
  int _selectedIndex = 3;
  bool _isLoading = true;
  List<Transacao> _transacoes = [];

  String _filtroSelecionado = 'Todos';
  final List<String> _filtros = ['Todos', 'Entrada', 'Saída', 'Transferência'];

  final _transacaoRepo = TransacaoRepository();

  @override
  void initState() {
    super.initState();
    _carregarTransacoes();
  }

  Future<void> _carregarTransacoes() async {
    setState(() => _isLoading = true);
    try {
      final transacoes = await _transacaoRepo.findByUsuarioId(widget.usuario.id!);
      if (!mounted) return;
      setState(() {
        _transacoes = transacoes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar extrato')),
      );
    }
  }

  List<Transacao> get _transacoesFiltradas {
    if (_filtroSelecionado == 'Todos') return _transacoes;
    return _transacoes.where((t) {
      // Simplificando lógica de filtro para transações reais
      if (_filtroSelecionado == 'Entrada') {
        return t.destinatarioId == widget.usuario.id;
      } else if (_filtroSelecionado == 'Saída') {
        return t.usuarioId == widget.usuario.id && t.destinatarioId != widget.usuario.id;
      }
      return true;
    }).toList();
  }

  void _onBottomNavTapped(int index) async {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pop(context);
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final transacoes = _transacoesFiltradas;
    const verde = Color(0xFF1B7A3E);

    return Scaffold(
      backgroundColor: isDark ? theme.colorScheme.surface : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: verde,
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
          _buildSaldoHeader(isDark),

          _buildFiltros(theme, isDark),
          
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : transacoes.isEmpty
                    ? _buildEstadoVazio(theme, isDark)
                    : _buildListaTransacoes(transacoes, theme, isDark),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
        selectedItemColor: verde,
        unselectedItemColor: isDark ? Colors.white38 : Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Início'),
          BottomNavigationBarItem(
              icon: Icon(Icons.currency_exchange_rounded), label: 'Conversor'),
          BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz_rounded), label: 'Transferir'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Extrato'),
        ],
      ),
    );
  }

  Widget _buildSaldoHeader(bool isDark) {
    const verde = Color(0xFF1B7A3E);
    return Container(
      width: double.infinity,
      color: verde,
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

  Widget _buildFiltros(ThemeData theme, bool isDark) {
    const verde = Color(0xFF1B7A3E);
    return Container(
      color: isDark ? Colors.black : theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar por',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.grey[600],
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
                      color: isSelected ? verde : (isDark ? Colors.white10 : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? verde : (isDark ? Colors.white24 : Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      filtro,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.grey[700]),
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

  Widget _buildEstadoVazio(ThemeData theme, bool isDark) {
    const verde = Color(0xFF1B7A3E);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? verde.withOpacity(0.1) : Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 56,
                color: isDark ? verde.withOpacity(0.5) : Colors.green[300],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma transação encontrada',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey[700],
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
                color: isDark ? Colors.white38 : Colors.grey[500],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaTransacoes(List<Transacao> transacoes, ThemeData theme, bool isDark) {
    final Map<String, List<Transacao>> agrupadas = {};
    for (final t in transacoes) {
      final data = '${t.dataHora.day.toString().padLeft(2, '0')}/${t.dataHora.month.toString().padLeft(2, '0')}/${t.dataHora.year}';
      agrupadas.putIfAbsent(data, () => []).add(t);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${transacoes.length} transaç${transacoes.length == 1 ? 'ão' : 'ões'}',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : Colors.grey[600],
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
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Divider(color: isDark ? Colors.white10 : Colors.grey[300], height: 1),
                    ),
                  ],
                ),
              ),
              // Cards de transação
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isDark ? Border.all(color: Colors.white12) : null,
                  boxShadow: isDark ? null : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  children: entry.value.asMap().entries.map((e) {
                    final isLast = e.key == entry.value.length - 1;
                    return _buildTransacaoItem(e.value, isLast, theme, isDark);
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
            color: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? Colors.blue.withOpacity(0.5) : Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: isDark ? Colors.blue[300] : Colors.blue[600], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Exibindo todas as movimentações da conta',
                  style: TextStyle(color: isDark ? Colors.blue[100] : Colors.blue[900], fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTransacaoItem(Transacao transacao, bool isLast, ThemeData theme, bool isDark) {
    final bool positivo = transacao.destinatarioId == widget.usuario.id;
    final tipoStr = positivo ? 'Entrada' : 'Saída';
    final cor = _corPorTipo(tipoStr);
    final icone = _iconePorTipo(tipoStr);
    final valor = transacao.valor;
    final horaStr = '${transacao.dataHora.hour.toString().padLeft(2, '0')}:${transacao.dataHora.minute.toString().padLeft(2, '0')}';
    final descricao = (transacao.descricao != null && transacao.descricao!.isNotEmpty) ? transacao.descricao! : (positivo ? 'Transferência recebida' : 'Transferência enviada');

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
                      descricao,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tipoStr,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
        
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatarValor(valor, tipoStr),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: positivo
                          ? (isDark ? Colors.green[300] : Colors.green[700])
                          : (isDark ? Colors.red[300] : Colors.red[700]),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    horaStr,
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white24 : Colors.grey[400]),
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
            color: isDark ? Colors.white10 : Colors.grey[100],
          ),
      ],
    );
  }
}
