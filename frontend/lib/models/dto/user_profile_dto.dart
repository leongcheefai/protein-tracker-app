class UserProfileDto {
  final String id;
  final String? displayName;
  final String? email;
  final int? age;
  final double? weight;
  final double? height;
  final double? dailyProteinGoal;
  final String? activityLevel;
  final List<String>? dietaryRestrictions;
  final String? units;
  final bool notificationsEnabled;
  final String? privacyLevel;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfileDto({
    required this.id,
    this.displayName,
    this.email,
    this.age,
    this.weight,
    this.height,
    this.dailyProteinGoal,
    this.activityLevel,
    this.dietaryRestrictions,
    this.units,
    this.notificationsEnabled = true,
    this.privacyLevel,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
      email: json['email'] as String?,
      age: json['age'] as int?,
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      dailyProteinGoal: json['daily_protein_goal']?.toDouble(),
      activityLevel: json['activity_level'] as String?,
      dietaryRestrictions: json['dietary_restrictions'] != null
          ? List<String>.from(json['dietary_restrictions'])
          : null,
      units: json['units'] as String?,
      notificationsEnabled: json['notifications_enabled'] ?? true,
      privacyLevel: json['privacy_level'] as String?,
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
      'display_name': displayName,
      'email': email,
      'age': age,
      'weight': weight,
      'height': height,
      'daily_protein_goal': dailyProteinGoal,
      'activity_level': activityLevel,
      'dietary_restrictions': dietaryRestrictions,
      'units': units,
      'notifications_enabled': notificationsEnabled,
      'privacy_level': privacyLevel,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserProfileDto copyWith({
    String? id,
    String? displayName,
    String? email,
    int? age,
    double? weight,
    double? height,
    double? dailyProteinGoal,
    String? activityLevel,
    List<String>? dietaryRestrictions,
    String? units,
    bool? notificationsEnabled,
    String? privacyLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileDto(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      dailyProteinGoal: dailyProteinGoal ?? this.dailyProteinGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      units: units ?? this.units,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}