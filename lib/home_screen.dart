import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _saldoVisivel = true;

  static const Color verde = Color(0xFF1B8C3E);
  static const Color verdeBackground = Color(0xFFEAF7EE);

  final List<Map<String, dynamic>> movimentacoes = [
    {
      'titulo': 'Pix recebido',
      'data': '14/05/2026',
      'valor': '+ R\$ 1.200,00',
      'positivo': true,
      'icone': Icons.pix
    },
    {
      'titulo': 'Transferência enviada',
      'data': '13/05/2026',
      'valor': '- R\$ 350,00',
      'positivo': false,
      'icone': Icons.swap_horiz_rounded
    },
    {
      'titulo': 'Pagamento',
      'data': '13/05/2026',
      'valor': '- R\$ 89,90',
      'positivo': false,
      'icone': Icons.receipt_long_outlined
    },
    {
      'titulo': 'Pix enviado',
      'data': '12/05/2026',
      'valor': '- R\$ 200,00',
      'positivo': false,
      'icone': Icons.pix
    },
    {
      'titulo': 'Depósito recebido',
      'data': '10/05/2026',
      'valor': '+ R\$ 3.000,00',
      'positivo': true,
      'icone': Icons.arrow_downward_rounded
    },
    {
      'titulo': 'Pagamento de conta',
      'data': '09/05/2026',
      'valor': '- R\$ 150,00',
      'positivo': false,
      'icone': Icons.receipt_long_outlined
    },
    {
      'titulo': 'Pix recebido',
      'data': '08/05/2026',
      'valor': '+ R\$ 500,00',
      'positivo': true,
      'icone': Icons.pix
    },
    {
      'titulo': 'Transferência enviada',
      'data': '07/05/2026',
      'valor': '- R\$ 220,00',
      'positivo': false,
      'icone': Icons.swap_horiz_rounded
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildAtalhos(),
                    const SizedBox(height: 16),
                    _buildSegurancaBanner(),
                    const SizedBox(height: 24),
                    _buildResumo(),
                    const SizedBox(height: 16),
                    _buildMovimentacoes(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: verde,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.menu, color: Colors.white, size: 28),
              Stack(
                children: [
                  const Icon(Icons.notifications_outlined,
                      color: Colors.white, size: 28),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      child: const Center(
                        child: Text('1',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Olá, Cliente!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const Text('Bem-vindo ao NewBank',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Saldo disponível',
                    style: TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _saldoVisivel ? 'R\$ 1.200,00' : 'R\$ ••••••',
                      style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 26,
                          fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _saldoVisivel = !_saldoVisivel),
                      child: Icon(
                        _saldoVisivel
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Conta corrente',
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                        SizedBox(height: 2),
                        Text('1234-5 • 67890-1',
                            style:
                                TextStyle(color: Colors.black87, fontSize: 13)),
                      ],
                    ),
                    Icon(Icons.chevron_right, color: Colors.black45),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtalhos() {
    final atalhos = [
      {
        'icon': Icons.swap_horiz_rounded,
        'label': 'Transferência',
        'rota': '/transferencia_screen'
      },
      {'icon': Icons.pix, 'label': 'Pix', 'rota': null},
      {
        'icon': Icons.bar_chart_rounded,
        'label': 'Cotação',
        'rota': '/cotacao_screen'
      },
      {'icon': Icons.receipt_long_outlined, 'label': 'Extrato', 'rota': null},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Atalhos',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: atalhos
                .map((a) => _buildAtalhoItem(a['icon'] as IconData,
                    a['label'] as String, a['rota'] as String?))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAtalhoItem(IconData icon, String label, String? rota) {
    return GestureDetector(
      onTap: () {
        if (rota != null) Navigator.pushNamed(context, rota);
      },
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Icon(icon, color: verde, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSegurancaBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: verdeBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: verde.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: verde.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.verified_user_outlined,
                  color: verde, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Seu dinheiro protegido',
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  SizedBox(height: 2),
                  Text(
                      'Suas transações são protegidas com segurança de ponta a ponta.',
                      style: TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  // Resumo de entradas e saídas
  Widget _buildResumo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildResumoItem('Entradas', '+ R\$ 4.700,00', true),
            Container(width: 1, height: 40, color: Colors.grey.shade200),
            _buildResumoItem('Saídas', '- R\$ 1.009,90', false),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoItem(String label, String valor, bool positivo) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            color: positivo ? verde : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildMovimentacoes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Últimas movimentações',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              children: movimentacoes.asMap().entries.map((entry) {
                final i = entry.key;
                final m = entry.value;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          // ícone da transação
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: m['positivo']
                                  ? verde.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              m['icone'] as IconData,
                              color:
                                  m['positivo'] ? verde : Colors.red.shade300,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // título e data
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m['titulo'],
                                    style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                const SizedBox(height: 3),
                                Text(m['data'],
                                    style: const TextStyle(
                                        color: Colors.black45, fontSize: 12)),
                              ],
                            ),
                          ),
                          // valor
                          Text(
                            m['valor'],
                            style: TextStyle(
                              color: m['positivo'] ? verde : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < movimentacoes.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Início', 'rota': null},
      {
        'icon': Icons.bar_chart_rounded,
        'label': 'Cotação',
        'rota': '/cotacao_screen'
      },
      {
        'icon': Icons.swap_horiz_rounded,
        'label': 'Transferência',
        'rota': '/transferencia_screen'
      },
      {'icon': Icons.receipt_long_outlined, 'label': 'Extrato', 'rota': null},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2))
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
                onTap: () {
                  setState(() => _currentIndex = i);
                  final rota = item['rota'] as String?;
                  if (rota != null) Navigator.pushNamed(context, rota);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item['icon'] as IconData,
                        color: selected ? verde : Colors.black38, size: 26),
                    const SizedBox(height: 4),
                    Text(item['label'] as String,
                        style: TextStyle(
                          color: selected ? verde : Colors.black38,
                          fontSize: 11,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.normal,
                        )),
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
