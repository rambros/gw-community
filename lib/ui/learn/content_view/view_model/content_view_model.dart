import 'package:flutter/material.dart';
import '/backend/supabase/supabase.dart';

class ContentViewModel extends ChangeNotifier {
  final int contentId;
  final ViewContentRow viewContentRow;

  ContentViewModel({
    required this.contentId,
    required this.viewContentRow,
  });

  String? get midiaType => viewContentRow.midiaType;

  // Add any other logic here if needed, e.g., tracking views, bookmarking
}
