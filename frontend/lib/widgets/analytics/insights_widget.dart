import 'package:flutter/cupertino.dart';
import '../../main.dart';
import '../../models/dto/analytics_dto.dart';

class InsightsWidget extends StatelessWidget {
  final List<InsightDto> insights;
  final String? category;

  const InsightsWidget({
    super.key,
    required this.insights,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final filteredInsights = category != null 
        ? insights.where((i) => i.category == category).toList()
        : insights;

    if (filteredInsights.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              CupertinoIcons.lightbulb,
              size: 48,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 12),
            Text(
              'No insights available yet',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep logging meals to get personalized insights!',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.lightbulb_fill,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                category != null ? '${_formatCategory(category!)} Insights' : 'Insights',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...filteredInsights.take(5).map((insight) => _buildInsightItem(insight)),
        ],
      ),
    );
  }

  Widget _buildInsightItem(InsightDto insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getInsightColor(insight.type).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getInsightColor(insight.type).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getInsightIcon(insight.type),
                color: _getInsightColor(insight.type),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  insight.title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (insight.priority > 0.8)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'HIGH',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insight.message,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (insight.priority > 0.8) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  CupertinoIcons.hand_point_right_fill,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'High priority insight',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Text(
            _formatInsightDate(insight.generatedAt),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getInsightColor(String type) {
    switch (type.toLowerCase()) {
      case 'success':
        return AppColors.success;
      case 'warning':
        return AppColors.warning;
      case 'tip':
        return AppColors.primary;
      case 'achievement':
        return AppColors.success;
      case 'reminder':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  IconData _getInsightIcon(String type) {
    switch (type.toLowerCase()) {
      case 'success':
        return CupertinoIcons.checkmark_circle_fill;
      case 'warning':
        return CupertinoIcons.exclamationmark_triangle_fill;
      case 'tip':
        return CupertinoIcons.lightbulb_fill;
      case 'achievement':
        return CupertinoIcons.star_fill;
      case 'reminder':
        return CupertinoIcons.bell_fill;
      default:
        return CupertinoIcons.info_circle_fill;
    }
  }

  String _formatCategory(String category) {
    return category.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }

  String _formatInsightDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class AchievementBadge extends StatelessWidget {
  final BadgeDto badge;
  final bool earned;

  const AchievementBadge({
    super.key,
    required this.badge,
    this.earned = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: earned 
          ? AppColors.success.withValues(alpha: 0.1)
          : CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
        border: earned
          ? Border.all(color: AppColors.success.withValues(alpha: 0.3), width: 2)
          : null,
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: earned ? AppColors.success : CupertinoColors.systemGrey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getBadgeIcon(badge.category),
              color: CupertinoColors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.name,
            style: TextStyle(
              color: earned ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (earned && badge.earnedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              _formatDate(badge.earnedAt!),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getBadgeIcon(String category) {
    switch (category.toLowerCase()) {
      case 'streak':
        return CupertinoIcons.flame_fill;
      case 'goal':
        return CupertinoIcons.scope;
      case 'consistency':
        return CupertinoIcons.checkmark_circle_fill;
      case 'milestone':
        return CupertinoIcons.star_fill;
      default:
        return CupertinoIcons.rosette;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}