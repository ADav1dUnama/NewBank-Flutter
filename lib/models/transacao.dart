import 'package:newbank/models/tipo_transacao.dart';

class Transacao {
  const Transacao({
    this.id,
    required this.usuarioId,
    required this.tipo,
    required this.valor,
    required this.dataHora,
    this.descricao,
  });

  final int? id;
  final int usuarioId;
  final TipoTransacao tipo;
  final double valor;
  final DateTime dataHora;
  final String? descricao;

  factory Transacao.fromMap(Map<String, Object?> map) {
    return Transacao(
      id: map['id'] as int?,
      usuarioId: map['usuario_id'] as int,
      tipo: TipoTransacao.fromDb(map['tipo'] as String),
      valor: (map['valor'] as num).toDouble(),
      dataHora: DateTime.fromMillisecondsSinceEpoch(
        map['data_hora'] as int,
        isUtc: true,
      ),
      descricao: map['descricao'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'usuario_id': usuarioId,
      'tipo': tipo.toDb(),
      'valor': valor,
      'data_hora': dataHora.toUtc().millisecondsSinceEpoch,
      'descricao': descricao,
    };
  }

  Transacao copyWith({
    int? id,
    int? usuarioId,
    TipoTransacao? tipo,
    double? valor,
    DateTime? dataHora,
    String? descricao,
  }) {
    return Transacao(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      tipo: tipo ?? this.tipo,
      valor: valor ?? this.valor,
      dataHora: dataHora ?? this.dataHora,
      descricao: descricao ?? this.descricao,
    );
  }

  @override
  String toString() {
    return 'Transacao(id: $id, usuarioId: $usuarioId, tipo: $tipo, '
        'valor: $valor, dataHora: $dataHora, descricao: $descricao)';
  }
}
