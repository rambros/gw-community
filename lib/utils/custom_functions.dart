
import '/data/models/enums/enums.dart';
import '/data/models/structs/index.dart';

bool hasUploadedMedia(String? mediaPath) {
  return mediaPath != null && mediaPath.isNotEmpty;
}

String getAdminRole() {
  return "Admin";
}

String getUserRole() {
  return 'User';
}

String? getInitials(String fullName) {
  List<String> words = fullName.split(' ');
  List<String> initials = words.where((s) => s.isNotEmpty).toList();

  if (initials.isEmpty) {
    return null;
  }

  String firstLetter = initials.first.substring(0, 1);
  String secondLetter =
      (initials.length > 1 ? initials.last.substring(0, 1) : '');
  return firstLetter + secondLetter;
}

bool? isLastStep(
  int indexListSteps,
  int? totalSteps,
) {
  bool isLast = false;
  totalSteps ?? 0;
  isLast = indexListSteps == totalSteps! - 1 ? true : false;
  return isLast;
}

String getFilterLineContent(
  String? author,
  String? event,
  String? year,
  List<String>? topics,
  String? journey,
  String? group,
) {
  String baseline = '';

  if (author!.trim().isNotEmpty) {
    baseline += '${baseline.isNotEmpty ? ", " : ""}Author = $author';
  }
  if (event!.trim().isNotEmpty) {
    baseline += '${baseline.isNotEmpty ? ", " : ""}event = $event';
  }

  if (year!.trim().isNotEmpty) {
    baseline += '${baseline.isNotEmpty ? ", " : ""}year = $year';
  }

  if (topics!.isNotEmpty) {
    baseline +=
        '${baseline.isNotEmpty ? ", " : ""}topics = ${topics.join(', ')}';
  }

  if (journey!.trim().isNotEmpty) {
    baseline += '${baseline.isNotEmpty ? ", " : ""}journey = $journey';
  }

  if (group!.trim().isNotEmpty) {
    baseline += '${baseline.isNotEmpty ? ", " : ""}group = $group';
  }

  if (baseline.isNotEmpty) {
    return 'Filter by $baseline';
  } else {
    return '';
  }
}

OrderSQLTypeStruct getOrderSQL(SortContentType contentType) {
  OrderSQLTypeStruct orderSQL = OrderSQLTypeStruct(column: 'title', asc: true);

  switch (contentType) {
    case SortContentType.mostLiked:
      orderSQL.column = 'num_likes';
      orderSQL.asc = false;
      //response = supabase
      //    .from('view_content')
      //    .select('*')
      //    .order('num_likes', ascending: false);
      break;
    case SortContentType.mostViewed:
      orderSQL.column = 'num_views';
      orderSQL.asc = false;
      //response = supabase
      //    .from('view_content')
      //    .select('*')
      //    .order('num_views', ascending: false);
      break;
    case SortContentType.mostRecent:
      orderSQL.column = 'date_published';
      orderSQL.asc = false;
      //response = supabase
      //    .from('view_content')
      //    .select('*')
      //    .order('date_published', ascending: false);
      break;
    case SortContentType.oldest:
      orderSQL.column = 'date_published';
      orderSQL.asc = true;
      //response = supabase
      //    .from('view_content')
      //    .select('*')
      //    .order('date_published', ascending: true);
      break;
    default:
      orderSQL.column = 'title';
      orderSQL.asc = true;
  }
  return orderSQL;
}

bool checkStepIniciouMais1Dia(DateTime dateStartedStep) {
  final now = DateTime.now();
  // Remove time component for date comparison
  final today = DateTime(now.year, now.month, now.day);
  final compareDate = DateTime(
      dateStartedStep.year, dateStartedStep.month, dateStartedStep.day);

  return today.difference(compareDate).inDays >= 1;
}
