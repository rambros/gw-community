# Guia de Refatoração de Páginas Flutter → Arquitetura MVVM (Compass Style)

Este documento serve como roteiro para refatorar páginas Flutter existentes para seguir os padrões de arquitetura MVVM estilo Compass definidos em `flutter_standards.md`.

---

## 📋 Checklist de Refatoração

Use este checklist para cada página que você refatorar:

### 1️⃣ Análise Inicial

- [ ] Identificar todas as chamadas diretas a serviços/banco de dados
- [ ] Listar toda a lógica de negócio presente no widget
- [ ] Identificar estados gerenciados (loading, error, data)
- [ ] Mapear ações do usuário (botões, formulários, etc.)
- [ ] Identificar widgets complexos que podem ser extraídos
- [ ] Verificar dependências externas (FFAppState, currentUserUid, etc.)

### 2️⃣ Planejamento

- [ ] Decidir nome do feature (ex: `sharing_view`, `user_profile`)
- [ ] Definir estrutura de pastas seguindo padrão
- [ ] Listar métodos necessários no Repository
- [ ] Listar estados necessários no ViewModel
- [ ] Listar Commands (ações) necessários no ViewModel
- [ ] Planejar extração de widgets

### 3️⃣ Implementação - Data Layer

- [ ] Criar Repository em `lib/data/repositories/`
- [ ] Implementar métodos de acesso a dados
- [ ] (Opcional) Criar Domain Models em `lib/domain/models/`
- [ ] Testar Repository isoladamente

### 4️⃣ Implementação - UI Layer

- [ ] Criar pasta do feature em `lib/ui/<feature_area>/<feature_name>/`
- [ ] Criar ViewModel em `lib/ui/<feature_area>/<feature_name>/view_model/`
- [ ] Implementar estados no ViewModel
- [ ] Implementar Commands no ViewModel
- [ ] Criar pasta `widgets/` para componentes extraídos
- [ ] Extrair widgets complexos
- [ ] **MOVER** widget principal de `lib/pages/` para `lib/ui/<feature_area>/<feature_name>/`
- [ ] Refatorar widget principal para usar ViewModel
- [ ] **DELETAR** arquivo `<feature>_model.dart` (FlutterFlow Model antigo)
- [ ] Atualizar imports em arquivos que referenciam o widget

### 5️⃣ Dependency Injection

- [ ] Registrar Repository no Provider (main.dart)
- [ ] Registrar ViewModel no Provider (main.dart)
- [ ] Verificar ordem de dependências

### 6️⃣ Verificação

- [ ] Testar todos os fluxos principais
- [ ] Verificar estados de loading e erro
- [ ] Validar permissões e autorizações
- [ ] Verificar navegação
- [ ] Code review seguindo Dart Style Guide

---

## 🏗️ Estrutura de Pastas

### Antes (FlutterFlow style)
```
lib/
  pages/
    <feature>/
      <feature>_widget.dart      ← Widget principal aqui
      <feature>_model.dart
```

### Depois (Compass style)
```
lib/
  ui/
    <feature_area>/          # ex: community, profile, learn
      <feature_page>/        # ex: sharing_edit_page, user_profile_page (nome do arquivo sem _page.dart)
        <feature_page>_page.dart  ← Widget principal MOVIDO para cá
        view_model/
          <feature>_view_model.dart
        widgets/
          <component>_widget.dart
          <component>_widget.dart
  
  data/
    repositories/
      <feature>_repository.dart
    services/
      <feature>_service.dart  # se necessário
    model/
      <feature>_model.dart    # API DTOs
  
  domain/
    models/
      <feature>_entity.dart   # Domain models (opcional)
```

> [!IMPORTANT]
> **Convenção de Nomenclatura de Diretórios**
> 
> O diretório deve ter o mesmo nome do arquivo da página, **com** o sufixo `_page`:
> - ✅ `lib/ui/community/sharing_edit_page/sharing_edit_page.dart`
> - ❌ `lib/ui/community/sharing_edit/sharing_edit_page.dart`
> 
> **Exemplos:**
> - Arquivo: `sharing_edit_page.dart` → Diretório: `sharing_edit_page/`
> - Arquivo: `user_profile_page.dart` → Diretório: `user_profile_page/`
> - Arquivo: `event_details_page.dart` → Diretório: `event_details_page/`

