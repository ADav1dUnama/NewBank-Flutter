import 'package:flutter/material.dart';
import 'package:newbank/controllers/home_controller.dart';
import 'package:newbank/models/tipo_conta.dart';
import 'package:newbank/models/tipo_transacao.dart';
import 'package:newbank/models/usuario.dart';
import 'package:newbank/repositories/transacao_repository.dart';
import 'package:newbank/repositories/usuario_repository.dart';
import 'package:newbank/services/currency_formatter.dart';
import 'package:newbank/services/secure_storage_service.dart';
import 'package:newbank/landing_page.dart';
import 'package:newbank/transferencia_screen.dart';
import 'package:newbank/cotacao_screen.dart';
import 'package:newbank/extrato_screen.dart';
import 'package:newbank/meus_dados_screen.dart';
import 'package:newbank/configuracoes_conta_screen.dart';
import 'package:newbank/theme/app_colors.dart';
import 'package:newbank/widgets/custom_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  final Usuario usuario;

  const HomeScreen({super.key, required this.usuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;
  int _currentIndex = 0;
  bool _saldoVisivel = true;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(
      usuarioRepo: UsuarioRepository(),
      transacaoRepo: TransacaoRepository(),
      usuario: widget.usuario,
    );
    _controller.carregarDados().then((_) {
      if (_controller.usuario.saldo == 0 && !_controller.promptDepositoMostrado) {
        _controller.setPromptMostrado(true);
        _exibirPromptDeposito();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fazerLogout() async {
    await SecureStorageService().clearLastLoggedUserId();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LandingPage()),
      (route) => false,
    );
  }

  void _exibirPromptDeposito() {
    final valController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Boas-vindas!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sua conta está zerada, você deseja depositar um valor?'),
            const SizedBox(height: 16),
            TextField(
              controller: valController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Valor do depósito',
                prefixText: 'R\$ ',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Recurso simulado', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Agora não')),
          ElevatedButton(
            onPressed: () async {
              final valor = double.tryParse(valController.text) ?? 0;
              await _controller.realizarDeposito(valor);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Depositar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: _buildDrawer(isDark),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return SafeArea(
            child: Column(
              children: [
                _buildHeader(isDark),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildAtalhos(isDark),
                        const SizedBox(height: 16),
                        _buildSegurancaBanner(isDark),
                        const SizedBox(height: 24),
                        _buildResumo(isDark),
                        const SizedBox(height: 16),
                        _buildMovimentacoes(isDark),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) async {
          if (i == _currentIndex) return;

          setState(() => _currentIndex = i);

          switch (i) {
            case 1:
              await Navigator.push(context, MaterialPageRoute(builder: (_) => CotacaoScreen(usuario: _controller.usuario)));
              setState(() => _currentIndex = 0);
              break;
            case 2:
              await _navegarTransferencia();
              setState(() => _currentIndex = 0);
              break;
            case 3:
              await Navigator.push(context, MaterialPageRoute(builder: (_) => ExtratoScreen(usuario: _controller.usuario)));
              setState(() => _currentIndex = 0);
              break;
          }
        },
      ),
    );
  }

  String _getIniciais(String nome) {
    if (nome.isEmpty) return 'U';
    final partes = nome.trim().split(' ');
    if (partes.length > 1) {
      return (partes.first[0] + partes.last[0]).toUpperCase();
    }
    return partes.first[0].toUpperCase();
  }

  Widget _buildDrawer(bool isDark) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  _getIniciais(_controller.usuario.nomeCompleto),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            accountName: Text(_controller.usuario.nomeCompleto, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(_controller.usuario.email),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Meus Dados'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => MeusDadosScreen(usuario: _controller.usuario)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Configurações da Conta'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => ConfiguracoesContaScreen(usuario: _controller.usuario)));
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: _fazerLogout,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final tipoConta = _controller.usuario.tipoConta == TipoConta.corrente ? 'Conta corrente' : 'Conta poupança';

    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(10, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                onPressed: () => Scaffold.of(context).openDrawer(),
              )),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Olá, ${_controller.usuario.nomeCompleto.split(' ').first}!',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Text('Bem-vindo ao NewBank', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Saldo disponível', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _saldoVisivel ? CurrencyFormatter.format(_controller.usuario.saldo) : 'R\$ ••••••',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(_saldoVisivel ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _saldoVisivel = !_saldoVisivel),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tipoConta, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
                        Text('${_controller.usuario.agencia} • ${_controller.usuario.numeroConta}', style: const TextStyle(fontSize: 13)),
                      ],
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

  Widget _buildAtalhos(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildAtalhoItem(Icons.pix, 'Pix', () => _navegarTransferencia()),
          _buildAtalhoItem(Icons.swap_horiz_rounded, 'Transferir', () => _navegarTransferencia()),
          _buildAtalhoItem(Icons.bar_chart_rounded, 'Cotação', () => Navigator.push(context, MaterialPageRoute(builder: (_) => CotacaoScreen(usuario: _controller.usuario)))),
          _buildAtalhoItem(Icons.receipt_long_outlined, 'Extrato', () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExtratoScreen(usuario: _controller.usuario)))),
        ],
      ),
    );
  }

  Widget _buildAtalhoItem(IconData icon, String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 62, height: 62,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isDark ? null : [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSegurancaBanner(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.verified_user_outlined, color: AppColors.primary),
            SizedBox(width: 14),
            Expanded(child: Text('Seu dinheiro protegido com segurança de ponta a ponta.', style: TextStyle(fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _buildResumo(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildResumoItem('Entradas', '+ ${CurrencyFormatter.format(_controller.totalEntradas)}', true),
            const VerticalDivider(),
            _buildResumoItem('Saídas', '- ${CurrencyFormatter.format(_controller.totalSaidas)}', false),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoItem(String label, String valor, bool positivo) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(valor, style: TextStyle(color: positivo ? AppColors.primary : Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _buildMovimentacoes(bool isDark) {
    if (_controller.transacoes.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Últimas movimentações', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: _controller.transacoes.take(5).map((t) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: t.tipo == TipoTransacao.deposito ? AppColors.primaryLight : Colors.red[50],
                  child: Icon(t.tipo == TipoTransacao.deposito ? Icons.arrow_downward : Icons.arrow_upward, color: t.tipo == TipoTransacao.deposito ? AppColors.primary : Colors.red, size: 20),
                ),
                title: Text(t.tipo == TipoTransacao.deposito ? 'Depósito' : 'Transferência', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(t.descricao ?? '', style: const TextStyle(fontSize: 12)),
                trailing: Text(
                  '${t.tipo == TipoTransacao.deposito ? '+' : '-'} ${CurrencyFormatter.format(t.valor)}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: t.tipo == TipoTransacao.deposito ? AppColors.primary : Colors.black),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navegarTransferencia() async {
    final refresh = await Navigator.push(context, MaterialPageRoute(builder: (_) => TransferenciaScreen(usuario: _controller.usuario)));
    if (refresh == true) await _controller.carregarDados();
  }
}
