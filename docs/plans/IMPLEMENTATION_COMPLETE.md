# ✅ Implementação Completa - Deep Links para Convites

## 🎉 O Que Foi Implementado

### ✅ 1. Pacote de Deep Links Adicionado

- **Arquivo:** `pubspec.yaml`
- **Pacote:** `app_links: ^3.4.5`
- **Status:** ✅ Concluído

### ✅ 2. Configuração iOS

- **Arquivo:** `ios/Runner/Info.plist`
- **URL Scheme:** `gw://`
- **Bundle URL Name:** `org.callofthetime.gw`
- **Status:** ✅ Concluído

### ✅ 3. Configuração Android

- **Arquivo:** `android/app/src/main/AndroidManifest.xml`
- **Intent Filter:** Adicionado para scheme `gw://`
- **Status:** ✅ Concluído

### ✅ 4. Listener de Deep Links

- **Arquivo:** `lib/main.dart`
- **Funcionalidade:**
  - Escuta deep links quando app está rodando
  - Processa deep link que abriu o app
  - Navega para `/invite?token=xxx` automaticamente
- **Status:** ✅ Concluído

### ✅ 5. Página de Aceitação de Convite

- **Arquivo:** `lib/ui/auth/invite_accept_page/invite_accept_page.dart`
- **Rota:** `/invite`
- **Status:** ✅ Concluído (criado anteriormente)

### ✅ 6. Rota Configurada

- **Arquivo:** `lib/routing/router.dart`
- **Rota:** `/invite` (pública, não requer login)
- **Status:** ✅ Concluído (criado anteriormente)

### ✅ 7. Landing Page

- **Arquivo:** `web/invite.html`
- **Funcionalidade:**
  - Detecta plataforma (iOS/Android)
  - Tenta abrir app via deep link
  - Mostra botões de download se app não instalado
- **Status:** ✅ Concluído

---

## 📋 Próximos Passos (Para Você)

### **Passo 1: Instalar Dependências** ⏱️ 2 min

```bash
cd /Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community
flutter pub get
```

### **Passo 2: Testar Deep Links Localmente** ⏱️ 5 min

#### iOS (Simulator):

```bash
# Rode o app
flutter run -d "iPhone 15 Pro"

# Em outro terminal, teste o deep link:
xcrun simctl openurl booted "gw://invite?token=test123"
```

#### Android (Emulator):

```bash
# Rode o app
flutter run -d emulator-5554

# Em outro terminal, teste o deep link:
adb shell am start -W -a android.intent.action.VIEW -d "gw://invite?token=test123" org.callofthetime.gw
```

**Resultado esperado:** App abre e navega para a página de convite.

---

### **Passo 3: Hospedar Landing Page** ⏱️ 10 min

#### Opção A: Netlify (Mais Fácil)

