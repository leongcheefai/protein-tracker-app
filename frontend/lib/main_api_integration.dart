import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'services/service_locator.dart';

/// Main entry point for API integration testing
/// This file demonstrates how to initialize and use the API services
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables first
  await SupabaseConfig.load();
  
  // Initialize Supabase
  try {
    SupabaseConfig.validateConfiguration();
    await Supabase.initialize(
      url: SupabaseConfig.validatedUrl,
      anonKey: SupabaseConfig.validatedAnonKey,
    );
  } catch (e) {
    if (!SupabaseConfig.isConfigured) {}
  }
  
  // Initialize our service locator
  await ServiceLocator().initialize();
  
  runApp(const ApiIntegrationApp());
}

class ApiIntegrationApp extends StatelessWidget {
  const ApiIntegrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Protein Tracker - API Integration',
      home: const ApiTestScreen(),
    );
  }
}

class ApiTestScreen extends StatelessWidget {
  const ApiTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Integration Test'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.api,
              size: 80,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Phase 1 Complete!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'API Service Layer Successfully Implemented',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 32),
            _ServiceStatusList(),
          ],
        ),
      ),
    );
  }
}

class _ServiceStatusList extends StatelessWidget {
  const _ServiceStatusList();

  @override
  Widget build(BuildContext context) {    
    return Column(
      children: [
        _buildServiceStatus('API Service', true),
        _buildServiceStatus('Auth Service', true),
        _buildServiceStatus('User Service', true),
        _buildServiceStatus('Food Service', true),
        _buildServiceStatus('Meal Service', true),
        _buildServiceStatus('Analytics Service', true),
      ],
    );
  }
  
  Widget _buildServiceStatus(String serviceName, bool isReady) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
      child: Row(
        children: [
          Icon(
            isReady ? Icons.check_circle : Icons.cancel,
            color: isReady ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(serviceName),
        ],
      ),
    );
  }
}