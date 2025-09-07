import { DatabaseService } from '../utils/database';
import { Meal, NutritionData } from '../types/supabase';

export interface DailyStats {
  date: string;
  totalCalories: number;
  totalProtein: number;
  totalCarbs: number;
  totalFat: number;
  totalFiber: number;
  goalMet: boolean;
  mealsCount: number;
  mealBreakdown: {
    breakfast: { protein: number; calories: number; count: number };
    lunch: { protein: number; calories: number; count: number };
    dinner: { protein: number; calories: number; count: number };
    snack: { protein: number; calories: number; count: number };
  };
}

export interface WeeklyStats {
  weekStart: string;
  weekEnd: string;
  averageDaily: {
    calories: number;
    protein: number;
    carbs: number;
    fat: number;
  };
  daysWithGoalMet: number;
  totalDaysTracked: number;
  goalHitPercentage: number;
  trend: 'improving' | 'declining' | 'stable';
}

export interface StreakData {
  currentStreak: number;
  longestStreak: number;
  lastStreakDate: string | null;
  streakHistory: Array<{
    startDate: string;
    endDate: string;
    length: number;
  }>;
}

export interface MealTimingAnalysis {
  averageMealTimes: {
    breakfast: string | null;
    lunch: string | null;
    dinner: string | null;
    snack: string | null;
  };
  mealConsistency: {
    breakfast: number; // percentage of days with breakfast
    lunch: number;
    dinner: number;
    snack: number;
  };
  optimalTimingSuggestions: Array<{
    meal: string;
    suggestedTime: string;
    reason: string;
  }>;
}

export interface NutritionInsight {
  type: 'achievement' | 'recommendation' | 'pattern' | 'warning';
  title: string;
  description: string;
  data?: any;
  priority: 'high' | 'medium' | 'low';
  actionable: boolean;
}

export interface AnalyticsOverview {
  period: string;
  dailyStats: DailyStats[];
  weeklyStats: WeeklyStats[];
  streakData: StreakData;
  mealTimingAnalysis: MealTimingAnalysis;
  insights: NutritionInsight[];
  achievements: Array<{
    id: string;
    name: string;
    description: string;
    dateEarned: string;
    category: 'streak' | 'goal' | 'consistency' | 'milestone';
  }>;
}

export class AnalyticsService {
  /**
   * Get comprehensive analytics overview for a user
   */
  static async getAnalyticsOverview(
    userId: string,
    startDate?: Date,
    endDate?: Date
  ): Promise<AnalyticsOverview> {
    // Default to last 30 days if no dates provided
    const end = endDate || new Date();
    end.setHours(23, 59, 59, 999);

    const start = startDate || new Date();
    if (!startDate) {
      start.setDate(start.getDate() - 29);
      start.setHours(0, 0, 0, 0);
    }

    // Get user profile for goals
    const userProfile = await DatabaseService.getUserProfile(userId);
    const dailyProteinGoal = userProfile?.daily_protein_goal || 100;

    // Get all meals in date range
    const meals = await DatabaseService.getUserMeals(
      userId,
      start.toISOString(),
      end.toISOString()
    );

    // Calculate daily stats
    const dailyStats = await this.calculateDailyStats(meals, dailyProteinGoal, start, end);

    // Calculate weekly stats
    const weeklyStats = this.calculateWeeklyStats(dailyStats);

    // Calculate streak data
    const streakData = this.calculateStreakData(dailyStats);

    // Analyze meal timing patterns
    const mealTimingAnalysis = this.analyzeMealTiming(meals);

    // Generate insights
    const insights = this.generateNutritionInsights(dailyStats, weeklyStats, streakData, mealTimingAnalysis);

    // Calculate achievements
    const achievements = this.calculateAchievements(dailyStats, streakData);

    return {
      period: `${start.toISOString().split('T')[0]} to ${end.toISOString().split('T')[0]}`,
      dailyStats,
      weeklyStats,
      streakData,
      mealTimingAnalysis,
      insights,
      achievements,
    };
  }

