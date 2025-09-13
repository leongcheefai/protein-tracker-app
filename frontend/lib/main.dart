import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'services/service_locator.dart';
import 'providers/auth_provider.dart';
import 'providers/user_profile_provider.dart';
import 'providers/food_provider.dart';
import 'providers/progress_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/authentication_welcome_screen.dart';
import 'screens/email_signup_screen.dart';
import 'screens/email_login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/password_reset_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/third_party_auth_loading_screen.dart' as auth_loading;
import 'screens/account_linking_screen.dart' as account_linking;
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
import 'screens/pricing_plans_screen.dart';
import 'screens/payment_processing_screen.dart';
import 'screens/payment_success_screen.dart';
import 'screens/subscription_management_screen.dart';
import 'screens/premium_features_unlock_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/enhanced_meal_logging_screen.dart';
import 'screens/meal_success_screen.dart';
import 'screens/analytics_dashboard_screen.dart';
import 'utils/user_settings_provider.dart';
import 'utils/meal_tracking_provider.dart';
import 'utils/nutrition_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables first
  await SupabaseConfig.load();
  
  // Initialize Supabase with error handling
  try {
    // Validate configuration before initializing
    SupabaseConfig.validateConfiguration();
    
    await Supabase.initialize(
      url: SupabaseConfig.validatedUrl,
      anonKey: SupabaseConfig.validatedAnonKey,
      debug: kDebugMode,
    );
  } catch (e) {
    // Re-throw the error so the app doesn't start with invalid config
    rethrow;
  }
  
  // Initialize our service locator
  await ServiceLocator().initialize();
  
  runApp(const ProteinPaceApp());
}

class ProteinPaceApp extends StatelessWidget {
  const ProteinPaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()..startAuthStateListener()),
        ChangeNotifierProvider(create: (context) => UserProfileProvider()),
        ChangeNotifierProvider(create: (context) => FoodProvider()),
        ChangeNotifierProvider(create: (context) => UserSettingsProvider()),
        ChangeNotifierProvider(create: (context) => MealTrackingProvider()),
        ChangeNotifierProvider(create: (context) => ProgressProvider()),
      ],
      child: Consumer2<AuthProvider, UserProfileProvider>(
        builder: (context, authProvider, profileProvider, _) {
          // Initialize profile provider when user is authenticated
          if (authProvider.isAuthenticated && profileProvider.profile == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              profileProvider.initializeFromAuth(authProvider.currentUser);
            });
          }
          
          return CupertinoApp(
            title: 'Fuelie',
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
            home: _buildHomeScreen(authProvider),
            routes: {
          '/auth-welcome': (context) => const AuthenticationWelcomeScreen(),
          '/welcome': (context) => const WelcomeScreen(),
          '/email-signup': (context) => const EmailSignupScreen(),
          '/email-login': (context) => const EmailLoginScreen(),
          '/password-reset': (context) => const PasswordResetScreen(),
          '/email-verification': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return EmailVerificationScreen(
              email: args['email'] as String,
            );
          },
          '/third-party-auth-loading': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return auth_loading.ThirdPartyAuthLoadingScreen(
              provider: args['provider'] as auth_loading.AuthProvider,
              onCancel: args['onCancel'] as VoidCallback?,
            );
          },
          '/account-linking': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return account_linking.AccountLinkingScreen(
              provider: args['provider'] as account_linking.AuthProvider,
              email: args['email'] as String,
            );
          },
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
              // Pass user settings if available
              height: args['height'] as double?,
              weight: args['weight'] as double?,
              trainingMultiplier: args['trainingMultiplier'] as double?,
              goal: args['goal'] as String?,
              dailyProteinTarget: args['dailyProteinTarget'] as double?,
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
          '/profile-settings': (context) => const ProfileSettingsScreen(),
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
          '/pricing-plans': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
            return PricingPlansScreen(
              currentPlan: args?['currentPlan'] as SubscriptionPlan? ?? SubscriptionPlan.free,
              isTrialUser: args?['isTrialUser'] as bool? ?? false,
              onClose: args?['onClose'] as VoidCallback?,
            );
          },
          '/payment-processing': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return PaymentProcessingScreen(
              plan: args['plan'] as SubscriptionPlan,
              period: args['period'] as SubscriptionPeriod,
              price: args['price'] as double,
            );
          },
          '/payment-success': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return PaymentSuccessScreen(
              plan: args['plan'] as SubscriptionPlan,
              period: args['period'] as SubscriptionPeriod,
              price: args['price'] as double,
            );
          },
          '/subscription-management': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return SubscriptionManagementScreen(
              currentPlan: args['currentPlan'] as SubscriptionPlan,
              currentPeriod: args['currentPeriod'] as SubscriptionPeriod,
              currentPrice: args['currentPrice'] as double,
              nextBillingDate: args['nextBillingDate'] as DateTime,
              isTrialActive: args['isTrialActive'] as bool? ?? false,
            );
          },
          '/premium-features-unlock': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return PremiumFeaturesUnlockScreen(
              trigger: args['trigger'] as UnlockTrigger,
              customMessage: args['customMessage'] as String?,
              onSkip: args['onSkip'] as VoidCallback?,
            );
          },
          '/profile-setup': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return ProfileSetupScreen(
              name: args['name'] as String?,
              email: args['email'] as String,
              profileImageUrl: args['profileImageUrl'] as String?,
              isReturningUser: args['isReturningUser'] as bool? ?? false,
            );
          },
          '/enhanced-meal-logging': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            return EnhancedMealLoggingScreen(
              imagePath: args?['imagePath'] as String?,
              detectedFoods: args?['detectedFoods'] as List<Map<String, dynamic>>?,
              preselectedMealType: args?['preselectedMealType'] as String?,
            );
          },
          '/meal-success': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return MealSuccessScreen(
              meal: args['meal'] as Meal,
              nutrition: args['nutrition'] as NutritionData,
            );
          },
          '/analytics': (context) => const AnalyticsDashboardScreen(),
            },
          );
        },
      ),
    );
  }

  Widget _buildHomeScreen(AuthProvider authProvider) {
    switch (authProvider.state) {
      case AuthenticationState.unknown:
        return const SplashScreen();
      case AuthenticationState.unauthenticated:
        return const AuthenticationWelcomeScreen();
      case AuthenticationState.authenticating:
        return const SplashScreen(); // or a loading screen
      case AuthenticationState.authenticated:
        // Check if user has completed essential profile setup (dailyProteinGoal)
        if (authProvider.dailyProteinGoal == null) {
          return const WelcomeScreen(); // Redirect to profile setup flow
        } else {
          // For users with completed profile setup, provide sensible defaults for any missing data
          return UserHomeScreen(
            height: authProvider.height ?? 170.0, // Default height in cm
            weight: authProvider.weight ?? 70.0,   // Default weight in kg  
            trainingMultiplier: 1.8, // Default moderate activity level
            goal: 'maintain', // Default goal
            dailyProteinTarget: authProvider.dailyProteinGoal!, // Use existing protein target
          );
        }
    }
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
