import 'package:flutter/material.dart';
import 'package:newbank/models/tipo_transacao.dart';
import 'package:newbank/models/transacao.dart';
import 'package:newbank/models/usuario.dart';
import 'package:newbank/repositories/transacao_repository.dart';
import 'package:newbank/repositories/usuario_repository.dart';
import 'package:newbank/services/currency_formatter.dart';
import 'package:newbank/services/validators.dart';

class TransferenciaScreen extends StatefulWidget {
  const TransferenciaScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<TransferenciaScreen> createState() => _TransferenciaScreenState();
}

class _TransferenciaScreenState extends State<TransferenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _emailDestinatarioController = TextEditingController();
  final _transacaoRepo = TransacaoRepository();
  final _usuarioRepo = UsuarioRepository();
  bool _carregando = false;

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    _emailDestinatarioController.dispose();
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
          backgroundColor: Colors.green,
        ),
      );

      // Voltar para Home e indicar que houve atualização
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
    const verde = Color(0xFF1B8C3E);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transferência',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: verde,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo atual: ${CurrencyFormatter.format(widget.usuario.saldo)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Email do destinatário ──
                TextFormField(
                  controller: _emailDestinatarioController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email do destinatário',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_search_outlined),
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
                  decoration: const InputDecoration(
                    labelText: 'Valor a transferir (R\$)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Informe o valor';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Descrição ──
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (Opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Botão ──
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _fazerTransferencia,
                    style: ElevatedButton.styleFrom(backgroundColor: verde),
                    child: _carregando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Transferir',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
