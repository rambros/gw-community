# Pop-up de anúncio

O app mostra um cartão ao abrir, com o conteúdo publicado no admin
(`cott-portal-admin`, menu Pop-up de anúncio). Trocar imagem, texto ou botão
não exige nova versão do app.

## Quando aparece

Na abertura do shell (`NavBarPage`), depois do primeiro frame. A função
`active_app_popup()` devolve no máximo um pop-up `active`, dentro da janela
de datas, cuja audiência inclui este usuário, e que ele ainda não encerrou.
A audiência (todo mundo, um grupo, uma lista, uma pessoa, uma jornada ou uma
etapa) é definida no admin e conferida de novo a cada abertura. Se mais de
um pop-up servir, o app recebe o mais específico.

Se a consulta falhar, a home abre sem o cartão.

`animation` pode ser `none`, `confetti`, `sparkle` ou `pulse`. O efeito toca
uma vez, por cima do cartão, e não impede Fechar nem o botão. Um valor
desconhecido fica parado.

Não aparece enquanto um admin está em “ver como”, e esse modo não grava
encerramento.

## O que o toque faz

- **Fechar** grava `cc_app_popup_dismissals.action = close`.
- O botão grava `action = cta` e só então abre a URL ou a rota.
- Toque fora do cartão e o botão de voltar do sistema não encerram o pop-up.
- Sair do app sem tocar mostra o mesmo pop-up na próxima abertura.
- Outro pop-up, com outro id, pode aparecer depois.

Rotas aceitas: `/homePage`, `/journeyPage`, `/communityPage`,
`/libraryHubPage`, `/userProfilePage`, `/inAppNotificationsPage`.

O contrato das tabelas e da função está em
`cott-portal-admin/docs/app_popup.md`.
