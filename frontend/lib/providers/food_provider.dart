import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/service_locator.dart';
import '../services/food_service.dart';
import '../services/camera_service.dart';
import '../models/dto/food_dto.dart';

class FoodProvider extends ChangeNotifier {
  final FoodService _foodService = ServiceLocator().foodService;
  final CameraService _cameraService = CameraService();

  // Current detection state
  FoodDetectionResultDto? _currentDetectionResult;
  List<FoodDto> _searchResults = [];
  List<FoodDto> _recentFoods = [];
  List<FoodDto> _customFoods = [];
  List<String> _categories = [];

  // Selected detection/food state
  DetectedFoodDto? _selectedDetectedFood;
  FoodDto? _selectedFood;
  int? _selectedDetectionIndex;

  // Loading states
  bool _isDetecting = false;
  bool _isSearching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // Error states
  String? _errorMessage;
  
  // Search state
  String _lastSearchQuery = '';
  String? _selectedCategory;

  // Getters
  FoodDetectionResultDto? get currentDetectionResult => _currentDetectionResult;
  List<FoodDto> get searchResults => _searchResults;
  List<FoodDto> get recentFoods => _recentFoods;
  List<FoodDto> get customFoods => _customFoods;
  List<String> get categories => _categories;
  
  DetectedFoodDto? get selectedDetectedFood => _selectedDetectedFood;
  FoodDto? get selectedFood => _selectedFood;
  int? get selectedDetectionIndex => _selectedDetectionIndex;
  
  bool get isDetecting => _isDetecting;
  bool get isSearching => _isSearching;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  
  String? get errorMessage => _errorMessage;
  String get lastSearchQuery => _lastSearchQuery;
  String? get selectedCategory => _selectedCategory;

  // Convenience getters
  bool get hasDetectionResults => _currentDetectionResult?.detectedFoods.isNotEmpty ?? false;
  List<DetectedFoodDto> get detectedFoods => _currentDetectionResult?.detectedFoods ?? [];
  bool get hasSelectedDetection => _selectedDetectedFood != null;

  // Food Detection Methods
  Future<bool> detectFoodFromImage(File image) async {
    try {
      _setDetecting(true);
      _clearError();
      _setUploadProgress(0.0);

      final response = await _cameraService.uploadAndAnalyze(
        image,
        onProgress: (sent, total) {
          _setUploadProgress(sent / total);
        },
      );

      if (response.success && response.data != null) {
        _currentDetectionResult = response.data;
        
        // Auto-select first detected food if available
        if (_currentDetectionResult!.detectedFoods.isNotEmpty) {
          selectDetectedFood(0);
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response.error?.message ?? 'Failed to detect food from image');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setDetecting(false);
      _setUploadProgress(0.0);
    }
  }

  Future<bool> detectFoodFromPath(String imagePath) async {
    final imageFile = File(imagePath);
    return await detectFoodFromImage(imageFile);
  }

  // Selection methods
  void selectDetectedFood(int index) {
    if (index >= 0 && index < detectedFoods.length) {
      _selectedDetectionIndex = index;
      _selectedDetectedFood = detectedFoods[index];
      _selectedFood = null; // Clear any selected food from search
      notifyListeners();
    }
  }

  void selectFood(FoodDto food) {
    _selectedFood = food;
    _selectedDetectedFood = null; // Clear any selected detected food
    _selectedDetectionIndex = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedDetectedFood = null;
    _selectedFood = null;
    _selectedDetectionIndex = null;
    notifyListeners();
  }

  // Food Search Methods
  Future<bool> searchFoods(
    String query, {
    String? category,
    int? limit,
    int? offset,
  }) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return true;
    }

    try {
      _setSearching(true);
      _clearError();
      _lastSearchQuery = query;
      
      final response = await _foodService.searchFoods(
        query,
        category: category,
        limit: limit,
        offset: offset,
      );

      if (response.success && response.data != null) {
        _searchResults = response.data!;
        notifyListeners();
        return true;
      } else {
        _setError(response.error?.message ?? 'Failed to search foods');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setSearching(false);
    }
  }

