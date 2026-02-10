import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Check Journey Status Filtering (Case Insensitive)', () async {
    final supabase = SupabaseClient(
      'https://hxhpzoyjjghtekqgfbfh.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh4aHB6b3lqamdodGVrcWdmYmZoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDE5NTQ2NTcsImV4cCI6MjAxNzUzMDY1N30.AXFvKve52GjqNJu9Npg3HCnfQ5suy_ba3n-2_s5ZnDs',
    );

    // 1. Verify that 'Published' and 'published' are accepted in the filter logic
    try {
      final publishedJourneys =
          await supabase.from('cc_journeys').select('id, title, status').inFilter('status', ['published', 'Published']);
      print('Published Journeys (should include both cases if exist): $publishedJourneys');

      // Verify Super Journey is NOT in this list (as it is Draft)
      // Note: This relies on "Super Journey" being 'Draft' as found previously.
      final superJourney = publishedJourneys.where((j) => j['title'].toString().contains('Super Journey'));
      if (superJourney.isNotEmpty) {
        fail('Super Journey (Draft) should NOT be in the published list: $superJourney');
      } else {
        print('SUCCESS: Super Journey excluded correctly.');
      }
    } catch (e) {
      fail('Error querying published journeys: $e');
    }

    // 2. Verify HomeRepository logic (Inner Join)
    try {
      final userJourneys = await supabase
          .from('cc_user_journeys')
          .select('*, cc_journeys!inner(status)')
          .inFilter('cc_journeys.status', ['published', 'Published']).limit(5);
      print('User Journeys with Published Status: $userJourneys');
    } catch (e) {
      fail('Error querying User Journeys with inner join: $e');
    }
  });
}
