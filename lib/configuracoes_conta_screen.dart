import 'package:flutter/material.dart';
import 'package:newbank/models/usuario.dart';
import 'package:newbank/repositories/usuario_repository.dart';
import 'package:newbank/services/secure_storage_service.dart';
import 'package:newbank/landing_page.dart';

class ConfiguracoesContaScreen extends StatelessWidget {
  final Usuario usuario;

  const ConfiguracoesContaScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const Color verde = Color(0xFF1B8C3E);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Configurações da Conta'),
        backgroundColor: verde,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildOption(
            Icons.lock_outline,
            'Alterar Senha',
            isDark,
            onTap: () => _simularAlterarSenha(context),
          ),
          _buildOption(
            Icons.account_balance_outlined,
            'Dados da Agência',
            isDark,
            onTap: () => _exibirDadosAgencia(context),
          ),
          _buildOption(
            Icons.delete_outline,
            'Encerrar Conta',
            isDark,
            isDestructive: true,
            onTap: () => _confirmarEncerramento(context),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Recurso simulado',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _simularAlterarSenha(BuildContext context) {
    final TextEditingController atualController = TextEditingController();
    final TextEditingController novaController = TextEditingController();
    final repo = UsuarioRepository();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Senha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: atualController,
              decoration: const InputDecoration(labelText: 'Senha Atual'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: novaController,
              decoration: const InputDecoration(labelText: 'Nova Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            const Text('Recurso simulado', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final atual = atualController.text;
              final nova = novaController.text;

              if (atual.isEmpty || nova.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preencha todos os campos')),
                );
                return;
              }

              if (nova.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('A nova senha deve ter pelo menos 6 caracteres')),
                );
                return;
              }

              // Verifica se a senha atual está correta
              final isValid = repo.verifyPassword(usuario, atual);
              if (!isValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Senha atual incorreta')),
                );
                return;
              }

              try {
                await repo.updatePassword(usuario.id!, nova);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Senha alterada com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao alterar senha: $e')),
                  );
                }
              }
            },
            child: const Text('Alterar'),
          ),
        ],
      ),
    );
  }

  void _exibirDadosAgencia(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dados da Conta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Agência: ${usuario.agencia}'),
            const SizedBox(height: 8),
            Text('Conta: ${usuario.numeroConta}'),
            const SizedBox(height: 16),
            const Text('Recurso simulado', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
        ],
      ),
    );
  }

  void _confirmarEncerramento(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Encerrar Conta'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tem certeza que deseja encerrar sua conta? Esta ação é irreversível.'),
            SizedBox(height: 16),
            Text('Recurso simulado', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Voltar')),
          ElevatedButton(
            onPressed: () async {
              try {
                final repo = UsuarioRepository();
                await repo.delete(usuario.id!);
                await SecureStorageService().clearLastLoggedUserId();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LandingPage()),
                    (route) => false,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Conta encerrada com sucesso.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao encerrar conta: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Sim, Encerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String label, bool isDark, {bool isDestructive = false, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : (isDark ? Colors.white70 : Colors.black54)),
        title: Text(
          label,
          style: TextStyle(
            color: isDestructive ? Colors.red : (isDark ? Colors.white : Colors.black87),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
