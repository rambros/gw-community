# Typography Guide - G&W Community App

## 🎯 Visão Geral

Este documento descreve a estratégia de tipografia para o aplicativo G&W Community, focado em meditação e espiritualidade.

---

## ✅ Implementação Atual

### Módulos com Design System Próprio

| Módulo | Status | Tipografia | Design System |
|--------|--------|-----------|---------------|
| **Journey** | ✅ Implementado | LexendDeca + Poppins (Original) | `lib/ui/journey/themes/` |
| **Library** | ✅ Implementado | LexendDeca + Poppins (Original) | `lib/ui/learn/themes/` |
| **Community** | ✅ Implementado | Cormorant Garamond + Nunito | `lib/ui/community/themes/` |
| **Home** | ⚪ AppTheme Base | LexendDeca + Poppins | Usa fontes padrão |
| **Profile** | ⚪ AppTheme Base | LexendDeca + Poppins | Usa fontes padrão |

### Uso nos Componentes

```dart
// Journey Module
Text(
  'Step Title',
  style: AppTheme.of(context).journey.stepTitle,
)

// Community Module
Text(
  'Event Name',
  style: AppTheme.of(context).community.cardTitle,
)

// Library Module
Text(
  'Content Title',
  style: AppTheme.of(context).learn.contentTitle,
)
```

---

## 🎨 Fontes Recomendadas

