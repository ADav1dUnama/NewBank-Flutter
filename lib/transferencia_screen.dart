import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newbank/models/tipo_transacao.dart';
import 'package:newbank/models/transacao.dart';
import 'package:newbank/models/usuario.dart';
import 'package:newbank/repositories/transacao_repository.dart';
import 'package:newbank/repositories/usuario_repository.dart';
import 'package:newbank/services/currency_formatter.dart';

class TransferenciaScreen extends StatefulWidget {
  const TransferenciaScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<TransferenciaScreen> createState() => _TransferenciaScreenState();
}

class _TransferenciaScreenState extends State<TransferenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pixKeyController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _transacaoRepo = TransacaoRepository();
  final _usuarioRepo = UsuarioRepository();

  int _currentNavIndex = 2;
  int _descriptionLength = 0;
  bool _carregando = false;

  static const Color _green = Color(0xFF1B7A3E);
  static const Color _lightGreen = Color(0xFFE8F5EE);
  static const Color _borderColor = Color(0xFFDDE3E8);
  static const Color _labelColor = Color(0xFF6B7280);
  static const Color _hintColor = Color(0xFFADB5BD);

  @override
  void initState() {
    super.initState();
    _valueController.text = 'R\$ 0,00';
    _descriptionController.addListener(() {
      setState(() {
        _descriptionLength = _descriptionController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _pixKeyController.dispose();
    _valueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fazerTransferencia() async {
    if (!_formKey.currentState!.validate()) return;

    String valorStr = _valueController.text
        .replaceAll('R\$ ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    final valor = double.tryParse(valorStr) ?? 0;
    if (valor <= 0) {
      _mostrarErro('Valor inválido');
      return;
    }

    final emailDest = _pixKeyController.text.trim();
    if (emailDest.isEmpty) {
      _mostrarErro('Informe a chave Pix');
      return;
    }

    setState(() => _carregando = true);

    try {
      final destinatario = await _usuarioRepo.findByEmail(emailDest);
      if (destinatario == null) {
        _mostrarErro('Destinatário não encontrado com a chave informada.');
        return;
      }

      if (destinatario.id == widget.usuario.id) {
        _mostrarErro('Não é possível transferir para si mesmo.');
        return;
      }

      final transacao = Transacao(
        usuarioId: widget.usuario.id!,
        destinatarioId: destinatario.id!,
        tipo: TipoTransacao.transferencia,
        valor: valor,
        dataHora: DateTime.now(),
        descricao: _descriptionController.text.trim(),
      );

      await _transacaoRepo.insert(transacao);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transferência de ${CurrencyFormatter.format(valor)} '
            'para ${destinatario.nomeCompleto} realizada!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      _pixKeyController.clear();
      _valueController.text = 'R\$ 0,00';
      _descriptionController.clear();

      Navigator.pop(context, true);
    } on SaldoInsuficienteException {
      _mostrarErro('Saldo insuficiente para esta transferência.');
    } catch (e) {
      _mostrarErro(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transferência',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildPixTab(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildPixTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Saldo atual'),
            const SizedBox(height: 8),
            _buildBalanceField(),
            const SizedBox(height: 20),
            _buildFieldLabel('Chave Pix'),
            const SizedBox(height: 8),
            _buildPixKeyField(),
            const SizedBox(height: 20),
            _buildFieldLabel('Nome do recebedor'),
            const SizedBox(height: 8),
            _buildReadOnlyField('Será exibido automaticamente'),
            const SizedBox(height: 20),
            _buildFieldLabel('Valor'),
            const SizedBox(height: 8),
            _buildValueField(),
            const SizedBox(height: 20),
            _buildFieldLabel('Descrição (opcional)'),
            const SizedBox(height: 8),
            _buildDescriptionField(),
            const SizedBox(height: 32),
            _buildTransferButton(),
            const SizedBox(height: 16),
            _buildSecurityBadge(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildBalanceField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFF9FAFB),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          'R\$ ${CurrencyFormatter.format(widget.usuario.saldo)}',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPixKeyField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _pixKeyController,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: const InputDecoration(
                hintText: 'CPF, e-mail, telefone ou chave aleatória',
                hintStyle: TextStyle(color: _hintColor, fontSize: 13),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: InputBorder.none,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Informe a chave Pix';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(Icons.qr_code_scanner, color: _green, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String hint) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFF9FAFB),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          hint,
          style: const TextStyle(color: _hintColor, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildValueField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: _valueController,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: InputBorder.none,
        ),
        onTap: () {
          if (_valueController.text == 'R\$ 0,00') {
            _valueController.clear();
          }
        },
        validator: (val) {
          if (val == null || val.isEmpty || val == 'R\$ 0,00') {
            return 'Informe um valor válido';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          TextFormField(
            controller: _descriptionController,
            maxLength: 50,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            decoration: const InputDecoration(
              hintText: 'Ex: Aluguel, pagamento...',
              hintStyle: TextStyle(color: _hintColor, fontSize: 13),
              contentPadding: EdgeInsets.fromLTRB(14, 14, 50, 14),
              border: InputBorder.none,
              counterText: '',
            ),
          ),
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                '$_descriptionLength/50',
                style: const TextStyle(color: _hintColor, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _carregando ? null : _fazerTransferencia,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _carregando
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Transferir',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }

  Widget _buildSecurityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _lightGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, color: _green, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Suas transações são protegidas\ncom segurança de ponta a ponta.',
              style: TextStyle(
                color: Color(0xFF1B5E34),
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Início',
      ),
      _NavItem(
        icon: Icons.show_chart_outlined,
        activeIcon: Icons.show_chart,
        label: 'Cotação',
      ),
      _NavItem(
        icon: Icons.swap_horiz_outlined,
        activeIcon: Icons.swap_horiz,
        label: 'Transferência',
      ),
      _NavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: 'Extrato',
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _borderColor, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (i) => setState(() => _currentNavIndex = i),
        selectedItemColor: _green,
        unselectedItemColor: _labelColor,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        backgroundColor: Colors.white,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: List.generate(
          items.length,
          (i) => BottomNavigationBarItem(
            icon: Icon(items[i].icon, size: 24),
            activeIcon: Icon(items[i].activeIcon, size: 24),
            label: items[i].label,
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
