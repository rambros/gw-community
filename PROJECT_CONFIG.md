# 🔧 Configuração do Projeto Good Wishes

## 📋 Informações do Projeto

### **Firebase**

- **Project ID:** `good-wishes-project`
- **Project Number:** `875067654858`
- **Region:** `us-central`
- **Hosting URLs:**
  - Site principal: `https://good-wishes-project.web.app`
  - App web: `https://gw-app.web.app`
  - Landing page convite: `https://gw-invite.web.app`

### **Supabase**

- **Project ID:** `hxhpzoyjjghtekqgfbfh`
- **Project Name:** `Portal`
- **Project Ref:** `hxhpzoyjjghtekqgfbfh`
- **Organization ID:** `mtzzpmkxlaykfybbynep`
- **Region:** `us-west-1`
- **Database Host:** `db.hxhpzoyjjghtekqgfbfh.supabase.co`
- **API URL:** `https://hxhpzoyjjghtekqgfbfh.supabase.co`

### **Repositórios**

- **App Mobile (Flutter):**
  `/Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community`
- **Portal Admin (Web):**
  `/Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/cott-portal-admin`
- **Supabase Functions:**
  `/Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/cott-portal-admin/supabase/functions`

### **App Mobile**

- **Bundle ID (iOS):** `org.callofthetime.gw`
- **Package Name (Android):** `org.callofthetime.gw`
- **App Name:** `Good Wishes`
- **Deep Link Scheme:** `gw://`

### **URLs Importantes**

- **Landing Page Convite:** `https://gw-invite.web.app`
- **App Store URL:** `https://apps.apple.com/app/good-wishes/idXXXXXXXXX`
  (atualizar quando publicar)
- **Play Store URL:**
  `https://play.google.com/store/apps/details?id=org.callofthetime.gw`
  (atualizar quando publicar)

---

## 🔑 Variáveis de Ambiente (Referência)

### **Supabase**

- `SUPABASE_URL`: `https://hxhpzoyjjghtekqgfbfh.supabase.co`
- `SUPABASE_ANON_KEY`: (configurado no app)
- `SUPABASE_SERVICE_ROLE_KEY`: (configurado nas Edge Functions)

### **Email (Resend)**

- `RESEND_API_KEY`: (configurado em cc_settings)
- `email_from_address`: `noreply@callofthetime.org`
- `email_from_name`: `Good Wishes`
- `email_invite_link`: `https://gw-invite.web.app`

---

## 📊 Edge Functions Deployadas

| Nome              | Status | Verify JWT | Descrição                   |
| ----------------- | ------ | ---------- | --------------------------- |
| `invite-user`     | ACTIVE | true       | Envia convite por email     |
| `accept-invite`   | ACTIVE | false      | Aceita convite e cria conta |
| `validate-invite` | ACTIVE | false      | Valida token de convite     |

---

## 🎯 Fluxo de Convite

```
1. Portal Admin → invite-user Edge Function
   ↓
2. Email enviado com link: https://gw-invite.web.app?token=xxx
   ↓
3. Usuário clica → Landing page tenta deep link: gw://invite?token=xxx
   ↓
4. App abre → /invite?token=xxx
   ↓
5. validate-invite Edge Function valida token
   ↓
6. Formulário de senha
   ↓
7. accept-invite Edge Function cria conta
   ↓
8. Login e acesso ao app
```

---

## 📝 Notas

- **Última atualização:** 2026-01-30
- **Versão do Flutter:** (adicionar quando relevante)
- **Versão do Dart:** (adicionar quando relevante)

---

**Este arquivo serve como referência rápida para o projeto. Mantenha-o
atualizado!**
