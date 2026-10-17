# Ver como usuário

Um admin do app (`cc_members.user_role` contém `ADMIN`) pode abrir o perfil de outro membro e navegar pelos grupos e jornadas dele sem trocar o login do Supabase e sem enviar e-mail.

A sessão continua sendo a do admin. O id do membro entra só nas leituras. Enquanto a simulação está ativa, entrar em grupo, iniciar ou resetar jornada, concluir atividade, comentar e criar experiência, evento ou aviso ficam bloqueados.

A entrada fica em Perfil → Ver como usuário. Um banner no rodapé da navegação mostra quem está sendo visto e o botão Sair. O estado some ao sair ou ao reiniciar o app.

Jornadas de outro membro passam pelas funções `admin_view_user_journeys` e `admin_view_user_steps`, porque a policy de `cc_user_journeys` só libera a linha do próprio `auth.uid()` ou de um admin do portal (`cc_users`).
