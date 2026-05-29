import 'package:newbank/models/tipo_conta.dart';

class Usuario {
  const Usuario({
    this.id,
    required this.email,
    required this.senha,
    required this.nomeCompleto,
    required this.saldo,
    required this.tipoConta,
    required this.dataCriacao,
    this.agencia = '0001',
    this.numeroConta = '',
  });

  final int? id;
  final String email;
  final String senha;
  final String nomeCompleto;
  final double saldo;
  final TipoConta tipoConta;
  final DateTime dataCriacao;
  final String agencia;
  final String numeroConta;

  factory Usuario.fromMap(Map<String, Object?> map) {
    return Usuario(
      id: map['id'] as int?,
      email: map['email'] as String,
      senha: map['senha'] as String,
      nomeCompleto: map['nome_completo'] as String,
      saldo: (map['saldo'] as num).toDouble(),
      tipoConta: TipoConta.fromDb(map['tipo_conta'] as String),
      dataCriacao: DateTime.fromMillisecondsSinceEpoch(
        map['data_criacao'] as int,
        isUtc: true,
      ),
      agencia: map['agencia'] as String? ?? '0001',
      numeroConta: map['numero_conta'] as String? ?? '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'senha': senha,
      'nome_completo': nomeCompleto,
      'saldo': saldo,
      'tipo_conta': tipoConta.toDb(),
      'data_criacao': dataCriacao.toUtc().millisecondsSinceEpoch,
      'agencia': agencia,
      'numero_conta': numeroConta,
    };
  }

  Usuario copyWith({
    int? id,
    String? email,
    String? senha,
    String? nomeCompleto,
    double? saldo,
    TipoConta? tipoConta,
    DateTime? dataCriacao,
    String? agencia,
    String? numeroConta,
  }) {
    return Usuario(
      id: id ?? this.id,
      email: email ?? this.email,
      senha: senha ?? this.senha,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      saldo: saldo ?? this.saldo,
      tipoConta: tipoConta ?? this.tipoConta,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      agencia: agencia ?? this.agencia,
      numeroConta: numeroConta ?? this.numeroConta,
    );
  }

  @override
  String toString() {
    return 'Usuario(id: $id, email: $email, nomeCompleto: $nomeCompleto, '
        'saldo: $saldo, tipoConta: $tipoConta, dataCriacao: $dataCriacao, '
        'agencia: $agencia, numeroConta: $numeroConta)';
  }
}
