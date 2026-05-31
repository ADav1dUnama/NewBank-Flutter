import 'package:flutter/material.dart';
import 'package:newbank/models/tipo_conta.dart';
import 'package:newbank/models/transacao.dart';
import 'package:newbank/models/tipo_transacao.dart';
import 'package:newbank/models/usuario.dart';
import 'package:newbank/repositories/transacao_repository.dart';
import 'package:newbank/repositories/usuario_repository.dart';
import 'package:newbank/services/currency_formatter.dart';
import 'package:newbank/transferencia_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _saldoVisivel = true;

  late Usuario _usuario;
  List<Transacao> _transacoes = [];
  double _totalEntradas = 0;
  double _totalSaidas = 0;

  final _usuarioRepo = UsuarioRepository();
  final _transacaoRepo = TransacaoRepository();

  static const Color verde = Color(0xFF1B8C3E);
  static const Color verdeBackground = Color(0xFFEAF7EE);

  @override
  void initState() {
    super.initState();
    _usuario = widget.usuario;
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    if (_usuario.id == null) return;

    final usuario = await _usuarioRepo.findById(_usuario.id!);
    final transacoes = await _transacaoRepo.findByUsuarioId(_usuario.id!);
    final resumo = await _transacaoRepo.calcularResumo(_usuario.id!);

    if (!mounted) return;
    setState(() {
      if (usuario != null) _usuario = usuario;
      _transacoes = transacoes;
      _totalEntradas = resumo['entradas'] ?? 0;
      _totalSaidas = resumo['saidas'] ?? 0;
    });
  }

  Future<void> _navegarTransferencia() async {
    final atualizou = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransferenciaScreen(usuario: _usuario),
      ),
    );
    if (atualizou == true) {
      await _carregarDados();
    }
  }

  void _mostrarEmBreve() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade em breve!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F5),
      drawer: _buildDrawer(theme, isDark),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme, isDark),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildAtalhos(theme, isDark),
                    const SizedBox(height: 16),
                    _buildSegurancaBanner(theme, isDark),
                    const SizedBox(height: 24),
                    _buildResumo(theme, isDark),
                    const SizedBox(height: 16),
                    _buildMovimentacoes(theme, isDark),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(theme, isDark),
    );
  }

  Widget _buildDrawer(ThemeData theme, bool isDark) {
    return Drawer(
      backgroundColor: isDark ? Colors.black : Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: verde),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _usuario.nomeCompleto[0].toUpperCase(),
                style: const TextStyle(
                  color: verde,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            accountName: Text(
              _usuario.nomeCompleto,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(_usuario.email),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Meus Dados'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Configurações da Conta'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: const Text('Segurança e Privacidade'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Ajuda e Suporte'),
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    final tipoConta = _usuario.tipoConta == TipoConta.corrente
        ? 'Conta corrente'
        : 'Conta poupança';
    final numeroConta = _usuario.numeroConta.isNotEmpty
        ? '${_usuario.agencia} • ${_usuario.numeroConta}'
        : _usuario.agencia;

    return Container(
      color: verde,
      padding: const EdgeInsets.fromLTRB(10, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              Stack(
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '1',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Olá, ${_usuario.nomeCompleto.split(' ').first}!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Bem-vindo ao NewBank',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isDark ? Border.all(color: Colors.white12) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo disponível',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _saldoVisivel
                          ? CurrencyFormatter.format(_usuario.saldo)
                          : 'R\$ ••••••',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _saldoVisivel = !_saldoVisivel),
                      child: Icon(
                        _saldoVisivel
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                    ),
                  ],
                ),
                Divider(height: 24, color: isDark ? Colors.white10 : null),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tipoConta,
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          numeroConta,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: isDark ? Colors.white38 : Colors.black45,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtalhos(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Atalhos',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAtalhoItem(
                Icons.swap_horiz_rounded,
                'Transferência',
                _navegarTransferencia,
                theme,
                isDark,
              ),
              _buildAtalhoItem(Icons.pix, 'Pix', _mostrarEmBreve, theme, isDark),
              _buildAtalhoItem(
                Icons.bar_chart_rounded,
                'Cotação',
                _mostrarEmBreve,
                theme,
                isDark,
              ),
              _buildAtalhoItem(
                Icons.receipt_long_outlined,
                'Extrato',
                _mostrarEmBreve,
                theme,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAtalhoItem(
    IconData icon,
    String label,
    VoidCallback onTap,
    ThemeData theme,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: isDark ? Border.all(color: Colors.white12) : null,
              boxShadow: isDark ? null : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: verde, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegurancaBanner(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.transparent : verdeBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? Colors.white12 : verde.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: verde.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user_outlined,
                color: verde,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seu dinheiro protegido',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Suas transações são protegidas com segurança de ponta a ponta.',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: isDark ? Colors.white38 : Colors.black45),
          ],
        ),
      ),
    );
  }

  // Resumo de entradas e saídas — dados reais do banco
  Widget _buildResumo(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isDark ? Border.all(color: Colors.white12) : null,
          boxShadow: isDark ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildResumoItem(
              'Entradas',
              '+ ${CurrencyFormatter.format(_totalEntradas)}',
              true,
              isDark,
            ),
            Container(
              width: 1,
              height: 40,
              color: isDark ? Colors.white10 : Colors.grey.shade200,
            ),
            _buildResumoItem(
              'Saídas',
              '- ${CurrencyFormatter.format(_totalSaidas)}',
              false,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoItem(String label, String valor, bool positivo, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            color: positivo ? verde : (isDark ? Colors.white : Colors.black87),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  IconData _iconeParaTipo(TipoTransacao tipo) {
    switch (tipo) {
      case TipoTransacao.transferencia:
        return Icons.swap_horiz_rounded;
      case TipoTransacao.deposito:
        return Icons.arrow_downward_rounded;
      case TipoTransacao.saque:
        return Icons.arrow_upward_rounded;
    }
  }

  String _labelParaTipo(TipoTransacao tipo) {
    switch (tipo) {
      case TipoTransacao.transferencia:
        return 'Transferência';
      case TipoTransacao.deposito:
        return 'Depósito';
      case TipoTransacao.saque:
        return 'Saque';
    }
  }

  /// Determina se a transação é positiva (entrada) para o usuário atual.
  bool _isEntrada(Transacao t) {
    if (t.tipo == TipoTransacao.deposito) return true;
    if (t.tipo == TipoTransacao.transferencia &&
        t.destinatarioId == _usuario.id) {
      return true;
    }
    return false;
  }

  Widget _buildMovimentacoes(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Últimas movimentações',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_transacoes.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: isDark ? Border.all(color: Colors.white12) : null,
                boxShadow: isDark ? null : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    color: isDark ? Colors.white24 : Colors.black26,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nenhuma movimentação ainda',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black45,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: isDark ? Border.all(color: Colors.white12) : null,
                boxShadow: isDark ? null : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: _transacoes.asMap().entries.map((entry) {
                  final i = entry.key;
                  final t = entry.value;
                  final positivo = _isEntrada(t);
                  final icone = _iconeParaTipo(t.tipo);
                  final titulo = _labelParaTipo(t.tipo);
                  final dataStr =
                      '${t.dataHora.toLocal().day.toString().padLeft(2, '0')}/'
                      '${t.dataHora.toLocal().month.toString().padLeft(2, '0')}/'
                      '${t.dataHora.toLocal().year}';
                  final valorStr = positivo
                      ? '+ ${CurrencyFormatter.format(t.valor)}'
                      : '- ${CurrencyFormatter.format(t.valor)}';

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: positivo
                                    ? verde.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                icone,
                                color: positivo
                                    ? verde
                                    : Colors.red.shade300,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    titulo,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    dataStr,
                                    style: TextStyle(
                                      color: isDark ? Colors.white38 : Colors.black45,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              valorStr,
                              style: TextStyle(
                                color: positivo ? verde : (isDark ? Colors.white : Colors.black87),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (i < _transacoes.length - 1)
                        Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: isDark ? Colors.white10 : null,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(ThemeData theme, bool isDark) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Início', 'action': 'home'},
      {'icon': Icons.bar_chart_rounded, 'label': 'Cotação', 'action': 'soon'},
      {
        'icon': Icons.swap_horiz_rounded,
        'label': 'Transferência',
        'action': 'transfer',
      },
      {
        'icon': Icons.receipt_long_outlined,
        'label': 'Extrato',
        'action': 'soon',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        border: isDark ? const Border(top: BorderSide(color: Colors.white12)) : null,
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final selected = i == _currentIndex;
              return GestureDetector(
                onTap: () async {
                  setState(() => _currentIndex = i);
                  final action = item['action'] as String;
                  if (action == 'transfer') {
                    await _navegarTransferencia();
                  } else if (action == 'soon') {
                    _mostrarEmBreve();
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: selected ? verde : (isDark ? Colors.white38 : Colors.black38),
                      size: 26,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        color: selected ? verde : (isDark ? Colors.white38 : Colors.black38),
                        fontSize: 11,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