  /**
   * Calculate daily nutrition statistics
   */
  private static async calculateDailyStats(
    meals: any[],
    dailyProteinGoal: number,
    startDate: Date,
    endDate: Date
  ): Promise<DailyStats[]> {
    const dailyStatsMap = new Map<string, DailyStats>();

    // Initialize all dates in range
    const currentDate = new Date(startDate);
    while (currentDate <= endDate) {
      const dateKey = currentDate.toISOString().split('T')[0];
      dailyStatsMap.set(dateKey, {
        date: dateKey,
        totalCalories: 0,
        totalProtein: 0,
        totalCarbs: 0,
        totalFat: 0,
        totalFiber: 0,
        goalMet: false,
        mealsCount: 0,
        mealBreakdown: {
          breakfast: { protein: 0, calories: 0, count: 0 },
          lunch: { protein: 0, calories: 0, count: 0 },
          dinner: { protein: 0, calories: 0, count: 0 },
          snack: { protein: 0, calories: 0, count: 0 },
        },
      });
      currentDate.setDate(currentDate.getDate() + 1);
    }

    // Process each meal
    for (const meal of meals) {
      const mealDate = new Date(meal.timestamp).toISOString().split('T')[0];
      const dailyStat = dailyStatsMap.get(mealDate);
      
      if (!dailyStat) continue;

      // Calculate meal nutrition
      const mealNutrition = await this.calculateMealNutrition(meal);
      const mealType = meal.meal_type.toLowerCase() as keyof typeof dailyStat.mealBreakdown;

      // Update daily totals
      dailyStat.totalCalories += mealNutrition.calories;
      dailyStat.totalProtein += mealNutrition.protein;
      dailyStat.totalCarbs += mealNutrition.carbs;
      dailyStat.totalFat += mealNutrition.fat;
      dailyStat.totalFiber += mealNutrition.fiber;
      dailyStat.mealsCount++;

      // Update meal breakdown
      if (dailyStat.mealBreakdown[mealType]) {
        dailyStat.mealBreakdown[mealType].protein += mealNutrition.protein;
        dailyStat.mealBreakdown[mealType].calories += mealNutrition.calories;
        dailyStat.mealBreakdown[mealType].count++;
      }
    }

    // Determine if goal was met for each day
    Array.from(dailyStatsMap.values()).forEach(stat => {
      stat.goalMet = stat.totalProtein >= dailyProteinGoal;
    });

    return Array.from(dailyStatsMap.values()).sort((a, b) => a.date.localeCompare(b.date));
  }

  /**
   * Calculate meal nutrition from meal_foods
   */
  private static async calculateMealNutrition(meal: any): Promise<NutritionData> {
    const mealFoods = meal.meal_foods || [];
    
    return mealFoods.reduce((total: NutritionData, mealFood: any) => {
      const nutrition = mealFood.nutrition_data || {};
      return {
        calories: (total.calories || 0) + (nutrition.calories || 0),
        protein: (total.protein || 0) + (nutrition.protein || 0),
        carbs: (total.carbs || 0) + (nutrition.carbs || 0),
        fat: (total.fat || 0) + (nutrition.fat || 0),
        fiber: (total.fiber || 0) + (nutrition.fiber || 0),
        sugar: (total.sugar || 0) + (nutrition.sugar || 0),
        sodium: (total.sodium || 0) + (nutrition.sodium || 0),
      };
    }, { calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0, sugar: 0, sodium: 0 });
  }

  /**
   * Calculate weekly statistics from daily stats
   */
  private static calculateWeeklyStats(dailyStats: DailyStats[]): WeeklyStats[] {
    const weeks: WeeklyStats[] = [];
    const grouped = new Map<string, DailyStats[]>();

    // Group by weeks
    dailyStats.forEach(day => {
      const date = new Date(day.date);
      const weekStart = new Date(date);
      weekStart.setDate(date.getDate() - date.getDay()); // Start of week (Sunday)
      const weekKey = weekStart.toISOString().split('T')[0];

      if (!grouped.has(weekKey)) {
        grouped.set(weekKey, []);
      }
      grouped.get(weekKey)!.push(day);
    });

    // Calculate stats for each week
    grouped.forEach((weekDays, weekStart) => {
      const weekEnd = new Date(weekStart);
      weekEnd.setDate(weekEnd.getDate() + 6);

      const totalDays = weekDays.length;
      const daysWithGoalMet = weekDays.filter(day => day.goalMet).length;

      const averages = weekDays.reduce(
        (acc, day) => ({
          calories: acc.calories + day.totalCalories,
          protein: acc.protein + day.totalProtein,
          carbs: acc.carbs + day.totalCarbs,
          fat: acc.fat + day.totalFat,
        }),
        { calories: 0, protein: 0, carbs: 0, fat: 0 }
      );

      // Calculate trend (simple comparison with previous week)
      let trend: 'improving' | 'declining' | 'stable' = 'stable';
      if (weeks.length > 0) {
        const prevWeek = weeks[weeks.length - 1];
        const currentAvgProtein = averages.protein / totalDays;
        const prevAvgProtein = prevWeek.averageDaily.protein;
        
        if (currentAvgProtein > prevAvgProtein * 1.05) trend = 'improving';
        else if (currentAvgProtein < prevAvgProtein * 0.95) trend = 'declining';
      }

      weeks.push({
        weekStart,
        weekEnd: weekEnd.toISOString().split('T')[0],
        averageDaily: {
          calories: Math.round(averages.calories / totalDays),
          protein: Math.round((averages.protein / totalDays) * 10) / 10,
          carbs: Math.round(averages.carbs / totalDays),
          fat: Math.round(averages.fat / totalDays),
        },
        daysWithGoalMet,
        totalDaysTracked: totalDays,
        goalHitPercentage: Math.round((daysWithGoalMet / totalDays) * 100),
        trend,
      });
    });

    return weeks.sort((a, b) => a.weekStart.localeCompare(b.weekStart));
  }

