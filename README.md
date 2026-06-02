# NewBank - Flutter

Um aplicativo de banco digital moderno, seguro e elegante, desenvolvido com Flutter. O NewBank oferece uma experiência completa de banco digital com foco em segurança, performance e design premium.

## ✨ Funcionalidades

O NewBank foi projetado para oferecer praticidade e segurança em cada detalhe:

### 🔐 Segurança & Acesso
- **Landing Page**: Apresentação minimalista e moderna para novos usuários.
- **Autenticação Biométrica**: Login rápido e seguro utilizando sensores nativos (Digital ou Face ID).
- **Sistema de Cadastro**: Fluxo intuitivo para criação de novas contas com validações em tempo real.
- **Login Seguro**: Proteção de dados com armazenamento criptografado de sessões.

### 🏦 Operações Financeiras
- **Dashboard Inteligente**: Visão clara do saldo, últimas movimentações e acesso rápido às principais funções.
- **Transferências**: Envio de valores entre contas com confirmação imediata e tela de sucesso.
- **Extrato Detalhado**: Histórico completo de transações (entradas e saídas) com categorização.
- **Cotação em Tempo Real**: Conversor de moedas integrado a APIs externas para consulta de câmbio (USD, EUR, etc.).

### 👤 Perfil & Gestão
- **Meus Dados**: Visualização completa das informações do perfil do usuário.
- **Configurações da Conta**: Gerenciamento de preferências e opções de segurança.
- **Sessão Persistente**: O app lembra o último usuário logado para facilitar o acesso via biometria.

### 🎨 Design & UX
- **Modo Escuro (Dark Mode)**: Suporte nativo ao tema escuro, otimizado para economia de bateria e conforto visual.
- **Interface Adaptativa**: Se ajusta automaticamente às preferências de sistema do usuário.
- **Componentes Customizados**: Widgets padronizados para uma experiência visual consistente e premium.

## 🛠️ Tecnologias Utilizadas

- **Flutter & Dart**: Framework e linguagem de alta performance.
- **SQLite (sqflite)**: Banco de dados local para persistência de dados offline.
- **Flutter Secure Storage**: Armazenamento seguro de chaves e IDs de sessão.
- **Local Auth**: Integração com biometria nativa do Android/iOS.
- **HTTP**: Comunicação com APIs externas para cotações de câmbio.
- **BCrypt**: Hashing de senhas para segurança de nível bancário.

## 📂 Estrutura do Projeto

A organização do código segue padrões de separação de responsabilidades:

```
lib/
├── controllers/  # Lógica de negócio e estado das telas
├── database/     # Configuração e constantes do SQLite
├── models/       # Modelos de dados (Usuário, Transação, etc.)
├── repositories/ # Camada de acesso ao banco de dados
├── services/     # Serviços transversais (Segurança, API, Validadores)
├── theme/        # Definições de cores e temas (Light/Dark)
├── widgets/      # Componentes de UI reutilizáveis
└── *screen.dart  # Interfaces principais do aplicativo (na raiz da lib)
```

## 🚀 Instalação e Execução

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

### 📦 Build de Produção (Split APK)

Para gerar APKs otimizados por arquitetura (reduzindo o tamanho do download):
```bash
flutter build apk --split-per-abi
```

## 🔒 Compromisso com a Segurança

O NewBank implementa as melhores práticas de segurança:
- Senhas nunca são armazenadas em texto simples (uso rigoroso de BCrypt).
- Dados sensíveis são isolados no Secure Storage do dispositivo.
- Bloqueio biométrico obrigatório para acesso a sessões existentes.
