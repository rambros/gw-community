# 🚀 Setup de Múltiplos Sites no Firebase Hosting

## Configuração de Sites Separados

Você precisa de:

1. **Site principal** - Para o app web (quando fizer build do Flutter)
2. **Site de convite** - Para a landing page de convite

---

## 📋 Passo a Passo

### **Passo 1: Criar os Sites no Firebase**

Execute estes comandos:

```bash
cd /Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community

# Criar site para landing page de convite
firebase hosting:sites:create gw-invite

# Criar site para o app web (opcional, se quiser URL separada)
firebase hosting:sites:create gw-app
```

**Resultado esperado:**

```
✔ Created site gw-invite
Site URL: https://gw-invite.web.app

✔ Created site gw-app  
Site URL: https://gw-app.web.app
```

---

### **Passo 2: Aplicar Targets**

```bash
# Target para landing page de convite
firebase target:apply hosting invite gw-invite

# Target para app web
firebase target:apply hosting app gw-app
```

**Resultado esperado:**

```
✔ Applied hosting target app to gw-app
✔ Applied hosting target invite to gw-invite
```

---

### **Passo 3: Deploy da Landing Page**

```bash
firebase deploy --only hosting:invite
```

**Resultado esperado:**

```
✔ Deploy complete!
Hosting URL: https://gw-invite.web.app
```

---

## 📝 Estrutura Final

Após configurar, você terá:

| Site          | URL                                   | Conteúdo                | Deploy                                  |
| ------------- | ------------------------------------- | ----------------------- | --------------------------------------- |
| **Default**   | `https://good-wishes-project.web.app` | Site padrão do projeto  | `firebase deploy --only hosting`        |
| **gw-invite** | `https://gw-invite.web.app`           | Landing page de convite | `firebase deploy --only hosting:invite` |
| **gw-app**    | `https://gw-app.web.app`              | App Flutter Web         | `firebase deploy --only hosting:app`    |

---

## 🎯 Comandos de Deploy

### **Deploy apenas landing page:**

```bash
firebase deploy --only hosting:invite
```

### **Deploy apenas app:**

```bash
firebase deploy --only hosting:app
```

### **Deploy tudo:**

```bash
firebase deploy --only hosting
```

---

## 📊 Verificar Sites Criados

```bash
firebase hosting:sites:list
```

---

## ⚙️ Configuração do firebase.json

O arquivo `firebase.json` já está configurado com:

```json
{
  "hosting": [
    {
      "target": "app",
      "public": "build/web",
      ...
    },
    {
      "target": "invite",
      "public": "web",
      ...
    }
  ]
}
```

---

## 🆘 Se Algo Der Errado

### **Erro: "Site already exists"**

```bash
# Listar sites existentes
firebase hosting:sites:list

# Usar site existente
firebase target:apply hosting invite [SITE_ID_EXISTENTE]
```

### **Erro: "Target not configured"**

```bash
# Verificar targets
cat .firebaserc

# Reaplicar targets
firebase target:apply hosting invite gw-invite
firebase target:apply hosting app gw-app
```

---

## ✅ Checklist

- [ ] Executar `firebase hosting:sites:create gw-invite`
- [ ] Executar `firebase hosting:sites:create gw-app`
- [ ] Executar `firebase target:apply hosting invite gw-invite`
- [ ] Executar `firebase target:apply hosting app gw-app`
- [ ] Executar `firebase deploy --only hosting:invite`
- [ ] Anotar URL: `https://gw-invite.web.app`
- [ ] Atualizar banco de dados com a URL
- [ ] Testar landing page

---

**Tempo estimado:** 5 minutos

**Próximo passo:** Execute os comandos do Passo 1! 🚀
