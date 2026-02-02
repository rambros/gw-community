# User Roles - Documentação

## Visão Geral

O sistema de roles foi padronizado usando o enum `UserRole` para garantir
consistência em todo o aplicativo.

## Roles Disponíveis

### 1. ADMIN

- **Valor no banco**: `"ADMIN"`
- **Permissões**:
  - Acesso total ao sistema
  - Editar/deletar qualquer evento, sharing ou notificação
  - Gerenciar grupos
  - Ver todas as opções administrativas

### 2. GROUP_MANAGER

- **Valor no banco**: `"GROUP_MANAGER"`
- **Permissões**:
  - Gerenciar grupos
  - Editar/deletar eventos (mesmo que não seja facilitador)
  - Permissões elevadas para gestão de grupos

### 3. MEMBER

- **Valor no banco**: `"MEMBER"`
- **Permissões**:
  - Permissões padrão de membro
  - Visualizar e participar de conteúdos
  - Sem permissões administrativas

## Armazenamento no Banco

Os roles são armazenados na tabela `cc_members`, coluna `user_role` como um
**array de strings**:

```sql
user_role text[] DEFAULT '{MEMBER}'::text[]
```

Exemplo de dados:

```json
user_role: ["ADMIN", "GROUP_MANAGER"]
user_role: ["GROUP_MANAGER"]
user_role: ["MEMBER"]
```

## Uso no Código

### Import

```dart
import 'package:gw_community/data/models/enums/enums.dart';
```

### Verificar Roles

```dart
// Verificar se tem role específico
final roles = userProfile?.userRole ?? [];

if (roles.hasAdmin) {
  // Usuário é admin
}

if (roles.hasGroupManager) {
  // Usuário é group manager
}

if (roles.hasAdminOrGroupManager) {
  // Usuário é admin OU group manager
}

// Verificar role específico
if (roles.containsRole(UserRole.admin)) {
  // Usuário é admin
}
```

### Converter String para Enum

```dart
// De string para enum
UserRole? role = UserRole.fromString('ADMIN'); // UserRole.admin
UserRole? role2 = UserRole.fromString('GROUP_MANAGER'); // UserRole.groupManager
UserRole? role3 = UserRole.fromString('Group Manager'); // UserRole.groupManager (também funciona)

// Obter valor do banco
String dbValue = UserRole.admin.value; // "ADMIN"
String dbValue2 = UserRole.groupManager.value; // "GROUP_MANAGER"
```

### Exibir Roles na UI

```dart
// Display name (com espaços)
String display = UserRole.groupManager.displayName; // "GROUP MANAGER"
String display2 = UserRole.admin.displayName; // "ADMIN"

// Title case (primeira letra maiúscula)
String title = UserRole.groupManager.titleCase; // "Group Manager"
String title2 = UserRole.admin.titleCase; // "Admin"
```

### Converter Lista de Strings

```dart
List<String> rolesFromDb = ["ADMIN", "GROUP_MANAGER"];

// Converter para enums (filtra valores inválidos)
List<UserRole> userRoles = rolesFromDb.asUserRoles;
// [UserRole.admin, UserRole.groupManager]
```

## Métodos Helper Disponíveis

### No Enum UserRole:

- `UserRole.fromString(String?)` - Converte string para enum
- `UserRole.hasRole(List<String>?, UserRole)` - Verifica se lista contém role
- `UserRole.isAdmin(List<String>?)` - Verifica se tem ADMIN
- `UserRole.isGroupManager(List<String>?)` - Verifica se tem GROUP_MANAGER
- `UserRole.isAdminOrGroupManager(List<String>?)` - Verifica se tem ADMIN OU
  GROUP_MANAGER
- `.value` - Retorna valor do banco
- `.displayName` - Retorna nome para exibição (com espaços)
- `.titleCase` - Retorna nome em title case

### Extension para List<String>:

- `.containsRole(UserRole)` - Verifica se lista contém role específico
- `.hasAdmin` - Getter que verifica se tem ADMIN
- `.hasGroupManager` - Getter que verifica se tem GROUP_MANAGER
- `.hasAdminOrGroupManager` - Getter que verifica se tem ADMIN ou GROUP_MANAGER
- `.asUserRoles` - Converte lista de strings em lista de UserRole

## Exemplos de Uso Comuns

### 1. Verificar Permissões de Edição

```dart
bool canEdit(List<String> roles, String ownerId) {
  return roles.hasAdminOrGroupManager || currentUserId == ownerId;
}
```

### 2. Buscar Usuários por Role

```dart
// No repository
Future<List<CcMembersRow>> getGroupManagers() async {
  return await CcMembersTable().queryRows(
    queryFn: (q) => q.containsOrNull('user_role', [UserRole.groupManager.value]),
  );
}
```

### 3. Exibir Role na UI

```dart
Widget buildRoleBadge(List<String> roles) {
  UserRole? primaryRole;
  if (roles.hasAdmin) {
    primaryRole = UserRole.admin;
  } else if (roles.hasGroupManager) {
    primaryRole = UserRole.groupManager;
  }

  if (primaryRole == null) return SizedBox.shrink();

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: theme.primary.withOpacity(0.15),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      primaryRole.displayName, // "GROUP MANAGER" ou "ADMIN"
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
    ),
  );
}
```

## Migração de Código Antigo

### Antes:

```dart
// ❌ String hardcoded
if (userRole.toLowerCase() == 'admin' || 
    userRole.toLowerCase().replaceAll('_', ' ') == 'group manager') {
  // ...
}
```

### Depois:

```dart
// ✅ Usando enum
if (roles.hasAdminOrGroupManager) {
  // ...
}
```

## Arquivos Atualizados

- ✅ `lib/data/models/enums/user_role.dart` - Enum criado
- ✅ `lib/data/models/enums/enums.dart` - Export adicionado
- ✅ `lib/ui/profile/user_profile_page/user_profile_page.dart` - Usando enum
- ✅ `lib/data/repositories/group_repository.dart` - Usando enum
- ✅
  `lib/ui/community/event_details_page/view_model/event_details_view_model.dart` -
  Usando enum
- ✅ `lib/ui/community/community_page/widgets/sharing_card_widget.dart` - Usando
  enum
- ✅
  `lib/ui/community/notification_view_page/view_model/notification_view_view_model.dart` -
  Usando enum
- ✅
  `lib/ui/community/sharing_view_page/view_model/sharing_view_view_model.dart` -
  Usando enum
- ✅ `lib/ui/community/widgets/group_card.dart` - Usando enum

## Notas Importantes

1. **Case Insensitive**: O `fromString()` aceita qualquer formato:
   - "ADMIN", "admin", "Admin" → `UserRole.admin`
   - "GROUP_MANAGER", "group_manager", "Group Manager" → `UserRole.groupManager`

2. **Compatibilidade**: O código continua funcionando com dados antigos no
   formato "Group Manager" (com espaço)

3. **Null Safety**: Todos os métodos tratam null e retornam valores seguros

4. **Performance**: Extensions são inline, sem overhead de performance
