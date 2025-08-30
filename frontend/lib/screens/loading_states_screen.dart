import 'package:flutter/cupertino.dart';
import '../main.dart';

enum LoadingStateType {
  initialLoad,
  dataFetch,
  processing,
  uploading,
  analyzing,
  saving,
  refreshing,
}

class LoadingStatesScreen extends StatefulWidget {
  final LoadingStateType loadingStateType;
  final String? customTitle;
  final String? customMessage;
  final bool showProgress;
  final double? progressValue;
  final VoidCallback? onCancel;
  final bool cancellable;

  const LoadingStatesScreen({
    super.key,
    required this.loadingStateType,
    this.customTitle,
    this.customMessage,
    this.showProgress = false,
    this.progressValue,
    this.onCancel,
    this.cancellable = false,
  });

  @override
  State<LoadingStatesScreen> createState() => _LoadingStatesScreenState();
}

class _LoadingStatesScreenState extends State<LoadingStatesScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );
    
    _startAnimations();
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  String get _getTitle {
    if (widget.customTitle != null) {
      return widget.customTitle!;
    }
    
    switch (widget.loadingStateType) {
      case LoadingStateType.initialLoad:
        return 'Loading App';
      case LoadingStateType.dataFetch:
        return 'Loading Data';
      case LoadingStateType.processing:
        return 'Processing';
      case LoadingStateType.uploading:
        return 'Uploading';
      case LoadingStateType.analyzing:
        return 'Analyzing';
      case LoadingStateType.saving:
        return 'Saving';
      case LoadingStateType.refreshing:
        return 'Refreshing';
    }
  }

  String get _getMessage {
    if (widget.customMessage != null) {
      return widget.customMessage!;
    }
    
    switch (widget.loadingStateType) {
      case LoadingStateType.initialLoad:
        return 'Preparing your protein tracking experience...';
      case LoadingStateType.dataFetch:
        return 'Fetching your latest progress data...';
      case LoadingStateType.processing:
        return 'Processing your meal photo...';
      case LoadingStateType.uploading:
        return 'Uploading your meal data...';
      case LoadingStateType.analyzing:
        return 'Analyzing your meal for protein content...';
      case LoadingStateType.saving:
        return 'Saving your progress...';
      case LoadingStateType.refreshing:
        return 'Updating your data...';
    }
  }

  IconData get _getIcon {
    switch (widget.loadingStateType) {
      case LoadingStateType.initialLoad:
        return CupertinoIcons.rocket;
      case LoadingStateType.dataFetch:
        return CupertinoIcons.cloud_download;
      case LoadingStateType.processing:
        return CupertinoIcons.gear;
      case LoadingStateType.uploading:
        return CupertinoIcons.cloud_upload;
      case LoadingStateType.analyzing:
        return CupertinoIcons.search;
      case LoadingStateType.saving:
        return CupertinoIcons.checkmark_circle;
      case LoadingStateType.refreshing:
        return CupertinoIcons.refresh;
    }
  }

  Color get _getIconColor {
    switch (widget.loadingStateType) {
      case LoadingStateType.initialLoad:
        return AppColors.primary;
      case LoadingStateType.dataFetch:
        return AppColors.primary;
      case LoadingStateType.processing:
        return AppColors.warning;
      case LoadingStateType.uploading:
        return AppColors.primary;
      case LoadingStateType.analyzing:
        return AppColors.success;
      case LoadingStateType.saving:
        return AppColors.success;
      case LoadingStateType.refreshing:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: widget.cancellable ? CupertinoNavigationBar(
        middle: Text(_getTitle),
        backgroundColor: AppColors.background,
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 0.5,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: widget.onCancel,
          child: const Text('Cancel'),
        ),
      ) : null,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Icon
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: _getIconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: AnimatedBuilder(
                        animation: _rotateAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotateAnimation.value * 2 * 3.14159,
                            child: Icon(
                              _getIcon,
                              size: 60,
                              color: _getIconColor,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                _getTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Message
              Text(
                _getMessage,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Progress Bar (if enabled)
              if (widget.showProgress) ...[
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: widget.progressValue ?? 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getIconColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Progress Text
                Text(
                  '${((widget.progressValue ?? 0.0) * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _getIconColor,
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
              
              // Loading Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLoadingDot(0),
                  const SizedBox(width: 8),
                  _buildLoadingDot(1),
                  const SizedBox(width: 8),
                  _buildLoadingDot(2),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Additional Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.info_circle,
                      color: AppColors.neutral,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This may take a few moments. Please don\'t close the app.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDot(int index) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final delay = index * 0.2;
        final animationValue = (_pulseController.value + delay) % 1.0;
        final scale = 0.6 + (0.4 * animationValue);
        final opacity = 0.3 + (0.7 * animationValue);
        
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getIconColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
