import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  /// Load environment variables from .env file
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Could not load .env file: $e');
        print('Make sure .env file exists in the root directory');
      }
    }
  }

  /// Supabase configuration from .env file
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  /// Validates that all required Supabase configuration is provided
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }
  
  /// Returns a detailed configuration status for debugging
  static String get configurationStatus {
    final buffer = StringBuffer();
    buffer.writeln('Supabase Configuration Status:');
    buffer.writeln('  URL: ${supabaseUrl.isEmpty ? "❌ Missing" : "✅ Configured"}');
    buffer.writeln('  Anon Key: ${supabaseAnonKey.isEmpty ? "❌ Missing" : "✅ Configured"}');
    
    if (!isConfigured) {
      buffer.writeln('');
      buffer.writeln('To configure:');
      buffer.writeln('  1. Create a .env file in the root directory');
      buffer.writeln('  2. Add your Supabase credentials:');
      buffer.writeln('     SUPABASE_URL=https://your-project.supabase.co');
      buffer.writeln('     SUPABASE_ANON_KEY=your-anon-key');
      buffer.writeln('  3. Make sure .env is added to pubspec.yaml assets');
    }
    
    return buffer.toString();
  }
  
  /// Validates configuration and throws if invalid
  static void validateConfiguration() {
    if (!isConfigured) {
      if (kDebugMode) {
        print(configurationStatus);
      }
      throw Exception(
        'Supabase configuration missing. '
        'Please create a .env file with SUPABASE_URL and SUPABASE_ANON_KEY. '
        'See .env.example for details.'
      );
    }
  }
  
  /// Safe getter for URL that validates first
  static String get validatedUrl {
    validateConfiguration();
    return supabaseUrl;
  }
  
  /// Safe getter for anon key that validates first
  static String get validatedAnonKey {
    validateConfiguration();
    return supabaseAnonKey;
  }
}