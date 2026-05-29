import 'package:flutter/material.dart';
import 'package:newbank/database/app_database.dart';
import 'package:newbank/models/tipo_conta.dart';
import 'package:newbank/models/usuario.dart';
import 'package:newbank/repositories/usuario_repository.dart';
import 'login_screen.dart';

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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NewBank',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
