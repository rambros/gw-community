# AGENTS.md — GW Community

App mobile Flutter (iOS/Android). Firebase: `good-wishes-project`. Backend: Supabase + Firebase.
Stack: MVVM + Provider + go_router.

Padrões detalhados (ler só quando for gerar código): `flutter_standards.md`, `docs/README.md`.

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
