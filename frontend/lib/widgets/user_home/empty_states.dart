import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../main.dart';

class EmptyStates extends StatelessWidget {
  final VoidCallback onTakePhotoPressed;
  final VoidCallback onClearFiltersPressed;

  const EmptyStates({
    super.key,
    required this.onTakePhotoPressed,
    required this.onClearFiltersPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(); // This will be used as a base class
  }

  static Widget buildEmptyState(VoidCallback onTakePhotoPressed) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutral.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          const Icon(
            CupertinoIcons.house,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            'No foods logged today',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start by taking a photo of your meal',
            style: TextStyle(
              color: Color(0xFF6B7280), // AppColors.textSecondary
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            onPressed: onTakePhotoPressed,
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.camera,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Take Your First Photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  static Widget buildNoResultsState(VoidCallback onClearFiltersPressed) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutral.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          const Icon(
            CupertinoIcons.search,
            size: 48,
            color: Color(0xFF6B7280), // AppColors.textSecondary
          ),
          const SizedBox(height: 16),
          const Text(
            'No foods found',
            style: TextStyle(
              color: Color(0xFF6B7280), // AppColors.textSecondary
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filter criteria',
            style: TextStyle(
              color: Color(0xFF6B7280), // AppColors.textSecondary
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            onPressed: onClearFiltersPressed,
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.clear,
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Clear Filters',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}
