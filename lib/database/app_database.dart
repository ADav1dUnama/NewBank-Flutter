import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:newbank/database/database_constants.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    return open();
  }

  Future<Database> open({String? path}) async {
    if (_database != null) {
      return _database!;
    }

    final dbPath = path ?? await _defaultPath();
    _database = await openDatabase(
      dbPath,
      version: DatabaseConstants.version,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
    return _database!;
  }

  Future<void> openInMemory() async {
    await close();
    _database = await openDatabase(
      inMemoryDatabasePath,
      version: DatabaseConstants.version,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<String> _defaultPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return join(directory.path, DatabaseConstants.databaseName);
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableUsuarios} (
        ${DatabaseConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colEmail} TEXT NOT NULL UNIQUE,
        ${DatabaseConstants.colSenha} TEXT NOT NULL,
        ${DatabaseConstants.colNomeCompleto} TEXT NOT NULL,
        ${DatabaseConstants.colSaldo} REAL NOT NULL DEFAULT 0,
        ${DatabaseConstants.colTipoConta} TEXT NOT NULL,
        ${DatabaseConstants.colDataCriacao} INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableTransacoes} (
        ${DatabaseConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colUsuarioId} INTEGER NOT NULL,
        ${DatabaseConstants.colTipo} TEXT NOT NULL,
        ${DatabaseConstants.colValor} REAL NOT NULL,
        ${DatabaseConstants.colDataHora} INTEGER NOT NULL,
        ${DatabaseConstants.colDescricao} TEXT,
        FOREIGN KEY (${DatabaseConstants.colUsuarioId})
          REFERENCES ${DatabaseConstants.tableUsuarios}(${DatabaseConstants.colId})
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE UNIQUE INDEX idx_usuarios_email
      ON ${DatabaseConstants.tableUsuarios}(${DatabaseConstants.colEmail})
    ''');

    await db.execute('''
      CREATE INDEX idx_transacoes_usuario_id
      ON ${DatabaseConstants.tableTransacoes}(${DatabaseConstants.colUsuarioId})
    ''');
  }
}
