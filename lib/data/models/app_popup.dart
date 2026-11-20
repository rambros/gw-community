class AppPopup {
  const AppPopup({
    required this.id,
    required this.bodyMarkdown,
    required this.ctaAction,
    this.title,
    this.imageUrl,
    this.ctaLabel,
    this.ctaTarget,
    this.animation = 'none',
  });

  final String id;
  final String? title;
  final String? imageUrl;
  final String bodyMarkdown;
  final String? ctaLabel;
  final String ctaAction;
  final String? ctaTarget;
  final String animation;

  bool get showsButton {
    final label = ctaLabel?.trim() ?? '';
    final target = ctaTarget?.trim() ?? '';
    return label.isNotEmpty && target.isNotEmpty && ctaAction != 'none';
  }

  factory AppPopup.fromMap(Map<String, dynamic> data) {
    return AppPopup(
      id: data['id'] as String,
      title: data['title'] as String?,
      imageUrl: data['image_url'] as String?,
      bodyMarkdown: data['body_markdown'] as String? ?? '',
      ctaLabel: data['cta_label'] as String?,
      ctaAction: data['cta_action'] as String? ?? 'none',
      ctaTarget: data['cta_target'] as String?,
      animation: _animation(data['animation'] as String?),
    );
  }
}

String _animation(String? value) {
  switch (value) {
    case 'confetti':
    case 'sparkle':
    case 'pulse':
      return value!;
    default:
      return 'none';
  }
}

const appPopupRouteTargets = <String>{
  '/homePage',
  '/journeyPage',
  '/communityPage',
  '/libraryHubPage',
  '/userProfilePage',
  '/inAppNotificationsPage',
};
