import 'package:flutter/material.dart';
import 'package:newbank/controllers/transferencia_controller.dart';
import 'package:newbank/models/usuario.dart';
import 'package:newbank/repositories/transacao_repository.dart';
import 'package:newbank/services/currency_formatter.dart';
import 'package:newbank/services/dialog_helper.dart';
import 'package:newbank/theme/app_colors.dart';
import 'package:newbank/widgets/custom_text_field.dart';
import 'package:newbank/widgets/primary_button.dart';
import 'package:newbank/widgets/custom_bottom_nav_bar.dart';
import 'package:newbank/transferencia_sucesso_screen.dart';

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
    _valueController.text = 'R\$ 0,00';
    
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

  void _onControllerUpdate() {
    if (_controller.errorMessage != null) {
      DialogHelper.showError(context, _controller.errorMessage!);
    }
    if (_controller.success) {
      Navigator.pop(context, true);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransferenciaSucessoScreen(
            chavePix: _pixKeyController.text.trim(),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
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
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _valueController,
                    label: 'Valor',
                    keyboardType: TextInputType.number,
                    onTap: () {
                      if (_valueController.text == 'R\$ 0,00') _valueController.clear();
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty || val == 'R\$ 0,00') return 'Informe um valor válido';
                      return null;
                    },
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
        'R\$ ${CurrencyFormatter.format(widget.usuario.saldo)}',
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
