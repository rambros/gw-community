
# Recomendações de desenvolvimento – Arquitetura estilo Compass (Flutter)

> Estas instruções são para o ChatGPT seguir sempre que estiver gerando código ou sugerindo estrutura para este app Flutter, com base no **Architecture case study – Compass app** da documentação oficial do Flutter.

---

1. Tech & Architecture Assumptions

- **Flutter:** Latest stable channel
- **Language:** Dart with sound null safety
- **Architecture style:** Clean-ish, feature-first
- **Layers:**
  - Presentation (widgets, controllers)
  - Domain (use cases, entities)
  - Data (repositories, data sources, models)

Recommended libraries:
- Routing: `go_router`
- State management: `provider` (or equivalent)
- Networking: `dio`
- Local storage: `shared_preferences` or `hive`

1. Arquitetura geral

- Use o padrão **MVVM** conforme o estudo de caso Compass:
  - **UI layer**: `View` (widgets) + `ViewModel` (ChangeNotifier/Listenable).
  - **Domain layer**: modelos de domínio (tipos de dados usados em toda a app).
  - **Data layer**: `repositories` + `services` + `model` (API models).

- Mantenha **separação clara de responsabilidades**:
  - UI **não** acessa serviços diretamente.
  - UI fala com ViewModel; ViewModel fala com Repositories.
  - Repositories falam com Services (HTTP, local storage etc.).

- Prefira **fluxo de dados unidirecional**:
  - Dados: `Service → Repository → ViewModel → UI`.
  - Eventos do usuário: `UI → ViewModel → Repository/Service`.

---

2. Estrutura de pastas

```text
lib/
  ui/
    core/
      ui/
      themes/
    <feature>/
      view_model/
      widgets/
  domain/
    models/
  data/
    repositories/
    services/
    model/
  config/
  utils/
  routing/
  main.dart
  main_staging.dart
  main_development.dart
```

---

3. UI (View + ViewModel + Commands)

### Views
- Widgets simples, sem lógica de negócio.
- Obtêm estado do ViewModel via Provider.

### ViewModels
- Usar ChangeNotifier.
- Responsáveis por estado e chamadas aos Repositories.
- Ações encapsuladas em Commands.

---

4. Camada de Dados

### Repositories
- Fonte de verdade da aplicação.
- Expor métodos de alto nível.

### Services
- Encapsular infraestrutura (HTTP, banco local).

### API Models
- DTOs com conversão JSON.

### Domain Models
- Entidades puras, independentes de API.

---

5. Dependency Injection

- Usar Provider para DI.
- Registrar primeiro Services, depois Repositories, depois ViewModels.

---

6. Gerência de Estado

- ChangeNotifier + Provider como padrão.
- UI consome estado via Consumer / watch().

---

7. Navegação

- Router centralizado em `routing/`.
- Preferir GoRouter ou API moderna de Router.

---

8. Testes

```
test/
  data/
  domain/
  ui/
  utils/
testing/
  fakes/
  models/
```

- Testar Repositories, ViewModels e widgets principais.

---

9. Convenções de código

- Seguir Dart Style Guide.
- Nomear arquivos consistentemente:
  - `home_view_model.dart`, `trips_repository.dart` etc.
- Dividir widgets grandes em subwidgets.
| Type | Rule | Example |
|------|------|---------|
| Files | snake_case | `login_page.dart` |
| Classes | PascalCase | `LoginController` |
| Variables/methods | camelCase | `isLoading` |
| Page widgets | end in `Page` | `HomePage` |
| DTO models | end in `Model` | `UserModel` |
| Domain entities | end in `Entity` | `UserEntity` |
| Repository interfaces | end in `Repository` | `AuthRepository` |

---

10. Instruções para voce ao gerar código

Sempre:
1. Informar o caminho correto do arquivo.
2. Manter camadas separadas.
3. Usar ChangeNotifier + Provider.
4. Criar Domain Models separados de API Models.
5. Seguir layout de pastas estilo Compass.
6. Se possível, gerar exemplos de testes.

---


11. Theming & UI Standards

- All theme assets in `ui/core/theme/`
- Never hard-code colours or text styles in widgets
- Use shared UI components where possible
- Use spacing/constants from core rather than magic numbers
- Widgets should remain focused and lightweight

---

This `flutter_standards.md` must be kept up-to-date and followed for all new Flutter applications and features.


