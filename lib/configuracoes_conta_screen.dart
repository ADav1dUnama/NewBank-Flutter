import 'package:flutter/material.dart';
import 'package:newbank/models/usuario.dart';

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
          _buildOption(Icons.notifications_none, 'Notificações', isDark),
          _buildOption(Icons.lock_outline, 'Alterar Senha', isDark),
          _buildOption(Icons.account_balance_outlined, 'Dados da Agência', isDark),
          _buildOption(Icons.delete_outline, 'Encerrar Conta', isDark, isDestructive: true),
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

  Widget _buildOption(IconData icon, String label, bool isDark, {bool isDestructive = false}) {
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
        onTap: () {},
      ),
    );
  }
}
