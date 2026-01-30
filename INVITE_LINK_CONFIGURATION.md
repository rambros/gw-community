# Configuração do Link de Convite - App Mobile

## Problema Identificado

O link de convite estava configurado para apontar para
`https://gw.callofthetime.org/invite`, mas essa URL não existe. O convite é para
**novos membros do app mobile**, não para o portal admin.

## Solução Implementada

### 1. Criada Página de Aceitação de Convite no App Mobile

**Arquivos criados:**

- `/lib/ui/auth/invite_accept_page/invite_accept_page.dart`
- `/lib/ui/auth/invite_accept_page/view_model/invite_accept_view_model.dart`

**Rota configurada:**

- Path: `/invite`
- Query parameter: `token`
- Exemplo: `https://[APP_URL]/invite?token=abc-123-xyz`

**Funcionalidades:**

- ✅ Validação do token (verifica se existe, está pendente e não expirou)
- ✅ Formulário para criar senha
- ✅ Validação de senha (mínimo 6 caracteres)
- ✅ Confirmação de senha
- ✅ Chamada à Edge Function `accept-invite`
- ✅ Criação de conta no Supabase Auth
- ✅ Criação de registro em `cc_members`
- ✅ Redirecionamento para login após sucesso

### 2. Rota Adicionada ao Router

**Arquivo:** `/lib/routing/router.dart`

**Mudanças:**

1. Import adicionado: `InviteAcceptPage`
2. Rota adicionada à lista de rotas públicas (não requer login)
3. Route definition criada com suporte a query parameter `token`

### 3. Configuração do Link no Banco de Dados

**IMPORTANTE:** Você precisa atualizar a configuração `email_invite_link` no
banco de dados para apontar para a URL do app mobile.

#### Opções de URL:

**A) Deep Link (Recomendado para produção)**

```sql
UPDATE cc_settings 
SET value = 'gw://invite' 
WHERE setting_key = 'email_invite_link';
```

Isso abrirá o app diretamente se instalado, ou redirecionará para a loja se não
estiver.

**B) Web URL (Para desenvolvimento/teste)**

```sql
-- Se o app tem versão web hospedada
UPDATE cc_settings 
SET value = 'https://[SEU_DOMINIO_WEB]/invite' 
WHERE setting_key = 'email_invite_link';
```

**C) Firebase Dynamic Link (Melhor opção)**

```sql
-- Cria um link que funciona tanto para web quanto mobile
UPDATE cc_settings 
SET value = 'https://gw.page.link/invite' 
WHERE setting_key = 'email_invite_link';
```

### 4. Como Configurar Firebase Dynamic Links (Recomendado)

Firebase Dynamic Links permitem que um único link funcione em:

- Web (abre no navegador)
- iOS (abre o app se instalado, senão vai para App Store)
- Android (abre o app se instalado, senão vai para Play Store)

**Passos:**

1. **Acesse o Firebase Console:**
   - https://console.firebase.google.com
   - Selecione o projeto Good Wishes

2. **Ative Dynamic Links:**
   - Menu lateral → Engage → Dynamic Links
   - Clique em "Get Started"

3. **Configure o domínio:**
   - Use `gw.page.link` (gratuito do Firebase)
   - Ou configure domínio customizado (ex: `link.callofthetime.org`)

4. **Crie o link de convite:**
   - Deep link URL: `https://gw.callofthetime.org/invite?token={token}`
   - iOS: Configure bundle ID e App Store ID
   - Android: Configure package name
   - Web: Configure fallback URL

5. **Atualize o banco:**

```sql
UPDATE cc_settings 
SET value = 'https://gw.page.link/invite' 
WHERE setting_key = 'email_invite_link';
```

### 5. Como Testar

#### Teste Local (Desenvolvimento):

1. **Configure para localhost:**

```sql
UPDATE cc_settings 
SET value = 'http://localhost:8080/invite' 
WHERE setting_key = 'email_invite_link';
```

2. **Rode o app:**

```bash
cd /Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community
flutter run -d chrome
```

3. **Envie um convite** pelo portal admin

4. **Copie o link do email** e cole no navegador

5. **Deve abrir a página de convite** com o formulário de senha

#### Teste em Produção:

1. **Build e deploy do app mobile** (iOS/Android/Web)

2. **Configure a URL correta** no banco de dados

3. **Envie um convite de teste**

4. **Verifique:**
   - Email chega com link correto
   - Link abre a página de convite
   - Formulário funciona
   - Conta é criada
   - Login funciona

### 6. Fluxo Completo Atualizado

```
1. Admin → Envia convite pelo portal
2. Sistema → Gera token e salva no banco
3. Sistema → Envia email com link: https://[APP_URL]/invite?token=xxx
4. Usuário → Clica no link do email
5. App Mobile → Abre página /invite
6. Sistema → Valida token (verifica se existe, está pending, não expirou)
7. Usuário → Vê formulário "Welcome!" e cria senha
8. Usuário → Clica "Create Account"
9. Sistema → Chama Edge Function accept-invite
10. Edge Function → Cria usuário no Supabase Auth
11. Edge Function → Cria registro em cc_members
12. Edge Function → Marca convite como 'used'
13. App → Mostra mensagem de sucesso
14. App → Redireciona para /login
15. Usuário → Faz login com email e senha
16. Usuário → Acessa o app normalmente
```

### 7. Próximos Passos

1. **Definir URL do app mobile em produção**
   - Onde o app será hospedado? (Firebase Hosting, Vercel, etc)
   - Qual será o domínio? (ex: app.callofthetime.org)

2. **Atualizar configuração no banco**
   ```sql
   UPDATE cc_settings 
   SET value = 'https://[URL_DEFINITIVA]/invite' 
   WHERE setting_key = 'email_invite_link';
   ```

3. **Fazer deploy do app mobile**
   - Build para produção
   - Deploy para hosting escolhido
   - Configurar domínio (se necessário)

4. **Testar fluxo completo**
   - Enviar convite real
   - Verificar email
   - Aceitar convite
   - Fazer login
   - Confirmar acesso ao app

### 8. Troubleshooting

**Link não abre o app:**

- Verifique se a URL está correta no banco
- Verifique se o app está deployado
- Verifique se o domínio está configurado

**Token inválido:**

- Verifique se o token existe no banco
- Verifique se o status é 'pending'
- Verifique se não expirou (expires_at > now())

**Erro ao criar conta:**

- Verifique logs da Edge Function accept-invite
- Verifique se o email já existe no sistema
- Verifique permissões do Supabase

**Não redireciona após criar conta:**

- Verifique se a rota /login existe
- Verifique console do navegador para erros
