import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../main.dart';
import '../utils/meal_tracking_provider.dart';
import '../utils/meal_utils.dart';
import '../models/dto/meal_dto.dart';
import '../providers/progress_provider.dart';
import '../widgets/user_home/enhanced_header.dart';
import '../widgets/user_home/progress_visualization.dart';
import '../widgets/user_home/meal_progress_rings.dart';
import '../widgets/user_home/quick_stats.dart';
import '../widgets/user_home/recent_items_list.dart';
import '../widgets/user_home/camera_modal.dart';
import '../widgets/user_home/footer_action_bar.dart';
import '../utils/user_settings_provider.dart';
import 'history_screen.dart';
import 'quick_add_screen.dart';
import 'pricing_plans_screen.dart' as pricing;
import 'premium_features_unlock_screen.dart' as premium;

class UserHomeScreen extends StatefulWidget {
  final double height;
  final double weight;
  final double trainingMultiplier;
  final String goal;
  final double dailyProteinTarget;

  const UserHomeScreen({
    super.key,
    required this.height,
    required this.weight,
    required this.trainingMultiplier,
    required this.goal,
    required this.dailyProteinTarget,
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
  
  // Image picker instance
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoadingImage = false;


  // Search and filter state
  String _searchQuery = '';
  String _selectedMealFilter = 'All';
  bool _showSearchBar = false;
  
  // Edit state
  String? _editingItemId;
  final Map<String, TextEditingController> _editControllers = {};





  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _initializeEditControllers();
    _initializeMealData();
  }
  
  void _initializeMealData() {
    // Initialize meal tracking and progress data when home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mealProvider = Provider.of<MealTrackingProvider>(context, listen: false);
      final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
      
      mealProvider.loadTodaysSummary();
      mealProvider.loadMeals();
      
      // Initialize progress data if needed
      if (progressProvider.needsRefresh) {
        progressProvider.loadProgressData();
      }
    });
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
      end: 1.0, // Will be updated dynamically based on real progress
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
    // Initialize controllers when meals are loaded
    // This will be updated in the provider listener
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

  Future<void> _saveEdit(String itemId) async {
    final controller = _editControllers[itemId];
    // final mealProvider = Provider.of<MealTrackingProvider>(context, listen: false);
    
    if (controller != null) {
      final newPortion = double.tryParse(controller.text);
      if (newPortion != null && newPortion > 0) {
        // Find the meal to update (currently unused, would be used for complex updates)
        // final meal = mealProvider.meals.firstWhere(
        //   (m) => m.id == itemId,
        //   orElse: () => throw Exception('Meal not found'),
        // );
        
        // Update meal with new portion (this would need to be implemented in the meal structure)
        // For now, we'll just close the edit mode
        setState(() {
          _editingItemId = null;
        });
        
        // In a full implementation, you would update the meal's food portions
        // and call mealProvider.updateMeal(itemId, updatedMeal)
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _editingItemId = null;
    });
    // Reset controllers to original values
    final mealProvider = Provider.of<MealTrackingProvider>(context, listen: false);
    for (final meal in mealProvider.meals) {
      final controller = _editControllers[meal.id];
      if (controller != null) {
        // Reset to original portion - this would need proper implementation
        // based on the meal's food structure
        controller.text = '100'; // Default value for now
      }
    }
  }

