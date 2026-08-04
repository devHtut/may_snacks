// COPY THIS FILE TO 'supabase_config.dart' AND FILL IN YOUR REAL CREDENTIALS.
// DO NOT COMMIT YOUR REAL CREDENTIALS TO GIT.

class SupabaseConfig {
  // Toggle this to false when you want to connect to a real Supabase instance.
  // When true, the application runs entirely offline using a robust mock client.
  static const bool useMock = true;

  // Replace these with your actual Supabase credentials when useMock is false.
  static const String url = 'https://your-project-id.supabase.co';
  static const String anonKey = 'your-anon-public-key';
}