Todas as fontes estão disponíveis no [Google Fonts](https://fonts.google.com/).

### Opção 0: Original do Projeto ⭐ (PADRÃO)

**Títulos e Corpo:** [LexendDeca](https://fonts.google.com/specimen/Lexend+Deca) (sans-serif legível e moderna)
- **H1 (Page Title):** 28px, Weight: 500, Letter-spacing: 0.0
- **H2 (Section Title):** 22px, Weight: 500, Letter-spacing: 0.0
- **H3 (Card Title):** 18px, Weight: 500, Letter-spacing: 0.0
- **Body Text:** 16px, Weight: 400, Letter-spacing: 0.0
- **Secondary Text:** 14px, Weight: 300, Letter-spacing: 0.0
- **Caption:** 13px, Weight: 400, Letter-spacing: 0.0
- **Step Number:** 14px, Weight: 600, Letter-spacing: 0.0

**Botões:** [Poppins](https://fonts.google.com/specimen/Poppins) (sans-serif geométrica e moderna)
- **Button:** 16px, Weight: 500, Letter-spacing: 0.0
- **Button Small:** 14px, Weight: 500, Letter-spacing: 0.0

#### 🎯 Filosofia da Opção 0 (Original)

**Conceito:** Legibilidade e acessibilidade máximas com tipografia sans-serif unificada

**LexendDeca (Principal):**
- ✅ Fonte criada especificamente para melhorar legibilidade
- ✅ Desenvolvida pela Applied Design Works com pesquisa em leitura
- ✅ Espaçamento otimizado para reduzir fadiga visual
- ✅ Formas claras e abertas
- ✅ Excelente legibilidade em todos os tamanhos
- ✅ Visual limpo e profissional sem ser frio
- ✅ Letter-spacing zero mantém texto compacto e clean

**Poppins (Botões):**
- ✅ Sans-serif geométrica com personalidade amigável
- ✅ Círculos perfeitos criam harmonia visual
- ✅ Contraste sutil com LexendDeca sem quebrar unidade
- ✅ Peso 500 oferece presença sem agressividade
- ✅ Ideal para CTAs e elementos interativos

**Resultado Visual:**
- 📖 **Legibilidade superior em todas as situações**
- 🎯 **Acessibilidade como prioridade**
- 🧘 **Clareza sem distrações**
- 💻 **Profissional e moderno**
- ✨ **Coesão visual em todo o app**

**Melhor para:** Apps que priorizam acessibilidade, leitura prolongada, clareza de informação, interfaces limpas

**Status:** ✅ Implementado nos módulos **Journey** e **Library**

---

### Opção 1: Elegante e Serena ⭐

**Títulos/Headers:** [Cormorant Garamond](https://fonts.google.com/specimen/Cormorant+Garamond) (serif elegante)
- **H1 (Page Title):** 28px, Weight: 600, Letter-spacing: 0.5
- **H2 (Section Title):** 22px, Weight: 500, Letter-spacing: 0.5
- **H3 (Card Title):** 18px, Weight: 500, Letter-spacing: 0.5

**Corpo/Body:** [Nunito](https://fonts.google.com/specimen/Nunito) (sans-serif suave e arredondada)
- **Body Text:** 16px, Weight: 400, Letter-spacing: 0.3
- **Secondary Text:** 14px, Weight: 300, Letter-spacing: 0.3
- **Caption:** 13px, Weight: 400, Letter-spacing: 0.2
- **Button:** 16px, Weight: 500, Letter-spacing: 0.3
- **Step Number:** 14px, Weight: 600, Letter-spacing: 0.0

#### 🎯 Filosofia da Opção 1

**Conceito:** Combinação clássica de serif elegante com sans humanista

**Cormorant Garamond (Títulos):**
- ✅ Serif elegante com curvas suaves e orgânicas
- ✅ Inspirada nas fontes Garamond históricas (século XVI)
- ✅ Transmite sofisticação, serenidade e atemporalidade
- ✅ Perfeita para criar hierarquia visual clara
- ✅ Weight moderado (500-600) mantém leveza

**Nunito (Corpo):**
- ✅ Sans-serif arredondada e humanista
- ✅ Terminações suaves que complementam a Garamond
- ✅ Extremamente legível em tamanhos pequenos
- ✅ Sensação acolhedora e amigável
- ✅ Ótimo contraste geométrico com serif

**Resultado Visual:**
- 🌸 **Elegância sem pretensiosidade**
- 🧘 **Equilíbrio entre clássico e moderno**
- 📖 **Ideal para leitura contemplativa**
- ✨ **Sensação de qualidade e cuidado**

**Melhor para:** Apps de meditação, wellness, conteúdo espiritual, journaling

---

### Opção 2: Minimalista e Calma

**Títulos:** [Playfair Display](https://fonts.google.com/specimen/Playfair+Display) (serif clássica)
- **H1 (Page Title):** 28px, Weight: 600, Letter-spacing: 0.3
- **H2 (Section Title):** 22px, Weight: 500, Letter-spacing: 0.3
- **H3 (Card Title):** 18px, Weight: 500, Letter-spacing: 0.3

**Corpo:** [Lato](https://fonts.google.com/specimen/Lato) (sans-serif limpa e profissional)
- **Body Text:** 16px, Weight: 400, Letter-spacing: 0.2
- **Secondary Text:** 14px, Weight: 300, Letter-spacing: 0.2
- **Caption:** 13px, Weight: 400, Letter-spacing: 0.2
- **Button:** 16px, Weight: 600, Letter-spacing: 0.5
- **Step Number:** 14px, Weight: 700, Letter-spacing: 0.0

#### 🎯 Filosofia da Opção 2

**Conceito:** Tradição editorial com clareza profissional

**Playfair Display (Títulos):**
- ✅ Serif clássica de alto contraste (transicional)
- ✅ Inspirada nas fontes do século XVIII
- ✅ Alta legibilidade em títulos grandes
- ✅ Elegância tradicional e sofisticada
- ✅ Contraste dramático entre hastes grossas e finas

**Lato (Corpo):**
- ✅ Sans-serif limpa e profissional
- ✅ Forma humanista com terminações arredondadas
- ✅ Originalmente criada para uso corporativo
- ✅ Excelente legibilidade em múltiplos tamanhos
- ✅ Sensação de "calor" apesar da limpeza

**Resultado Visual:**
- 📚 **Mais tradicional e editorial**
- 🎨 **Sofisticação clássica**
- 📖 **Perfeita para leitura longa e imersiva**
- 🏛️ **Sensação de autoridade e credibilidade**

**Melhor para:** Conteúdo educacional, artigos longos, blogs de reflexão, bibliotecas digitais

---

### Opção 3: Moderna e Zen ⚡ (ATUAL - IMPLEMENTADA)

**Títulos:** [Poppins](https://fonts.google.com/specimen/Poppins) Regular (sans-serif moderna e geométrica)
- **H1 (Page Title):** 26px, Weight: 400, Letter-spacing: 0.0
- **H2 (Section Title):** 20px, Weight: 400, Letter-spacing: 0.0
- **H3 (Card Title):** 18px, Weight: 400, Letter-spacing: 0.0

**Corpo:** [Inter](https://fonts.google.com/specimen/Inter) (sans-serif neutra e técnica)
- **Body Text:** 15px, Weight: 400, Letter-spacing: 0.0
- **Secondary Text:** 14px, Weight: 400, Letter-spacing: 0.0
- **Caption:** 13px, Weight: 400, Letter-spacing: 0.0
- **Button:** 15px, Weight: 500, Letter-spacing: 0.0
- **Step Number:** 14px, Weight: 600, Letter-spacing: 0.0

#### 🎯 Filosofia da Opção 3

**Conceito:** Abordagem totalmente sans-serif, moderna e zen

**Poppins (Títulos):**
- ✅ Sans-serif geométrica com personalidade
- ✅ Formas arredondadas e amigáveis
- ✅ Weight Regular (400) cria leveza zen
- ✅ Moderna sem ser técnica demais
- ✅ Círculos perfeitos nas letras (o, e, a)
- ✅ Visual limpo e descomplicado

**Inter (Corpo):**
- ✅ Projetada especificamente para telas digitais
- ✅ Extremamente legível em tamanhos pequenos
- ✅ Neutra e sem distrações
- ✅ Otimizada para rendering de alta resolução
- ✅ Hinting perfeito para claridade
- ✅ Espaçamento equilibrado

**Letter-spacing Zero:**
- 🎯 Visual mais compacto e clean
- 🎯 Minimalismo máximo
- 🎯 Foco no conteúdo, não na tipografia

**Resultado Visual:**
- 💻 **Nativa digital e contemporânea**
- 🧘‍♀️ **Zen através da simplicidade**
- 🎯 **Minimalismo funcional**
- ⚡ **Leveza visual máxima**
- 🌐 **Interface moderna e acessível**

**Melhor para:** Apps digitais modernos, dashboards, produtos SaaS zen, mindfulness apps, interfaces minimalistas

---

### Opção 4: Calorosa e Acolhedora

**Títulos:** [Crimson Text](https://fonts.google.com/specimen/Crimson+Text) (serif calorosa)
- **H1 (Page Title):** 28px, Weight: 600
- **H2 (Section Title):** 22px, Weight: 600
- **H3 (Card Title):** 18px, Weight: 600

**Corpo:** [Source Sans Pro](https://fonts.google.com/specimen/Source+Sans+Pro) (sans-serif humanista)
- **Body Text:** 16px, Weight: 400
- **Secondary Text:** 14px, Weight: 400
- **Caption:** 13px, Weight: 400
- **Button:** 16px, Weight: 600

#### 🎯 Filosofia da Opção 4

**Conceito:** Calor humano e acessibilidade

**Crimson Text (Títulos):**
- ✅ Serif com personalidade calorosa
- ✅ Inspirada nas oldstyle serifas
- ✅ Formas abertas e acolhedoras
- ✅ Menos formal que Garamond ou Playfair
- ✅ Sensação de conversa pessoal

**Source Sans Pro (Corpo):**
- ✅ Primeira fonte open-source da Adobe
- ✅ Humanista com toque amigável
- ✅ Criada para legibilidade máxima
- ✅ Formas abertas e generosas
- ✅ Versátil em múltiplos contextos

**Resultado Visual:**
- 🤗 **Mais pessoal e acolhedor**
- 💬 **Sensação de conversa íntima**
- 👥 **Proximidade e empatia**
- 🏡 **Conforto e familiaridade**

**Melhor para:** Comunidades, coaching, terapia online, conversas profundas, grupos de apoio

---

## 📐 Scale de Tamanhos (Typography Scale)

### Implementação Atual

| Elemento | Tamanho | Weight | Uso |
|----------|---------|--------|-----|
| **Page Title** | 24-28px | 600 | Títulos de páginas principais (AppBar) |
| **Section Title** | 20-22px | 500 | Títulos de seções e divisões |
| **Card Title** | 18px | 500 | Títulos em cards e listas |
| **Body Text** | 16px | 400 | Texto principal de conteúdo |
| **Secondary Text** | 14px | 300-400 | Descrições, subtítulos |
| **Metadata** | 13px | 400 | Datas, autores, informações contextuais |
| **Caption** | 12px | 400 | Labels, badges, pequenas informações |
| **Button Text** | 16px | 500 | Texto em botões principais |
| **Button Small** | 14px | 500 | Texto em botões secundários |

### Recomendações Gerais

```
H1 (Page Title):     28-32px
H2 (Section):        20-24px
H3 (Card/Item):      18-20px
Body:                16px
Secondary:           14px
Caption/Label:       12-13px
```

---

## 🎨 Características para Apps de Espiritualidade

### ✅ Buscar

- **Curvas suaves:** Letras com terminações arredondadas
- **Boa legibilidade:** Clareza em diversos tamanhos
- **Espaçamento generoso:** Letter-spacing de 0.3-0.5
- **Weights leves:** 300-500 para títulos (evitar muito bold)
- **Sensação de calma:** Fontes que transmitem serenidade
- **Abertura visual:** Altura-x generosa, formas abertas

### ❌ Evitar

- ❌ Fontes muito pesadas/bold (>700 weight)
- ❌ Sans-serif muito geométricas (ex: Futura, Avant Garde)
- ❌ Fontes técnicas/corporativas
- ❌ Condensadas ou comprimidas
- ❌ Muito modernas/futuristas (ex: Orbitron)
- ❌ Display fonts decorativas

---

## 💡 Migração e Manutenção

### Status Atual do Projeto

**Antes da migração:**
- LexendDeca (padrão)
- Poppins (botões e labels)
- Inter (alguns componentes)

**Após migração (módulos Journey/Community/Library):**
- Cormorant Garamond (todos os títulos/headings)
- Nunito (todo corpo de texto)

### Módulos Restantes (Home/Profile)

**Opção A:** Manter AppTheme base (atual)
- Continuar usando LexendDeca + Poppins
- Menor overhead de manutenção

**Opção B:** Atualizar fontes sem design system
```dart
// Trocar apenas as fontes:
GoogleFonts.lexendDeca() → GoogleFonts.cormorantGaramond()
GoogleFonts.poppins() → GoogleFonts.nunito()
```

**Opção C:** Criar design systems completos
- Seguir padrão dos outros módulos
- Maior consistência visual

---

## 📦 Estrutura dos Design Systems

### Journey Typography

**Arquivo:** `lib/ui/journey/themes/journey_typography.dart`

**Estilos disponíveis:**
- `pageTitle` - 28px, w600
- `sectionTitle` - 22px, w500
- `stepTitle` - 18px, w500
- `cardTitle` - 18px, w500
- `bodyText` - 16px, w400
- `stepDescription` - 14px, w300
- `caption` - 13px, w400
- `buttonText` - 16px, w500
- `buttonSmall` - 14px, w500
- `stepNumber` - 14px, w600

### Community Typography

**Arquivo:** `lib/ui/community/themes/community_typography.dart`

**Estilos adicionais:**
- `userName` - 16px, w500
- `inputLabel` - 16px, w500
- `inputHint` - 14px, w400
- `commentAuthor` - 14px, w600
- `commentContent` - 14px, w400
- `commentTimestamp` - 12px, w400

### Library Typography

**Arquivo:** `lib/ui/learn/themes/learn_typography.dart`

**Estilos específicos:**
- `contentTitle` - 18px, w600
- `modalTitle` - 18px, bold
- `listHeader` - 16px, w600
- `bodyLight` - 14px, w300
- `filterLabel` - 14px, w500
- `separatorText` - 14px, w400

---

## 🔧 Implementação Técnica

### Adicionando ao pubspec.yaml

```yaml
dependencies:
  google_fonts: ^6.1.0
```

### Importando nos arquivos

```dart
// Para módulos com design system
import '/ui/journey/themes/journey_theme_extension.dart';

// Para uso direto
import 'package:google_fonts/google_fonts.dart';
```

### Aplicando estilos

```dart
// Com design system (recomendado para Journey/Community/Library)
Text(
  'Welcome',
  style: AppTheme.of(context).journey.pageTitle.override(
    color: Colors.white,
  ),
)

// Sem design system (Home/Profile)
Text(
  'Profile',
  style: AppTheme.of(context).headlineMedium.override(
    font: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.w600),
    color: AppTheme.of(context).primary,
  ),
)
```

---

## 📊 Comparação de Complexidade

| Módulo | Arquivos | Overrides | Fontes | Estratégia |
|--------|----------|-----------|--------|------------|
| Community | 49 | 201 | 5 → 2 | Design System |
| Journey | 17 | 41 | 3 → 2 | Design System |
| Library | 8 | 37 | 2 → 2 | Design System |
| Profile | 18 | 64 | 3 | AppTheme Base |
| Home | 4 | 10 | 2 | AppTheme Base |

**Benefícios do Design System:**
- ✅ 70% menos código de estilização
- ✅ Manutenção centralizada
- ✅ Consistência visual garantida
- ✅ Mudanças em 1 arquivo afetam todo módulo

---

## 🎯 Recomendações Finais

### Para Novos Módulos

**Se o módulo tiver:**
- Mais de 30 `.override()` calls → Criar design system
- Menos de 15 calls → Usar AppTheme base

### Para Consistência Visual

**Opção Recomendada:** Manter estratégia híbrida atual
- Journey/Community/Library: Design systems completos
- Home/Profile: AppTheme base (mais simples)

**Opcional:** Atualizar Home/Profile apenas trocando fontes
```dart
// Buscar e substituir:
GoogleFonts.lexendDeca → GoogleFonts.cormorantGaramond (títulos)
GoogleFonts.poppins → GoogleFonts.nunito (labels/botões)
```

---

## 📚 Recursos

- [Google Fonts](https://fonts.google.com/)
- [Cormorant Garamond](https://fonts.google.com/specimen/Cormorant+Garamond)
- [Nunito](https://fonts.google.com/specimen/Nunito)
- [Material Design Typography](https://m3.material.io/styles/typography/overview)

---

**Última atualização:** Dezembro 2024
**Fontes em produção:**
- **Journey, Library:** LexendDeca + Poppins (Original)
- **Community:** Cormorant Garamond + Nunito (Elegante)
- **Home, Profile:** LexendDeca + Poppins (via AppTheme base - sem overrides)
