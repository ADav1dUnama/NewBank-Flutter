import 'package:flutter_test/flutter_test.dart';
import 'package:newbank/database/app_database.dart';
import 'package:newbank/database/database_constants.dart';
import 'package:newbank/models/tipo_conta.dart';
import 'package:newbank/models/tipo_transacao.dart';
import 'package:newbank/models/transacao.dart';
import 'package:newbank/models/usuario.dart';
import 'package:newbank/repositories/transacao_repository.dart';
import 'package:newbank/repositories/usuario_repository.dart';
import 'package:newbank/services/password_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late AppDatabase appDatabase;
  late UsuarioRepository usuarioRepository;
  late TransacaoRepository transacaoRepository;
  const passwordService = PasswordService();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    appDatabase = AppDatabase.instance;
    await appDatabase.openInMemory();
    usuarioRepository = UsuarioRepository(database: appDatabase);
    transacaoRepository = TransacaoRepository(database: appDatabase);
  });

  tearDown(() async {
    await appDatabase.close();
  });

  test('creates usuarios and transacoes tables on first open', () async {
    final db = await appDatabase.database;
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
    );
    final names = tables.map((row) => row['name'] as String).toList();

    expect(names, contains(DatabaseConstants.tableUsuarios));
    expect(names, contains(DatabaseConstants.tableTransacoes));
  });

  test('inserts usuario and reads by id and email', () async {
    final usuario = _sampleUsuario();
    final id = await usuarioRepository.insert(
      usuario,
      plainPassword: 'secret123',
    );

    final byId = await usuarioRepository.findById(id);
    final byEmail = await usuarioRepository.findByEmail(usuario.email);

    expect(byId, isNotNull);
    expect(byEmail, isNotNull);
    expect(byId!.email, usuario.email);
    expect(byEmail!.nomeCompleto, usuario.nomeCompleto);
    expect(byId.senha, isNot('secret123'));
    expect(passwordService.verify('secret123', byId.senha), isTrue);
  });

  test('rejects duplicate email', () async {
    final usuario = _sampleUsuario();
    await usuarioRepository.insert(usuario, plainPassword: 'secret123');

    expect(
      () => usuarioRepository.insert(usuario, plainPassword: 'other'),
      throwsA(isA<UsuarioDuplicateEmailException>()),
    );
  });

  test('inserts transacao linked to usuario', () async {
    final usuarioId = await usuarioRepository.insert(
      _sampleUsuario(),
      plainPassword: 'secret123',
    );

    final transacaoId = await transacaoRepository.insert(
      Transacao(
        usuarioId: usuarioId,
        tipo: TipoTransacao.transferencia,
        valor: 150.0,
        dataHora: DateTime.utc(2026, 5, 26, 12),
        descricao: 'Transferência teste',
      ),
    );

    final saved = await transacaoRepository.findById(transacaoId);
    expect(saved, isNotNull);
    expect(saved!.usuarioId, usuarioId);
    expect(saved.tipo, TipoTransacao.transferencia);
  });

  test('deleting usuario cascades transacoes', () async {
    final usuarioId = await usuarioRepository.insert(
      _sampleUsuario(),
      plainPassword: 'secret123',
    );

    await transacaoRepository.insert(
      Transacao(
        usuarioId: usuarioId,
        tipo: TipoTransacao.consulta,
        valor: 0,
        dataHora: DateTime.utc(2026, 5, 26, 10),
      ),
    );

    await usuarioRepository.delete(usuarioId);

    final transacoes = await transacaoRepository.findByUsuarioId(usuarioId);
    expect(transacoes, isEmpty);
  });

  test('rejects transacao for missing usuario', () async {
    expect(
      () => transacaoRepository.insert(
        Transacao(
          usuarioId: 999,
          tipo: TipoTransacao.saque,
          valor: 50,
          dataHora: DateTime.utc(2026, 5, 26, 11),
        ),
      ),
      throwsA(isA<TransacaoUsuarioNotFoundException>()),
    );
  });

  test('findByUsuarioId returns transacoes ordered by data_hora desc', () async {
    final usuarioId = await usuarioRepository.insert(
      _sampleUsuario(),
      plainPassword: 'secret123',
    );

    await transacaoRepository.insert(
      Transacao(
        usuarioId: usuarioId,
        tipo: TipoTransacao.deposito,
        valor: 100,
        dataHora: DateTime.utc(2026, 5, 26, 8),
      ),
    );
    await transacaoRepository.insert(
      Transacao(
        usuarioId: usuarioId,
        tipo: TipoTransacao.saque,
        valor: 25,
        dataHora: DateTime.utc(2026, 5, 26, 18),
      ),
    );

    final transacoes = await transacaoRepository.findByUsuarioId(usuarioId);
    expect(transacoes.length, 2);
    expect(transacoes.first.tipo, TipoTransacao.saque);
    expect(transacoes.last.tipo, TipoTransacao.deposito);
  });

  test('verifyPassword validates hashed password', () async {
    const plainPassword = 'my-secure-password';
    final id = await usuarioRepository.insert(
      _sampleUsuario(),
      plainPassword: plainPassword,
    );
    final usuario = await usuarioRepository.findById(id);

    expect(usuario, isNotNull);
    expect(usuario!.senha, isNot(plainPassword));
    expect(usuarioRepository.verifyPassword(usuario, plainPassword), isTrue);
    expect(usuarioRepository.verifyPassword(usuario, 'wrong'), isFalse);
  });
}

Usuario _sampleUsuario() {
  return Usuario(
    email: 'user@example.com',
    senha: '',
    nomeCompleto: 'Maria Silva',
    saldo: 1000,
    tipoConta: TipoConta.corrente,
    dataCriacao: DateTime.utc(2026, 5, 26),
  );
}
