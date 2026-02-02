# 🚀 Deploy da Landing Page no Firebase Hosting

## Passo a Passo Completo

### **Pré-requisitos**

1. **Firebase CLI instalado:**

```bash
npm install -g firebase-tools
```

2. **Login no Firebase:**

```bash
firebase login
```

---

## 📋 Setup Inicial (Primeira vez apenas)

### **Passo 1: Inicializar Firebase no Projeto**

```bash
cd /Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community

# Inicializar Firebase
firebase init hosting
```

**Respostas para as perguntas:**

- **Select a default Firebase project:** Escolha o projeto Good Wishes (ou crie
  um novo)
- **What do you want to use as your public directory?** `web`
- **Configure as a single-page app?** `No`
- **Set up automatic builds and deploys with GitHub?** `No`
- **File web/index.html already exists. Overwrite?** `No`

### **Passo 2: Configurar Múltiplos Sites (Opcional)**

Se você quiser ter URLs separadas para o app e para a landing page:

```bash
# Criar site para landing page
firebase hosting:sites:create gw-invite

# Aplicar target
firebase target:apply hosting invite gw-invite
```

Isso criará uma URL separada como: `https://gw-invite.web.app`

---

## 🚀 Deploy da Landing Page

### **Opção A: Deploy Simples (Recomendado)**

```bash
cd /Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community

# Copiar invite.html como index.html
cp web/invite.html web/index.html

# Deploy
firebase deploy --only hosting
```

### **Opção B: Usar Script Automatizado**

```bash
cd /Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community

# Dar permissão ao script
chmod +x deploy-invite.sh

# Executar
./deploy-invite.sh
```

---

## 📝 Após o Deploy

### **1. Anotar a URL**

Após o deploy, você verá algo como:

```
✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/good-wishes-app/overview
Hosting URL: https://good-wishes-app.web.app
```

Anote essa URL!

### **2. Atualizar URLs na Landing Page**

Edite `web/invite.html` (linhas 120-122):

```javascript
// ATUALIZE ESTAS URLs:
const IOS_APP_STORE_URL = "https://apps.apple.com/app/good-wishes/idXXXXXXXXX";
const ANDROID_PLAY_STORE_URL =
    "https://play.google.com/store/apps/details?id=org.callofthetime.gw";
```

**Enquanto não publicou:**

- TestFlight: `https://testflight.apple.com/join/XXXXXXXX`
- Internal Testing: `https://play.google.com/apps/internaltest/XXXXXXXX`

Depois de editar, faça deploy novamente:

```bash
firebase deploy --only hosting
```

### **3. Atualizar Banco de Dados**

```sql
UPDATE cc_settings 
SET value = 'https://good-wishes-app.web.app' 
WHERE setting_key = 'email_invite_link';
```

**⚠️ Importante:** Use a URL exata que o Firebase mostrou!

---

## 🧪 Testar

### **1. Testar a Landing Page**

Abra no navegador:

```
https://good-wishes-app.web.app/?token=test123
```

Você deve ver:

- Logo do app
- Mensagem "Opening Good Wishes..."
- Depois de 2 segundos, botões de download

### **2. Testar Fluxo Completo**

1. **Envie um convite** pelo portal admin
2. **Verifique o email** recebido
3. **Clique no link** no celular
4. **Resultado esperado:**
   - Landing page abre
   - Tenta abrir o app
   - Se app instalado: abre direto
   - Se não: mostra botões de download

---

## 🔧 Configuração Avançada

### **Domínio Customizado**

Se quiser usar `https://invite.callofthetime.org`:

1. **No Firebase Console:**
   - Hosting → Add custom domain
   - Digite: `invite.callofthetime.org`
   - Siga instruções de DNS

2. **Configure DNS:**
   - Adicione registro A ou CNAME conforme instruções

3. **Aguarde propagação** (pode levar até 24h)

### **Múltiplos Sites**

Se configurou múltiplos sites, você terá:

- **App:** `https://good-wishes-app.web.app`
- **Invite:** `https://gw-invite.web.app`

Para deploy separado:

```bash
# Deploy apenas landing page
firebase deploy --only hosting:invite

# Deploy apenas app
firebase deploy --only hosting:app
```

---

## 📊 Monitoramento

### **Ver Estatísticas**

No Firebase Console:

- Hosting → Dashboard
- Veja número de acessos, banda utilizada, etc.

### **Ver Logs**

```bash
firebase hosting:channel:list
```

---

## 🆘 Troubleshooting

### **Erro: "Firebase CLI not found"**

```bash
npm install -g firebase-tools
```

### **Erro: "Not logged in"**

```bash
firebase login --reauth
```

### **Erro: "No project selected"**

```bash
firebase use --add
# Selecione o projeto Good Wishes
```

### **Landing page mostra 404**

1. Verifique se `web/index.html` existe
2. Verifique se o deploy foi bem-sucedido
3. Tente limpar cache: `firebase hosting:channel:delete preview`

### **Deep link não funciona**

1. Verifique se o app está instalado
2. Teste com comando direto (xcrun/adb)
3. Verifique logs do navegador (F12)

---

## 📋 Checklist

- [ ] Firebase CLI instalado
- [ ] Login no Firebase feito
- [ ] Projeto Firebase inicializado
- [ ] `web/invite.html` existe
- [ ] Deploy executado com sucesso
- [ ] URL anotada
- [ ] URLs da App Store/Play Store atualizadas
- [ ] Deploy feito novamente após atualizar URLs
- [ ] Banco de dados atualizado
- [ ] Landing page testada no navegador
- [ ] Email de convite enviado
- [ ] Link do email testado

---

## 🎯 Comandos Rápidos

```bash
# Setup inicial (primeira vez)
firebase login
firebase init hosting
firebase target:apply hosting invite gw-invite

# Deploy
cp web/invite.html web/index.html
firebase deploy --only hosting

# Ver projetos
firebase projects:list

# Ver sites de hosting
firebase hosting:sites:list

# Ver URL do site
firebase hosting:channel:open live
```

---

## 📞 Próximos Passos

Depois do deploy bem-sucedido:

1. ✅ Anote a URL
2. ✅ Atualize URLs na landing page
3. ✅ Faça deploy novamente
4. ✅ Atualize banco de dados
5. ✅ Teste enviando convite
6. ✅ Publique apps nas lojas (quando pronto)
7. ✅ Atualize URLs das lojas na landing page

---

**Tempo estimado:** 10-15 minutos

**Custo:** Gratuito (plano Spark do Firebase)

**Resultado:** Landing page profissional hospedada e funcionando! 🎉
