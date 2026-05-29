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
import 'package:newbank/services/validators.dart';
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

  // ─── Schema Tests ───

  test('creates usuarios and transacoes tables on first open', () async {
    final db = await appDatabase.database;
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
    );
    final names = tables.map((row) => row['name'] as String).toList();

    expect(names, contains(DatabaseConstants.tableUsuarios));
    expect(names, contains(DatabaseConstants.tableTransacoes));
  });

  // ─── Usuario Tests ───

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

  test('inserts usuario with generated agencia and numero_conta', () async {
    final id = await usuarioRepository.insert(
      _sampleUsuario(),
      plainPassword: 'secret123',
    );

    final usuario = await usuarioRepository.findById(id);
    expect(usuario, isNotNull);
    expect(usuario!.agencia, '0001');
    expect(usuario.numeroConta, isNotEmpty);
    expect(usuario.numeroConta, contains('-'));
  });

  test('rejects duplicate email', () async {
    final usuario = _sampleUsuario();
    await usuarioRepository.insert(usuario, plainPassword: 'secret123');

    expect(
      () => usuarioRepository.insert(usuario, plainPassword: 'other'),
      throwsA(isA<UsuarioDuplicateEmailException>()),
    );
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

  // ─── Transacao Tests ───

  test('deposito increases user saldo', () async {
    final userId = await usuarioRepository.insert(
      _sampleUsuario(saldo: 100),
      plainPassword: 'secret123',
    );

    await transacaoRepository.insert(
      Transacao(
        usuarioId: userId,
        tipo: TipoTransacao.deposito,
        valor: 250,
        dataHora: DateTime.utc(2026, 5, 26, 12),
      ),
    );

    final updated = await usuarioRepository.findById(userId);
    expect(updated!.saldo, 350);
  });

  test('saque decreases user saldo', () async {
    final userId = await usuarioRepository.insert(
      _sampleUsuario(saldo: 500),
      plainPassword: 'secret123',
    );

    await transacaoRepository.insert(
      Transacao(
        usuarioId: userId,
        tipo: TipoTransacao.saque,
        valor: 200,
        dataHora: DateTime.utc(2026, 5, 26, 12),
      ),
    );

    final updated = await usuarioRepository.findById(userId);
    expect(updated!.saldo, 300);
  });

  test('saque rejects when saldo insuficiente', () async {
    final userId = await usuarioRepository.insert(
      _sampleUsuario(saldo: 50),
      plainPassword: 'secret123',
    );

    expect(
      () => transacaoRepository.insert(
        Transacao(
          usuarioId: userId,
          tipo: TipoTransacao.saque,
          valor: 100,
          dataHora: DateTime.utc(2026, 5, 26, 12),
        ),
      ),
      throwsA(isA<SaldoInsuficienteException>()),
    );
  });

  test('transferencia debits sender and credits recipient', () async {
    final senderId = await usuarioRepository.insert(
      _sampleUsuario(saldo: 1000),
      plainPassword: 'secret123',
    );
    final recipientId = await usuarioRepository.insert(
      _sampleUsuario2(saldo: 200),
      plainPassword: 'secret456',
    );

    await transacaoRepository.insert(
      Transacao(
        usuarioId: senderId,
        destinatarioId: recipientId,
        tipo: TipoTransacao.transferencia,
        valor: 300,
        dataHora: DateTime.utc(2026, 5, 26, 14),
        descricao: 'Transferência teste',
      ),
    );

    final sender = await usuarioRepository.findById(senderId);
    final recipient = await usuarioRepository.findById(recipientId);
    expect(sender!.saldo, 700);
    expect(recipient!.saldo, 500);
  });

  test('transferencia rejects without destinatarioId', () async {
    final userId = await usuarioRepository.insert(
      _sampleUsuario(saldo: 1000),
      plainPassword: 'secret123',
    );

    expect(
      () => transacaoRepository.insert(
        Transacao(
          usuarioId: userId,
          tipo: TipoTransacao.transferencia,
          valor: 100,
          dataHora: DateTime.utc(2026, 5, 26, 12),
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('transferencia rejects self-transfer', () async {
    final userId = await usuarioRepository.insert(
      _sampleUsuario(saldo: 1000),
      plainPassword: 'secret123',
    );

    expect(
      () => transacaoRepository.insert(
        Transacao(
          usuarioId: userId,
          destinatarioId: userId,
          tipo: TipoTransacao.transferencia,
          valor: 100,
          dataHora: DateTime.utc(2026, 5, 26, 12),
        ),
      ),
      throwsA(isA<TransacaoAutoTransferenciaException>()),
    );
  });

  test('transferencia rejects when destinatario not found', () async {
    final userId = await usuarioRepository.insert(
      _sampleUsuario(saldo: 1000),
      plainPassword: 'secret123',
    );

    expect(
      () => transacaoRepository.insert(
        Transacao(
          usuarioId: userId,
          destinatarioId: 999,
          tipo: TipoTransacao.transferencia,
          valor: 100,
          dataHora: DateTime.utc(2026, 5, 26, 12),
        ),
      ),
      throwsA(isA<TransacaoDestinatarioNotFoundException>()),
    );
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

  test('findByUsuarioId returns transacoes ordered by data_hora desc',
      () async {
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

  test('deleting usuario cascades transacoes', () async {
    final usuarioId = await usuarioRepository.insert(
      _sampleUsuario(),
      plainPassword: 'secret123',
    );

    await transacaoRepository.insert(
      Transacao(
        usuarioId: usuarioId,
        tipo: TipoTransacao.deposito,
        valor: 100,
        dataHora: DateTime.utc(2026, 5, 26, 10),
      ),
    );

    await usuarioRepository.delete(usuarioId);

    final transacoes = await transacaoRepository.findByUsuarioId(usuarioId);
    expect(transacoes, isEmpty);
  });

  // ─── Resumo Tests ───

  test('calcularResumo returns correct entradas and saidas', () async {
    final userId = await usuarioRepository.insert(
      _sampleUsuario(saldo: 0),
      plainPassword: 'secret123',
    );

    // Two deposits = 300 entradas
    await transacaoRepository.insert(
      Transacao(
        usuarioId: userId,
        tipo: TipoTransacao.deposito,
        valor: 200,
        dataHora: DateTime.utc(2026, 5, 26, 8),
      ),
    );
    await transacaoRepository.insert(
      Transacao(
        usuarioId: userId,
        tipo: TipoTransacao.deposito,
        valor: 100,
        dataHora: DateTime.utc(2026, 5, 26, 9),
      ),
    );
    // One withdrawal = 50 saidas
    await transacaoRepository.insert(
      Transacao(
        usuarioId: userId,
        tipo: TipoTransacao.saque,
        valor: 50,
        dataHora: DateTime.utc(2026, 5, 26, 10),
      ),
    );

    final resumo = await transacaoRepository.calcularResumo(userId);
    expect(resumo['entradas'], 300);
    expect(resumo['saidas'], 50);
  });

  test('calcularResumo counts received transfers as entradas', () async {
    final senderId = await usuarioRepository.insert(
      _sampleUsuario(saldo: 1000),
      plainPassword: 'secret123',
    );
    final recipientId = await usuarioRepository.insert(
      _sampleUsuario2(saldo: 0),
      plainPassword: 'secret456',
    );

    await transacaoRepository.insert(
      Transacao(
        usuarioId: senderId,
        destinatarioId: recipientId,
        tipo: TipoTransacao.transferencia,
        valor: 400,
        dataHora: DateTime.utc(2026, 5, 26, 12),
      ),
    );

    // For recipient: entradas = 400 (received transfer), saidas = 0
    final recipientResumo =
        await transacaoRepository.calcularResumo(recipientId);
    expect(recipientResumo['entradas'], 400);
    expect(recipientResumo['saidas'], 0);

    // For sender: entradas = 0, saidas = 400 (sent transfer)
    final senderResumo = await transacaoRepository.calcularResumo(senderId);
    expect(senderResumo['entradas'], 0);
    expect(senderResumo['saidas'], 400);
  });

  // ─── Validator Tests ───

  group('Validators', () {
    test('email rejects empty', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('email rejects invalid formats', () {
      expect(Validators.email('@'), isNotNull);
      expect(Validators.email('foo@'), isNotNull);
      expect(Validators.email('@bar'), isNotNull);
      expect(Validators.email('no-at-sign'), isNotNull);
      expect(Validators.email('foo@bar'), isNotNull); // no TLD
    });

    test('email accepts valid formats', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('a.b@c.de'), isNull);
      expect(Validators.email('test123@domain.co.uk'), isNull);
    });

    test('senha rejects short passwords', () {
      expect(Validators.senha(null), isNotNull);
      expect(Validators.senha('12345'), isNotNull);
    });

    test('senha accepts valid passwords', () {
      expect(Validators.senha('123456'), isNull);
      expect(Validators.senha('my-secure-pass'), isNull);
    });

    test('nomeCompleto requires first and last name', () {
      expect(Validators.nomeCompleto(null), isNotNull);
      expect(Validators.nomeCompleto(''), isNotNull);
      expect(Validators.nomeCompleto('Maria'), isNotNull);
    });

    test('nomeCompleto accepts full names', () {
      expect(Validators.nomeCompleto('Maria Silva'), isNull);
      expect(Validators.nomeCompleto('João Pedro Santos'), isNull);
    });
  });
}

Usuario _sampleUsuario({double saldo = 1000}) {
  return Usuario(
    email: 'user@example.com',
    senha: '',
    nomeCompleto: 'Maria Silva',
    saldo: saldo,
    tipoConta: TipoConta.corrente,
    dataCriacao: DateTime.utc(2026, 5, 26),
  );
}

Usuario _sampleUsuario2({double saldo = 500}) {
  return Usuario(
    email: 'user2@example.com',
    senha: '',
    nomeCompleto: 'João Santos',
    saldo: saldo,
    tipoConta: TipoConta.poupanca,
    dataCriacao: DateTime.utc(2026, 5, 26),
  );
}
