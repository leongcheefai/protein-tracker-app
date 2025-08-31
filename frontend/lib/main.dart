import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/camera_launch_screen.dart';
import 'screens/photo_capture_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/food_detection_results_screen.dart';
import 'screens/portion_selection_screen.dart';
import 'screens/meal_assignment_screen.dart';
import 'screens/confirmation_screen.dart';
import 'screens/user_home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/meal_breakdown_view.dart';
import 'screens/stats_overview.dart';
import 'screens/profile_settings_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/privacy_settings_screen.dart';
import 'screens/about_help_screen.dart';
import 'screens/permission_denied_screen.dart';
import 'screens/network_error_screen.dart';
import 'screens/empty_states_screen.dart';
import 'screens/loading_states_screen.dart';
import 'screens/error_demo_screen.dart';
import 'utils/user_settings_provider.dart';

void main() {
  runApp(const ProteinPaceApp());
}

class ProteinPaceApp extends StatelessWidget {
  const ProteinPaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserSettingsProvider(),
      child: CupertinoApp(
        title: 'Protein Pace',
        debugShowCheckedModeBanner: false,
        theme: const CupertinoThemeData(
          primaryColor: AppColors.primary,
          brightness: Brightness.light,
          textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(
              fontFamily: 'SF Pro Display',
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/camera-launch': (context) => const CameraLaunchScreen(),
          '/photo-capture': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as String;
            return PhotoCaptureScreen(imagePath: args);
          },
          '/processing': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as String;
            return ProcessingScreen(imagePath: args);
          },
          '/food-detection-results': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return FoodDetectionResultsScreen(
              imagePath: args['imagePath'] as String,
              detectedFoods: args['detectedFoods'] as List<Map<String, dynamic>>,
            );
          },
          '/portion-selection': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return PortionSelectionScreen(
              imagePath: args['imagePath'] as String,
              detectedFoods: args['detectedFoods'] as List<Map<String, dynamic>>,
              selectedFoodIndex: args['selectedFoodIndex'] as int,
            );
          },
          '/meal-assignment': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return MealAssignmentScreen(
              imagePath: args['imagePath'] as String,
              detectedFoods: args['detectedFoods'] as List<Map<String, dynamic>>,
              selectedFoodIndex: args['selectedFoodIndex'] as int,
              portion: args['portion'] as double,
              protein: args['protein'] as double,
            );
          },
          '/confirmation': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return ConfirmationScreen(
              imagePath: args['imagePath'] as String,
              foodName: args['foodName'] as String,
              portion: args['portion'] as double,
              protein: args['protein'] as double,
              meal: args['meal'] as String,
              mealProgress: args['mealProgress'] as Map<String, double>,
              mealTargets: args['mealTargets'] as Map<String, double>,
            );
          },
          '/user-home': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return UserHomeScreen(
              height: args['height'] as double,
              weight: args['weight'] as double,
              trainingMultiplier: args['trainingMultiplier'] as double,
              goal: args['goal'] as String,
              dailyProteinTarget: args['dailyProteinTarget'] as double,
              meals: args['meals'] as Map<String, bool>,
            );
          },
          '/history': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return HistoryScreen(
              dailyProteinTarget: args['dailyProteinTarget'] as double,
              meals: args['meals'] as Map<String, bool>,
            );
          },
          '/meal-breakdown': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return MealBreakdownView(
              date: args['date'] as String,
              dailyTotal: args['dailyTotal'] as double,
              dailyGoal: args['dailyGoal'] as double,
              meals: args['meals'] as Map<String, Map<String, dynamic>>,
            );
          },
          '/stats-overview': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return StatsOverview(
              dailyProteinTarget: args['dailyProteinTarget'] as double,
            );
          },
          '/profile-settings': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return ProfileSettingsScreen(
              height: args['height'] as double,
              weight: args['weight'] as double,
              trainingMultiplier: args['trainingMultiplier'] as double,
              goal: args['goal'] as String,
              dailyProteinTarget: args['dailyProteinTarget'] as double,
            );
          },
          '/notification-settings': (context) => const NotificationSettingsScreen(),
          '/privacy-settings': (context) => const PrivacySettingsScreen(),
          '/about-help': (context) => const AboutHelpScreen(),
          '/permission-denied': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return PermissionDeniedScreen(
              permissionType: args['permissionType'] as PermissionType,
              onRetry: args['onRetry'] as VoidCallback?,
              onMaybeLater: args['onMaybeLater'] as VoidCallback?,
            );
          },
          '/network-error': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return NetworkErrorScreen(
              errorType: args['errorType'] as NetworkErrorType,
              customMessage: args['customMessage'] as String?,
              onRetry: args['onRetry'] as VoidCallback?,
              onGoBack: args['onGoBack'] as VoidCallback?,
              showOfflineMode: args['showOfflineMode'] as bool? ?? false,
            );
          },
          '/error-demo': (context) => const ErrorDemoScreen(),
          '/empty-states': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return EmptyStatesScreen(
              emptyStateType: args['emptyStateType'] as EmptyStateType,
              customTitle: args['customTitle'] as String?,
              customMessage: args['customMessage'] as String?,
              customActionText: args['customActionText'] as String?,
              onActionPressed: args['onActionPressed'] as VoidCallback?,
              showIllustration: args['showIllustration'] as bool? ?? true,
            );
          },
          '/loading-states': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return LoadingStatesScreen(
              loadingStateType: args['loadingStateType'] as LoadingStateType,
              customTitle: args['customTitle'] as String?,
              customMessage: args['customMessage'] as String?,
              showProgress: args['showProgress'] as bool? ?? false,
              progressValue: args['progressValue'] as double?,
              onCancel: args['onCancel'] as VoidCallback?,
              cancellable: args['cancellable'] as bool? ?? false,
            );
          },
        },
      ),
    );
  }
}

// App Colors
class AppColors {
  // New green + beige color scheme
  static const primary = Color(0xFF4F7C8A);        // Sage green - main brand color
  static const secondary = Color(0xFF7FB069);      // Fresh green - accent color
  static const accent = Color(0xFFF5F1E8);        // Warm beige - secondary accent
  
  // Success, warning, error colors (keeping some green for consistency)
  static const success = Color(0xFF7FB069);       // Fresh green for success states
  static const warning = Color(0xFFE6A23C);       // Warm amber for warnings
  static const error = Color(0xFFE74C3C);         // Warm red for errors
  
  // Neutral colors
  static const neutral = Color(0xFF8B8B8B);       // Warm gray
  
  // Background colors
  static const background = Color(0xFFFDFCFA);    // Warm white background
  static const secondaryBackground = Color(0xFFFAF8F3); // Light beige background
  
  // Text colors
  static const textPrimary = Color(0xFF2C3E50);   // Dark blue-gray for primary text
  static const textSecondary = Color(0xFF7F8C8D); // Medium gray for secondary text
}