  /**
   * Calculate streak data from daily stats
   */
  private static calculateStreakData(dailyStats: DailyStats[]): StreakData {
    let currentStreak = 0;
    let longestStreak = 0;
    let tempStreak = 0;
    let lastStreakDate: string | null = null;
    const streakHistory: Array<{ startDate: string; endDate: string; length: number }> = [];
    let streakStart: string | null = null;

    // Calculate streaks from most recent backwards
    for (let i = dailyStats.length - 1; i >= 0; i--) {
      const day = dailyStats[i];
      
      if (day.goalMet) {
        tempStreak++;
        if (i === dailyStats.length - 1) {
          currentStreak = tempStreak;
          lastStreakDate = day.date;
        }
        if (!streakStart) streakStart = day.date;
        longestStreak = Math.max(longestStreak, tempStreak);
      } else {
        if (tempStreak > 0 && streakStart) {
          streakHistory.unshift({
            startDate: streakStart,
            endDate: dailyStats[i + 1]?.date || streakStart,
            length: tempStreak,
          });
        }
        tempStreak = 0;
        streakStart = null;
      }
    }

    // Add final streak if it goes to the beginning
    if (tempStreak > 0 && streakStart) {
      streakHistory.unshift({
        startDate: streakStart,
        endDate: dailyStats[0]?.date || streakStart,
        length: tempStreak,
      });
    }

    return {
      currentStreak,
      longestStreak,
      lastStreakDate,
      streakHistory: streakHistory.slice(0, 10), // Keep last 10 streaks
    };
  }

