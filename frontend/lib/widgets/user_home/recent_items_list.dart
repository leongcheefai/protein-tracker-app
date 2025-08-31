import 'package:flutter/cupertino.dart';
import '../../main.dart';
import 'search_filter.dart';
import 'empty_states.dart';
import 'food_item_card.dart';
import '../../screens/history_screen.dart';

class RecentItemsList extends StatelessWidget {
  final List<Map<String, dynamic>> recentItems;
  final List<Map<String, dynamic>> filteredItems;
  final bool showSearchBar;
  final String searchQuery;
  final String selectedMealFilter;
  final List<String> availableMeals;
  final String? editingItemId;
  final Map<String, TextEditingController> editControllers;
  final double dailyProteinTarget;
  final Map<String, bool> meals;
  final VoidCallback onToggleSearchBar;
  final Function(String) onSearchChanged;
  final Function(String) onMealFilterChanged;
  final VoidCallback onTakePhoto;
  final VoidCallback onClearFilters;
  final Function(String) onStartEditing;
  final Function(String) onSaveEdit;
  final VoidCallback onCancelEdit;
  final Function(String) onDeleteItem;
  final Function(String) onEditItem;
  final double Function(Map<String, dynamic>) calculateProtein;

  const RecentItemsList({
    super.key,
    required this.recentItems,
    required this.filteredItems,
    required this.showSearchBar,
    required this.searchQuery,
    required this.selectedMealFilter,
    required this.availableMeals,
    required this.editingItemId,
    required this.editControllers,
    required this.dailyProteinTarget,
    required this.meals,
    required this.onToggleSearchBar,
    required this.onSearchChanged,
    required this.onMealFilterChanged,
    required this.onTakePhoto,
    required this.onClearFilters,
    required this.onStartEditing,
    required this.onSaveEdit,
    required this.onCancelEdit,
    required this.onDeleteItem,
    required this.onEditItem,
    required this.calculateProtein,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with search toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today\'s Foods',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onToggleSearchBar,
                  child: Icon(
                    showSearchBar ? CupertinoIcons.clear : CupertinoIcons.search,
                    color: AppColors.primary,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => HistoryScreen(
                          dailyProteinTarget: dailyProteinTarget,
                          meals: meals,
                        ),
                      ),
                    );
                  },
                                      child: const Text(
                      'View All',
                      style: TextStyle(color: AppColors.primary),
                    ),
                ),
              ],
            ),
          ],
        ),
        
        // Search and Filter Bar
        if (showSearchBar) ...[
          const SizedBox(height: 16),
          SearchFilter(
            searchQuery: searchQuery,
            selectedMealFilter: selectedMealFilter,
            availableMeals: availableMeals,
            onSearchChanged: onSearchChanged,
            onMealFilterChanged: onMealFilterChanged,
          ),
          const SizedBox(height: 16),
        ],
        
        // Results count
        if (showSearchBar && filteredItems.isNotEmpty) ...[
          Text(
            'Found ${filteredItems.length} item${filteredItems.length == 1 ? '' : 's'}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Items list
        if (recentItems.isEmpty)
          EmptyStates.buildEmptyState(onTakePhoto)
        else if (filteredItems.isEmpty && (searchQuery.isNotEmpty || selectedMealFilter != 'All'))
          EmptyStates.buildNoResultsState(onClearFilters)
        else
          ...filteredItems.map((item) => FoodItemCard(
            item: item,
            isEditing: editingItemId == item['id'],
            editController: editControllers[item['id']],
            onTap: () {
              if (editingItemId != item['id']) {
                onStartEditing(item['id']);
              }
            },
            onSave: () => onSaveEdit(item['id']),
            onCancel: onCancelEdit,
            onDelete: () => onDeleteItem(item['id']),
            onEdit: () => onEditItem(item['id']),
            calculatedProtein: calculateProtein(item),
          )),
      ],
    );
  }
}
