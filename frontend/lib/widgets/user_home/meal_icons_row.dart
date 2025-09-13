import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/meal_config.dart';

/// A pure UI widget that displays meal icons in a horizontal row
/// 
/// This widget is completely independent of progress data and only shows
/// the meal types with their icons. It's designed for static displays
/// or places where you want to show available meal types without progress.
class MealIconsRow extends StatelessWidget {
  final List<MealType> mealTypes;
  final double iconSize;
  final Color? iconColor;
  final Color? disabledColor;
  final bool showLabels;
  final EdgeInsets? itemPadding;
  final double? itemSpacing;
  final Function(MealType)? onMealTypeTap;
  final Set<String>? disabledMealTypes;

  const MealIconsRow({
    super.key,
    required this.mealTypes,
    this.iconSize = 24.0,
    this.iconColor,
    this.disabledColor,
    this.showLabels = true,
    this.itemPadding,
    this.itemSpacing = 16.0,
    this.onMealTypeTap,
    this.disabledMealTypes,
  });

  /// Create from enabled meal type IDs (most common use case)
  factory MealIconsRow.fromEnabledIds({
    required List<String> enabledMealTypeIds,
    double iconSize = 24.0,
    Color? iconColor,
    Color? disabledColor,
    bool showLabels = true,
    EdgeInsets? itemPadding,
    double? itemSpacing = 16.0,
    Function(MealType)? onMealTypeTap,
    Set<String>? disabledMealTypes,
  }) {
    final mealTypes = MealConfig.getEnabledMealTypes(enabledMealTypeIds);
    return MealIconsRow(
      mealTypes: mealTypes,
      iconSize: iconSize,
      iconColor: iconColor,
      disabledColor: disabledColor,
      showLabels: showLabels,
      itemPadding: itemPadding,
      itemSpacing: itemSpacing,
      onMealTypeTap: onMealTypeTap,
      disabledMealTypes: disabledMealTypes,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (mealTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: showLabels ? 70 : 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: mealTypes.length,
        separatorBuilder: (context, index) => SizedBox(width: itemSpacing ?? 16.0),
        itemBuilder: (context, index) {
          final mealType = mealTypes[index];
          final isDisabled = disabledMealTypes?.contains(mealType.id) ?? false;
          final effectiveIconColor = isDisabled 
              ? (disabledColor ?? AppColors.neutral.withValues(alpha: 0.3))
              : (iconColor ?? AppColors.primary);

          return GestureDetector(
            onTap: onMealTypeTap != null ? () => onMealTypeTap!(mealType) : null,
            child: Container(
              padding: itemPadding ?? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    mealType.icon,
                    size: iconSize,
                    color: effectiveIconColor,
                  ),
                  if (showLabels) ...[
                    const SizedBox(height: 4),
                    Text(
                      mealType.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDisabled 
                            ? (disabledColor ?? AppColors.neutral.withValues(alpha: 0.3))
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A compact version of MealIconsRow for smaller spaces
class CompactMealIconsRow extends StatelessWidget {
  final List<MealType> mealTypes;
  final double iconSize;
  final Color? iconColor;
  final Color? disabledColor;
  final Function(MealType)? onMealTypeTap;
  final Set<String>? disabledMealTypes;

  const CompactMealIconsRow({
    super.key,
    required this.mealTypes,
    this.iconSize = 20.0,
    this.iconColor,
    this.disabledColor,
    this.onMealTypeTap,
    this.disabledMealTypes,
  });

  /// Create from enabled meal type IDs
  factory CompactMealIconsRow.fromEnabledIds({
    required List<String> enabledMealTypeIds,
    double iconSize = 20.0,
    Color? iconColor,
    Color? disabledColor,
    Function(MealType)? onMealTypeTap,
    Set<String>? disabledMealTypes,
  }) {
    final mealTypes = MealConfig.getEnabledMealTypes(enabledMealTypeIds);
    return CompactMealIconsRow(
      mealTypes: mealTypes,
      iconSize: iconSize,
      iconColor: iconColor,
      disabledColor: disabledColor,
      onMealTypeTap: onMealTypeTap,
      disabledMealTypes: disabledMealTypes,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (mealTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: mealTypes.asMap().entries.map((entry) {
        final index = entry.key;
        final mealType = entry.value;
        final isDisabled = disabledMealTypes?.contains(mealType.id) ?? false;
        final effectiveIconColor = isDisabled 
            ? (disabledColor ?? AppColors.neutral.withValues(alpha: 0.3))
            : (iconColor ?? AppColors.primary);

        return Padding(
          padding: EdgeInsets.only(right: index < mealTypes.length - 1 ? 12.0 : 0),
          child: GestureDetector(
            onTap: onMealTypeTap != null ? () => onMealTypeTap!(mealType) : null,
            child: Icon(
              mealType.icon,
              size: iconSize,
              color: effectiveIconColor,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Helper widget to show all available meal types (for settings screens)
class AllMealTypesGrid extends StatelessWidget {
  final Function(MealType)? onMealTypeTap;
  final Set<String>? selectedMealTypes;
  final double iconSize;

  const AllMealTypesGrid({
    super.key,
    this.onMealTypeTap,
    this.selectedMealTypes,
    this.iconSize = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.0,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: MealConfig.allMealTypes.length,
      itemBuilder: (context, index) {
        final mealType = MealConfig.allMealTypes[index];
        final isSelected = selectedMealTypes?.contains(mealType.id) ?? false;

        return GestureDetector(
          onTap: onMealTypeTap != null ? () => onMealTypeTap!(mealType) : null,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.neutral.withValues(alpha: 0.3),
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  mealType.icon,
                  size: iconSize,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  mealType.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}