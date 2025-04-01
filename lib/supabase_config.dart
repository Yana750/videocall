import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url:"https://njgrfdshknmqyisqzpbn.supabase.co",
      anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5qZ3JmZHNoa25tcXlpc3F6cGJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM0NTQ4OTMsImV4cCI6MjA1OTAzMDg5M30.gS-rfdNXauFWBjJ5bszEnBvTGuxzTdI4tfoLdjgkDmE");
  }

  static SupabaseClient get client => Supabase.instance.client;
}