> [!IMPORTANT]
> **Remoção de FlutterFlow Models**
> 
> Durante a refatoração, você encontrará arquivos `<feature>_model.dart` que estendem `FlutterFlowModel`. Estes devem ser **deletados** e substituídos pelo ViewModel:
> 
> **Antes (FlutterFlow):**
> ```dart
> class MyPageModel extends FlutterFlowModel<MyPageWidget> {
>   // State fields
>   Completer<List<SomeRow>>? requestCompleter;
>   
>   @override
>   void initState(BuildContext context) { }
> }
> ```
> 
> **Depois (MVVM):**
> ```dart
> class MyPageViewModel extends ChangeNotifier {
>   bool _isLoading = false;
>   bool get isLoading => _isLoading;
>   
>   Future<void> loadData() async {
>     _setLoading(true);
>     // ...
>     notifyListeners();
>   }
> }
> ```

---

## 📝 Template: Repository

```dart
// lib/data/repositories/<feature>_repository.dart

import '/backend/supabase/supabase.dart';

class <Feature>Repository {
  // Exemplo: buscar dados
  Future<List<SomeRow>> getData() async {
    return await SomeTable().queryRows(
      queryFn: (q) => q.order('created_at'),
    );
  }

  // Exemplo: buscar por ID
  Future<SomeRow?> getById(int id) async {
    final result = await SomeTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('id', id),
    );
    return result;
  }

  // Exemplo: criar
  Future<void> create(Map<String, dynamic> data) async {
    await SomeTable().insert(data);
  }

  // Exemplo: atualizar
  Future<void> update(int id, Map<String, dynamic> data) async {
    await SomeTable().update(
      data: data,
      matchingRows: (rows) => rows.eqOrNull('id', id),
    );
  }

  // Exemplo: deletar
  Future<void> delete(int id) async {
    await SomeTable().delete(
      matchingRows: (rows) => rows.eqOrNull('id', id),
    );
  }

  // Exemplo: stream
  Stream<List<SomeRow>> getDataStream() {
    return SupaFlow.client
        .from("table_name")
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((list) => list.map((item) => SomeRow(item)).toList());
  }
}
```

---

## 📝 Template: ViewModel

```dart
// lib/ui/<feature_area>/<feature>/view_model/<feature>_view_model.dart

import 'package:flutter/material.dart';
import '/data/repositories/<feature>_repository.dart';
import '/backend/supabase/supabase.dart';

class <Feature>ViewModel extends ChangeNotifier {
  final <Feature>Repository _repository;
  final String currentUserUid;

  <Feature>ViewModel({
    required <Feature>Repository repository,
    required this.currentUserUid,
  }) : _repository = repository {
    _init();
  }

  // ========== STATE ==========
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<SomeRow> _items = [];
  List<SomeRow> get items => _items;

  SomeRow? _currentItem;
  SomeRow? get currentItem => _currentItem;

  // ========== INITIALIZATION ==========

  void _init() {
    // Inicialização se necessário
  }

  // ========== COMMANDS (User Actions) ==========

  /// Carrega dados iniciais
  Future<void> loadData() async {
    _setLoading(true);
    _clearError();

    try {
      _items = await _repository.getData();
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar dados: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega item por ID
  Future<void> loadItemById(int id) async {
    _setLoading(true);
    _clearError();

    try {
      _currentItem = await _repository.getById(id);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar item: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Deleta item com confirmação
  Future<void> deleteItemCommand(BuildContext context, int id) async {
    try {
      await _repository.delete(id);
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
      
      // Navegar de volta ou mostrar mensagem
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _setError('Erro ao deletar: $e');
    }
  }

  /// Atualiza item
  Future<void> updateItemCommand(int id, Map<String, dynamic> data) async {
    try {
      await _repository.update(id, data);
      await loadItemById(id); // Recarregar
    } catch (e) {
      _setError('Erro ao atualizar: $e');
    }
  }

  // ========== VALIDATIONS ==========

  /// Verifica se usuário pode editar
  bool canEdit(String itemUserId) {
    return itemUserId == currentUserUid || _isAdmin();
  }

  /// Verifica se usuário pode deletar
  bool canDelete(String itemUserId) {
    return itemUserId == currentUserUid || _isAdmin();
  }

  bool _isAdmin() {
    // Implementar verificação de admin
    return false;
  }

  // ========== HELPER METHODS ==========

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    // Cleanup se necessário
    super.dispose();
  }
}
```

