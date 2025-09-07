import 'api_service.dart';
import 'auth_service.dart';
import 'user_service.dart';
import 'food_service.dart';
import 'meal_service.dart';
import 'analytics_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Service instances
  ApiService? _apiService;
  AuthService? _authService;
  UserService? _userService;
  FoodService? _foodService;
  MealService? _mealService;
  AnalyticsService? _analyticsService;

  // Initialize all services
  Future<void> initialize() async {
    _apiService = ApiService();
    await _apiService!.loadAuthToken();
    
    _authService = AuthService(_apiService!);
    _userService = UserService(_apiService!);
    _foodService = FoodService(_apiService!);
    _mealService = MealService(_apiService!);
    _analyticsService = AnalyticsService(_apiService!);
  }

  // Service getters
  ApiService get apiService {
    if (_apiService == null) {
      throw Exception('ServiceLocator not initialized. Call initialize() first.');
    }
    return _apiService!;
  }

  AuthService get authService {
    if (_authService == null) {
      throw Exception('ServiceLocator not initialized. Call initialize() first.');
    }
    return _authService!;
  }

  UserService get userService {
    if (_userService == null) {
      throw Exception('ServiceLocator not initialized. Call initialize() first.');
    }
    return _userService!;
  }

  FoodService get foodService {
    if (_foodService == null) {
      throw Exception('ServiceLocator not initialized. Call initialize() first.');
    }
    return _foodService!;
  }

  MealService get mealService {
    if (_mealService == null) {
      throw Exception('ServiceLocator not initialized. Call initialize() first.');
    }
    return _mealService!;
  }

  AnalyticsService get analyticsService {
    if (_analyticsService == null) {
      throw Exception('ServiceLocator not initialized. Call initialize() first.');
    }
    return _analyticsService!;
  }

  // Clean up services (useful for testing)
  void dispose() {
    _apiService = null;
    _authService = null;
    _userService = null;
    _foodService = null;
    _mealService = null;
    _analyticsService = null;
  }

  // Update API base URL (useful for switching environments)
  void updateApiBaseUrl(String newBaseUrl) {
    // This would require updating the ApiService constructor
    // For now, we'll dispose and reinitialize
    dispose();
    // Would need to recreate with new base URL
  }
}