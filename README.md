# NewBank - Flutter

Um aplicativo de banco digital moderno, seguro e elegante, desenvolvido com Flutter. O NewBank oferece uma experiência completa de banco digital com foco em segurança, performance e design premium.

## 🚀 Funcionalidades

- **✨ Experiência de Entrada**:
  - **Landing Page**: Tela de boas-vindas com design moderno.
  - **Autenticação Biométrica**: Login rápido e seguro via Digital ou Face ID.
  - **Sistema de Cadastro**: Criação de contas de forma intuitiva.

- **🏦 Operações Bancárias**:
  - **Dashboard Completo**: Visão geral do saldo e movimentações recentes.
  - **Transferências Pix**: Envie dinheiro instantaneamente para outros usuários do app.
  - **Extrato Detalhado**: Histórico completo de transações com filtros por tipo.
  - **Conversor de Moedas**: Cotações em tempo real integradas a APIs externas.

- **🎨 Design & Personalização**:
  - **Modo Escuro AMOLED**: Suporte nativo ao tema escuro com economia de bateria para telas OLED.
  - **Interface Adaptativa**: Se adapta automaticamente às configurações do sistema do usuário.
  - **Menu Lateral (Drawer)**: Acesso rápido às configurações e dados da conta.

## 🛠️ Tecnologias Utilizadas

- **Flutter & Dart**: Framework principal.
- **SQLite (sqflite)**: Banco de dados local para persistência de dados.
- **Flutter Secure Storage**: Armazenamento criptografado de credenciais sensíveis.
- **Local Auth**: Integração com sensores biométricos nativos.
- **HTTP**: Consumo de APIs de câmbio.
- **BCrypt**: Hashing de senhas para segurança de ponta.

## 📦 Instalação e Execução

1. **Pré-requisitos**: Flutter SDK instalado e configurado.
2. **Clonar o repositório**:
   ```bash
   git clone https://github.com/ADav1dUnama/NewBank-Flutter.git
   ```
3. **Instalar dependências**:
   ```bash
   flutter pub get
   ```
4. **Executar o projeto**:
   ```bash
   flutter run
   ```

## 📂 Estrutura do Projeto

```
lib/
├── database/     # Configurações e constantes do SQLite
├── models/       # Modelos de dados (Usuário, Transação, etc.)
├── repositories/ # Camada de acesso a dados e lógica de persistência
├── services/     # Serviços (Segurança, Formatação, Validadores)
└── screens/      # Interfaces de usuário (Screens e Widgets)
```

## 🔒 Segurança

O NewBank leva a segurança a sério:
- Senhas nunca são armazenadas em texto puro (utilizamos BCrypt).
- IDs de sessão são persistidos em armazenamento seguro do sistema.
- Suporte a biometria nativa para evitar acesso não autorizado.
