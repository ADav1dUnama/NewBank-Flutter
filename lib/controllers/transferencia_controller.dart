import 'package:flutter/material.dart';
import '../models/tipo_transacao.dart';
import '../models/transacao.dart';
import '../models/usuario.dart';
import '../repositories/transacao_repository.dart';

class TransferenciaController extends ChangeNotifier {
  final TransacaoRepository transacaoRepo;
  final Usuario usuario;

  TransferenciaController({
    required this.transacaoRepo,
    required this.usuario,
  });

  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _success = false;
  bool get success => _success;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  bool isValidaChavePix(String chave) {
    final cleanChave = chave.trim();
    if (cleanChave.isEmpty) return false;

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (emailRegExp.hasMatch(cleanChave)) return true;

    final digitsOnly = cleanChave.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length == 11 || digitsOnly.length == 14) return true;

    final phoneRegExp = RegExp(r'^\+?([0-9]{2})?([0-9]{2})([0-9]{8,9})$');
    if (phoneRegExp.hasMatch(digitsOnly) || phoneRegExp.hasMatch(cleanChave)) return true;

    return false;
  }

  Future<void> realizarTransferencia({
    required String chavePix,
    required String valorStr,
  }) async {
    _errorMessage = null;
    _success = false;

    if (!isValidaChavePix(chavePix)) {
      _errorMessage = 'Chave Pix inválida. Use CPF, CNPJ, E-mail ou Telefone.';
      notifyListeners();
      return;
    }

    final valorDouble = double.tryParse(
          valorStr.replaceAll(RegExp(r'[R\$\s]'), '').replaceAll('.', '').replaceAll(',', '.'),
        ) ?? 0.0;
        
    final valor = (valorDouble * 100).round();

    if (valor <= 0) {
      _errorMessage = 'Valor inválido';
      notifyListeners();
      return;
    }

    _setLoading(true);

    try {
      final transacao = Transacao(
        usuarioId: usuario.id!,
        destinatarioId: null,
        tipo: TipoTransacao.saque,
        valor: valor,
        dataHora: DateTime.now(),
        descricao: 'Pix enviado para: $chavePix',
      );

      await transacaoRepo.insert(transacao);
      _success = true;
    } on SaldoInsuficienteException {
      _errorMessage = 'Saldo insuficiente para esta transferência.';
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }
}
