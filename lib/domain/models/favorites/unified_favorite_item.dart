import 'package:gw_community/data/services/supabase/supabase.dart';

/// Tipo de favorito
enum FavoriteType {
  recording,
  activity,
}

/// Item unificado de favorito que pode ser um Recording ou Activity
/// Usado para exibir ambos os tipos em uma única lista
class UnifiedFavoriteItem {
  UnifiedFavoriteItem.recording(this.recording)
      : type = FavoriteType.recording,
        activity = null;

  UnifiedFavoriteItem.activity(this.activity)
      : type = FavoriteType.activity,
        recording = null;

  final FavoriteType type;
  final CcViewUserFavoriteRecordingsRow? recording;
  final CcViewUserFavoriteActivitiesRow? activity;

  /// Data em que foi favoritado
  DateTime get favoritedAt {
    if (type == FavoriteType.recording) {
      return recording!.favoritedAt ?? DateTime.now();
    } else {
      return activity!.favoritedAt ?? DateTime.now();
    }
  }

  /// ID do conteúdo
  int get contentId {
    if (type == FavoriteType.recording) {
      return recording!.contentId ?? 0;
    } else {
      return activity!.id;
    }
  }

  /// Título do item
  String get title {
    if (type == FavoriteType.recording) {
      return recording!.title ?? 'Untitled';
    } else {
      return activity!.activityLabel ?? 'Activity';
    }
  }

  /// Descrição ou prompt
  String? get description {
    if (type == FavoriteType.recording) {
      return recording!.description;
    } else {
      return activity!.activityPrompt;
    }
  }

  /// Tipo de mídia (para recordings) ou tipo de activity
  String? get mediaType {
    if (type == FavoriteType.recording) {
      return recording!.midiaType;
    } else {
      return activity!.activityType;
    }
  }

  /// Verifica se é um recording
  bool get isRecording => type == FavoriteType.recording;

  /// Verifica se é uma activity
  bool get isActivity => type == FavoriteType.activity;
}
