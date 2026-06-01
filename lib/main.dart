import 'package:flutter/material.dart';
import 'package:newbank/database/app_database.dart';
import 'package:newbank/models/tipo_conta.dart';
import 'package:newbank/models/usuario.dart';
import 'package:newbank/repositories/usuario_repository.dart';
import 'package:newbank/services/secure_storage_service.dart';
import 'package:newbank/biometric_lock_screen.dart';
import 'package:newbank/theme/app_theme.dart';
import 'landing_page.dart';

Future<void> _seedDatabase() async {
  final repo = UsuarioRepository();
  final admin = await repo.findByEmail('admin@banco.com.br');
  if (admin == null) {
    await repo.insert(
      Usuario(
        email: 'admin@banco.com.br',
        senha: '',
        nomeCompleto: 'Administrador Sistema',
        saldo: 1500.0,
        tipoConta: TipoConta.corrente,
        dataCriacao: DateTime.now(),
      ),
      plainPassword: 'admin123',
    );
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
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: initialUserId != null
          ? BiometricLockScreen(userId: initialUserId!)
          : const LandingPage(),
    );
  }
}
