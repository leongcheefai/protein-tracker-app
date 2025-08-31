import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../utils/category_utils.dart';
import '../../utils/meal_utils.dart';

class FoodItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isEditing;
  final TextEditingController? editController;
  final VoidCallback onTap;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final double calculatedProtein;

  const FoodItemCard({
    super.key,
    required this.item,
    required this.isEditing,
    this.editController,
    required this.onTap,
    required this.onSave,
    required this.onCancel,
    required this.onDelete,
    required this.onEdit,
    required this.calculatedProtein,
  });

  @override
  Widget build(BuildContext context) {
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
        onDelete();
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444), // AppColors.error
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
            color: isEditing ? const Color(0xFF3B82F6) : const Color(0xFF9CA3AF).withValues(alpha: 0.1), // AppColors.primary vs neutral
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
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Food Icon with Category
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: CategoryUtils.getCategoryColor(item['category']).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      CategoryUtils.getCategoryIcon(item['category']),
                      color: CategoryUtils.getCategoryColor(item['category']),
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
                            color: Color(0xFF111827), // AppColors.textPrimary
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
                                  controller: editController,
                                  keyboardType: TextInputType.number,
                                  placeholder: 'Portion (g)',
                                  style: const TextStyle(
                                    color: Color(0xFF111827), // AppColors.textPrimary
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  placeholderStyle: const TextStyle(
                                    color: Color(0xFF9CA3AF), // AppColors.neutral
                                    fontSize: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFF9CA3AF).withValues(alpha: 0.3)), // AppColors.neutral
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '≈ ${calculatedProtein.toStringAsFixed(1)}g protein',
                                  style: const TextStyle(
                                    color: Color(0xFF3B82F6), // AppColors.primary
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
                                    color: Color(0xFF6B7280), // AppColors.textSecondary
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
                                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1), // AppColors.primary
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item['meal'] as String,
                                    style: const TextStyle(
                                      color: Color(0xFF6B7280), // AppColors.textSecondary
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
                                  color: CategoryUtils.getCategoryColor(item['category']).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item['category'] as String,
                                  style: TextStyle(
                                    color: CategoryUtils.getCategoryColor(item['category']),
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
                                  color: Color(0xFF6B7280), // AppColors.textSecondary
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
                          onPressed: onSave,
                          child: const Icon(CupertinoIcons.check_mark, color: AppColors.success), // AppColors.success
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: onCancel,
                          child: const Icon(CupertinoIcons.clear, color: AppColors.error), // AppColors.error
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
                                  onEdit();
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.pencil, size: 20),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.pop(context);
                                  onDelete();
                                },
                                isDestructiveAction: true,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.delete, size: 20),
                                    SizedBox(width: 8),
                                    Text('Delete'),
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
                      child: const Icon(CupertinoIcons.ellipsis, color: AppColors.textSecondary), // AppColors.textSecondary
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
}
