import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'height_weight_screen.dart';
import '../main.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              
              // Hero Image
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  CupertinoIcons.creditcard,
                  size: 100,
                  color: AppColors.primary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // App Tagline
              Text(
                'Track protein intake with just a photo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Key Benefits
              _buildBenefitItem(
                context,
                CupertinoIcons.camera,
                'AI-powered food recognition',
                'Simply take a photo of your meal',
              ),
              
              const SizedBox(height: 16),
              
              _buildBenefitItem(
                context,
                CupertinoIcons.chart_bar,
                'Accurate protein tracking',
                'Get precise protein content for your foods',
              ),
              
              const SizedBox(height: 16),
              
              _buildBenefitItem(
                context,
                CupertinoIcons.graph_circle,
                'Progress monitoring',
                'Track your daily protein goals and progress',
              ),
              
              const SizedBox(height: 32),
              
              // Privacy Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.shield,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your photos are never stored',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Get Started Button
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const HeightWeightScreen(),
                      ),
                    );
                  },
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      color: Colors.white,
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
    );
  }

  Widget _buildBenefitItem(BuildContext context, IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
