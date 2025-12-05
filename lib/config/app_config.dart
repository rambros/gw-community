/// Configurações globais da aplicação
class AppConfig {
  // Previne instanciação
  AppConfig._();

  /// Define se o controle de datas está ativo para navegação entre steps
  /// Quando true: usuário precisa esperar 1 dia após iniciar um step para acessar o próximo
  /// Quando false: usuário pode acessar qualquer step disponível imediatamente
  static const bool enableDateControl = false;

  /// Número de dias que o usuário precisa esperar antes de acessar o próximo step
  /// Só é usado quando enableDateControl é true
  static const int daysToWaitBetweenSteps = 1;
}

