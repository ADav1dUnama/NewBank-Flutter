import 'package:newbank/models/tipo_transacao.dart';

class Transacao {
  const Transacao({
    this.id,
    required this.usuarioId,
    this.destinatarioId,
    required this.tipo,
    required this.valor,
    required this.dataHora,
    this.descricao,
  });

  final int? id;
  final int usuarioId;
  final int? destinatarioId;
  final TipoTransacao tipo;
  final double valor;
  final DateTime dataHora;
  final String? descricao;

  factory Transacao.fromMap(Map<String, Object?> map) {
    return Transacao(
      id: map['id'] as int?,
      usuarioId: map['usuario_id'] as int,
      destinatarioId: map['destinatario_id'] as int?,
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
      'destinatario_id': destinatarioId,
      'tipo': tipo.toDb(),
      'valor': valor,
      'data_hora': dataHora.toUtc().millisecondsSinceEpoch,
      'descricao': descricao,
    };
  }

  Transacao copyWith({
    int? id,
    int? usuarioId,
    int? destinatarioId,
    TipoTransacao? tipo,
    double? valor,
    DateTime? dataHora,
    String? descricao,
  }) {
    return Transacao(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      destinatarioId: destinatarioId ?? this.destinatarioId,
      tipo: tipo ?? this.tipo,
      valor: valor ?? this.valor,
      dataHora: dataHora ?? this.dataHora,
      descricao: descricao ?? this.descricao,
    );
  }

  @override
  String toString() {
    return 'Transacao(id: $id, usuarioId: $usuarioId, '
        'destinatarioId: $destinatarioId, tipo: $tipo, '
        'valor: $valor, dataHora: $dataHora, descricao: $descricao)';
  }
}
