class FoodDto {
  final String id;
  final String name;
  final String? category;
  final String? brand;
  final String? barcode;
  final NutritionDataDto nutritionPer100g;
  final List<PortionDto>? commonPortions;
  final bool verified;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FoodDto({
    required this.id,
    required this.name,
    this.category,
    this.brand,
    this.barcode,
    required this.nutritionPer100g,
    this.commonPortions,
    this.verified = false,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory FoodDto.fromJson(Map<String, dynamic> json) {
    return FoodDto(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      brand: json['brand'] as String?,
      barcode: json['barcode'] as String?,
      nutritionPer100g: NutritionDataDto.fromJson(json['nutrition_per_100g']),
      commonPortions: json['common_portions'] != null
          ? (json['common_portions'] as List)
              .map((p) => PortionDto.fromJson(p))
              .toList()
          : null,
      verified: json['verified'] ?? false,
      userId: json['user_id'] as String?,
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
      'name': name,
      'category': category,
      'brand': brand,
      'barcode': barcode,
      'nutrition_per_100g': nutritionPer100g.toJson(),
      'common_portions': commonPortions?.map((p) => p.toJson()).toList(),
      'verified': verified,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class NutritionDataDto {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? fiber;
  final double? sugar;
  final double? sodium;
  final double? saturatedFat;
  final double? transFat;
  final double? cholesterol;
  final double? potassium;
  final double? calcium;
  final double? iron;
  final double? vitaminA;
  final double? vitaminC;

  NutritionDataDto({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
    this.saturatedFat,
    this.transFat,
    this.cholesterol,
    this.potassium,
    this.calcium,
    this.iron,
    this.vitaminA,
    this.vitaminC,
  });

  factory NutritionDataDto.fromJson(Map<String, dynamic> json) {
    return NutritionDataDto(
      calories: json['calories']?.toDouble() ?? 0.0,
      protein: json['protein']?.toDouble() ?? 0.0,
      carbs: json['carbs']?.toDouble() ?? 0.0,
      fat: json['fat']?.toDouble() ?? 0.0,
      fiber: json['fiber']?.toDouble(),
      sugar: json['sugar']?.toDouble(),
      sodium: json['sodium']?.toDouble(),
      saturatedFat: json['saturated_fat']?.toDouble(),
      transFat: json['trans_fat']?.toDouble(),
      cholesterol: json['cholesterol']?.toDouble(),
      potassium: json['potassium']?.toDouble(),
      calcium: json['calcium']?.toDouble(),
      iron: json['iron']?.toDouble(),
      vitaminA: json['vitamin_a']?.toDouble(),
      vitaminC: json['vitamin_c']?.toDouble(),
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
      'saturated_fat': saturatedFat,
      'trans_fat': transFat,
      'cholesterol': cholesterol,
      'potassium': potassium,
      'calcium': calcium,
      'iron': iron,
      'vitamin_a': vitaminA,
      'vitamin_c': vitaminC,
    };
  }

  NutritionDataDto scale(double factor) {
    return NutritionDataDto(
      calories: calories * factor,
      protein: protein * factor,
      carbs: carbs * factor,
      fat: fat * factor,
      fiber: fiber != null ? fiber! * factor : null,
      sugar: sugar != null ? sugar! * factor : null,
      sodium: sodium != null ? sodium! * factor : null,
      saturatedFat: saturatedFat != null ? saturatedFat! * factor : null,
      transFat: transFat != null ? transFat! * factor : null,
      cholesterol: cholesterol != null ? cholesterol! * factor : null,
      potassium: potassium != null ? potassium! * factor : null,
      calcium: calcium != null ? calcium! * factor : null,
      iron: iron != null ? iron! * factor : null,
      vitaminA: vitaminA != null ? vitaminA! * factor : null,
      vitaminC: vitaminC != null ? vitaminC! * factor : null,
    );
  }
}

class PortionDto {
  final String name;
  final double grams;

  PortionDto({
    required this.name,
    required this.grams,
  });

  factory PortionDto.fromJson(Map<String, dynamic> json) {
    return PortionDto(
      name: json['name'] as String,
      grams: json['grams']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'grams': grams,
    };
  }
}

class FoodDetectionResultDto {
  final String id;
  final String userId;
  final String imageUrl;
  final List<DetectedFoodDto> detectedFoods;
  final Map<String, double>? confidenceScores;
  final DateTime processedAt;
  final String status;

  FoodDetectionResultDto({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.detectedFoods,
    this.confidenceScores,
    required this.processedAt,
    required this.status,
  });

  factory FoodDetectionResultDto.fromJson(Map<String, dynamic> json) {
    return FoodDetectionResultDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      imageUrl: json['image_url'] as String,
      detectedFoods: (json['detected_foods'] as List)
          .map((f) => DetectedFoodDto.fromJson(f))
          .toList(),
      confidenceScores: json['confidence_scores'] != null
          ? Map<String, double>.from(json['confidence_scores'])
          : null,
      processedAt: DateTime.parse(json['processed_at']),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_url': imageUrl,
      'detected_foods': detectedFoods.map((f) => f.toJson()).toList(),
      'confidence_scores': confidenceScores,
      'processed_at': processedAt.toIso8601String(),
      'status': status,
    };
  }
}

class DetectedFoodDto {
  final String name;
  final String? category;
  final double confidence;
  final NutritionDataDto? estimatedNutrition;
  final double? estimatedQuantity;
  final String? estimatedUnit;

  DetectedFoodDto({
    required this.name,
    this.category,
    required this.confidence,
    this.estimatedNutrition,
    this.estimatedQuantity,
    this.estimatedUnit,
  });

  factory DetectedFoodDto.fromJson(Map<String, dynamic> json) {
    return DetectedFoodDto(
      name: json['name'] as String,
      category: json['category'] as String?,
      confidence: json['confidence']?.toDouble() ?? 0.0,
      estimatedNutrition: json['estimated_nutrition'] != null
          ? NutritionDataDto.fromJson(json['estimated_nutrition'])
          : null,
      estimatedQuantity: json['estimated_quantity']?.toDouble(),
      estimatedUnit: json['estimated_unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'confidence': confidence,
      'estimated_nutrition': estimatedNutrition?.toJson(),
      'estimated_quantity': estimatedQuantity,
      'estimated_unit': estimatedUnit,
    };
  }
}