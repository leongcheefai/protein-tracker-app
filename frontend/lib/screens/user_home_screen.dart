import 'package:flutter/cupertino.dart';
import '../main.dart';
import '../widgets/user_home/enhanced_header.dart';
import '../widgets/user_home/progress_visualization.dart';
import '../widgets/user_home/meal_progress.dart';
import '../widgets/user_home/quick_stats.dart';
import '../widgets/user_home/recent_items_list.dart';
import '../widgets/user_home/camera_modal.dart';
import 'history_screen.dart';
import 'quick_add_screen.dart';

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
    setState(() {
      _recentItems.removeWhere((item) => item['id'] == itemId);
    });
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

  // Calculate protein for editing
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
        return CameraModal(
          onTakePhoto: () {
            Navigator.pop(context);
            // TODO: Navigate to camera screen
          },
          onChooseFromGallery: () {
            Navigator.pop(context);
            // TODO: Navigate to gallery picker
          },
        );
      },
    );
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
          onPressed: () => _showSettingsMenu(context),
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
            SliverToBoxAdapter(
              child: const EnhancedHeader(),
            ),
            
            // Main Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Advanced Progress Visualization
                    ProgressVisualization(
                      totalProgress: _totalProgress,
                      dailyProteinTarget: widget.dailyProteinTarget,
                      goal: widget.goal,
                      trainingMultiplier: widget.trainingMultiplier,
                      ringAnimation: _ringAnimation,
                      pulseAnimation: _pulseAnimation,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Per-meal Mini-rings
                    MealProgress(
                      meals: widget.meals,
                      mealProgress: _mealProgress,
                      dailyProteinTarget: widget.dailyProteinTarget,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Quick Stats Panel
                    QuickStats(
                      totalProgress: _totalProgress,
                      progressPercentage: _progressPercentage,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Quick Actions Grid
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.black.withValues(alpha: 0.05),
                            blurRadius: 10.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildQuickActionCard(
                                  icon: CupertinoIcons.camera,
                                  title: 'Upload Photo',
                                  subtitle: 'Take a photo of your meal',
                                  onTap: () => _showCameraSettingsModal(context),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildQuickActionCard(
                                  icon: CupertinoIcons.chart_bar,
                                  title: 'View History',
                                  subtitle: 'Check your progress',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => HistoryScreen(
                                          dailyProteinTarget: widget.dailyProteinTarget,
                                          meals: widget.meals,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildQuickActionCard(
                                  icon: CupertinoIcons.slider_horizontal_3,
                                  title: 'Edit Goals',
                                  subtitle: 'Update your targets',
                                  onTap: () async {
                                    final result = await Navigator.pushNamed(
                                      context,
                                      '/profile-settings',
                                      arguments: {
                                        'height': widget.height,
                                        'weight': widget.weight,
                                        'trainingMultiplier': widget.trainingMultiplier,
                                        'goal': widget.goal,
                                        'dailyProteinTarget': widget.dailyProteinTarget,
                                      },
                                    );
                                    
                                    // Refresh the screen if profile was updated
                                    if (result == true) {
                                      setState(() {
                                        // Trigger a rebuild to reflect any changes
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildQuickActionCard(
                                  icon: CupertinoIcons.add,
                                  title: 'Quick Add',
                                  subtitle: 'Add protein manually',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => QuickAddScreen(
                                          mealProgress: _mealProgress,
                                          mealTargets: {
                                            'Breakfast': widget.dailyProteinTarget / 4,
                                            'Lunch': widget.dailyProteinTarget / 4,
                                            'Dinner': widget.dailyProteinTarget / 4,
                                            'Snack': widget.dailyProteinTarget / 4,
                                          },
                                          enabledMeals: widget.meals,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Recent Items List
                    RecentItemsList(
                      recentItems: _recentItems,
                      filteredItems: _filteredItems,
                      showSearchBar: _showSearchBar,
                      searchQuery: _searchQuery,
                      selectedMealFilter: _selectedMealFilter,
                      availableMeals: _availableMeals,
                      editingItemId: _editingItemId,
                      editControllers: _editControllers,
                      dailyProteinTarget: widget.dailyProteinTarget,
                      meals: widget.meals,
                      onToggleSearchBar: _toggleSearchBar,
                      onSearchChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      onMealFilterChanged: (value) {
                        setState(() {
                          _selectedMealFilter = value;
                        });
                      },
                      onTakePhoto: () => _showCameraSettingsModal(context),
                      onClearFilters: () {
                        setState(() {
                          _searchQuery = '';
                          _selectedMealFilter = 'All';
                        });
                      },
                      onStartEditing: _startEditing,
                      onSaveEdit: _saveEdit,
                      onCancelEdit: _cancelEdit,
                      onDeleteItem: _deleteItem,
                      onEditItem: _startEditing,
                      calculateProtein: _calculateProtein,
                    ),
                    
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

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: AppColors.background,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Settings'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(context).pop();
              final result = await Navigator.of(context).pushNamed(
                '/profile-settings',
                arguments: {
                  'height': widget.height,
                  'weight': widget.weight,
                  'trainingMultiplier': widget.trainingMultiplier,
                  'goal': widget.goal,
                  'dailyProteinTarget': widget.dailyProteinTarget,
                },
              );
              
              // Refresh the screen if profile was updated
              if (result == true) {
                setState(() {
                  // Trigger a rebuild to reflect any changes
                });
              }
            },
            child: const Text('Profile Settings'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/notification-settings');
            },
            child: const Text('Notification Settings'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/privacy-settings');
            },
            child: const Text('Privacy & Data'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/about-help');
            },
            child: const Text('About & Help'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/pricing-plans');
            },
            child: const Text('Upgrade to Pro'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
