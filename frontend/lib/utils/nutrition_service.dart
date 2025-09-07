import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NutritionData {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;

  NutritionData({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
  });

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    return NutritionData(
      calories: (json['calories'] ?? 0.0).toDouble(),
      protein: (json['protein'] ?? 0.0).toDouble(),
      carbs: (json['carbs'] ?? 0.0).toDouble(),
      fat: (json['fat'] ?? 0.0).toDouble(),
      fiber: (json['fiber'] ?? 0.0).toDouble(),
      sugar: (json['sugar'] ?? 0.0).toDouble(),
      sodium: (json['sodium'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
    };
  }

  NutritionData operator +(NutritionData other) {
    return NutritionData(
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fat: fat + other.fat,
      fiber: fiber + other.fiber,
      sugar: sugar + other.sugar,
      sodium: sodium + other.sodium,
    );
  }

  NutritionData operator *(double multiplier) {
    return NutritionData(
      calories: calories * multiplier,
      protein: protein * multiplier,
      carbs: carbs * multiplier,
      fat: fat * multiplier,
      fiber: fiber * multiplier,
      sugar: sugar * multiplier,
      sodium: sodium * multiplier,
    );
  }
}

class Food {
  final String id;
  final String name;
  final String? category;
  final String? brand;
  final NutritionData nutritionPer100g;
  final List<Portion> commonPortions;
  final bool verified;

  Food({
    required this.id,
    required this.name,
    this.category,
    this.brand,
    required this.nutritionPer100g,
    required this.commonPortions,
    required this.verified,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    final nutritionJson = json['nutrition_per_100g'] as Map<String, dynamic>? ?? {};
    final portionsJson = json['common_portions'] as List<dynamic>? ?? [];
    
    return Food(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'],
      brand: json['brand'],
      nutritionPer100g: NutritionData.fromJson(nutritionJson),
      commonPortions: portionsJson.map((p) => Portion.fromJson(p)).toList(),
      verified: json['verified'] ?? false,
    );
  }
}

class Portion {
  final String name;
  final double grams;

  Portion({
    required this.name,
    required this.grams,
  });

  factory Portion.fromJson(Map<String, dynamic> json) {
    return Portion(
      name: json['name'] ?? '',
      grams: (json['grams'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'grams': grams,
    };
  }
}

class MealFood {
  final String id;
  final Food food;
  final double quantity;
  final String unit;
  final NutritionData nutritionData;

  MealFood({
    required this.id,
    required this.food,
    required this.quantity,
    required this.unit,
    required this.nutritionData,
  });

  factory MealFood.fromJson(Map<String, dynamic> json) {
    return MealFood(
      id: json['id'] ?? '',
      food: Food.fromJson(json['foods'] ?? json['food'] ?? {}),
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? 'grams',
      nutritionData: NutritionData.fromJson(json['nutrition_data'] ?? {}),
    );
  }
}

class Meal {
  final String id;
  final String mealType;
  final DateTime timestamp;
  final String? photoUrl;
  final String? notes;
  final List<MealFood> foods;
  final NutritionData nutrition;

  Meal({
    required this.id,
    required this.mealType,
    required this.timestamp,
    this.photoUrl,
    this.notes,
    required this.foods,
    required this.nutrition,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    final foodsJson = json['foods'] as List<dynamic>? ?? [];
    
    return Meal(
      id: json['id'] ?? '',
      mealType: json['meal_type'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      photoUrl: json['photo_url'],
      notes: json['notes'],
      foods: foodsJson.map((f) => MealFood.fromJson(f)).toList(),
      nutrition: NutritionData.fromJson(json['nutrition'] ?? {}),
    );
  }
}

class NutritionService {
  static const String baseUrl = 'http://localhost:3000/api';
  static String? _authToken;

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  // Meal operations
  static Future<List<Meal>> getUserMeals({
    String? startDate,
    String? endDate,
    String? mealType,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (mealType != null) queryParams['mealType'] = mealType;

    final uri = Uri.parse('$baseUrl/meals').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final mealsJson = data['data'] as List<dynamic>;
        return mealsJson.map((m) => Meal.fromJson(m)).toList();
      }
    }
    
    throw Exception('Failed to load meals');
  }

  static Future<Meal> getMealById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/meals/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return Meal.fromJson(data['data']);
      }
    }
    
    throw Exception('Failed to load meal');
  }

  static Future<Meal> createMeal({
    required String mealType,
    DateTime? timestamp,
    String? photoUrl,
    String? notes,
    List<Map<String, dynamic>>? foods,
  }) async {
    final requestBody = {
      'meal_type': mealType,
      'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
      'photo_url': photoUrl,
      'notes': notes,
      'foods': foods,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/meals'),
      headers: _headers,
      body: json.encode(requestBody),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return Meal.fromJson(data['data']);
      }
    }
    
    throw Exception('Failed to create meal');
  }

  static Future<Meal> updateMeal(String id, Map<String, dynamic> updates) async {
    final response = await http.put(
      Uri.parse('$baseUrl/meals/$id'),
      headers: _headers,
      body: json.encode(updates),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return Meal.fromJson(data['data']);
      }
    }
    
    throw Exception('Failed to update meal');
  }

  static Future<void> deleteMeal(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/meals/$id'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete meal');
    }
  }

  static Future<Map<String, dynamic>> getMealsByDate(String date) async {
    final response = await http.get(
      Uri.parse('$baseUrl/meals/date/$date'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'];
      }
    }
    
    throw Exception('Failed to load meals for date');
  }

  static Future<Map<String, dynamic>> getTodaysSummary() async {
    final response = await http.get(
      Uri.parse('$baseUrl/meals/today/summary'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'];
      }
    }
    
    throw Exception('Failed to load today\'s summary');
  }

  // Food operations
  static Future<List<Food>> searchFoods(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/food/search?q=$query'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final foodsJson = data['data'] as List<dynamic>;
        return foodsJson.map((f) => Food.fromJson(f)).toList();
      }
    }
    
    throw Exception('Failed to search foods');
  }

  // Utility functions
  static NutritionData calculateNutritionForQuantity(
    NutritionData nutritionPer100g,
    double quantity,
    String unit,
  ) {
    double grams = quantity;
    
    // Convert to grams if needed
    if (unit != 'grams' && unit != 'g') {
      // For now, assume other units are already in grams
      // This could be expanded to handle cups, tablespoons, etc.
    }
    
    final multiplier = grams / 100.0;
    return nutritionPer100g * multiplier;
  }

  static String formatNutritionValue(double value) {
    if (value == value.round()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }

  static Color getNutritionProgressColor(double current, double target) {
    final percentage = current / target;
    if (percentage >= 1.0) {
      return const Color(0xFF34C759); // Green - goal met
    } else if (percentage >= 0.8) {
      return const Color(0xFFFF9500); // Orange - close to goal
    } else if (percentage >= 0.5) {
      return const Color(0xFF007AFF); // Blue - making progress
    } else {
      return const Color(0xFF8E8E93); // Gray - needs more
    }
  }
}

// Add this import at the top of the file if it's not already there
// import 'package:flutter/material.dart';