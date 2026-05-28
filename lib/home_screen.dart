import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tela Principal')),
      body: const Center(
        child: Text('Login feito com sucesso! 🎉', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}