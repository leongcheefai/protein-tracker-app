import 'package:flutter/material.dart';
import '../main.dart';

class UserHomeScreen extends StatefulWidget {
  final double height;
  final double weight;
  final double trainingMultiplier;
  final String goal;
  final double dailyProteinTarget;
  final Map<String, bool> meals;

  const UserHomeScreen({
    super.key,
    required this.height,
    required this.weight,
    required this.trainingMultiplier,
    required this.goal,
    required this.dailyProteinTarget,
    required this.meals,
  });

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _ringController;
  late AnimationController _pulseController;
  late Animation<double> _ringAnimation;
  late Animation<double> _pulseAnimation;

  // Mock data for demonstration - in real app this would come from a database
  final Map<String, double> _mealProgress = {
    'Breakfast': 25.0,
    'Lunch': 45.0,
    'Dinner': 30.0,
    'Snack': 15.0,
  };

  // Mock recent items data
  final List<Map<String, dynamic>> _recentItems = [
    {
      'name': 'Grilled Chicken Breast',
      'portion': 150.0,
      'protein': 46.5,
      'meal': 'Lunch',
      'time': '12:30 PM',
      'image': 'assets/images/chicken.jpg',
    },
    {
      'name': 'Greek Yogurt',
      'portion': 200.0,
      'protein': 20.0,
      'meal': 'Breakfast',
      'time': '8:15 AM',
      'image': 'assets/images/yogurt.jpg',
    },
    {
      'name': 'Salmon Fillet',
      'portion': 120.0,
      'protein': 28.8,
      'meal': 'Dinner',
      'time': '7:45 PM',
      'image': 'assets/images/salmon.jpg',
    },
  ];

  double get _totalProgress {
    return _mealProgress.values.fold(0.0, (sum, value) => sum + value);
  }

  double get _progressPercentage {
    if (widget.dailyProteinTarget == 0) return 0.0;
    return (_totalProgress / widget.dailyProteinTarget) * 100;
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _ringController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _ringAnimation = Tween<double>(
      begin: 0.0,
      end: _progressPercentage / 100,
    ).animate(CurvedAnimation(
      parent: _ringController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _ringController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ringController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Enhanced Header
            _buildEnhancedHeader(),
            
            // Main Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Advanced Progress Visualization
                    _buildAdvancedProgressVisualization(),
                    
                    const SizedBox(height: 32),
                    
                    // Per-meal Mini-rings
                    _buildPerMealMiniRings(),
                    
                    const SizedBox(height: 32),
                    
                    // Quick Stats Panel
                    _buildQuickStatsPanel(),
                    
                    const SizedBox(height: 32),
                    
                    // Recent Items List
                    _buildRecentItemsList(),
                    
                    const SizedBox(height: 100), // Space for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildEnhancedHeader() {
    final now = DateTime.now();
    final dateString = '${_getMonthName(now.month)} ${now.day}, ${now.year}';
    
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Protein Pace',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: AppColors.textPrimary),
                    onPressed: () {
                      // TODO: Navigate to settings screen
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dateString,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedProgressVisualization() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress Ring
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Ring
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 12,
                    backgroundColor: AppColors.neutral.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.transparent),
                  ),
                ),
                
                // Progress Ring
                AnimatedBuilder(
                  animation: _ringAnimation,
                  builder: (context, child) {
                    return SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: _ringAnimation.value,
                        strokeWidth: 12,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(_progressPercentage),
                        ),
                      ),
                    );
                  },
                ),
                
                // Center Content
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_totalProgress.toStringAsFixed(1)}g',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'of ${widget.dailyProteinTarget.toStringAsFixed(1)}g',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getProgressColor(_progressPercentage).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_progressPercentage.toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getProgressColor(_progressPercentage),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Goal Info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Goal: ${widget.goal} • ${widget.trainingMultiplier.toStringAsFixed(1)}x training',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerMealMiniRings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meal Progress',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 16),
        
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.meals.entries.where((entry) => entry.value).length,
            itemBuilder: (context, index) {
              final mealEntry = widget.meals.entries.where((entry) => entry.value).elementAt(index);
              final mealName = mealEntry.key;
              final progress = _mealProgress[mealName] ?? 0.0;
              final target = widget.dailyProteinTarget / 
                  widget.meals.values.where((enabled) => enabled).length;
              final mealPercentage = target > 0 ? (progress / target) : 0.0;
              
              return Container(
                width: 80,
                margin: EdgeInsets.only(right: index == widget.meals.entries.where((entry) => entry.value).length - 1 ? 0 : 16),
                child: Column(
                  children: [
                    // Mini Progress Ring
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 4,
                            backgroundColor: AppColors.neutral.withValues(alpha: 0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.transparent),
                          ),
                          CircularProgressIndicator(
                            value: (mealPercentage / 100).clamp(0.0, 1.0),
                            strokeWidth: 4,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getProgressColor(mealPercentage),
                            ),
                          ),
                          Icon(
                            _getMealIcon(mealName),
                            color: _getProgressColor(mealPercentage),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      mealName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    Text(
                      '${progress.toStringAsFixed(0)}g',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Weekly Avg',
                  '${(_totalProgress * 7).toStringAsFixed(0)}g',
                  Icons.trending_up,
                  AppColors.success,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Goal Hit Rate',
                  '${_progressPercentage >= 100 ? 100 : _progressPercentage.toInt()}%',
                  Icons.flag,
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Streak',
                  '3 days',
                  Icons.local_fire_department,
                  AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Foods',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full history
              },
              child: Text(
                'View All',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
                 if (_recentItems.isEmpty)
           _buildEmptyState()
         else
           ..._recentItems.map((item) => _buildRecentItemCard(item)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No foods logged today',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by taking a photo of your meal',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItemCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Food Icon Placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.restaurant,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Food Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${item['portion'].toStringAsFixed(0)}g • ${item['protein'].toStringAsFixed(1)}g protein',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item['meal'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['time'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Quick Actions
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
            onSelected: (value) {
              // TODO: Handle quick actions
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showCameraSettingsModal(context),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.camera_alt),
      label: const Text('Add Food'),
      elevation: 8,
    );
  }

  IconData _getMealIcon(String mealName) {
    switch (mealName) {
      case 'Breakfast':
        return Icons.wb_sunny;
      case 'Lunch':
        return Icons.restaurant;
      case 'Dinner':
        return Icons.dinner_dining;
      case 'Snack':
        return Icons.coffee;
      default:
        return Icons.restaurant;
    }
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 100) return AppColors.success;
    if (percentage >= 80) return AppColors.warning;
    if (percentage >= 60) return AppColors.primary;
    return AppColors.error;
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  void _showCameraSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              Text(
                'Upload Photo',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Choose how you want to add your meal',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Scrollable content area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Camera option
                      _buildCameraOption(
                        context,
                        'Take Photo',
                        Icons.camera_alt,
                        'Use your camera to take a new photo',
                        () {
                          Navigator.pop(context);
                          // TODO: Navigate to camera screen
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Gallery option
                      _buildCameraOption(
                        context,
                        'Choose from Gallery',
                        Icons.photo_library,
                        'Select an existing photo from your gallery',
                        () {
                          Navigator.pop(context);
                          // TODO: Navigate to gallery picker
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Cancel button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: BorderSide(color: AppColors.neutral.withValues(alpha: 0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCameraOption(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            
            const SizedBox(width: 20),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.neutral,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