  // Delete functionality
  Future<void> _deleteItem(String itemId) async {
    final mealProvider = Provider.of<MealTrackingProvider>(context, listen: false);
    final success = await mealProvider.deleteMeal(itemId);
    
    if (success) {
      // Remove controller for deleted meal
      _editControllers.remove(itemId);
    } else {
      // Show error if deletion failed
      _showErrorDialog(mealProvider.error ?? 'Failed to delete meal');
    }
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

  // Helper methods to get data from providers
  Map<String, double> _getMealProgress(MealTrackingProvider mealProvider) {
    // Safely handle null meal summary
    final summary = mealProvider.mealSummary;
    if (summary.isEmpty) {
      return {
        'Breakfast': 0.0,
        'Lunch': 0.0,
        'Dinner': 0.0,
        'Snack': 0.0,
      };
    }
    
    return {
      'Breakfast': summary['breakfast']?['protein']?.toDouble() ?? 0.0,
      'Lunch': summary['lunch']?['protein']?.toDouble() ?? 0.0,
      'Dinner': summary['dinner']?['protein']?.toDouble() ?? 0.0,
      'Snack': summary['snack']?['protein']?.toDouble() ?? 0.0,
    };
  }
  
  List<Map<String, dynamic>> _getRecentItems(MealTrackingProvider mealProvider) {
    // Safely handle null or empty meals list
    final meals = mealProvider.todaysMeals;
    if (meals.isEmpty) {
      return [];
    }
    
    return meals.map((meal) {
      // Convert MealDto to the expected format for the UI
      final totalProtein = meal.totalNutrition?.protein ?? 0.0;
      final totalCalories = meal.totalNutrition?.calories ?? 0.0;
      
      return {
        'id': meal.id,
        'name': _getMealDisplayName(meal),
        'portion': _getMealPortion(meal),
        'protein': totalProtein,
        'meal': _capitalizeFirst(meal.mealType),
        'time': _formatTime(meal.timestamp),
        'image': meal.photoUrl ?? 'assets/images/default_food.jpg',
        'category': 'Mixed', // Default category
        'calories': totalCalories.toInt(),
      };
    }).toList();
  }
  
  // Get filtered items
  List<Map<String, dynamic>> _getFilteredItems(List<Map<String, dynamic>> recentItems) {
    List<Map<String, dynamic>> items = recentItems;
    
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
  List<String> _getAvailableMeals(List<Map<String, dynamic>> recentItems) {
    final meals = recentItems.map((item) => item['meal'] as String).toSet().toList();
    meals.insert(0, 'All');
    return meals;
  }
  
  // Helper methods for meal data conversion
  String _getMealDisplayName(MealDto meal) {
    if (meal.foods.isNotEmpty) {
      // Use the first food's ID as the meal name (simplified)
      return meal.foods.first.foodId;
    }
    return 'Mixed meal';
  }
  
  double _getMealPortion(MealDto meal) {
    if (meal.foods.isNotEmpty) {
      return meal.foods.first.quantity;
    }
    return 100.0; // Default portion
  }
  
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
  
  // Helper method to convert enabled meal types to the legacy format
  Map<String, bool> _getMealsMap(UserSettingsProvider userSettings) {
    return MealUtils.convertMealIdsToLegacy(userSettings.enabledMealTypes);
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
            _takePhoto();
          },
          onChooseFromGallery: () {
            Navigator.pop(context);
            _pickImageFromGallery();
          },
        );
      },
    );
  }

  Future<void> _takePhoto() async {
    // Navigate to the dedicated camera launch screen
    if (mounted) {
      Navigator.pushNamed(context, '/camera-launch');
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() {
      _isLoadingImage = true;
    });
    
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      
      if (image != null) {
        final File imageFile = File(image.path);
        if (await _validateImageFile(imageFile)) {
          // Navigate to processing screen with the selected image
          if (mounted) {
            Navigator.pushNamed(
              context,
              '/processing',
              arguments: image.path,
            );
          }
        }
      }
    } catch (e) {
      String errorMessage = 'Failed to pick image';
      if (e.toString().contains('permission')) {
        errorMessage = 'Gallery permission denied. Please enable photo library access in settings.';
      } else if (e.toString().contains('gallery')) {
        errorMessage = 'Gallery not available. Please check your device photo library.';
      }
      _showErrorDialog(errorMessage);
    } finally {
      setState(() {
        _isLoadingImage = false;
      });
    }
  }

  Future<bool> _validateImageFile(File imageFile) async {
    try {
      // Check if file exists and is readable
      if (!await imageFile.exists()) {
        _showErrorDialog('Selected image file is not accessible.');
        return false;
      }

      // Check file size (max 5MB)
      final int fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        _showErrorDialog('Image file is too large. Please select an image smaller than 5MB.');
        return false;
      }

      return true;
    } catch (e) {
      _showErrorDialog('Failed to validate image file: ${e.toString()}');
      return false;
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MealTrackingProvider, ProgressProvider>(
      builder: (context, mealProvider, progressProvider, child) {
        // Initialize edit controllers for current meals
        _updateEditControllers(mealProvider.todaysMeals);
        
        // Get user settings
        final userSettings = context.watch<UserSettingsProvider>();
        
        return CupertinoPageScaffold(
          backgroundColor: AppColors.background,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: AppColors.background,
            border: null,
            middle: const Text(
              'Fuelie',
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
          child: _buildMainContent(mealProvider, progressProvider, userSettings),
        );
      },
    );
  }
  
  void _updateEditControllers(List<MealDto> meals) {
    // Update edit controllers when meals change
    final existingIds = _editControllers.keys.toSet();
    final currentIds = meals.map((m) => m.id).toSet();
    
    // Remove controllers for meals that no longer exist
    for (final id in existingIds.difference(currentIds)) {
      _editControllers[id]?.dispose();
      _editControllers.remove(id);
    }
    
    // Add controllers for new meals
    for (final meal in meals) {
      if (!_editControllers.containsKey(meal.id)) {
        _editControllers[meal.id] = TextEditingController(
          text: _getMealPortion(meal).toString(),
        );
      }
    }
  }
  
  Widget _buildMainContent(MealTrackingProvider mealProvider, ProgressProvider progressProvider, UserSettingsProvider userSettings) {
    // Show loading state if data is still being fetched
    if (mealProvider.isLoading && mealProvider.todaysSummary == null) {
      return const Center(
        child: CupertinoActivityIndicator(
          radius: 20,
          color: AppColors.primary,
        ),
      );
    }
    
    // Show error state if there's an error and no data
    if (mealProvider.error != null && mealProvider.todaysSummary == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load meal data',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mealProvider.error ?? 'Unknown error occurred',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CupertinoButton.filled(
              onPressed: () {
                mealProvider.refreshAll();
                if (progressProvider.needsRefresh) {
                  progressProvider.loadProgressData();
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        // Main Content
        Expanded(
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
                          totalProgress: mealProvider.todaysTotalProtein,
                          dailyProteinTarget: mealProvider.dailyProteinGoal,
                          goal: widget.goal,
                          trainingMultiplier: widget.trainingMultiplier,
                          ringAnimation: _ringAnimation,
                          pulseAnimation: _pulseAnimation,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Per-meal Mini-rings
                        MealProgressRings(
                          enabledMealTypes: userSettings.enabledMealTypes,
                          dailyProteinTarget: mealProvider.dailyProteinGoal,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Quick Stats Panel
                        QuickStats(
                          totalProgress: mealProvider.todaysTotalProtein,
                          progressPercentage: mealProvider.todaysProgress * 100,
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
                                      title: _isLoadingImage ? 'Loading...' : 'Upload Photo',
                                      subtitle: _isLoadingImage ? 'Processing image...' : 'Take a photo of your meal',
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
                                              meals: _getMealsMap(userSettings),
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
                                              mealProgress: _getMealProgress(mealProvider),
                                              mealTargets: {
                                                'Breakfast': mealProvider.dailyProteinGoal / 4,
                                                'Lunch': mealProvider.dailyProteinGoal / 4,
                                                'Dinner': mealProvider.dailyProteinGoal / 4,
                                                'Snack': mealProvider.dailyProteinGoal / 4,
                                              },
                                              enabledMeals: _getMealsMap(userSettings),
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
                        Builder(
                          builder: (context) {
                            final recentItems = _getRecentItems(mealProvider);
                            final filteredItems = _getFilteredItems(recentItems);
                            final availableMeals = _getAvailableMeals(recentItems);
                            
                            return RecentItemsList(
                              recentItems: recentItems,
                              filteredItems: filteredItems,
                              showSearchBar: _showSearchBar,
                              searchQuery: _searchQuery,
                              selectedMealFilter: _selectedMealFilter,
                              availableMeals: availableMeals,
                              editingItemId: _editingItemId,
                              editControllers: _editControllers,
                              dailyProteinTarget: mealProvider.dailyProteinGoal,
                              meals: _getMealsMap(userSettings),
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
                              onSaveEdit: (itemId) => _saveEdit(itemId),
                              onCancelEdit: _cancelEdit,
                              onDeleteItem: (itemId) => _deleteItem(itemId),
                              onEditItem: _startEditing,
                              calculateProtein: _calculateProtein,
                            );
                          },
                        ),
                        
                        const SizedBox(height: 32), // Space for footer
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
            // Footer Action Bar
            FooterActionBar(
              onQuickAdd: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => QuickAddScreen(
                      mealProgress: _getMealProgress(mealProvider),
                      mealTargets: {
                        'Breakfast': mealProvider.dailyProteinGoal / 4,
                        'Lunch': mealProvider.dailyProteinGoal / 4,
                        'Dinner': mealProvider.dailyProteinGoal / 4,
                        'Snack': mealProvider.dailyProteinGoal / 4,
                      },
                      enabledMeals: _getMealsMap(userSettings),
                    ),
                  ),
                );
              },
              onCamera: () => _showCameraSettingsModal(context),
              onAnalytics: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => HistoryScreen(
                      dailyProteinTarget: mealProvider.dailyProteinGoal,
                      meals: _getMealsMap(userSettings),
                    ),
                  ),
                );
              },
            ),
          ],
        );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final bool isLoading = title == 'Loading...';
    
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isLoading ? AppColors.background.withValues(alpha: 0.5) : AppColors.background,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isLoading ? AppColors.neutral.withValues(alpha: 0.3) : AppColors.background,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading)
              const CupertinoActivityIndicator(
                color: AppColors.primary,
                radius: 12,
              )
            else
              Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isLoading ? AppColors.textSecondary : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: isLoading ? AppColors.textSecondary.withValues(alpha: 0.7) : AppColors.textSecondary,
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
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to subscription management with mock data
              Navigator.of(context).pushNamed(
                '/subscription-management',
                arguments: {
                  'currentPlan': pricing.SubscriptionPlan.pro,
                  'currentPeriod': pricing.SubscriptionPeriod.annual,
                  'currentPrice': 39.99,
                  'nextBillingDate': DateTime.now().add(const Duration(days: 15)),
                  'isTrialActive': false,
                },
              );
            },
            child: const Text('Manage Subscription'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to premium features unlock screen
              Navigator.of(context).pushNamed(
                '/premium-features-unlock',
                arguments: {
                  'trigger': premium.UnlockTrigger.historyLimit,
                  'customMessage': 'You\'ve reached the 7-day history limit. Upgrade to Pro for unlimited access!',
                },
              );
            },
            child: const Text('Demo: Premium Unlock'),
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
