import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/support_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/l10n/app_localizations.dart';

enum SupportCategory {
  journey('journey', 'Journey'),
  community('community', 'Community'),
  account('account', 'Account'),
  technical('technical', 'Technical'),
  other('other', 'Other');

  final String value;
  final String label;
  const SupportCategory(this.value, this.label);

  static SupportCategory? fromValue(String? value) {
    if (value == null) return null;
    return SupportCategory.values.firstWhere(
      (c) => c.value == value,
      orElse: () => SupportCategory.other,
    );
  }
}

class NewRequestViewModel extends ChangeNotifier {
  final SupportRepository _repository;
  final String? contextType;
  final int? contextId;
  final String? contextTitle;

  NewRequestViewModel({
    required SupportRepository repository,
    this.contextType,
    this.contextId,
    this.contextTitle,
  }) : _repository = repository {
    // Set default category to 'Other'
    _selectedCategory = SupportCategory.other;

    // Pre-select category based on context if provided
    if (contextType != null) {
      _selectedCategory = SupportCategory.fromValue(contextType);
    }
  }

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  SupportCategory? _selectedCategory;
  bool _isSubmitting = false;
  String? _errorMessage;

  SupportCategory? get selectedCategory => _selectedCategory;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  void setCategory(SupportCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  String? validateTitle(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.pleaseEnterSubject;
    }
    if (value.trim().length < 5) {
      return l10n.subjectMinLength;
    }
    return null;
  }

  String? validateDescription(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.pleaseDescribeQuestion;
    }
    if (value.trim().length < 20) {
      return l10n.descriptionMinLength;
    }
    return null;
  }

  Future<CcSupportRequestsRow?> submit(AppLocalizations l10n) async {
    _errorMessage = null;

    // Validate form
    if (!formKey.currentState!.validate()) {
      return null;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final result = await _repository.createRequest(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        category: _selectedCategory!.value,
        contextType: contextType,
        contextId: contextId,
        contextTitle: contextTitle,
      );

      _isSubmitting = false;

      if (result == null) {
        _errorMessage = l10n.failedToCreateQuestion;
        notifyListeners();
        return null;
      }

      notifyListeners();
      return result;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = l10n.anErrorOccurred('$e');
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