  /**
   * Analyze meal timing patterns
   */
  private static analyzeMealTiming(meals: any[]): MealTimingAnalysis {
    const mealTimes = {
      breakfast: [] as number[],
      lunch: [] as number[],
      dinner: [] as number[],
      snack: [] as number[],
    };

    const mealCounts = {
      breakfast: 0,
      lunch: 0,
      dinner: 0,
      snack: 0,
    };

    const totalDays = new Set(meals.map(meal => 
      new Date(meal.timestamp).toISOString().split('T')[0]
    )).size || 1;

    // Collect meal times
    meals.forEach(meal => {
      const mealType = meal.meal_type.toLowerCase() as keyof typeof mealTimes;
      const mealTime = new Date(meal.timestamp);
      const hourMinutes = mealTime.getHours() + (mealTime.getMinutes() / 60);
      
      if (mealTimes[mealType]) {
        mealTimes[mealType].push(hourMinutes);
        mealCounts[mealType]++;
      }
    });

    // Calculate averages
    const averageMealTimes = Object.entries(mealTimes).reduce((acc, [mealType, times]) => {
      if (times.length > 0) {
        const avgTime = times.reduce((sum, time) => sum + time, 0) / times.length;
        const hours = Math.floor(avgTime);
        const minutes = Math.round((avgTime - hours) * 60);
        acc[mealType as keyof typeof acc] = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`;
      } else {
        acc[mealType as keyof typeof acc] = null;
      }
      return acc;
    }, {} as MealTimingAnalysis['averageMealTimes']);

    // Calculate consistency percentages
    const mealConsistency = Object.entries(mealCounts).reduce((acc, [mealType, count]) => {
      acc[mealType as keyof typeof acc] = Math.round((count / totalDays) * 100);
      return acc;
    }, {} as MealTimingAnalysis['mealConsistency']);

    // Generate optimization suggestions
    const optimalTimingSuggestions: MealTimingAnalysis['optimalTimingSuggestions'] = [];

    // Add suggestions based on patterns
    if (mealConsistency.breakfast < 70) {
      optimalTimingSuggestions.push({
        meal: 'breakfast',
        suggestedTime: '07:30',
        reason: 'Eating breakfast more consistently can help meet daily protein goals',
      });
    }

    if (averageMealTimes.dinner && parseFloat(averageMealTimes.dinner.replace(':', '.')) > 20) {
      optimalTimingSuggestions.push({
        meal: 'dinner',
        suggestedTime: '18:30',
        reason: 'Earlier dinner timing may improve protein absorption and sleep quality',
      });
    }

    return {
      averageMealTimes,
      mealConsistency,
      optimalTimingSuggestions,
    };
  }

  /**
   * Generate personalized nutrition insights
   */
  private static generateNutritionInsights(
    dailyStats: DailyStats[],
    weeklyStats: WeeklyStats[],
    streakData: StreakData,
    mealTiming: MealTimingAnalysis
  ): NutritionInsight[] {
    const insights: NutritionInsight[] = [];

    // Goal achievement insights
    const recentDays = dailyStats.slice(-7);
    const goalMetCount = recentDays.filter(day => day.goalMet).length;
    const goalPercentage = (goalMetCount / recentDays.length) * 100;

    if (goalPercentage >= 80) {
      insights.push({
        type: 'achievement',
        title: 'Excellent Progress!',
        description: `You've hit your protein goal ${goalMetCount} out of the last 7 days. Keep it up!`,
        priority: 'high',
        actionable: false,
      });
    } else if (goalPercentage >= 50) {
      insights.push({
        type: 'recommendation',
        title: 'You\'re Getting There',
        description: `You've met your goal ${goalMetCount} out of 7 days. Try adding a protein-rich snack to improve consistency.`,
        priority: 'medium',
        actionable: true,
      });
    } else {
      insights.push({
        type: 'warning',
        title: 'Need More Consistency',
        description: `Only ${goalMetCount} out of 7 days met your protein goal. Consider increasing portion sizes or adding more meals.`,
        priority: 'high',
        actionable: true,
      });
    }

    // Streak insights
    if (streakData.currentStreak >= 7) {
      insights.push({
        type: 'achievement',
        title: 'Weekly Streak!',
        description: `Amazing! You're on a ${streakData.currentStreak}-day streak of hitting your protein goals.`,
        priority: 'high',
        actionable: false,
      });
    } else if (streakData.currentStreak === 0 && streakData.longestStreak >= 3) {
      insights.push({
        type: 'recommendation',
        title: 'Get Back on Track',
        description: `Your longest streak was ${streakData.longestStreak} days. You can do it again!`,
        priority: 'medium',
        actionable: true,
      });
    }

    // Meal timing insights
    if (mealTiming.mealConsistency.breakfast < 60) {
      insights.push({
        type: 'recommendation',
        title: 'Breakfast Opportunity',
        description: `You're missing breakfast ${100 - mealTiming.mealConsistency.breakfast}% of the time. Starting your day with protein can help reach daily goals.`,
        priority: 'medium',
        actionable: true,
      });
    }

    // Weekly trend insights
    if (weeklyStats.length >= 2) {
      const latestWeek = weeklyStats[weeklyStats.length - 1];
      if (latestWeek.trend === 'improving') {
        insights.push({
          type: 'achievement',
          title: 'Upward Trend!',
          description: 'Your weekly average protein intake is improving. Great progress!',
          priority: 'medium',
          actionable: false,
        });
      } else if (latestWeek.trend === 'declining') {
        insights.push({
          type: 'warning',
          title: 'Declining Trend',
          description: 'Your protein intake has decreased this week. Consider reviewing your meal planning.',
          priority: 'medium',
          actionable: true,
        });
      }
    }

    // Meal distribution insights
    const avgMealBreakdown = dailyStats.reduce((acc, day) => {
      acc.breakfast += day.mealBreakdown.breakfast.protein;
      acc.lunch += day.mealBreakdown.lunch.protein;
      acc.dinner += day.mealBreakdown.dinner.protein;
      acc.snack += day.mealBreakdown.snack.protein;
      return acc;
    }, { breakfast: 0, lunch: 0, dinner: 0, snack: 0 });

    const totalProtein = Object.values(avgMealBreakdown).reduce((sum, val) => sum + val, 0);
    if (totalProtein > 0) {
      const dinnerPercentage = (avgMealBreakdown.dinner / totalProtein) * 100;
      
      if (dinnerPercentage > 50) {
        insights.push({
          type: 'recommendation',
          title: 'Balance Your Protein',
          description: 'You\'re getting most of your protein at dinner. Try spreading it more evenly throughout the day for better absorption.',
          priority: 'medium',
          actionable: true,
        });
      }
    }

    return insights.sort((a, b) => {
      const priorityOrder = { high: 0, medium: 1, low: 2 };
      return priorityOrder[a.priority] - priorityOrder[b.priority];
    });
  }

