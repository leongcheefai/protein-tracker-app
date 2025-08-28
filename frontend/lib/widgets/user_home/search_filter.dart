import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchFilter extends StatelessWidget {
  final String searchQuery;
  final String selectedMealFilter;
  final List<String> availableMeals;
  final Function(String) onSearchChanged;
  final Function(String) onMealFilterChanged;

  const SearchFilter({
    super.key,
    required this.searchQuery,
    required this.selectedMealFilter,
    required this.availableMeals,
    required this.onSearchChanged,
    required this.onMealFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search TextField
        CupertinoTextField(
          onChanged: onSearchChanged,
          placeholder: 'Search foods by name or category...',
          placeholderStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280), // AppColors.textSecondary
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF111827), // AppColors.textPrimary
          ),
          prefix: const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(CupertinoIcons.search, color: Color(0xFF6B7280), size: 18), // AppColors.textSecondary
          ),
          suffix: searchQuery.isNotEmpty
              ? CupertinoButton(
                  padding: const EdgeInsets.only(right: 8.0),
                  onPressed: () => onSearchChanged(''),
                  child: const Icon(CupertinoIcons.clear, color: Color(0xFF6B7280), size: 18), // AppColors.textSecondary
                )
              : null,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF9CA3AF).withValues(alpha: 0.3)), // AppColors.neutral
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        
        const SizedBox(height: 12),
        
        // Meal Filter Chips
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: availableMeals.length,
            itemBuilder: (context, index) {
              final meal = availableMeals[index];
              final isSelected = selectedMealFilter == meal;
              
              return Container(
                margin: EdgeInsets.only(right: index == availableMeals.length - 1 ? 0 : 8),
                child: GestureDetector(
                  onTap: () {
                    onMealFilterChanged(isSelected ? 'All' : meal);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF3B82F6).withValues(alpha: 0.2) : Colors.white, // AppColors.primary
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF9CA3AF).withValues(alpha: 0.3), // AppColors.primary vs neutral
                      ),
                    ),
                    child: Text(
                      meal,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF6B7280), // AppColors.primary vs textSecondary
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
}
