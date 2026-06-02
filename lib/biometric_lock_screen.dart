import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:newbank/models/usuario.dart';
import 'package:newbank/repositories/usuario_repository.dart';
import 'package:newbank/services/secure_storage_service.dart';
import 'package:newbank/home_screen.dart';
import 'package:newbank/landing_page.dart';

class BiometricLockScreen extends StatefulWidget {
  final int userId;
  const BiometricLockScreen({super.key, required this.userId});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> {
  final _localAuth = LocalAuthentication();
  final _secureStorage = SecureStorageService();
  final _usuarioRepository = UsuarioRepository();
  Usuario? _usuario;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    final usuario = await _usuarioRepository.findById(widget.userId);
    if (usuario != null) {
      setState(() => _usuario = usuario);
      _autenticar();
    } else {
      _logout();
    }
  }

  Future<void> _autenticar() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      
      if (!canCheck && !isSupported) {
        // Se o dispositivo não suporta biometria, poderíamos pedir a senha
        // Mas por enquanto, vamos apenas permitir entrar se o usuário existir
        // (Em um app real, pediria PIN/Senha aqui)
        _entrar();
        return;
      }

      final autenticado = await _localAuth.authenticate(
        localizedReason: 'Acesse sua conta NewBank',
      );

      if (autenticado) {
        _entrar();
      }
    } catch (e) {
      debugPrint('Erro na autenticação: $e');
    }
  }

  void _entrar() {
    if (_usuario != null && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(usuario: _usuario!)),
        (route) => false,
      );
    }
  }

  Future<void> _logout() async {
    await _secureStorage.clearLastLoggedUserId();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LandingPage()),
        (route) => false,
      );
    }
  }

  @override
    Widget build(BuildContext context) {
    const verde = Color(0xFF1B7A3E);
    
    return Scaffold(
      backgroundColor: verde,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'N',
                      style: TextStyle(
                        color: verde,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _usuario != null 
                      ? 'Olá, ${_usuario!.nomeCompleto.split(' ').first}' 
                      : 'Bem-vindo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Acesse sua conta com biometria ou senha',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70, 
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 56),
                GestureDetector(
                  onTap: _autenticar,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(
                      Icons.fingerprint, 
                      size: 72, 
                      color: Colors.white
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tocar para autenticar',
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 80),
                TextButton(
                  onPressed: _logout,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Sair / Usar outra conta',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
