# Guia de Deploy - Good Wishes Community App

## ✅ Solução Recomendada: Web App Simples

Já que Firebase Dynamic Links está desativado, a melhor solução é usar o **app
Flutter Web** hospedado no Firebase Hosting.

---

## 📋 Passo a Passo

### 1. Verificar Configuração do Firebase

Verifique se o projeto já está configurado:

```bash
cd /Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community
firebase projects:list
```

Se não estiver configurado:

```bash
firebase login
firebase init hosting
# Selecione o projeto Good Wishes
# Public directory: build/web
# Configure as single-page app: Yes
# Set up automatic builds: No
```

### 2. Build do App para Web

```bash
# Limpar build anterior
flutter clean
flutter pub get

# Build para produção
flutter build web --release --web-renderer canvaskit
```

### 3. Deploy para Firebase Hosting

```bash
firebase deploy --only hosting
```

Após o deploy, você verá a URL, algo como:

- `https://gw-community.web.app`
- `https://gw-community.firebaseapp.com`

### 4. (Opcional) Configurar Domínio Customizado

Se quiser usar `https://gw.callofthetime.org`:

```bash
firebase hosting:sites:create gw-community
firebase target:apply hosting gw-community gw-community
```

No Firebase Console:

1. Hosting → Add custom domain
2. Digite: `gw.callofthetime.org`
3. Siga as instruções para configurar DNS

### 5. Atualizar Link no Banco de Dados

Depois do deploy, atualize a configuração:

```sql
-- Use a URL do Firebase Hosting
UPDATE cc_settings 
SET value = 'https://gw-community.web.app/invite' 
WHERE setting_key = 'email_invite_link';

-- OU se configurou domínio customizado
UPDATE cc_settings 
SET value = 'https://gw.callofthetime.org/invite' 
WHERE setting_key = 'email_invite_link';
```

### 6. Testar o Fluxo Completo

1. **Envie um convite** pelo portal admin
2. **Verifique o email** recebido
3. **Clique no link** do email
4. **Deve abrir** a página de convite no navegador
5. **Crie uma senha** e confirme
6. **Faça login** com as credenciais criadas

---

## 🎯 Alternativas de URL

### Opção A: Firebase Hosting (Gratuito)

```
https://gw-community.web.app/invite?token=xxx
```

✅ Grátis ✅ SSL automático ✅ CDN global ✅ Deploy em segundos

### Opção B: Domínio Customizado

```
https://gw.callofthetime.org/invite?token=xxx
```

✅ Mais profissional ✅ Mesma infraestrutura do Firebase ⚠️ Requer configuração
de DNS

### Opção C: Subdomínio

```
https://app.callofthetime.org/invite?token=xxx
```

✅ Separação clara (app vs portal) ✅ Fácil de configurar ⚠️ Requer configuração
de DNS

---

## 🚀 Deploy Rápido (Script)

Criei um script `deploy.sh` que faz tudo automaticamente:

```bash
cd /Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community
chmod +x deploy.sh
./deploy.sh prod
```

---

## 🔄 Futuro: Deep Links (Opcional)

Se no futuro você quiser que o link abra o app nativo (iOS/Android) quando
instalado:

1. Configure deep links (veja `DEEP_LINKS_SETUP.md`)
2. O mesmo link funcionará para:
   - Web: Abre no navegador
   - iOS: Abre o app se instalado
   - Android: Abre o app se instalado

Mas por enquanto, **apenas a versão web já resolve** o problema do convite!

---

## ❓ FAQ

**Q: O app mobile precisa estar na App Store/Play Store?** A: Não! A versão web
funciona em qualquer navegador (desktop e mobile).

**Q: Usuários podem usar o app no celular?** A: Sim! A versão web é responsiva e
funciona perfeitamente em mobile browsers.

**Q: E se eu quiser apps nativos depois?** A: Você pode adicionar deep links
depois sem mudar o fluxo de convite.

**Q: Quanto custa o Firebase Hosting?** A: Plano gratuito: 10GB storage +
360MB/dia de transferência (mais que suficiente).

---

## 📝 Checklist de Deploy

- [ ] Build do app (`flutter build web --release`)
- [ ] Deploy para Firebase (`firebase deploy --only hosting`)
- [ ] Anotar URL do Firebase Hosting
- [ ] Atualizar `email_invite_link` no banco de dados
- [ ] Enviar convite de teste
- [ ] Verificar email recebido
- [ ] Clicar no link e testar criação de conta
- [ ] Fazer login e confirmar acesso

---

## 🆘 Troubleshooting

**Build falha:**

```bash
flutter clean
flutter pub get
flutter build web --release
```

**Deploy falha:**

```bash
firebase login --reauth
firebase use --add  # Selecione o projeto correto
firebase deploy --only hosting
```

**Link não funciona:**

- Verifique se a URL no banco está correta
- Verifique se o app foi deployado com sucesso
- Teste a URL diretamente no navegador

**Página em branco:**

- Verifique console do navegador (F12)
- Verifique se o build foi feito com `--release`
- Tente limpar cache do navegador
