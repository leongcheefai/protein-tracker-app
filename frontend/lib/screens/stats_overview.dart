import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/progress_provider.dart';
import '../services/analytics_service.dart';

class StatsOverview extends StatefulWidget {
  final double dailyProteinTarget;

  const StatsOverview({
    super.key,
    required this.dailyProteinTarget,
  });

  @override
  State<StatsOverview> createState() => _StatsOverviewState();
}

class _StatsOverviewState extends State<StatsOverview> {
  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }
  
  void _loadProgressData() {
    // Initialize progress data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
      if (progressProvider.needsRefresh) {
        progressProvider.loadProgressData();
        progressProvider.loadNutritionTrends(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, child) {
        return CupertinoPageScaffold(
          backgroundColor: AppColors.background,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: AppColors.background,
            border: null,
            middle: const Text(
              'Stats Overview',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: progressProvider.isLoading ? null : () {
                progressProvider.refreshStats();
              },
              child: progressProvider.isLoading 
                ? const CupertinoActivityIndicator()
                : const Icon(CupertinoIcons.refresh, color: AppColors.primary),
            ),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: const Icon(
                CupertinoIcons.back,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          child: SafeArea(
            child: progressProvider.isLoading 
              ? const Center(child: CupertinoActivityIndicator())
              : progressProvider.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.exclamationmark_triangle, 
                          size: 48, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load stats',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          progressProvider.error!,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        CupertinoButton.filled(
                          onPressed: () => progressProvider.refreshStats(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // Today's Stats Card
                      _buildStatCard(
                        title: 'Today\'s Protein',
                        value: '${progressProvider.todaysProteinAchievement.round()}g',
                        subtitle: 'Goal: ${progressProvider.todaysProteinGoal.round()}g',
                        icon: CupertinoIcons.chart_bar_fill,
                        color: progressProvider.isTodaysGoalMet ? AppColors.success : AppColors.primary,
                      ),
                      const SizedBox(height: 16),

                      // Weekly Average Card
                      _buildStatCard(
                        title: 'Weekly Average',
                        value: '${progressProvider.getWeeklyAverage('protein').round()}g',
                        subtitle: 'Last 7 days',
                        icon: CupertinoIcons.chart_bar_fill,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),

                      // Goal Hit Rate Card
                      if (progressProvider.hasWeeklyStats) 
                        _buildStatCard(
                          title: 'Goal Hit Rate',
                          value: '${(progressProvider.weeklyStats!.successRate * 100).round()}%',
                          subtitle: '${progressProvider.weeklyStats!.goalMetDays}/${progressProvider.weeklyStats!.totalDays} days',
                          icon: CupertinoIcons.checkmark_circle_fill,
                          color: AppColors.success,
                        ),
                      const SizedBox(height: 16),

                      // Streak Information Card
                      _buildStreakCard(progressProvider),
                      const SizedBox(height: 16),

                      // Monthly Average Card
                      if (progressProvider.hasWeeklyStats)
                        _buildStatCard(
                          title: 'Monthly Average',
                          value: '${progressProvider.getMonthlyAverage('protein').round()}g',
                          subtitle: 'Last 30 days',
                          icon: CupertinoIcons.calendar,
                          color: AppColors.warning,
                        ),
                      const SizedBox(height: 16),

                      // Insights Section
                      if (progressProvider.insights.isNotEmpty) ...[
                        _buildInsightsCard(progressProvider),
                        const SizedBox(height: 16),
                      ],

                      // Badges Section
                      if (progressProvider.badges.isNotEmpty) ...[
                        _buildBadgesCard(progressProvider),
                        const SizedBox(height: 16),
                      ],

                      // Export Data Button
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton.filled(
                          onPressed: () => _showExportDialog(progressProvider),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.square_arrow_up,
                                color: CupertinoColors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Export Data',
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(ProgressProvider progressProvider) {
    final currentStreak = progressProvider.currentStreak;
    final longestStreak = progressProvider.longestStreak;
    
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12.0),
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
          const Text(
            'Streaks',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Icon(
                        CupertinoIcons.flame_fill,
                        color: AppColors.success,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$currentStreak',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Current',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Icon(
                        CupertinoIcons.star_fill,
                        color: AppColors.warning,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$longestStreak',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Longest',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(ProgressProvider progressProvider) {
    final insights = progressProvider.insights.take(3).toList(); // Show top 3 insights
    
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12.0),
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
          const Text(
            'Insights',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.lightbulb_fill,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight.message,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBadgesCard(ProgressProvider progressProvider) {
    final earnedBadges = progressProvider.getEarnedBadges().take(6).toList();
    
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12.0),
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
          const Text(
            'Achievements',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: earnedBadges.map((badge) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                badge.name,
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )).toList(),
          ),
          if (earnedBadges.isEmpty)
            const Text(
              'Keep logging meals to earn achievements!',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  void _showExportDialog(ProgressProvider progressProvider) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Export Data'),
        content: const Text('Choose the format for your data export:'),
        actions: [
          CupertinoDialogAction(
            child: const Text('CSV'),
            onPressed: () async {
              Navigator.of(context).pop();
              final downloadUrl = await progressProvider.exportData(ExportFormat.csv);
              if (downloadUrl != null && mounted) {
                _showExportSuccess(downloadUrl);
              }
            },
          ),
          CupertinoDialogAction(
            child: const Text('JSON'),
            onPressed: () async {
              Navigator.of(context).pop();
              final downloadUrl = await progressProvider.exportData(ExportFormat.json);
              if (downloadUrl != null && mounted) {
                _showExportSuccess(downloadUrl);
              }
            },
          ),
          CupertinoDialogAction(
            child: const Text('Cancel'),
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showExportSuccess(String downloadUrl) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Export Complete'),
        content: Text('Your data export is ready. Download URL: $downloadUrl'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}