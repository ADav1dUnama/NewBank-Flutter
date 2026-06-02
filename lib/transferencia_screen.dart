import 'package:flutter/material.dart';
import 'package:newbank/controllers/transferencia_controller.dart';
import 'package:newbank/models/usuario.dart';
import 'package:newbank/repositories/transacao_repository.dart';
import 'package:newbank/services/currency_formatter.dart';
import 'package:newbank/services/validators.dart';

class TransferenciaScreen extends StatefulWidget {
  final Usuario usuario;

  const TransferenciaScreen({super.key, required this.usuario});

  @override
  State<TransferenciaScreen> createState() => _TransferenciaScreenState();
}

class _TransferenciaScreenState extends State<TransferenciaScreen> {
  late final TransferenciaController _controller;
  final _formKey = GlobalKey<FormState>();
  
  final _pixKeyController = TextEditingController();
  final _valueController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = TransferenciaController(
      transacaoRepo: TransacaoRepository(),
      usuario: widget.usuario,
    );
    _valueController.text = '0,00';
    
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _pixKeyController.dispose();
    _valueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fazerTransferencia() async {
    if (!_formKey.currentState!.validate()) return;

    final valorStr = _valorController.text.replaceAll('.', '').replaceAll(',', '.');
    final valorDouble = double.tryParse(valorStr);
    if (valorDouble == null || valorDouble <= 0) {
      _mostrarErro('Valor inválido');
      return;
    }


    final valor = (valorDouble * 100).round(); // centavos

    final emailDest = _emailDestinatarioController.text.trim();

    setState(() => _carregando = true);

    try {
      // Buscar destinatário por email
      final destinatario = await _usuarioRepo.findByEmail(emailDest);
      if (destinatario == null) {
        _mostrarErro('Destinatário não encontrado com o email informado.');
        return;
      }

      if (destinatario.id == widget.usuario.id) {
        _mostrarErro('Não é possível transferir para si mesmo.');
        return;
      }

      if (!mounted) return;
      final confirmado = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar transferência'),
          content: Text(
            'Transferir ${CurrencyFormatter.format(valor)} para '
            '${destinatario.nomeCompleto}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B8C3E)),
              child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (!mounted) return;

      if (confirmado != true) {
        setState(() => _carregando = false);
        return;
      }

      final transacao = Transacao(
        usuarioId: widget.usuario.id!,
        destinatarioId: destinatario.id!,
        tipo: TipoTransacao.transferencia,
        valor: valor,
        dataHora: DateTime.now(),
        descricao: _descricaoController.text.trim(),
      );

      await _transacaoRepo.insert(transacao);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transferência de ${CurrencyFormatter.format(valor)} '
            'para ${destinatario.nomeCompleto} realizada!',
          ),
        ),
      );
    }
  }

  Future<void> _fazerTransferencia() async {
    if (!_formKey.currentState!.validate()) return;
    
    await _controller.realizarTransferencia(
      chavePix: _pixKeyController.text,
      valorStr: _valueController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Transferência'),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saldo atual',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  _buildBalanceCard(isDark),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _pixKeyController,
                    label: 'Chave Pix',
                    hintText: 'CPF, CNPJ, e-mail ou telefone',
                    suffixIcon: const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 22),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Informe a chave Pix';
                      if (!_controller.isValidaChavePix(val)) return 'Formato inválido';
                      return null;
                    },
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),

                // ── Valor ──
                TextFormField(
                  controller: _valorController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Descrição (opcional)',
                    hintText: 'Ex: Aluguel, pagamento...',
                    maxLength: 50,
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: 'Transferir',
                    isLoading: _controller.loading,
                    onPressed: _fazerTransferencia,
                  ),
                  const SizedBox(height: 16),
                  _buildSecurityBadge(isDark),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'Recurso simulado',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (i) {
          if (i == 2) return;
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildBalanceCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: isDark ? Colors.white12 : AppColors.border),
        borderRadius: BorderRadius.circular(10),
        color: isDark ? Colors.black : AppColors.card,
      ),
      child: Text(
        CurrencyFormatter.format(widget.usuario.saldo),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSecurityBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.transparent : AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: Colors.white12) : null,
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Suas transações são protegidas\ncom segurança de ponta a ponta.',
              style: TextStyle(fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
