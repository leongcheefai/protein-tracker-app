import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/camera_launch_screen.dart';
import 'screens/photo_capture_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/food_detection_results_screen.dart';
import 'screens/portion_selection_screen.dart';
import 'screens/meal_assignment_screen.dart';
import 'screens/confirmation_screen.dart';
import 'screens/user_home_screen.dart';

void main() {
  runApp(const ProteinPaceApp());
}

class ProteinPaceApp extends StatelessWidget {
  const ProteinPaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Protein Pace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          displaySmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF2563EB), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
      },
    );
  }
}

// App Colors
class AppColors {
  static const primary = Color(0xFF2563EB);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const neutral = Color(0xFF6B7280);
  static const background = Color(0xFFFFFFFF);
  static const secondaryBackground = Color(0xFFF9FAFB);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
}
