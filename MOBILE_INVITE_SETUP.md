# Guia Completo - Link de Convite para App Mobile

## 🎯 Solução: Landing Page + Deep Links

Esta solução funciona assim:

1. Link do email aponta para landing page web
2. Landing page tenta abrir o app nativo
3. Se app não instalado, mostra botões para baixar

---

## 📋 Configuração Completa

### **Passo 1: Configure Deep Links no App**

#### iOS (Xcode)

1. **Abra o projeto iOS:**

```bash
open /Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community/ios/Runner.xcworkspace
```

2. **Edite `Info.plist`:**

Adicione em `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>org.callofthetime.gw</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>gw</string>
    </array>
  </dict>
</array>
```

#### Android (Android Studio)

1. **Edite `AndroidManifest.xml`:**

Em `android/app/src/main/AndroidManifest.xml`, dentro da tag `<activity>`:

```xml
<!-- Deep Link -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="gw" />
</intent-filter>
```

---

### **Passo 2: Adicione Pacote de Deep Links**

1. **Adicione ao `pubspec.yaml`:**

```yaml
dependencies:
    app_links: ^3.4.5
```

2. **Instale:**

```bash
cd /Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community
flutter pub get
```

---

### **Passo 3: Configure o Listener no App**

Edite `lib/main.dart`:

```dart
import 'package:app_links/app_links.dart';
import 'dart:async';

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // Handle deep link when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      print('Deep link error: $err');
    });

    // Handle deep link that opened the app
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      print('Failed to get initial link: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    print('Deep link received: $uri');
    
    // Check if it's an invite link
    if (uri.scheme == 'gw' && uri.host == 'invite') {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        // Navigate to invite accept page
        // Use your router to navigate
        // Example with GoRouter:
        GoRouter.of(context).go('/invite?token=$token');
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  // ... rest of your code
}
```

---

### **Passo 4: Hospede a Landing Page**

#### Opção A: Firebase Hosting (Recomendado)

1. **Crie projeto Firebase Hosting separado:**

```bash
# Crie uma pasta para a landing page
mkdir -p ~/invite-landing
cd ~/invite-landing

# Copie a landing page
cp /Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community/web/invite.html index.html

# Inicialize Firebase
firebase init hosting
# Public directory: . (pasta atual)
# Single-page app: No
```

2. **Deploy:**

```bash
firebase deploy --only hosting
```

Você receberá uma URL como: `https://gw-invite.web.app`

#### Opção B: GitHub Pages (Grátis)

1. Crie repositório no GitHub
2. Faça upload do `invite.html` como `index.html`
3. Ative GitHub Pages nas configurações
4. URL será: `https://[seu-usuario].github.io/[repo-name]`

#### Opção C: Netlify (Grátis)