  Future<bool> searchFoodsByCategory(String category) async {
    try {
      _setSearching(true);
      _clearError();
      _selectedCategory = category;
      
      final response = await _foodService.getFoodsByCategory(category);

      if (response.success && response.data != null) {
        _searchResults = response.data!;
        notifyListeners();
        return true;
      } else {
        _setError(response.error?.message ?? 'Failed to get foods by category');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setSearching(false);
    }
  }

  // Recent Foods Methods
  Future<bool> loadRecentFoods({int? limit}) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _foodService.getRecentFoods(limit: limit);

      if (response.success && response.data != null) {
        _recentFoods = response.data!;
        notifyListeners();
        return true;
      } else {
        _setError(response.error?.message ?? 'Failed to load recent foods');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Custom Food Methods
  Future<bool> createCustomFood(FoodDto food) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _foodService.createCustomFood(food);

      if (response.success && response.data != null) {
        _customFoods.add(response.data!);
        notifyListeners();
        return true;
      } else {
        _setError(response.error?.message ?? 'Failed to create custom food');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateFood(String foodId, FoodDto food) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _foodService.updateFood(foodId, food);

      if (response.success && response.data != null) {
        // Update in custom foods list if it exists there
        final index = _customFoods.indexWhere((f) => f.id == foodId);
        if (index != -1) {
          _customFoods[index] = response.data!;
        }
        
        // Update selected food if it's the one being updated
        if (_selectedFood?.id == foodId) {
          _selectedFood = response.data!;
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response.error?.message ?? 'Failed to update food');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteFood(String foodId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _foodService.deleteFood(foodId);

      if (response.success) {
        // Remove from custom foods list
        _customFoods.removeWhere((f) => f.id == foodId);
        
        // Clear selection if the deleted food was selected
        if (_selectedFood?.id == foodId) {
          _selectedFood = null;
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response.error?.message ?? 'Failed to delete food');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Categories Methods
  Future<bool> loadFoodCategories() async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _foodService.getFoodCategories();

      if (response.success && response.data != null) {
        _categories = response.data!;
        notifyListeners();
        return true;
      } else {
        _setError(response.error?.message ?? 'Failed to load food categories');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Barcode Methods
  Future<FoodDto?> getFoodByBarcode(String barcode) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _foodService.getFoodByBarcode(barcode);

      if (response.success && response.data != null) {
        final food = response.data!;
        selectFood(food);
        return food;
      } else {
        _setError(response.error?.message ?? 'Food not found for barcode');
        return null;
      }
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Utility Methods
  NutritionDataDto calculateNutritionForQuantity(
    FoodDto food,
    double quantity,
    String unit,
  ) {
    return _foodService.calculateNutritionForQuantity(food, quantity, unit);
  }

  // Get the currently selected food (either detected or searched)
  FoodDto? getCurrentlySelectedFood() {
    if (_selectedFood != null) {
      return _selectedFood;
    }
    
    if (_selectedDetectedFood != null) {
      // Create a FoodDto from the detected food for consistency
      return FoodDto(
        id: 'detected_${_selectedDetectionIndex}',
        name: _selectedDetectedFood!.name,
        category: _selectedDetectedFood!.category,
        nutritionPer100g: _selectedDetectedFood!.estimatedNutrition ?? 
          NutritionDataDto(calories: 0, protein: 0, carbs: 0, fat: 0),
        verified: false,
      );
    }
    
    return null;
  }

  // Reset/Clear Methods
  void clearDetectionResults() {
    _currentDetectionResult = null;
    _selectedDetectedFood = null;
    _selectedDetectionIndex = null;
    notifyListeners();
  }

  void clearSearchResults() {
    _searchResults = [];
    _lastSearchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  void clearAllData() {
    _currentDetectionResult = null;
    _searchResults = [];
    _selectedDetectedFood = null;
    _selectedFood = null;
    _selectedDetectionIndex = null;
    _lastSearchQuery = '';
    _selectedCategory = null;
    _clearError();
    notifyListeners();
  }

  // State management helpers
  void _setDetecting(bool detecting) {
    _isDetecting = detecting;
    _isUploading = detecting;
    notifyListeners();
  }

  void _setSearching(bool searching) {
    _isSearching = searching;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setUploadProgress(double progress) {
    _uploadProgress = progress;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void clearError() {
    _clearError();
  }
}