---

## 📝 Template: Widget Principal (Page)

```dart
// lib/ui/<feature_area>/<feature>/<feature>_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import 'view_model/<feature>_view_model.dart';
import 'widgets/<component>_widget.dart';

class <Feature>Page extends StatefulWidget {
  const <Feature>Page({
    super.key,
    required this.itemId,
  });

  final int itemId;

  static String routeName = '<feature>Page';
  static String routePath = '/<feature>Page';

  @override
  State<<Feature>Page> createState() => _<Feature>PageState();
}

class _<Feature>PageState extends State<<Feature>Page> {
  @override
  void initState() {
    super.initState();
    
    // Carregar dados após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<<Feature>ViewModel>().loadItemById(widget.itemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<<Feature>ViewModel>();

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: _buildAppBar(context),
      body: _buildBody(context, viewModel),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: FlutterFlowTheme.of(context).primary,
      automaticallyImplyLeading: false,
      leading: FlutterFlowIconButton(
        borderRadius: 30.0,
        buttonSize: 60.0,
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 30.0,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Title',
        style: FlutterFlowTheme.of(context).titleLarge,
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(BuildContext context, <Feature>ViewModel viewModel) {
    // Loading state
    if (viewModel.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: FlutterFlowTheme.of(context).primary,
        ),
      );
    }

    // Error state
    if (viewModel.errorMessage != null) {
      return Center(
        child: Text(
          viewModel.errorMessage!,
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
      );
    }

    // Empty state
    if (viewModel.currentItem == null) {
      return Center(
        child: Text(
          'Item não encontrado',
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
      );
    }

    // Success state
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            <Component>Widget(item: viewModel.currentItem!),
            // Mais widgets...
          ],
        ),
      ),
    );
  }
}
```

---

## 📝 Template: Widget Extraído

```dart
// lib/ui/<feature_area>/<feature>/widgets/<component>_widget.dart

import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/supabase/supabase.dart';

class <Component>Widget extends StatelessWidget {
  const <Component>Widget({
    super.key,
    required this.item,
    this.onAction,
  });

  final SomeRow item;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: FlutterFlowTheme.of(context).primaryBackground,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title ?? '',
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              item.description ?? '',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
            if (onAction != null)
              ElevatedButton(
                onPressed: onAction,
                child: const Text('Action'),
              ),
          ],
        ),
      ),
    );
  }
}
```

---

## 📝 Template: Dependency Injection (main.dart)

```dart
// lib/main.dart

import 'package:provider/provider.dart';
import '/data/repositories/<feature>_repository.dart';
import '/ui/<feature_area>/<feature>/view_model/<feature>_view_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // ========== REPOSITORIES ==========
        Provider(create: (_) => <Feature>Repository()),
        
        // ========== VIEW MODELS ==========
        ChangeNotifierProvider(
          create: (context) => <Feature>ViewModel(
            repository: context.read<<Feature>Repository>(),
            currentUserUid: currentUserUid, // ou FFAppState().loginUser.uid
          ),
        ),
        
        // Outros providers...
      ],
      child: MyApp(),
    ),
  );
}
```

---

## 🎯 Padrões e Boas Práticas

### ✅ DO (Faça)

1. **Separação de Responsabilidades**
   - UI apenas renderiza e captura eventos
   - ViewModel gerencia estado e lógica de negócio
   - Repository acessa dados

2. **Nomenclatura Consistente**
   - Arquivos: `snake_case`
   - Classes: `PascalCase`
   - Variáveis/métodos: `camelCase`
   - Pages: terminam com `Page` (ex: `SharingEditPage`, não `SharingEditPageWidget`)
   - ViewModels: terminam com `ViewModel`
   - Repositories: terminam com `Repository`

3. **Estado no ViewModel**
   - Use `notifyListeners()` após mudanças de estado
   - Exponha getters para estado (não variáveis públicas)
   - Mantenha estado privado (`_variableName`)

4. **Commands**
   - Nomeie ações do usuário com sufixo `Command`
   - Ex: `deleteItemCommand`, `saveFormCommand`

5. **Validações**
   - Coloque validações no ViewModel
   - Ex: `canEdit()`, `canDelete()`, `isFormValid()`