1. Acesse [netlify.com](https://netlify.com)
2. Arraste a pasta com `invite.html`
3. Pronto! URL gerada automaticamente

---

### **Passo 5: Atualize URLs na Landing Page**

Edite `invite.html` e atualize estas linhas:

```javascript
// ATUALIZE ESTAS URLs:
const IOS_APP_STORE_URL = "https://apps.apple.com/app/good-wishes/idXXXXXXXXX";
const ANDROID_PLAY_STORE_URL =
    "https://play.google.com/store/apps/details?id=org.callofthetime.gw";
```

**Como obter as URLs:**

**iOS:**

- Publique o app na App Store
- URL será: `https://apps.apple.com/app/[nome-do-app]/id[APP_ID]`

**Android:**

- Publique o app na Play Store
- URL será: `https://play.google.com/store/apps/details?id=[PACKAGE_NAME]`

**Enquanto não publicou:**

- Use links de TestFlight (iOS) ou Internal Testing (Android)
- Ou deixe os botões levarem para uma página "Em breve"

---

### **Passo 6: Configure o Link no Banco de Dados**

```sql
UPDATE cc_settings 
SET value = 'https://gw-invite.web.app' 
WHERE setting_key = 'email_invite_link';
```

**Nota:** A landing page automaticamente adiciona `?token=xxx` ao deep link.

---

## 🧪 Como Testar

### **Teste 1: App Instalado**

1. Instale o app no celular (via Xcode/Android Studio)
2. Envie um convite de teste
3. Abra o link do email no celular
4. **Resultado esperado:** App abre direto na tela de criar senha

### **Teste 2: App NÃO Instalado**

1. Use um celular sem o app
2. Abra o link do email
3. **Resultado esperado:** Página mostra botões para baixar

### **Teste 3: Deep Link Direto**

```bash
# iOS Simulator
xcrun simctl openurl booted "gw://invite?token=test123"

# Android Emulator
adb shell am start -W -a android.intent.action.VIEW -d "gw://invite?token=test123" org.callofthetime.gw
```

---

## 📱 Fluxo Completo Final

```
1. Admin envia convite
   ↓
2. Email chega: "https://gw-invite.web.app/?token=abc123"
   ↓
3. Usuário clica no link
   ↓
4. Landing page carrega
   ↓
5a. SE APP INSTALADO:
    → Landing page tenta: "gw://invite?token=abc123"
    → App abre
    → Vai para InviteAcceptPage
    → Usuário cria senha
    → Login automático
    → Home do app
    
5b. SE APP NÃO INSTALADO:
    → Landing page detecta (após 2 segundos)
    → Mostra botões de download
    → Usuário baixa app
    → Instala e abre
    → Faz login com email do convite
    → Sistema detecta convite pendente
    → Pede para criar senha
    → Home do app
```

---

## ⚙️ Configurações Adicionais

### **Customizar Landing Page**

Edite `invite.html` para:

- Mudar cores (linha 15-20)
- Mudar logo (linha 87)
- Mudar textos (linhas 93, 95, etc)
- Adicionar analytics

### **Adicionar Analytics**

Adicione antes do `</head>`:

```html
<!-- Google Analytics -->
<script
    async
    src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"
></script>
<script>
    window.dataLayer = window.dataLayer || [];
    function gtag() {
        dataLayer.push(arguments);
    }
    gtag("js", new Date());
    gtag("config", "G-XXXXXXXXXX");
</script>
```

---

## 🎨 Melhorias Opcionais

### **1. Salvar Token Localmente**

Se o usuário baixar o app depois, você pode salvar o token:

```javascript
// Na landing page, adicione:
if (token) {
    localStorage.setItem("invite_token", token);
}
```

Depois, no app, verifique:

```dart
// No primeiro acesso do app
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('invite_token');
if (token != null) {
  // Redirecionar para aceitar convite
}
```

### **2. QR Code**

Adicione um QR code na landing page para facilitar:

```html
<div id="qr-code"></div>
<script src="https://cdn.jsdelivr.net/npm/qrcodejs@1.0.0/qrcode.min.js"></script
>
<script>
    new QRCode(document.getElementById("qr-code"), {
        text: "gw://invite?token=" + token,
        width: 200,
        height: 200,
    });
</script>
```

---

## 📊 Checklist de Implementação

- [ ] Configurar deep links no iOS (Info.plist)
- [ ] Configurar deep links no Android (AndroidManifest.xml)
- [ ] Adicionar pacote `app_links` ao pubspec.yaml
- [ ] Implementar listener de deep links no main.dart
- [ ] Atualizar URLs na landing page (App Store/Play Store)
- [ ] Hospedar landing page (Firebase/Netlify/GitHub)
- [ ] Atualizar `email_invite_link` no banco de dados
- [ ] Testar com app instalado
- [ ] Testar sem app instalado
- [ ] Publicar apps nas lojas (ou TestFlight/Internal Testing)

---

## 🆘 Troubleshooting

**Deep link não abre o app:**

- Verifique se o scheme `gw://` está configurado
- Teste com `adb` ou `xcrun simctl`
- Verifique logs do app

**Landing page não detecta app:**

- Normal! Navegadores não conseguem detectar apps instalados
- A detecção funciona tentando abrir e esperando 2 segundos

**Botões de download não funcionam:**

- Atualize as URLs do App Store/Play Store
- Use links de TestFlight/Internal Testing enquanto desenvolve

---

Esta é a solução mais robusta e profissional para apps nativos! 🚀
