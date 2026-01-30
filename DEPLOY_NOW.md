# 🚀 Deploy Rápido - Landing Page de Convite

## ✅ Tudo Pronto!

Já configurei tudo para você:

- ✅ Firebase configurado para projeto `good-wishes-project`
- ✅ `web/index.html` criado (cópia do invite.html)
- ✅ `firebase.json` configurado

---

## 📋 Execute Apenas Estes Comandos

### **Passo 1: Navegue até o projeto**

```bash
cd /Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community
```

### **Passo 2: Faça o deploy**

```bash
firebase deploy --only hosting
```

**Pronto!** O Firebase vai fazer o deploy e mostrar a URL.

---

## 📝 Após o Deploy

### **1. Anote a URL**

Você verá algo como:

```
✔  Deploy complete!

Hosting URL: https://good-wishes-project.web.app
```

### **2. Atualize o banco de dados**

```sql
UPDATE cc_settings 
SET value = 'https://good-wishes-project.web.app' 
WHERE setting_key = 'email_invite_link';
```

### **3. Teste!**

Abra no navegador:

```
https://good-wishes-project.web.app/?token=test123
```

Deve mostrar a landing page com o spinner e depois os botões de download.

---

## 🎯 Próximos Passos (Opcional)

### **Atualizar URLs das Lojas**

Quando tiver os apps publicados, edite `web/invite.html` (linhas 222-225):

```javascript
const IOS_APP_STORE_URL = "https://apps.apple.com/app/good-wishes/idXXXXXXXXX";
const ANDROID_PLAY_STORE_URL =
    "https://play.google.com/store/apps/details?id=org.callofthetime.gw";
```

Depois faça deploy novamente:

```bash
cp web/invite.html web/index.html
firebase deploy --only hosting
```

---

## ✅ Checklist Final

- [ ] Executar `firebase deploy --only hosting`
- [ ] Anotar URL do Firebase Hosting
- [ ] Atualizar `email_invite_link` no banco
- [ ] Testar landing page no navegador
- [ ] Enviar convite de teste
- [ ] Verificar email recebido
- [ ] Clicar no link e testar

---

## 🎉 Resultado

Quando tudo estiver funcionando:

```
1. Admin envia convite
   ↓
2. Email: "https://good-wishes-project.web.app/?token=abc123"
   ↓
3. Usuário clica (celular com app instalado)
   ↓
4. Landing page tenta abrir: "gw://invite?token=abc123"
   ↓
5. App abre automaticamente
   ↓
6. Vai para tela de criar senha
   ↓
7. Usuário cria senha e faz login
   ↓
8. Acessa o app! 🎉
```

---

**Tempo estimado:** 2 minutos

**Comando único:** `firebase deploy --only hosting`

**É só isso!** 🚀
