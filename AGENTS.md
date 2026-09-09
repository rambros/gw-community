# AGENTS.md — GW Community

App mobile Flutter (iOS/Android). Firebase: `good-wishes-project`. Backend: Supabase + Firebase.
Stack: MVVM + Provider + go_router.

Padrões detalhados (ler só quando for gerar código): `flutter_standards.md`, `docs/README.md`.

---

## Repos do produto Good Wishes / COTT

Mudanças podem afetar os dois códigos. Tratar como um produto com duas superfícies:

| Superfície | Repo | Plataforma |
|---|---|---|
| App do participante (este repo) | `/Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community` | Flutter iOS/Android |
| Admin | `/Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/cott-portal-admin` | Flutter Web |

Antes de alterar contrato de dados, rotas, jornadas, membros ou convites: verificar o impacto no outro repo. Não assumir que uma mudança no mobile vale sozinha no admin, nem o contrário.

---

## Estrutura

```
lib/
  ui/              # Views + ViewModels
  domain/          # entidades e use cases
  data/            # repositories e services (API/local)
  config/  routing/  utils/  main.dart
docs/
```

| Tipo | Convenção | Exemplo |
|---|---|---|
| Arquivos | snake_case | `journey_list_page.dart` |
| Páginas | `*Page` | `JourneyListPage` |
| ViewModels | `*ViewModel` | `JourneyListViewModel` |
| Repos | `I*` | `IJourneyRepository` |

---

## MVVM (estilo Compass)

- **UI:** widgets + Provider. Sem lógica de negócio na View.
- **ViewModel:** `ChangeNotifier`, estado da tela, chama repositories.
- **Domain:** modelos puros. **Data:** Supabase/Firebase/HTTP.

Proibido: UI → Repository direto; estado global desnecessário.

Usar `go_router` para navegação. Preferir composição sobre herança. Widgets imutáveis quando possível.

Nova feature: model → `I*Repository` → implementação → ViewModel → Page → rota → doc em `docs/features/` ou `docs/technical/`.