  /**
   * Calculate achievements based on user data
   */
  private static calculateAchievements(
    dailyStats: DailyStats[],
    streakData: StreakData
  ): AnalyticsOverview['achievements'] {
    const achievements: AnalyticsOverview['achievements'] = [];

    // Streak achievements
    if (streakData.currentStreak >= 7) {
      achievements.push({
        id: 'week_streak',
        name: 'Week Warrior',
        description: 'Hit your protein goal 7 days in a row',
        dateEarned: new Date().toISOString(),
        category: 'streak',
      });
    }

    if (streakData.longestStreak >= 30) {
      achievements.push({
        id: 'month_streak',
        name: 'Monthly Master',
        description: 'Hit your protein goal 30 days in a row',
        dateEarned: new Date().toISOString(),
        category: 'streak',
      });
    }

    // Goal achievements
    const goalMetDays = dailyStats.filter(day => day.goalMet).length;
    const totalDays = dailyStats.length;
    
    if (goalMetDays / totalDays >= 0.9) {
      achievements.push({
        id: 'consistent_achiever',
        name: 'Consistent Achiever',
        description: 'Hit your protein goal 90% of the time',
        dateEarned: new Date().toISOString(),
        category: 'goal',
      });
    }

    // Consistency achievements
    const breakfastConsistency = dailyStats.filter(day => day.mealBreakdown.breakfast.count > 0).length;
    if (breakfastConsistency / totalDays >= 0.8) {
      achievements.push({
        id: 'breakfast_champion',
        name: 'Breakfast Champion',
        description: 'Ate breakfast 80% of tracked days',
        dateEarned: new Date().toISOString(),
        category: 'consistency',
      });
    }

    // Milestone achievements
    const totalMeals = dailyStats.reduce((sum, day) => sum + day.mealsCount, 0);
    if (totalMeals >= 100) {
      achievements.push({
        id: 'meal_milestone_100',
        name: 'Century Club',
        description: 'Logged 100 meals',
        dateEarned: new Date().toISOString(),
        category: 'milestone',
      });
    }

    return achievements;
  }

  /**
   * Export user data in various formats
   */
  static async exportUserData(
    userId: string,
    format: 'json' | 'csv',
    startDate?: Date,
    endDate?: Date
  ): Promise<{ data: string; filename: string; contentType: string }> {
    const analytics = await this.getAnalyticsOverview(userId, startDate, endDate);
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-').split('T')[0];

    if (format === 'json') {
      return {
        data: JSON.stringify(analytics, null, 2),
        filename: `protein-tracker-data-${timestamp}.json`,
        contentType: 'application/json',
      };
    } else {
      // CSV format
      const csvRows: string[] = [];
      
      // Header
      csvRows.push('Date,Total Protein,Total Calories,Goal Met,Meals Count,Breakfast Protein,Lunch Protein,Dinner Protein,Snack Protein');
      
      // Data rows
      analytics.dailyStats.forEach(day => {
        csvRows.push([
          day.date,
          day.totalProtein.toFixed(1),
          day.totalCalories.toFixed(0),
          day.goalMet ? 'Yes' : 'No',
          day.mealsCount.toString(),
          day.mealBreakdown.breakfast.protein.toFixed(1),
          day.mealBreakdown.lunch.protein.toFixed(1),
          day.mealBreakdown.dinner.protein.toFixed(1),
          day.mealBreakdown.snack.protein.toFixed(1),
        ].join(','));
      });

      return {
        data: csvRows.join('\n'),
        filename: `protein-tracker-data-${timestamp}.csv`,
        contentType: 'text/csv',
      };
    }
  }
}