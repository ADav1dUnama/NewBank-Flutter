import 'package:flutter/material.dart';
import '../models/tipo_transacao.dart';
import '../models/transacao.dart';
import '../models/usuario.dart';
import '../repositories/transacao_repository.dart';
import '../repositories/usuario_repository.dart';

class HomeController extends ChangeNotifier {
  final UsuarioRepository usuarioRepo;
  final TransacaoRepository transacaoRepo;
  Usuario usuario;

  HomeController({
    required this.usuarioRepo,
    required this.transacaoRepo,
    required this.usuario,
  });

  bool _loading = false;
  bool get loading => _loading;

  List<Transacao> _transacoes = [];
  List<Transacao> get transacoes => _transacoes;

  int _totalEntradas = 0;
  int get totalEntradas => _totalEntradas;

  int _totalSaidas = 0;
  int get totalSaidas => _totalSaidas;

  bool _promptDepositoMostrado = false;
  bool get promptDepositoMostrado => _promptDepositoMostrado;

  void setPromptMostrado(bool value) {
    _promptDepositoMostrado = value;
  }

  Future<void> carregarDados() async {
    if (usuario.id == null) return;

    _loading = true;
    notifyListeners();

    try {
      final userUpdate = await usuarioRepo.findById(usuario.id!);
      if (userUpdate != null) usuario = userUpdate;

      _transacoes = await transacaoRepo.findByUsuarioId(usuario.id!);
      final resumo = await transacaoRepo.calcularResumo(usuario.id!);

      _totalEntradas = resumo['entradas']?.toInt() ?? 0;
      _totalSaidas = resumo['saidas']?.toInt() ?? 0;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> realizarDeposito(int valor) async {
    if (valor <= 0) return;

    final transacao = Transacao(
      usuarioId: usuario.id!,
      destinatarioId: usuario.id!,
      tipo: TipoTransacao.deposito,
      valor: valor,
      dataHora: DateTime.now(),
      descricao: 'Depósito inicial simulado',
    );

    await transacaoRepo.insert(transacao);
    await carregarDados();
  }
}
