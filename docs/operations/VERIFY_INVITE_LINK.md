# ✅ Checklist de Verificação - Link de Convite

## 🔍 Verificar Configuração do Banco de Dados

### **Passo 1: Verificar o valor atual**

Execute no Supabase SQL Editor:

```sql
SELECT setting_key, value, is_active 
FROM cc_settings 
WHERE setting_key = 'email_invite_link';
```

**Resultado esperado:**

| setting_key       | value                     | is_active |
| ----------------- | ------------------------- | --------- |
| email_invite_link | https://gw-invite.web.app | true      |

---

### **Passo 2: Atualizar se necessário**

Se o valor estiver diferente, execute:

```sql
UPDATE cc_settings 
SET value = 'https://gw-invite.web.app',
    is_active = true
WHERE setting_key = 'email_invite_link';
```

**⚠️ IMPORTANTE:** A URL **NÃO** deve ter barra no final!

- ✅ Correto: `https://gw-invite.web.app`
- ❌ Errado: `https://gw-invite.web.app/`

---

### **Passo 3: Verificar outras configurações de email**

```sql
SELECT setting_key, value, is_active 
FROM cc_settings 
WHERE setting_key IN (
    'email_invite_link',
    'email_from_address',
    'email_from_name',
    'resend_api_token'
)
ORDER BY setting_key;
```

**Resultado esperado:**

| setting_key        | value                     | is_active |
| ------------------ | ------------------------- | --------- |
| email_from_address | noreply@callofthetime.org | true      |
| email_from_name    | Good Wishes               | true      |
| email_invite_link  | https://gw-invite.web.app | true      |
| resend_api_token   | re_xxxxxxxxxx             | true      |

---

## 📧 Como o Link é Gerado

A Edge Function `invite-user` gera o link assim:

```typescript
// Linha 74 de invite-user/index.ts
const inviteLink = `${INVITE_LINK_BASE}?token=${token}`;
```

Onde:

- `INVITE_LINK_BASE` = valor de `email_invite_link` no banco
- `token` = UUID gerado automaticamente

**Exemplo de link gerado:**

```
https://gw-invite.web.app?token=123e4567-e89b-12d3-a456-426614174000
```

---

## 🧪 Testar Envio de Convite

### **Passo 1: Enviar convite de teste**

1. Acesse o portal admin
2. Vá para a seção de convites
3. Preencha o formulário:
   - Email: seu email de teste
   - Nome: Teste
   - Sobrenome: Convite
   - Role: member
4. Clique em "Send Invitation"

### **Passo 2: Verificar o email**

1. Abra seu email
2. Procure por email de "Good Wishes"
3. Verifique o link no email

**Link esperado:**

```
https://gw-invite.web.app?token=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
```

### **Passo 3: Testar o link**

**No navegador (desktop):**

```
https://gw-invite.web.app?token=XXXXXXXX
```

**Resultado esperado:**

1. Página carrega com spinner
2. Após 2 segundos, mostra botões de download

**No celular (com app instalado):**

1. Clique no link do email
2. Landing page abre
3. Tenta abrir o app automaticamente
4. App abre na página de criar senha

---

## 🔧 Troubleshooting

### **Problema: Email não chega**

**Verificar:**

```sql
-- Ver convites pendentes
SELECT email, token, created_at, status 
FROM invitations 
WHERE status = 'pending' 
ORDER BY created_at DESC 
LIMIT 5;
```

**Verificar logs da Edge Function:**

1. Acesse Supabase Dashboard
2. Edge Functions → invite-user → Logs
3. Procure por erros

### **Problema: Link está errado no email**

**Verificar valor no banco:**

```sql
SELECT value FROM cc_settings WHERE setting_key = 'email_invite_link';
```

**Atualizar:**

```sql
UPDATE cc_settings 
SET value = 'https://gw-invite.web.app' 
WHERE setting_key = 'email_invite_link';
```

### **Problema: Landing page não abre**

**Verificar se está hospedada:**

```bash
curl -I https://gw-invite.web.app
```

**Resultado esperado:**

```
HTTP/2 200
```

**Testar no navegador:**

```
https://gw-invite.web.app?token=test123
```

---

## ✅ Checklist Final

- [ ] Valor de `email_invite_link` está correto no banco
- [ ] Valor está sem barra no final
- [ ] `is_active` está como `true`
- [ ] Outras configurações de email estão corretas
- [ ] Convite de teste enviado
- [ ] Email recebido
- [ ] Link no email está correto
- [ ] Link abre landing page
- [ ] Landing page funciona corretamente

---

## 📋 SQL Rápido - Copiar e Colar

```sql
-- Verificar configuração atual
SELECT setting_key, value, is_active 
FROM cc_settings 
WHERE setting_key = 'email_invite_link';

-- Atualizar se necessário
UPDATE cc_settings 
SET value = 'https://gw-invite.web.app',
    is_active = true
WHERE setting_key = 'email_invite_link';

-- Verificar todas configurações de email
SELECT setting_key, value, is_active 
FROM cc_settings 
WHERE setting_key IN (
    'email_invite_link',
    'email_from_address',
    'email_from_name',
    'resend_api_token'
)
ORDER BY setting_key;

-- Ver últimos convites enviados
SELECT email, token, created_at, status 
FROM invitations 
ORDER BY created_at DESC 
LIMIT 10;
```

---

**Próximo passo:** Execute o SQL de verificação e me avise o resultado! 🚀
