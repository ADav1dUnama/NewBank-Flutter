import 'package:flutter/material.dart';
import 'package:newbank/database/app_database.dart';
import 'package:newbank/models/tipo_conta.dart';
import 'package:newbank/models/usuario.dart';
import 'package:newbank/repositories/usuario_repository.dart';
import 'package:newbank/theme/app_theme.dart';
import 'package:newbank/services/secure_storage_service.dart';
import 'login_screen.dart';

/// Seeds the database with a demo admin user for development.
/// In production, this should be removed or replaced by a proper
/// onboarding flow.
Future<void> _seedDatabase() async {
  try {
    final repo = UsuarioRepository();
    final admin = await repo.findByEmail('admin@banco.com.br');
    if (admin == null) {
      await repo.insert(
        Usuario(
          email: 'admin@banco.com.br',
          senha: '',
          nomeCompleto: 'Administrador Sistema',
          saldo: 150000, // R$ 1.500,00 em centavos
          tipoConta: TipoConta.corrente,
          dataCriacao: DateTime.now(),
        ),
        plainPassword: const String.fromEnvironment(
          'ADMIN_PASSWORD',
          defaultValue: 'Admin@2026!',
        ),
      );
    }
  } catch (e) {
    debugPrint('Erro ao popular banco de dados: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.database;
  await _seedDatabase();

  final secureStorage = SecureStorageService();
  final lastLoggedUserId = await secureStorage.getLastLoggedUserId();

  runApp(MyApp(initialUserId: lastLoggedUserId));
}

class MyApp extends StatelessWidget {
  final int? initialUserId;
  const MyApp({super.key, this.initialUserId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NewBank',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
