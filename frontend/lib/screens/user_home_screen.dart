import 'package:flutter/cupertino.dart';
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
      'id': '1',
      'name': 'Grilled Chicken Breast',
      'portion': 150.0,
      'protein': 46.5,
      'meal': 'Lunch',
      'time': '12:30 PM',
      'image': 'assets/images/chicken.jpg',
      'category': 'Protein',
      'calories': 165,
    },
    {
      'id': '2',
      'name': 'Greek Yogurt',
      'portion': 200.0,
      'protein': 20.0,
      'meal': 'Breakfast',
      'time': '8:15 AM',
      'image': 'assets/images/yogurt.jpg',
      'category': 'Dairy',
      'calories': 120,
    },
    {
      'id': '3',
      'name': 'Salmon Fillet',
      'portion': 120.0,
      'protein': 28.8,
      'meal': 'Dinner',
      'time': '7:45 PM',
      'image': 'assets/images/salmon.jpg',
      'category': 'Protein',
      'calories': 180,
    },
    {
      'id': '4',
      'name': 'Quinoa Bowl',
      'portion': 100.0,
      'protein': 4.0,
      'meal': 'Lunch',
      'time': '1:15 PM',
      'image': 'assets/images/quinoa.jpg',
      'category': 'Carbohydrate',
      'calories': 120,
    },
  ];

  // Search and filter state
  String _searchQuery = '';
  String _selectedMealFilter = 'All';
  bool _showSearchBar = false;
  
  // Edit state
  String? _editingItemId;
  final Map<String, TextEditingController> _editControllers = {};

  // Get filtered items
  List<Map<String, dynamic>> get _filteredItems {
    List<Map<String, dynamic>> items = _recentItems;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) =>
        item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
        item['category'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Apply meal filter
    if (_selectedMealFilter != 'All') {
      items = items.where((item) => item['meal'] == _selectedMealFilter).toList();
    }
    
    return items;
  }

  // Get unique meals for filter
  List<String> get _availableMeals {
    final meals = _recentItems.map((item) => item['meal'] as String).toSet().toList();
    meals.insert(0, 'All');
    return meals;
  }

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
    _initializeEditControllers();
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

  void _initializeEditControllers() {
    for (final item in _recentItems) {
      _editControllers[item['id']] = TextEditingController(
        text: item['portion'].toString(),
      );
    }
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
    for (final controller in _editControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Quick edit functionality
  void _startEditing(String itemId) {
    setState(() {
      _editingItemId = itemId;
    });
  }

  void _saveEdit(String itemId) {
    final controller = _editControllers[itemId];
    if (controller != null) {
      final newPortion = double.tryParse(controller.text);
      if (newPortion != null && newPortion > 0) {
        setState(() {
          final itemIndex = _recentItems.indexWhere((item) => item['id'] == itemId);
          if (itemIndex != -1) {
            _recentItems[itemIndex]['portion'] = newPortion;
            // Recalculate protein based on portion
            final proteinPer100g = _recentItems[itemIndex]['protein'] / _recentItems[itemIndex]['portion'] * 100;
            _recentItems[itemIndex]['protein'] = (newPortion / 100) * proteinPer100g;
          }
          _editingItemId = null;
        });
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _editingItemId = null;
    });
    // Reset controllers to original values
    for (final item in _recentItems) {
      final controller = _editControllers[item['id']];
      if (controller != null) {
        controller.text = item['portion'].toString();
      }
    }
  }

  // Delete functionality
  void _deleteItem(String itemId) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Food Item'),
        content: const Text('Are you sure you want to delete this item? This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              setState(() {
                _recentItems.removeWhere((item) => item['id'] == itemId);
              });
              Navigator.pop(context);
            },
            isDestructiveAction: true,
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Toggle search bar
  void _toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _searchQuery = '';
        _selectedMealFilter = 'All';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        border: null,
        middle: const Text(
          'Protein Pace',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // TODO: Navigate to settings screen
          },
          child: Icon(
            CupertinoIcons.settings,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      child: SafeArea(
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
    );
  }

  Widget _buildEnhancedHeader() {
    final now = DateTime.now();
    final dateString = '${_getMonthName(now.month)} ${now.day}, ${now.year}';
    
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              dateString,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
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
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'of ${widget.dailyProteinTarget.toStringAsFixed(1)}g',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
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
                              style: TextStyle(
                                color: _getProgressColor(_progressPercentage),
                                fontSize: 14,
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
                CupertinoIcons.heart_fill,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Goal: ${widget.goal} • ${widget.trainingMultiplier.toStringAsFixed(1)}x training',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
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
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 16),
        
        SizedBox(
          height: 120, // Increased height to prevent bottom overflow
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.meals.entries.length, // Show all meals, not just enabled ones
            itemBuilder: (context, index) {
              final mealEntry = widget.meals.entries.elementAt(index);
              final mealName = mealEntry.key;
              final isEnabled = mealEntry.value;
              final progress = _mealProgress[mealName] ?? 0.0;
              final target = widget.dailyProteinTarget / 
                  widget.meals.values.where((enabled) => enabled).length;
              final mealPercentage = target > 0 ? (progress / target) : 0.0;
              
              return Container(
                width: 90, // Increased width to prevent text truncation
                margin: EdgeInsets.only(right: index == widget.meals.entries.length - 1 ? 0 : 16),
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
                            value: isEnabled ? (mealPercentage / 100).clamp(0.0, 1.0) : 0.0,
                            strokeWidth: 4,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isEnabled ? _getProgressColor(mealPercentage) : AppColors.neutral.withValues(alpha: 0.3),
                            ),
                          ),
                          Icon(
                            _getMealIcon(mealName),
                            color: isEnabled ? _getProgressColor(mealPercentage) : AppColors.neutral.withValues(alpha: 0.3),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      mealName,
                      style: TextStyle(
                        color: isEnabled ? AppColors.textPrimary : AppColors.neutral.withValues(alpha: 0.3),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    
                    Text(
                      isEnabled ? '${progress.toStringAsFixed(0)}g' : '0g',
                      style: TextStyle(
                        color: isEnabled ? AppColors.textSecondary : AppColors.neutral.withValues(alpha: 0.3),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
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
                  CupertinoIcons.chart_bar,
                  AppColors.success,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Goal Hit Rate',
                  '${_progressPercentage >= 100 ? 100 : _progressPercentage.toInt()}%',
                  CupertinoIcons.flag,
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Streak',
                  '3 days',
                  CupertinoIcons.flame,
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
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
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
        // Header with search toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Foods',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _toggleSearchBar,
                  child: Icon(
                    _showSearchBar ? CupertinoIcons.clear : CupertinoIcons.search,
                    color: AppColors.primary,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
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
          ],
        ),
        
        // Search and Filter Bar
        if (_showSearchBar) ...[
          const SizedBox(height: 16),
          _buildSearchAndFilterBar(),
          const SizedBox(height: 16),
        ],
        
        // Results count
        if (_showSearchBar && _filteredItems.isNotEmpty) ...[
          Text(
            'Found ${_filteredItems.length} item${_filteredItems.length == 1 ? '' : 's'}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Items list
        if (_recentItems.isEmpty)
          _buildEmptyState()
        else if (_filteredItems.isEmpty && (_searchQuery.isNotEmpty || _selectedMealFilter != 'All'))
          _buildNoResultsState()
        else
          ..._filteredItems.map((item) => _buildRecentItemCard(item)),
      ],
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Column(
      children: [
        // Search TextField
        CupertinoTextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          placeholder: 'Search foods by name or category...',
          placeholderStyle: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          prefix: const Icon(CupertinoIcons.search, color: AppColors.textSecondary, size: 18),
          suffix: _searchQuery.isNotEmpty
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  child: const Icon(CupertinoIcons.clear, color: AppColors.textSecondary, size: 18),
                )
              : null,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutral.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        
        const SizedBox(height: 12),
        
        // Meal Filter Chips
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _availableMeals.length,
            itemBuilder: (context, index) {
              final meal = _availableMeals[index];
              final isSelected = _selectedMealFilter == meal;
              
              return Container(
                margin: EdgeInsets.only(right: index == _availableMeals.length - 1 ? 0 : 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMealFilter = isSelected ? 'All' : meal;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.neutral.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      meal,
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
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
            CupertinoIcons.house,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No foods logged today',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by taking a photo of your meal',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            onPressed: () => _showCameraSettingsModal(context),
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.camera,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
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
    );
  }

  Widget _buildNoResultsState() {
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
            CupertinoIcons.search,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No foods found',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedMealFilter = 'All';
              });
            },
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.clear,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
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
    );
  }

  Widget _buildRecentItemCard(Map<String, dynamic> item) {
    final isEditing = _editingItemId == item['id'];
    
    return Dismissible(
      key: Key(item['id']),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showCupertinoDialog<bool>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Delete Food Item'),
            content: Text('Are you sure you want to delete "${item['name']}"?'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context, true),
                isDestructiveAction: true,
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        _deleteItem(item['id']);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          CupertinoIcons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEditing ? AppColors.primary : AppColors.neutral.withValues(alpha: 0.1),
            width: isEditing ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (!isEditing) {
                _startEditing(item['id']);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Food Icon with Category
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(item['category']).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(item['category']),
                      color: _getCategoryColor(item['category']),
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
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // Portion and Protein (with inline editing)
                        if (isEditing) ...[
                          Row(
                            children: [
                              Expanded(
                                child: CupertinoTextField(
                                  controller: _editControllers[item['id']],
                                  keyboardType: TextInputType.number,
                                  placeholder: 'Portion (g)',
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.neutral.withValues(alpha: 0.3)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '≈ ${_calculateProtein(item).toStringAsFixed(1)}g protein',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item['portion'].toStringAsFixed(0)}g • ${item['protein'].toStringAsFixed(1)}g protein',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item['meal'] as String,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        
                        const SizedBox(height: 4),
                        
                        // Category and Time
                        Row(
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(item['category']).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item['category'] as String,
                                  style: TextStyle(
                                    color: _getCategoryColor(item['category']),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                item['time'] as String,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Action Buttons
                  if (isEditing) ...[
                    // Save/Cancel buttons
                    Column(
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => _saveEdit(item['id']),
                          child: Icon(CupertinoIcons.check_mark, color: AppColors.success),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _cancelEdit,
                          child: Icon(CupertinoIcons.clear, color: AppColors.error),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Quick Actions Menu
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) => CupertinoActionSheet(
                            actions: [
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _startEditing(item['id']);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.pencil, size: 20),
                                    const SizedBox(width: 8),
                                    const Text('Edit'),
                                  ],
                                ),
                              ),
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteItem(item['id']);
                                },
                                isDestructiveAction: true,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.delete, size: 20),
                                    const SizedBox(width: 8),
                                    const Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ),
                        );
                      },
                      child: Icon(CupertinoIcons.ellipsis, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getMealIcon(String mealName) {
    switch (mealName) {
      case 'Breakfast':
        return CupertinoIcons.sun_max;
      case 'Lunch':
        return CupertinoIcons.house;
      case 'Dinner':
        return CupertinoIcons.moon;
      case 'Snack':
        return CupertinoIcons.circle;
      default:
        return CupertinoIcons.house;
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'protein':
        return AppColors.error; // Red for protein
      case 'carbohydrate':
        return AppColors.warning; // Orange for carbs
      case 'vegetable':
        return AppColors.success; // Green for vegetables
      case 'fruit':
        return const Color(0xFF8B5CF6); // Purple for fruits
      case 'dairy':
        return const Color(0xFF3B82F6); // Blue for dairy
      case 'fat':
        return const Color(0xFFF59E0B); // Amber for fats
      default:
        return AppColors.neutral;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'protein':
        return CupertinoIcons.heart_fill;
      case 'carbohydrate':
        return CupertinoIcons.circle;
      case 'vegetable':
        return CupertinoIcons.leaf_arrow_circlepath;
      case 'fruit':
        return CupertinoIcons.circle_fill;
      case 'dairy':
        return CupertinoIcons.drop;
      case 'fat':
        return CupertinoIcons.drop;
      default:
        return CupertinoIcons.house;
    }
  }

  double _calculateProtein(Map<String, dynamic> item) {
    final portion = double.tryParse(_editControllers[item['id']]?.text ?? '0') ?? 0.0;
    final originalPortion = item['portion'] as double;
    final originalProtein = item['protein'] as double;
    
    if (originalPortion > 0) {
      final proteinPer100g = (originalProtein / originalPortion) * 100;
      return (portion / 100) * proteinPer100g;
    }
    return 0.0;
  }

  void _showCameraSettingsModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
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
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Choose how you want to add your meal',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
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
                        CupertinoIcons.camera,
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
                        CupertinoIcons.photo,
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
                        child: CupertinoButton(
                          onPressed: () => Navigator.pop(context),
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.neutral,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