6. **Tratamento de Erros**
   - Use try-catch em todos os Commands
   - Exponha `errorMessage` no estado
   - Mostre feedback ao usuário

7. **Loading States**
   - Sempre tenha um estado `isLoading`
   - Mostre indicador visual durante operações assíncronas

### ❌ DON'T (Não Faça)

1. **Não acesse serviços diretamente do Widget**
   ```dart
   // ❌ ERRADO
   await CcSharingsTable().delete(...);
   
   // ✅ CORRETO
   await viewModel.deleteSharingCommand(id);
   ```

2. **Não coloque lógica de negócio no Widget**
   ```dart
   // ❌ ERRADO
   if (item.userId == currentUserUid || isAdmin) { ... }
   
   // ✅ CORRETO
   if (viewModel.canDelete(item.userId)) { ... }
   ```

3. **Não use hard-coded colors/styles**
   ```dart
   // ❌ ERRADO
   color: Colors.blue
   
   // ✅ CORRETO
   color: FlutterFlowTheme.of(context).primary
   ```

4. **Não crie widgets gigantes**
   - Extraia em componentes menores
   - Máximo ~300 linhas por widget

5. **Não misture concerns**
   - Repository não deve ter lógica de UI
   - ViewModel não deve ter lógica de renderização
   - Widget não deve ter lógica de dados

---

## 🔄 Fluxo de Dados

```
┌─────────────────────────────────────────────────────┐
│                      USER                           │
└──────────────────────┬──────────────────────────────┘
                       │ Interaction (tap, input)
                       ↓
┌─────────────────────────────────────────────────────┐
│                   WIDGET (UI)                       │
│  - Renderiza estado                                 │
│  - Captura eventos                                  │
│  - context.watch<ViewModel>()                       │
└──────────────────────┬──────────────────────────────┘
                       │ Calls Command
                       ↓
┌─────────────────────────────────────────────────────┐
│                  VIEW MODEL                         │
│  - Gerencia estado                                  │
│  - Lógica de negócio                                │
│  - Validações                                       │
│  - notifyListeners()                                │
└──────────────────────┬──────────────────────────────┘
                       │ Calls Repository
                       ↓
┌─────────────────────────────────────────────────────┐
│                  REPOSITORY                         │
│  - Acessa dados                                     │
│  - Transforma dados                                 │
│  - Cache (opcional)                                 │
└──────────────────────┬──────────────────────────────┘
                       │ Calls Service/API
                       ↓
┌─────────────────────────────────────────────────────┐
│              SERVICE / SUPABASE                     │
│  - HTTP requests                                    │
│  - Database queries                                 │
│  - External APIs                                    │
└─────────────────────────────────────────────────────┘
```

---

## 📚 Exemplo Completo: Refatoração de Sharing View

Ver `implementation_plan.md` para um exemplo completo e detalhado de refatoração de páginas seguindo o padrão MVVM.

---

## 🧪 Testing

### Repository Tests

```dart
// test/data/repositories/<feature>_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gw_community/data/repositories/<feature>_repository.dart';

void main() {
  group('<Feature>Repository', () {
    late <Feature>Repository repository;

    setUp(() {
      repository = <Feature>Repository();
    });

    test('getData returns list of items', () async {
      final result = await repository.getData();
      expect(result, isA<List>());
    });

    // Mais testes...
  });
}
```

### ViewModel Tests

```dart
// test/ui/<feature_area>/<feature>/<feature>_view_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gw_community/ui/<feature>/<feature>_view_model.dart';

void main() {
  group('<Feature>ViewModel', () {
    late <Feature>ViewModel viewModel;
    late Mock<Feature>Repository mockRepository;

    setUp(() {
      mockRepository = Mock<Feature>Repository();
      viewModel = <Feature>ViewModel(
        repository: mockRepository,
        currentUserUid: 'test-uid',
      );
    });

    test('loadData sets loading state', () async {
      expect(viewModel.isLoading, false);
      
      final future = viewModel.loadData();
      expect(viewModel.isLoading, true);
      
      await future;
      expect(viewModel.isLoading, false);
    });

    // Mais testes...
  });
}
```

---

## 📖 Referências

- [Flutter Architecture Case Study - Compass App](https://docs.flutter.dev/app-architecture/case-study)
- [Provider Package](https://pub.dev/packages/provider)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- `flutter_standards.md` - Padrões do projeto

---

**Última atualização:** 2025-11-19
