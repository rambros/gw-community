import 'package:flutter/material.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/form_field_controller.dart';
import 'package:gw_community/ui/learn/widgets/portal_filter_sheet.dart';

enum PortalListSort {
  relevance,
  dateNewest,
  dateOldest,
  titleAsc,
  titleDesc;

  static List<PortalListSort> get browseOptions =>
      values.where((option) => option != relevance).toList();

  bool get isRelevance => this == relevance;

  PortalListSort get forBrowse => isRelevance ? dateNewest : this;

  String label(AppLocalizations l10n) => switch (this) {
        relevance => l10n.sortByRelevance,
        dateNewest => l10n.sortByDateNewest,
        dateOldest => l10n.sortByDateOldest,
        titleAsc => l10n.sortByTitleAZ,
        titleDesc => l10n.sortByTitleZA,
      };

  String shortLabel(AppLocalizations l10n) => switch (this) {
        relevance => l10n.sortByRelevance,
        dateNewest || dateOldest => l10n.date,
        titleAsc || titleDesc => l10n.title,
      };

  String get queryColumn => switch (this) {
        relevance || dateNewest || dateOldest => 'date_published',
        titleAsc || titleDesc => 'title',
      };

  bool get queryAscending => switch (this) {
        dateOldest || titleAsc => true,
        relevance || dateNewest || titleDesc => false,
      };

  IconData? get directionIcon => switch (this) {
        relevance => null,
        dateOldest || titleAsc => Icons.arrow_upward,
        dateNewest || titleDesc => Icons.arrow_downward,
      };
}

List<T> sortPortalList<T>({
  required List<T> items,
  required PortalListSort sort,
  required String Function(T item) titleOf,
  required DateTime? Function(T item) dateOf,
}) {
  final sorted = List<T>.from(items);
  sorted.sort((a, b) {
    switch (sort) {
      case PortalListSort.dateNewest:
        return _compareDates(dateOf(a), dateOf(b), newestFirst: true);
      case PortalListSort.dateOldest:
        return _compareDates(dateOf(a), dateOf(b), newestFirst: false);
      case PortalListSort.titleAsc:
        return titleOf(a).toLowerCase().compareTo(titleOf(b).toLowerCase());
      case PortalListSort.titleDesc:
        return titleOf(b).toLowerCase().compareTo(titleOf(a).toLowerCase());
      case PortalListSort.relevance:
        return 0;
    }
  });
  return sorted;
}

int _compareDates(DateTime? a, DateTime? b, {required bool newestFirst}) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return newestFirst ? b.compareTo(a) : a.compareTo(b);
}

class PortalSortedList<T> {
  PortalSortedList({
    required this.titleOf,
    required this.dateOf,
  });

  final String Function(T item) titleOf;
  final DateTime? Function(T item) dateOf;

  List<T> _source = [];
  List<T>? _cached;
  PortalListSort _sort = PortalListSort.dateNewest;

  PortalListSort get sort => _sort;
  List<T> get items {
    if (_sort.isRelevance) return _source;
    return _cached ??= sortPortalList(
      items: _source,
      sort: _sort,
      titleOf: titleOf,
      dateOf: dateOf,
    );
  }

  void replace(List<T> items) {
    _source = items;
    _cached = null;
  }

  bool setSort(PortalListSort sort) {
    if (_sort == sort) return false;
    _sort = sort;
    _cached = null;
    return true;
  }
}

class PortalSortButton extends StatelessWidget {
  const PortalSortButton({
    super.key,
    required this.value,
    required this.onChanged,
    this.showRelevance = false,
  });

  final PortalListSort value;
  final ValueChanged<PortalListSort> onChanged;
  final bool showRelevance;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = context.l10n;
    final options = showRelevance ? PortalListSort.values : PortalListSort.browseOptions;
    final overridden = showRelevance && !value.isRelevance;
    final color = overridden ? theme.primary : theme.secondary;
    final directionIcon = value.directionIcon;

    return PopupMenuButton<PortalListSort>(
      tooltip: l10n.sortBy,
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final option in options)
          CheckedPopupMenuItem<PortalListSort>(
            value: option,
            checked: option == value,
            child: Row(
              children: [
                Expanded(child: Text(option.label(l10n))),
                if (option.directionIcon case final optionDirection?)
                  Icon(optionDirection, size: 16, color: theme.secondary),
              ],
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sort, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              value.shortLabel(l10n),
              style: theme.bodySmall.override(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (directionIcon != null) ...[
              const SizedBox(width: 2),
              Icon(directionIcon, size: 16, color: color),
            ],
          ],
        ),
      ),
    );
  }
}

class PortalSortDropdown extends StatelessWidget {
  const PortalSortDropdown({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final FormFieldController<PortalListSort> controller;
  final ValueChanged<PortalListSort> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PortalFilterDropdown<PortalListSort>(
      label: l10n.sortBy,
      controller: controller,
      options: PortalListSort.browseOptions,
      optionLabels: PortalListSort.browseOptions.map((option) => option.label(l10n)).toList(),
      hintText: l10n.sortBy,
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