1. Acesse [netlify.com](https://netlify.com)
2. Faça login (pode usar GitHub)
3. Clique em "Add new site" → "Deploy manually"
4. Arraste a pasta `web/` do projeto
5. Anote a URL gerada (ex: `https://gw-invite.netlify.app`)

#### Opção B: Firebase Hosting

```bash
# Crie pasta separada para landing page
mkdir ~/gw-invite-landing
cp /Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community/web/invite.html ~/gw-invite-landing/index.html

cd ~/gw-invite-landing

# Inicialize Firebase
firebase init hosting
# Public directory: . (pasta atual)
# Single-page app: No

# Deploy
firebase deploy --only hosting
```

---

### **Passo 4: Atualizar URLs na Landing Page** ⏱️ 5 min

Edite `web/invite.html` (linhas 120-122):

```javascript
// ATUALIZE ESTAS URLs:
const IOS_APP_STORE_URL = "https://apps.apple.com/app/good-wishes/idXXXXXXXXX";
const ANDROID_PLAY_STORE_URL =
    "https://play.google.com/store/apps/details?id=org.callofthetime.gw";
```

**Enquanto não publicou:**

- Use links de TestFlight (iOS)
- Use links de Internal Testing (Android)
- Ou deixe apontando para uma página "Em breve"

Depois de editar, faça deploy novamente.

---

### **Passo 5: Atualizar Banco de Dados** ⏱️ 1 min

```sql
UPDATE cc_settings 
SET value = 'https://[URL_DA_SUA_LANDING_PAGE]' 
WHERE setting_key = 'email_invite_link';
```

**Exemplo:**

```sql
UPDATE cc_settings 
SET value = 'https://gw-invite.netlify.app' 
WHERE setting_key = 'email_invite_link';
```

---

### **Passo 6: Testar Fluxo Completo** ⏱️ 10 min

1. **Envie um convite** pelo portal admin
2. **Verifique o email** recebido
3. **Abra o link no celular** (com app instalado)
4. **Resultado esperado:**
   - Landing page carrega
   - Tenta abrir app automaticamente
   - App abre na página de criar senha
   - Usuário cria senha
   - Conta é criada
   - Redireciona para login

5. **Teste sem app instalado:**
   - Abra link em celular sem app
   - Deve mostrar botões de download

---

## 🧪 Comandos de Teste

### Testar Deep Link Direto

```bash
# iOS
xcrun simctl openurl booted "gw://invite?token=abc123"

# Android
adb shell am start -W -a android.intent.action.VIEW -d "gw://invite?token=abc123" org.callofthetime.gw
```

### Ver Logs do App

```bash
# iOS
flutter logs

# Android
adb logcat | grep "Deep link"
```

### Rebuild do App (se necessário)

```bash
flutter clean
flutter pub get
flutter run
```

---

## 📊 Checklist de Validação

- [ ] `flutter pub get` executado com sucesso
- [ ] Deep link funciona no iOS Simulator
- [ ] Deep link funciona no Android Emulator
- [ ] Landing page hospedada e acessível
- [ ] URLs da App Store/Play Store atualizadas na landing page
- [ ] Link no banco de dados atualizado
- [ ] Email de convite enviado com link correto
- [ ] Link abre landing page no navegador
- [ ] Landing page tenta abrir app
- [ ] App abre na página de convite
- [ ] Formulário de senha funciona
- [ ] Conta é criada com sucesso
- [ ] Login funciona após criar conta

---

## 🎯 URLs Importantes

### Deep Link Scheme

```
gw://invite?token={TOKEN}
```

### Landing Page

```
https://[SUA_URL]/
```

### Rota no App

```
/invite?token={TOKEN}
```

### Email Link (no banco)

```
https://[SUA_URL]/?token={TOKEN}
```

---

## 🆘 Troubleshooting

### Deep link não funciona

**Problema:** App não abre quando clica no link

**Soluções:**

1. Verifique se o scheme `gw://` está configurado no Info.plist (iOS) e
   AndroidManifest.xml (Android)
2. Teste com comando direto (xcrun/adb)
3. Verifique logs do app
4. Rebuild o app: `flutter clean && flutter run`

### Landing page não detecta app

**Problema:** Sempre mostra botões de download

**Solução:** Isso é normal! Navegadores não conseguem detectar apps instalados.
A landing page tenta abrir o app e espera 2 segundos. Se o app não abrir, assume
que não está instalado.

### Erro ao navegar para /invite

**Problema:** App abre mas não vai para página de convite

**Soluções:**

1. Verifique se a rota `/invite` está configurada no router
2. Verifique se `InviteAcceptPage` está importado
3. Verifique logs para ver se o deep link foi recebido

### Token inválido

**Problema:** Página mostra "Invalid invitation"

**Soluções:**

1. Verifique se o token existe no banco (`invitations` table)
2. Verifique se o status é 'pending'
3. Verifique se não expirou (`expires_at > now()`)

---

## 📚 Documentação Adicional

- **Deep Links Setup:** `DEEP_LINKS_SETUP.md`
- **Mobile Invite Setup:** `MOBILE_INVITE_SETUP.md`
- **Deploy Guide:** `DEPLOY_GUIDE.md`
- **Invite Link Configuration:** `INVITE_LINK_CONFIGURATION.md`

---

## 🎉 Resultado Final

Quando tudo estiver funcionando:

```
1. Admin envia convite
   ↓
2. Email chega: "https://gw-invite.netlify.app/?token=abc123"
   ↓
3. Usuário clica no link (celular com app instalado)
   ↓
4. Landing page abre e tenta: "gw://invite?token=abc123"
   ↓
5. App abre automaticamente
   ↓
6. Vai direto para tela de criar senha
   ↓
7. Usuário cria senha
   ↓
8. Conta criada com sucesso
   ↓
9. Redireciona para login
   ↓
10. Usuário faz login
   ↓
11. Acessa o app! 🎉
```

---

**Tempo total estimado:** ~30 minutos

**Dificuldade:** Média

**Próximo passo:** Execute o Passo 1 (`flutter pub get`) e teste! 🚀
