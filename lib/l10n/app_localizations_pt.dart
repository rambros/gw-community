// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get navHome => 'Início';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navJourney => 'Jornada';

  @override
  String get navCommunity => 'Comunidade';

  @override
  String get navProfile => 'Perfil';

  @override
  String get language => 'Idioma';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get chooseLanguage => 'Escolher idioma';

  @override
  String get journeyContents => 'Conteúdo';

  @override
  String get start => 'Começar';

  @override
  String get resume => 'Continuar';

  @override
  String get startUpper => 'COMEÇAR';

  @override
  String get resumeUpper => 'CONTINUAR';

  @override
  String get completedUpper => 'CONCLUÍDO';

  @override
  String get viewAgain => 'VER DE NOVO';

  @override
  String get viewMore => 'Ver mais';

  @override
  String get seeAllJourneys => 'Ver todas';

  @override
  String get seeAllGroups => 'Ver todos';

  @override
  String get journeys => 'Jornadas';

  @override
  String get myJourneys => 'Minhas jornadas';

  @override
  String get otherJourneys => 'Outras jornadas';

  @override
  String get untitledJourney => 'Jornada sem título';

  @override
  String get noJourneysStarted => 'Nenhuma jornada iniciada ainda';

  @override
  String get noJourneysStartedYet => 'Você ainda não começou nenhuma jornada';

  @override
  String get noOtherJourneys => 'Não há outras jornadas disponíveis';

  @override
  String stepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count etapas',
      one: '1 etapa',
    );
    return '$_temp0';
  }

  @override
  String stepsProgress(int completed, int total) {
    return 'Concluídas $completed de $total etapas';
  }

  @override
  String get publicLabel => 'pública';

  @override
  String get privateLabel => 'privada';

  @override
  String get groupPrivacyPublic => 'Público';

  @override
  String get groupPrivacyPrivate => 'Privado';

  @override
  String get noPostsYet => 'Nenhuma publicação ainda';

  @override
  String get lastPostJustNow => 'Última publicação agora';

  @override
  String lastPostMinutesAgo(int minutes) {
    return 'Última publicação há $minutes min';
  }

  @override
  String lastPostHoursAgo(int hours) {
    return 'Última publicação há $hours h';
  }

  @override
  String lastPostDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Última publicação há $count dias',
      one: 'Última publicação há 1 dia',
    );
    return '$_temp0';
  }

  @override
  String lastPostOn(String date) {
    return 'Última publicação $date';
  }

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros',
      one: '1 membro',
    );
    return '$_temp0';
  }

  @override
  String groupMetaLine(String privacy, String members) {
    return '$privacy - $members';
  }

  @override
  String groupMetaDetails(String privacy, String members) {
    return 'Grupo $privacy - $members';
  }

  @override
  String get deleteGroup => 'Excluir grupo';

  @override
  String confirmDeleteGroup(String name) {
    return 'Confirmar exclusão do grupo $name';
  }

  @override
  String get confirm => 'Confirmar';

  @override
  String get groupDeleted => 'Grupo excluído com sucesso';

  @override
  String get welcomeComma => 'Bem-vindo,';

  @override
  String get communityTagline =>
      'Uma comunidade de bem-intencionados\ncriando um mundo novo juntos';

  @override
  String get myGroups => 'Meus grupos';

  @override
  String get otherGroups => 'Outros grupos';

  @override
  String get upcomingEvents => 'Próximos eventos';

  @override
  String get profile => 'Perfil';

  @override
  String get accountSettings => 'Configurações da conta';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get changePassword => 'Alterar senha';

  @override
  String get setNotifications => 'Notificações';

  @override
  String get editGuidelines => 'Editar diretrizes';

  @override
  String get resetTips => 'Redefinir dicas';

  @override
  String get tipsReset =>
      'Dicas redefinidas — ao trocar de aba elas aparecem de novo.';

  @override
  String get myFavorites => 'Meus favoritos';

  @override
  String get myJournal => 'Meu diário';

  @override
  String get myExperiences => 'Minhas experiências';

  @override
  String get askAQuestion => 'Fazer uma pergunta';

  @override
  String get communityGuidelines => 'Diretrizes da comunidade';

  @override
  String get logOut => 'Sair';

  @override
  String versionLabel(String version) {
    return 'Versão $version';
  }

  @override
  String get library => 'Biblioteca';

  @override
  String get community => 'Comunidade';

  @override
  String get login => 'Entrar';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get yourEmail => 'Seu e-mail';

  @override
  String get yourPassword => 'Sua senha';

  @override
  String get emailRequired => 'E-mail é obrigatório';

  @override
  String get enterValidEmail => 'Digite um e-mail válido';

  @override
  String get fieldRequired => 'Campo obrigatório';

  @override
  String get accessAccountBelow => 'Acesse sua conta abaixo.';

  @override
  String get forgotPassword => 'Esqueceu a senha?';

  @override
  String get sendAccessLink => 'Enviar link de acesso';

  @override
  String get magicLinkHint =>
      'Digite seu e-mail para receber um link seguro de acesso.';

  @override
  String get emailNotRegistered =>
      'E-mail não cadastrado. Fale com o administrador.';

  @override
  String get errorSendingLink => 'Erro ao enviar o link. Tente de novo.';

  @override
  String get checkYourEmail => 'Confira seu e-mail!';

  @override
  String magicLinkSentTo(String email) {
    return 'Enviamos um link de acesso para $email. Toque nele para entrar.';
  }

  @override
  String get linkSentAgain =>
      'Link enviado de novo. Confira sua caixa de entrada.';

  @override
  String get resendLink => 'Reenviar link';

  @override
  String get signInWithPassword => 'Entrar com senha →';

  @override
  String get signInWithoutPassword => '← Entrar sem senha';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get notifications => 'Notificações';

  @override
  String get noNotificationsYet => 'Nenhuma notificação ainda';

  @override
  String get markAllAsRead => 'Marcar todas como lidas';

  @override
  String get deleteRead => 'Excluir lidas';

  @override
  String get deleteAll => 'Excluir todas';

  @override
  String get notificationsNew => 'Novas';

  @override
  String get notificationsRead => 'Lidas';

  @override
  String get deleteReadNotifications => 'Excluir notificações lidas';

  @override
  String get confirmDeleteReadNotifications =>
      'Tem certeza de que deseja excluir todas as notificações lidas?';

  @override
  String get deleteAllNotifications => 'Excluir todas as notificações';

  @override
  String get confirmDeleteAllNotifications =>
      'Tem certeza de que deseja excluir todas as notificações do sistema? Esta ação não pode ser desfeita.';

  @override
  String get justNow => 'Agora';

  @override
  String minutesAgoShort(int minutes) {
    return 'há $minutes min';
  }

  @override
  String hoursAgoShort(int hours) {
    return 'há $hours h';
  }

  @override
  String daysAgoShort(int days) {
    return 'há $days d';
  }

  @override
  String get yourProfile => 'Seu perfil';

  @override
  String get firstName => 'Nome';

  @override
  String get lastName => 'Sobrenome';

  @override
  String get displayName => 'Nome de exibição';

  @override
  String get hideMyLastName => 'Ocultar meu sobrenome';

  @override
  String get saveChanges => 'Salvar alterações';

  @override
  String get nameFallback => 'Nome';

  @override
  String get signUp => 'Cadastro';

  @override
  String get hideLastNameHint =>
      'Você pode ocultar o sobrenome no perfil se quiser.';

  @override
  String get agreeToTermsPrefix =>
      'Ao criar uma conta, você concorda com nossos ';

  @override
  String get termsAndConditions => 'Termos e condições ';

  @override
  String get andWord => 'e ';

  @override
  String get privacyPolicy => 'Política de privacidade.';

  @override
  String get completeSetup => 'Concluir cadastro';

  @override
  String get resetOnboardingTitle => 'Redefinir experiência inicial';

  @override
  String get resetOnboardingDescription =>
      'Vamos limpar o progresso da introdução para você vê-la de novo.';

  @override
  String get resetOnboarding => 'Redefinir introdução';

  @override
  String get onboardingResetSuccess => 'Introdução redefinida com sucesso.';

  @override
  String errorResettingOnboarding(String error) {
    return 'Erro ao redefinir a introdução: $error';
  }

  @override
  String errorLoggingOut(String error) {
    return 'Erro ao sair: $error';
  }

  @override
  String get yourJournalEntry => 'Sua anotação';

  @override
  String get journalEntriesPrivate => 'Suas anotações são privadas e seguras.';

  @override
  String get noJournalEntries => 'Nenhuma anotação encontrada.';

  @override
  String get journalEntryNotFound => 'Anotação não encontrada.';

  @override
  String get journeyLabel => 'Jornada';

  @override
  String get journalSaved => 'Anotação salva';

  @override
  String get saving => 'Salvando...';

  @override
  String get edit => 'Editar';

  @override
  String get deletionOfJournalEntry => 'Exclusão da anotação';

  @override
  String get confirmDeleteJournalEntry => 'Confirmar exclusão desta anotação?';

  @override
  String get clearing => 'Limpando...';

  @override
  String get clearEntry => 'Limpar anotação';

  @override
  String get tryAgain => 'Tentar de novo';

  @override
  String get noExperiencesYet => 'Nenhuma experiência ainda';

  @override
  String get group => 'Grupo';

  @override
  String get allGroups => 'Todos os grupos';

  @override
  String get status => 'Status';

  @override
  String get allStatus => 'Todos os status';

  @override
  String get published => 'Publicada';

  @override
  String get inReflection => 'Em reflexão';

  @override
  String get awaitingApproval => 'Aguardando aprovação';

  @override
  String get notPublished => 'Não publicada';

  @override
  String get refinementSuggested => 'Ajuste sugerido';

  @override
  String get clearFilters => 'Limpar filtros';

  @override
  String get deleteExperience => 'Excluir experiência';

  @override
  String get confirmDeleteExperience =>
      'Tem certeza de que deseja excluir esta experiência? Esta ação não pode ser desfeita.';

  @override
  String get experienceDeleted => 'Experiência excluída com sucesso';

  @override
  String get publishExperience => 'Publicar experiência';

  @override
  String get confirmPublishExperience =>
      'Tem certeza de que deseja publicar esta experiência? Ela será enviada para moderação.';

  @override
  String get experiencePublished => 'Experiência publicada com sucesso';

  @override
  String get view => 'Ver';

  @override
  String get submit => 'Enviar';

  @override
  String get revise => 'Revisar';

  @override
  String get publish => 'Publicar';

  @override
  String get visibleForEveryone => 'Visível para todos';

  @override
  String get groupOnly => 'Somente o grupo';

  @override
  String get userFallback => 'Usuário';

  @override
  String get enterNewPasswordBelow => 'Digite sua nova senha abaixo.';

  @override
  String get newPassword => 'Nova senha';

  @override
  String get enterNewPassword => 'Digite a nova senha';

  @override
  String get confirmPassword => 'Confirmar senha';

  @override
  String get confirmNewPassword => 'Confirme a nova senha';

  @override
  String get passwordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get passwordUpdated => 'Senha atualizada com sucesso';

  @override
  String get updatePassword => 'Atualizar senha';

  @override
  String get pushNotifications => 'Notificações push';

  @override
  String get pushNotificationsSubtitle =>
      'Receba alertas no aparelho mesmo com o app fechado.';

  @override
  String get inAppNotifications => 'Notificações no app';

  @override
  String get inAppNotificationsSubtitle =>
      'Mostrar o sino e os alertas dentro do app.';

  @override
  String get startSharingExperiences =>
      'Compartilhe suas experiências com a comunidade!';

  @override
  String visibleOnlyFor(String group) {
    return 'Visível somente para $group';
  }

  @override
  String get save => 'Salvar';

  @override
  String get markdownSupported =>
      'Markdown suportado: **negrito**, *itálico*, # título, - lista';

  @override
  String get enterGuidelinesHint =>
      'Escreva as diretrizes da comunidade aqui...';

  @override
  String get enterEnglishGuidelinesHint =>
      'Escreva as diretrizes em inglês aqui...';

  @override
  String get enterPortugueseGuidelinesHint =>
      'Escreva as diretrizes em português aqui...';

  @override
  String get guidelinesVersionsHint =>
      'O app mostra a versão no idioma do participante. Se o português estiver vazio, usa o inglês.';

  @override
  String get noGuidelinesYet => 'Ainda não há diretrizes.';

  @override
  String get guidelinesSaved => 'Diretrizes salvas com sucesso!';

  @override
  String failedToSaveGuidelines(String error) {
    return 'Não foi possível salvar as diretrizes: $error';
  }

  @override
  String get myQuestions => 'Minhas perguntas';

  @override
  String get supportFilterAll => 'Todas';

  @override
  String get supportFilterOpen => 'Abertas';

  @override
  String get supportFilterCompleted => 'Concluídas';

  @override
  String get failedToLoadQuestions => 'Não foi possível carregar as perguntas';

  @override
  String get noQuestionsYet => 'Nenhuma pergunta ainda';

  @override
  String get noQuestionsFound => 'Nenhuma pergunta encontrada';

  @override
  String get haveAQuestionHelp => 'Tem uma pergunta? Estamos aqui para ajudar!';

  @override
  String get tryChangingFilter => 'Tente mudar o filtro';

  @override
  String get deleteQuestion => 'Excluir pergunta';

  @override
  String get confirmDeleteQuestion =>
      'Tem certeza de que deseja excluir esta pergunta? Esta ação não pode ser desfeita.';

  @override
  String get questionDeleted => 'Pergunta excluída com sucesso';

  @override
  String get subject => 'Assunto';

  @override
  String get description => 'Descrição';

  @override
  String get subjectHint => 'Resumo breve da sua pergunta';

  @override
  String get descriptionHint => 'Dê o máximo de detalhes possível...';

  @override
  String get submitQuestion => 'Enviar pergunta';

  @override
  String get questionAbout => 'Pergunta sobre:';

  @override
  String get questionSubmitted => 'Pergunta enviada com sucesso!';

  @override
  String get pleaseEnterSubject => 'Digite um assunto para a pergunta';

  @override
  String get subjectMinLength => 'O assunto deve ter pelo menos 5 caracteres';

  @override
  String get pleaseDescribeQuestion => 'Descreva a sua pergunta';

  @override
  String get descriptionMinLength =>
      'A descrição deve ter pelo menos 20 caracteres';

  @override
  String get failedToCreateQuestion =>
      'Não foi possível criar a pergunta. Tente de novo.';

  @override
  String anErrorOccurred(String error) {
    return 'Ocorreu um erro: $error';
  }

  @override
  String get question => 'Pergunta';

  @override
  String get questionNotFound => 'Pergunta não encontrada';

  @override
  String get markAsCompleted => 'Marcar como concluída';

  @override
  String get reopenQuestion => 'Reabrir pergunta';

  @override
  String askedOn(String date) {
    return 'Feita em $date';
  }

  @override
  String referenceNumber(String number) {
    return 'Referência $number';
  }

  @override
  String get noMessagesYet => 'Nenhuma mensagem ainda';

  @override
  String get sendMessageToStart => 'Envie uma mensagem para começar a conversa';

  @override
  String get typeAMessage => 'Escreva uma mensagem...';

  @override
  String get questionHasBeenCompleted => 'Esta pergunta foi concluída';

  @override
  String get reopen => 'Reabrir';

  @override
  String get chooseFromGallery => 'Escolher da galeria';

  @override
  String get takeAPhoto => 'Tirar uma foto';

  @override
  String get confirmMarkCompleted =>
      'Sua pergunta já foi respondida? Você pode reabri-la depois se precisar.';

  @override
  String get questionMarkedCompleted => 'Pergunta marcada como concluída';

  @override
  String get confirmReopenQuestion =>
      'Você precisa de mais ajuda com esta pergunta?';

  @override
  String get questionReopened => 'Pergunta reaberta';

  @override
  String get supportTeam => 'Suporte';

  @override
  String get supportStatusOpen => 'Aberta';

  @override
  String get supportStatusReviewed => 'Em análise';

  @override
  String get supportStatusNeedsResponse => 'Precisa da sua resposta';

  @override
  String get supportStatusCompleted => 'Concluída';

  @override
  String get yesterday => 'Ontem';

  @override
  String get failedToSendMessage => 'Não foi possível enviar a mensagem';

  @override
  String errorSendingMessage(String error) {
    return 'Erro ao enviar a mensagem: $error';
  }

  @override
  String get noFavoritesYet => 'Nenhum favorito ainda';

  @override
  String get tapHeartToCollectPrefix => 'Toque em ';

  @override
  String get tapHeartToCollectSuffix => ' pelo app para guardar seus favoritos';

  @override
  String get failedToLoadFavorites => 'Não foi possível carregar os favoritos';

  @override
  String get fromLibrary => 'Da biblioteca';

  @override
  String get fromJourney => 'Da jornada';

  @override
  String fromSource(String title) {
    return 'De $title';
  }

  @override
  String stepWithTitle(int number, String title) {
    return 'Etapa $number: $title';
  }

  @override
  String get mediaAudio => 'Áudio';

  @override
  String get mediaVideo => 'Vídeo';

  @override
  String get mediaText => 'Texto';

  @override
  String get mediaJournal => 'Diário';

  @override
  String get untitled => 'Sem título';

  @override
  String get activityFallback => 'Atividade';

  @override
  String get communityHintTitle => 'O poder da comunidade';

  @override
  String get communityHintMessage =>
      'Participe de uma comunidade para se conectar e compartilhar experiências, pensamentos de incentivo, ideias e conteúdos para o autodesenvolvimento.';

  @override
  String get libraryHintTitle => 'Aprofunde sua prática';

  @override
  String get libraryHintMessage =>
      'Acesse uma coleção crescente de reflexões, meditações e recursos para aprofundar sua prática e apoiar seu desenvolvimento espiritual.';

  @override
  String get journeyHintTitle => 'Bem-vindo a uma jornada maravilhosa!';

  @override
  String get journeyHintMessage =>
      'Aprenda, crie e compartilhe bons votos que geram impacto real. Descubra inspiração, meditações e práticas diárias para a transformação pessoal e do mundo.';

  @override
  String get onboardingJourneyTitle => 'Jornada';

  @override
  String get onboardingJourneyBody =>
      'Bem-vindo a uma jornada maravilhosa! Uma jornada para aprender, criar e compartilhar bons desejos que geram impacto. Os bons desejos são um caminho de autotransformação e de transformação do mundo. Você encontrará inspirações, meditações, práticas diárias e companhia…';

  @override
  String get onboardingLearnTitle => 'Aprenda';

  @override
  String get onboardingLearnBody =>
      'Quando sentir vontade de aprender mais, esclarecer ou aprofundar sua compreensão e experiência, novos conteúdos e referências estarão disponíveis para apoiar sua prática e seu progresso pessoal…';

  @override
  String get onboardingCommunityTitle => 'Comunidade';

  @override
  String get onboardingCommunityBody =>
      'Os bons desejos coletivos são poderosos. Ao avançar, você fará parte de uma comunidade de bem-intencionados, disposta a se apoiar mutuamente pela troca de sentimentos sinceros que trazem esperança, força e apoio… a base de um mundo novo.';

  @override
  String get onboardingBeginsTitle => 'Sua jornada começa';

  @override
  String get onboardingBeginsSubtitle => 'Cadastre-se abaixo para começar!';

  @override
  String get onboardingGetStarted => 'Começar';

  @override
  String get searchAllContent => 'Pesquisar todo o conteúdo...';

  @override
  String get filter => 'Filtrar';

  @override
  String get listOfAllContent => 'Lista de todo o conteúdo';

  @override
  String get listOfContents => 'Lista de conteúdos';

  @override
  String get clearFilter => 'Limpar filtro';

  @override
  String get noContentFound => 'Nenhum conteúdo encontrado';

  @override
  String get tryAdjustingFilters =>
      'Tente ajustar os filtros ou os termos de busca';

  @override
  String get transcript => 'Transcrição';

  @override
  String get contentFilter => 'Filtro de conteúdo';

  @override
  String get author => 'Autor';

  @override
  String get event => 'Evento';

  @override
  String get year => 'Ano';

  @override
  String get topics => 'Temas';

  @override
  String get selectAuthor => 'Selecionar autor';

  @override
  String get selectEvent => 'Selecionar evento';

  @override
  String get selectYear => 'Selecionar ano';

  @override
  String get selectTopics => 'Selecionar temas';

  @override
  String get searchAuthor => 'Pesquisar um autor...';

  @override
  String get searchEvent => 'Pesquisar um evento...';

  @override
  String get searchYear => 'Pesquisar um ano...';

  @override
  String get searchTapOutsideToClose => 'Pesquisar... (toque fora para fechar)';

  @override
  String get applyFilters => 'Aplicar filtros';

  @override
  String clearNamedFilter(String label) {
    return 'Limpar filtro de $label';
  }

  @override
  String get portalContentLibrary => 'Biblioteca de conteúdo';

  @override
  String get portalHubTitle => 'The Call of the Time Portal';

  @override
  String get portalDialoguesRetreats => 'Diálogos e Retiros';

  @override
  String get portalHeartToHeart => 'Conversas de Coração a Coração';

  @override
  String get portalMessages => 'Mensagens';

  @override
  String get portalDadiJanki => 'Dadi Janki';

  @override
  String get portalMeditations => 'Meditações';

  @override
  String get portalListOfAllMessages => 'Lista de todas as mensagens';

  @override
  String get portalListOfAllMeditations => 'Lista de todas as meditações';

  @override
  String get portalListOfAllDadiJanki =>
      'Lista de todo o conteúdo com Dadi Janki';

  @override
  String get portalListOfAllDialogues => 'Lista de todos os Diálogos e Retiros';

  @override
  String get portalListOfAllHeartToHeart =>
      'Lista de todas as Conversas de Coração a Coração';

  @override
  String get portalEventContents => 'Conteúdos do evento';

  @override
  String messageFromAuthors(String authors) {
    return 'Mensagem de $authors';
  }

  @override
  String get shareContent => 'Compartilhar';

  @override
  String get location => 'Local';

  @override
  String get eventType => 'Tipo de evento';

  @override
  String get selectLocation => 'Selecionar local';

  @override
  String get selectEventType => 'Selecionar tipo de evento';

  @override
  String get orSeparator => 'ou';

  @override
  String withAuthors(String names) {
    return 'Com $names';
  }

  @override
  String atEvent(String event) {
    return 'em $event';
  }

  @override
  String get linkToGroups => 'Vincular a grupos';

  @override
  String get groupLinksUpdated => 'Vínculos com grupos atualizados.';

  @override
  String get failedToUpdateLinks => 'Não foi possível atualizar os vínculos.';

  @override
  String get noGroupsAvailable => 'Nenhum grupo disponível.';

  @override
  String noGroupsMatch(String query) {
    return 'Nenhum grupo corresponde a \"$query\".';
  }

  @override
  String get searchGroups => 'Pesquisar grupos…';

  @override
  String get willBeUnlinked => 'Será desvinculado';

  @override
  String get willBeLinked => 'Será vinculado';

  @override
  String get noFilter => 'Nenhum filtro';

  @override
  String filteredBySearch(String query) {
    return 'Filtrado pela busca → $query';
  }

  @override
  String filtersApplied(String filters) {
    return 'Filtros → $filters';
  }

  @override
  String filterByAuthor(String value) {
    return 'Autor: $value';
  }

  @override
  String filterByEvent(String value) {
    return 'Evento: $value';
  }

  @override
  String filterByYear(String value) {
    return 'Ano: $value';
  }

  @override
  String filterByJourney(String value) {
    return 'Jornada: $value';
  }

  @override
  String filterByGroup(String value) {
    return 'Grupo: $value';
  }

  @override
  String filterByTopics(String value) {
    return 'Temas: $value';
  }

  @override
  String get about => 'Sobre';

  @override
  String get aboutGroup => 'Sobre o grupo';

  @override
  String get aboutThisGroup => 'Sobre este grupo';

  @override
  String get leaveGroup => 'Sair do grupo';

  @override
  String get leaveTheGroup => 'Sair do grupo';

  @override
  String get leave => 'Sair';

  @override
  String get confirmLeaveGroup => 'Tem certeza de que deseja sair deste grupo?';

  @override
  String get leftGroupSuccessfully => 'Você saiu do grupo';

  @override
  String get editGroup => 'Editar grupo';

  @override
  String get newGroup => 'Novo grupo';

  @override
  String get createGroup => 'Criar grupo';

  @override
  String get updateGroup => 'Atualizar grupo';

  @override
  String get joinGroup => 'Entrar no grupo';

  @override
  String get joinedGroupSuccessfully => 'Você entrou no grupo';

  @override
  String get groupNotFound => 'Grupo não encontrado';

  @override
  String get groupInformationMissing =>
      'As informações do grupo estão ausentes.';

  @override
  String get privateGroupInviteOnly =>
      'Este é um grupo privado. Você precisa de um convite para entrar e ver o conteúdo.';

  @override
  String get facilitators => 'Facilitadores';

  @override
  String get members => 'Membros';

  @override
  String get noMembersFound => 'Nenhum membro encontrado.';

  @override
  String get noMembersInGroup => 'Não há membros neste grupo';

  @override
  String get unknown => 'Desconhecido';

  @override
  String get tabExperiences => 'Experiências';

  @override
  String get tabEvents => 'Eventos';

  @override
  String get tabMessages => 'Mensagens';

  @override
  String get tabResources => 'Recursos';

  @override
  String get newExperience => 'Nova experiência';

  @override
  String get shareExperiencesSpace =>
      'Um espaço para compartilhar suas experiências, inspirar outras pessoas e receber bons desejos da comunidade';

  @override
  String get experienceUnpublished => 'Experiência despublicada';

  @override
  String get experiencesInspire => 'Viva experiências que inspiram';

  @override
  String get errorLoadingExperiences => 'Erro ao carregar experiências';

  @override
  String get beFirstToShareExperience =>
      'Seja a primeira pessoa a compartilhar uma experiência com todos';

  @override
  String get noExperiencesYetPeriod => 'Nenhuma experiência ainda.';

  @override
  String fromGroup(String name) {
    return 'Do grupo $name';
  }

  @override
  String get shareYourExperience => 'Compartilhe sua experiência';

  @override
  String get writeAboutExperience => 'Escreva sobre a sua experiência...';

  @override
  String get enableComments => 'Permitir comentários';

  @override
  String get draft => 'Rascunho';

  @override
  String get draftSaved => 'Rascunho salvo';

  @override
  String get experienceNotFound => 'Experiência não encontrada';

  @override
  String get editExperience => 'Editar experiência';

  @override
  String get draftNotPublishedYet => 'Rascunho — ainda não publicado';

  @override
  String get update => 'Atualizar';

  @override
  String get noCommentsYet => 'Nenhum comentário ainda';

  @override
  String get noCommentsYetPeriod => 'Nenhum comentário ainda.';

  @override
  String get confirmDeleteThisExperience =>
      'Confirmar a exclusão desta experiência?';

  @override
  String get confirmDeleteThisComment =>
      'Confirmar a exclusão deste comentário?';

  @override
  String get withdrawExperienceTitle => 'Retirar esta experiência?';

  @override
  String get withdrawExperienceMessage =>
      'Ela será removida do grupo de forma permanente e não poderá ser restaurada.';

  @override
  String get unpublish => 'Despublicar';

  @override
  String get unpublishExperienceTitle => 'Despublicar esta experiência?';

  @override
  String get unpublishExperienceMessage =>
      'A experiência deixará de aparecer publicamente.';

  @override
  String get welcomeToReviseExperience =>
      'Você pode revisar e compartilhar de novo quando se sentir pronto.';

  @override
  String get suggestionsSharedToRefine =>
      'Sugestões foram compartilhadas para ajudar a aprimorar esta experiência.';

  @override
  String get newEvent => 'Novo evento';

  @override
  String get editEvent => 'Editar evento';

  @override
  String get eventDetails => 'Detalhes do evento';

  @override
  String facilitatedBy(String name) {
    return 'Facilitado por $name';
  }

  @override
  String get openForEveryone => 'Aberto para todos';

  @override
  String get openOnlyForThisGroup => 'Aberto somente para este grupo';

  @override
  String get eventLink => 'Link do evento';

  @override
  String get noRegistrationsYet => 'Nenhuma inscrição ainda.';

  @override
  String get registeredSuccessfully => 'Inscrição feita com sucesso';

  @override
  String get processing => 'Processando...';

  @override
  String get register => 'Inscrever-se';

  @override
  String get registered => 'Inscrito';

  @override
  String get unsubscribedSuccessfully => 'Inscrição cancelada com sucesso';

  @override
  String get unsubscribe => 'Cancelar inscrição';

  @override
  String get deleteThisEvent => 'Excluir este evento?';

  @override
  String get eventDeletedSuccessfully => 'Evento excluído com sucesso';

  @override
  String get eventCreatedSuccessfully => 'Evento criado com sucesso';

  @override
  String get eventUpdatedSuccessfully => 'Evento atualizado com sucesso';

  @override
  String get upcoming => 'Próximos';

  @override
  String get recorded => 'Gravados';

  @override
  String get noUpcomingEvents => 'Nenhum evento próximo encontrado';

  @override
  String get noRecordedEvents => 'Nenhum evento gravado encontrado';

  @override
  String get noEventsYet => 'Nenhum evento ainda.';

  @override
  String get noDate => 'Sem data';

  @override
  String get title => 'Título';

  @override
  String get facilitator => 'Facilitador';

  @override
  String get required => 'Obrigatório';

  @override
  String get singleDay => 'Um dia';

  @override
  String get multiDay => 'Vários dias';

  @override
  String get durationMinutes => 'Duração (minutos)';

  @override
  String get startDate => 'Data de início';

  @override
  String get endDate => 'Data de término';

  @override
  String get registrationUrlOptional => 'URL de inscrição (opcional)';

  @override
  String get scheduled => 'Agendado';

  @override
  String get selectDate => 'Selecionar data';

  @override
  String get selectTime => 'Selecionar horário';

  @override
  String get time => 'Horário';

  @override
  String get saveEvent => 'Salvar evento';

  @override
  String get eventHeaderImage => 'Imagem de capa do evento';

  @override
  String get changeImage => 'Trocar imagem';

  @override
  String get uploadImage => 'Enviar imagem';

  @override
  String get onlyThisGroup => 'Somente este grupo';

  @override
  String get everyone => 'Todos';

  @override
  String get date => 'Data';

  @override
  String get messagesByFacilitator =>
      'Mensagens compartilhadas pelo facilitador.';

  @override
  String get newMessage => 'Nova mensagem';

  @override
  String get editMessage => 'Editar mensagem';

  @override
  String get details => 'Detalhes';

  @override
  String get message => 'Mensagem';

  @override
  String get sendTo => 'Enviar para';

  @override
  String get allMembersBroadcast => 'Todos os membros (broadcast)';

  @override
  String get member => 'Membro';

  @override
  String get messageUpdatedSuccessfully => 'Mensagem atualizada com sucesso';

  @override
  String get messageCreatedSuccessfully => 'Mensagem criada com sucesso';

  @override
  String get saveMessage => 'Salvar mensagem';

  @override
  String get addMessage => 'Adicionar mensagem';

  @override
  String get confirmDeleteThisMessage => 'Confirmar a exclusão desta mensagem?';

  @override
  String get newResource => 'Novo recurso';

  @override
  String get addResource => 'Adicionar recurso';

  @override
  String get editResource => 'Editar recurso';

  @override
  String get noResourcesYetAddFirst =>
      'Nenhum recurso ainda.\nToque em + para adicionar o primeiro.';

  @override
  String get noResourcesAvailable => 'Nenhum recurso disponível ainda.';

  @override
  String get unlinkFromGroup => 'Desvincular do grupo';

  @override
  String get unlink => 'Desvincular';

  @override
  String confirmUnlinkResource(String title) {
    return 'Remover \"$title\" da aba Recursos deste grupo?\n\nO conteúdo original permanece na Biblioteca.';
  }

  @override
  String get deleteResource => 'Excluir recurso';

  @override
  String confirmRemoveResource(String title) {
    return 'Remover \"$title\" deste grupo?';
  }

  @override
  String get titleRequired => 'O título é obrigatório.';

  @override
  String get urlRequired => 'A URL / endereço é obrigatório.';

  @override
  String get failedToSaveTryAgain => 'Não foi possível salvar. Tente de novo.';

  @override
  String get optionalDescription => 'Descrição opcional';

  @override
  String get urlAddress => 'URL / Endereço';

  @override
  String get resourceTitle => 'Título do recurso';

  @override
  String get type => 'Tipo';

  @override
  String get youtubeVideoUrl => 'URL do vídeo (YouTube) *';

  @override
  String get youtubeUrl => 'URL do YouTube';

  @override
  String get pleaseEnterYoutubeUrl => 'Digite uma URL do YouTube.';

  @override
  String get pleaseSelectFile => 'Selecione um arquivo.';

  @override
  String get uploadFailed => 'Falha no envio. Tente de novo.';

  @override
  String get failedToSaveResource => 'Não foi possível salvar o recurso.';

  @override
  String get tapToSelectFile => 'Toque para selecionar o arquivo';

  @override
  String get fileRequired => 'Arquivo *';

  @override
  String get noContentAvailable => 'Nenhum conteúdo disponível.';

  @override
  String get noContentFoundInResources =>
      'Nenhum conteúdo encontrado nos recursos.';

  @override
  String get writeSomething => 'Escreva algo...';

  @override
  String get close => 'Fechar';

  @override
  String get posting => 'Publicando...';

  @override
  String get post => 'Publicar';

  @override
  String get name => 'Nome';

  @override
  String get moreInformation => 'Mais informações';

  @override
  String get groupManagers => 'Gestores do grupo';

  @override
  String get selectManagers => 'Selecionar gestores/facilitadores';

  @override
  String get privateGroup => 'Grupo privado';

  @override
  String get onlyMembersCanSee => 'Somente membros veem o conteúdo.';

  @override
  String get anyoneCanSee => 'Qualquer pessoa pode ver o conteúdo.';

  @override
  String managersFacilitatorsCount(int count) {
    return 'Gestores / Facilitadores ($count)';
  }

  @override
  String get searchByNameOrEmail =>
      'Buscar por nome ou e-mail (mín. 3 caracteres)...';

  @override
  String get searchToFindUsers => 'Busque para encontrar usuários';

  @override
  String get noUsersFound => 'Nenhum usuário encontrado';

  @override
  String get groupImage => 'Imagem do grupo';

  @override
  String get noJourneysFoundForGroup =>
      'Nenhuma jornada encontrada neste grupo.';

  @override
  String get noExperiencesToModerate => 'Nenhuma experiência para moderar';

  @override
  String noFilteredExperiences(String filter) {
    return 'Nenhuma experiência $filter';
  }

  @override
  String get noPendingExperiences => 'Nenhuma experiência pendente';

  @override
  String get confirmApproveExperience =>
      'Tem certeza de que deseja aprovar esta experiência?';

  @override
  String get setAsNotPublished => 'Marcar como não publicada';

  @override
  String get explainNotPublished =>
      'Explique por que esta experiência não será publicada...';

  @override
  String get suggestRefinement => 'Sugerir aprimoramento';

  @override
  String get provideRefinementFeedback =>
      'Descreva o aprimoramento sugerido...';

  @override
  String get pleaseProvideReason => 'Informe um motivo';

  @override
  String get provideAReason => 'Informe um motivo...';

  @override
  String confirmRemoveMemberNamed(String name) {
    return 'Tem certeza de que deseja remover \"$name\" deste grupo?';
  }

  @override
  String confirmMemberAction(String action, String name) {
    return 'Tem certeza de que deseja $action \"$name\"?';
  }

  @override
  String get noEmailRegistered => 'Nenhum e-mail cadastrado';

  @override
  String get confirmation => 'Confirmação';

  @override
  String get moderation => 'Moderação';

  @override
  String get moderationFilterAwaiting => 'Aguardando';

  @override
  String get moderationFilterRefinement => 'Aprimoramento';

  @override
  String get approved => 'Aprovada';

  @override
  String get approve => 'Aprovar';

  @override
  String get approveExperience => 'Aprovar experiência';

  @override
  String get experienceApproved => 'Experiência aprovada com sucesso';

  @override
  String get revert => 'Reverter';

  @override
  String get refine => 'Aprimorar';

  @override
  String get reject => 'Recusar';

  @override
  String errorJoiningGroup(String error) {
    return 'Erro ao entrar no grupo: $error';
  }

  @override
  String get noPermissionToDeleteExperience =>
      'Você não tem permissão para excluir esta experiência';

  @override
  String get noPermissionToLockExperience =>
      'Você não tem permissão para bloquear esta experiência';

  @override
  String get messageNotFound => 'Mensagem não encontrada.';

  @override
  String get messageDeletedSuccessfully => 'Mensagem excluída com sucesso';

  @override
  String welcomeBack(String name) {
    return 'Bem-vindo de volta, $name';
  }

  @override
  String get journeyResources => 'Recursos da jornada';

  @override
  String get restartJourney => 'Reiniciar jornada';

  @override
  String get aboutThisJourney => 'Sobre esta jornada';

  @override
  String aboutNamed(String title) {
    return 'Sobre $title';
  }

  @override
  String get resetJourneyTitle => 'Reiniciar esta jornada';

  @override
  String get resetJourneyDescription =>
      'Reiniciar a jornada apaga todo o progresso feito até agora. Esta ação não pode ser desfeita.';

  @override
  String get resetJourneyConfirm => 'Reiniciar jornada';

  @override
  String get journeyResetSuccess => 'Jornada reiniciada com sucesso';

  @override
  String errorResettingJourney(String error) {
    return 'Erro ao reiniciar a jornada: $error';
  }
}
