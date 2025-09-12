import 'food_dto.dart';

class MealDto {
  final String id;
  final String userId;
  final String mealType;
  final DateTime timestamp;
  final String? photoUrl;
  final String? notes;
  final NutritionDataDto? totalNutrition;
  final List<MealFoodDto> foods;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MealDto({
    required this.id,
    required this.userId,
    required this.mealType,
    required this.timestamp,
    this.photoUrl,
    this.notes,
    this.totalNutrition,
    required this.foods,
    this.createdAt,
    this.updatedAt,
  });

  factory MealDto.fromJson(Map<String, dynamic> json) {
    return MealDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mealType: json['meal_type'] as String,
      timestamp: DateTime.parse(json['timestamp']),
      photoUrl: json['photo_url'] as String?,
      notes: json['notes'] as String?,
      totalNutrition: json['total_nutrition'] != null
          ? NutritionDataDto.fromJson(json['total_nutrition'])
          : null,
      foods: json['foods'] != null
          ? (json['foods'] as List)
              .map((f) => MealFoodDto.fromJson(f))
              .toList()
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'meal_type': mealType,
      'timestamp': timestamp.toIso8601String(),
      'photo_url': photoUrl,
      'notes': notes,
      'total_nutrition': totalNutrition?.toJson(),
      'foods': foods.map((f) => f.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  MealDto copyWith({
    String? id,
    String? userId,
    String? mealType,
    DateTime? timestamp,
    String? photoUrl,
    String? notes,
    NutritionDataDto? totalNutrition,
    List<MealFoodDto>? foods,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mealType: mealType ?? this.mealType,
      timestamp: timestamp ?? this.timestamp,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
      totalNutrition: totalNutrition ?? this.totalNutrition,
      foods: foods ?? this.foods,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MealFoodDto {
  final String id;
  final String mealId;
  final String foodId;
  final FoodDto? food; // Populated when meal is fetched with food details
  final double quantity;
  final String unit;
  final NutritionDataDto? nutritionData;
  final DateTime? createdAt;

  MealFoodDto({
    required this.id,
    required this.mealId,
    required this.foodId,
    this.food,
    required this.quantity,
    required this.unit,
    this.nutritionData,
    this.createdAt,
  });

  factory MealFoodDto.fromJson(Map<String, dynamic> json) {
    return MealFoodDto(
      id: json['id'] as String,
      mealId: json['meal_id'] as String,
      foodId: json['food_id'] as String,
      food: json['food'] != null ? FoodDto.fromJson(json['food']) : null,
      quantity: json['quantity']?.toDouble() ?? 0.0,
      unit: json['unit'] as String,
      nutritionData: json['nutrition_data'] != null
          ? NutritionDataDto.fromJson(json['nutrition_data'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meal_id': mealId,
      'food_id': foodId,
      'food': food?.toJson(),
      'quantity': quantity,
      'unit': unit,
      'nutrition_data': nutritionData?.toJson(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  MealFoodDto copyWith({
    String? id,
    String? mealId,
    String? foodId,
    FoodDto? food,
    double? quantity,
    String? unit,
    NutritionDataDto? nutritionData,
    DateTime? createdAt,
  }) {
    return MealFoodDto(
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      foodId: foodId ?? this.foodId,
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      nutritionData: nutritionData ?? this.nutritionData,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class NutritionSummaryDto {
  final DateTime date;
  final NutritionDataDto totalNutrition;
  final Map<String, NutritionDataDto> mealBreakdown;
  final double proteinGoal;
  final double proteinProgress;
  final int mealCount;

  NutritionSummaryDto({
    required this.date,
    required this.totalNutrition,
    required this.mealBreakdown,
    required this.proteinGoal,
    required this.proteinProgress,
    required this.mealCount,
  });

  factory NutritionSummaryDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      // Return default values when json is null
      return NutritionSummaryDto(
        date: DateTime.now(),
        totalNutrition: NutritionDataDto(
          calories: 0,
          protein: 0,
          carbs: 0,
          fat: 0,
          fiber: 0,
          sugar: 0,
          sodium: 0,
        ),
        mealBreakdown: {},
        proteinGoal: 0.0,
        proteinProgress: 0.0,
        mealCount: 0,
      );
    }

    return NutritionSummaryDto(
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
      totalNutrition: json['total_nutrition'] != null 
          ? NutritionDataDto.fromJson(json['total_nutrition'])
          : NutritionDataDto(
              calories: 0,
              protein: 0,
              carbs: 0,
              fat: 0,
              fiber: 0,
              sugar: 0,
              sodium: 0,
            ),
      mealBreakdown: json['meal_breakdown'] != null
          ? Map<String, NutritionDataDto>.from(
              json['meal_breakdown'].map(
                (k, v) => MapEntry(k as String, NutritionDataDto.fromJson(v)),
              ),
            )
          : {},
      proteinGoal: json['protein_goal']?.toDouble() ?? 0.0,
      proteinProgress: json['protein_progress']?.toDouble() ?? 0.0,
      mealCount: json['meal_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'total_nutrition': totalNutrition.toJson(),
      'meal_breakdown': mealBreakdown.map(
        (k, v) => MapEntry(k, v.toJson()),
      ),
      'protein_goal': proteinGoal,
      'protein_progress': proteinProgress,
      'meal_count': mealCount,
    };
  }

  bool get isProteinGoalMet => proteinProgress >= 1.0;
  
  double get proteinPercentage => (proteinProgress * 100).clamp(0, 100);
  
  double get remainingProtein => (proteinGoal - totalNutrition.protein).clamp(0, double.infinity);
}