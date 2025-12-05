# Configurações da Aplicação

Este diretório contém arquivos de configuração global da aplicação.

## app_config.dart

Arquivo principal de configurações globais.

### Configurações Disponíveis

#### Controle de Datas

- **`enableDateControl`** (bool): Define se o controle de datas está ativo para navegação entre steps
  - `true`: Usuário precisa esperar o tempo definido após iniciar um step para acessar o próximo
  - `false`: Usuário pode acessar qualquer step disponível imediatamente
  - **Padrão**: `true`

- **`daysToWaitBetweenSteps`** (int): Número de dias que o usuário precisa esperar antes de acessar o próximo step
  - Só é usado quando `enableDateControl` é `true`
  - **Padrão**: `1`

#### Outras Configurações

- **`removeDuplicates`** (bool): Define se deve remover duplicatas automaticamente nas listas
  - **Padrão**: `true`

- **`requestTimeout`** (int): Timeout para requisições em segundos
  - **Padrão**: `30`

- **`maxRetries`** (int): Número máximo de tentativas de requisição em caso de falha
  - **Padrão**: `3`

### Como Usar

```dart
import '/config/app_config.dart';

// Verificar se o controle de datas está ativo
if (AppConfig.enableDateControl) {
  // Lógica com controle de datas
}

// Obter número de dias para esperar
final daysToWait = AppConfig.daysToWaitBetweenSteps;
```

### Alterando Configurações

Para alterar as configurações, edite os valores das constantes em `app_config.dart`:

```dart
class AppConfig {
  // Para desabilitar o controle de datas:
  static const bool enableDateControl = false;
  
  // Para alterar o tempo de espera:
  static const int daysToWaitBetweenSteps = 2; // 2 dias
}
```

**Nota**: Após alterar as configurações, é necessário recompilar a aplicação.

