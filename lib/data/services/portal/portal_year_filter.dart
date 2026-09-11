int? parsePublishedYear(String year) => int.tryParse(year.trim());

bool matchesPublishedYear({
  required String year,
  DateTime? datePublished,
  num? yearPublished,
}) {
  final selected = parsePublishedYear(year);
  if (selected == null) return true;
  if (yearPublished?.toInt() == selected) return true;
  return datePublished?.year == selected;
}

/// Filters on `date_published` instead of the computed `year_published`
/// column. PostgREST `eq` on EXTRACT(year) (float8) often fails to match.
dynamic applyDatePublishedYearFilter(dynamic query, String year) {
  final selected = parsePublishedYear(year);
  if (selected == null) return query;
  return query
      .gte('date_published', '$selected-01-01')
      .lt('date_published', '${selected + 1}-01-01');
}
