import 'package:supabase_flutter/supabase_flutter.dart';

export 'database/database.dart';
export 'storage/storage.dart';

String _kSupabaseUrl = 'https://hxhpzoyjjghtekqgfbfh.supabase.co';
String _kSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh4aHB6b3lqamdodGVrcWdmYmZoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDE5NTQ2NTcsImV4cCI6MjAxNzUzMDY1N30.AXFvKve52GjqNJu9Npg3HCnfQ5suy_ba3n-2_s5ZnDs';

class SupaFlow {
  SupaFlow._();

  static SupaFlow? _instance;
  static SupaFlow get instance => _instance ??= SupaFlow._();

  final _supabase = Supabase.instance.client;
  static SupabaseClient get client => instance._supabase;

  static Future initialize() async {
    await Supabase.initialize(
      url: _kSupabaseUrl,
      headers: {
        'X-Client-Info': 'flutterflow',
      },
      anonKey: _kSupabaseAnonKey,
      // Use pkce flow for native apps (persists session)
      authOptions: const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
    );
  }
}
