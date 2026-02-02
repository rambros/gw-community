# 🚀 Deploy da Edge Function validate-invite

## 📋 O Que Foi Corrigido

O erro `AuthSessionMissingException` acontecia porque o app tentava fazer uma
query direta no Supabase sem autenticação.

**Solução:** Criamos uma Edge Function `validate-invite` que valida o token
usando o Service Role Key (sem precisar de autenticação do usuário).

---

## 🔧 Deploy da Edge Function

### **Passo 1: Navegar até o projeto do portal admin**

```bash
cd /Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/cott-portal-admin
```

### **Passo 2: Fazer deploy da função**

```bash
supabase functions deploy validate-invite
```

**Resultado esperado:**

```
Deploying function validate-invite...
✔ Function validate-invite deployed successfully
```

---

## 🧪 Testar a Função

### **Teste 1: Token inválido**

```bash
curl -X POST \
  'https://YOUR_PROJECT_REF.supabase.co/functions/v1/validate-invite' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"token": "invalid-token"}'
```

**Resultado esperado:**

```json
{
    "valid": false,
    "message": "This invitation link is invalid or has already been used."
}
```

### **Teste 2: Token válido**

```bash
curl -X POST \
  'https://YOUR_PROJECT_REF.supabase.co/functions/v1/validate-invite' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"token": "VALID_TOKEN_FROM_DB"}'
```

**Resultado esperado:**

```json
{
    "valid": true,
    "email": "user@example.com"
}
```

---

## ✅ Testar no App

Depois do deploy:

1. **Hot restart do app:**

```bash
# No terminal onde o app está rodando, pressione:
R
```

2. **Testar deep link:**

```bash
xcrun simctl openurl booted "gw://invite?token=test123"
```

**Resultado esperado:**

- Logs de deep link aparecem
- App navega para `/invite`
- Página mostra "Validating..." e depois "Invalid invitation" (porque test123
  não existe)

3. **Testar com token real:**
   - Envie um convite pelo portal admin
   - Copie o token do email
   - Teste: `xcrun simctl openurl booted "gw://invite?token=REAL_TOKEN"`
   - Deve mostrar formulário de senha

---

## 📊 Fluxo Completo

```
1. Deep link recebido: gw://invite?token=abc123
   ↓
2. App navega para /invite?token=abc123
   ↓
3. InviteAcceptPage carrega
   ↓
4. ViewModel chama validate-invite Edge Function
   ↓
5. Edge Function valida token no banco
   ↓
6. Se válido: mostra formulário de senha
   Se inválido: mostra mensagem de erro
```

---

## 🆘 Troubleshooting

### **Erro: "Function not found"**

```bash
# Verificar funções deployadas
supabase functions list

# Fazer deploy novamente
supabase functions deploy validate-invite
```

### **Erro: "Service role key not found"**

Verifique se as variáveis de ambiente estão configuradas no Supabase Dashboard:

- Settings → Edge Functions → Environment Variables
- `SUPABASE_SERVICE_ROLE_KEY` deve estar configurada

### **App ainda mostra AuthSessionMissingException**

1. Certifique-se de fazer **hot restart** (não apenas hot reload)
2. Ou pare e rode o app novamente: `flutter run`

---

## ✅ Checklist

- [ ] Edge Function `validate-invite` criada
- [ ] Deploy feito com sucesso
- [ ] Função testada com curl
- [ ] App com hot restart
- [ ] Deep link testado
- [ ] Página de convite carrega sem erro
- [ ] Validação de token funciona

---

**Próximo passo:** Execute o deploy da Edge Function! 🚀

```bash
cd /Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/cott-portal-admin
supabase functions deploy validate-invite
```
