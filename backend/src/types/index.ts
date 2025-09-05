export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
  timestamp: string;
}

export interface AuthenticatedRequest extends Request {
  user?: {
    id: string;
    email: string;
    role?: string;
  };
}

export interface CreateUserData {
  email: string;
  name?: string;
  password?: string;
  profileImageUrl?: string;
  height?: number;
  weight?: number;
  trainingMultiplier?: number;
  goal?: 'maintain' | 'bulk' | 'cut';
}

export interface UpdateUserProfile {
  name?: string;
  height?: number;
  weight?: number;
  trainingMultiplier?: number;
  goal?: 'maintain' | 'bulk' | 'cut';
  dailyProteinTarget?: number;
}

export interface UserSettings {
  notificationsEnabled: boolean;
  mealReminderTimes: {
    breakfast: string;
    lunch: string;
    snack: string;
    dinner: string;
  };
  doNotDisturbStart: string;
  doNotDisturbEnd: string;
  nightlySummaryEnabled: boolean;
}

export interface FoodDetectionResult {
  name: string;
  confidence: number;
  estimatedProtein: number;
  category: string;
  boundingBox?: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
}

export interface LogFoodData {
  foodName?: string;
  customName?: string;
  portionSize: number;
  proteinContent: number;
  mealType: 'breakfast' | 'lunch' | 'dinner' | 'snack';
  imagePath?: string;
  calories?: number;
  detectionResults?: FoodDetectionResult[];
  isQuickAdd?: boolean;
}

export interface DailyProgress {
  date: string;
  totalProtein: number;
  dailyTarget: number;
  goalMet: boolean;
  streakCount: number;
  mealBreakdown: {
    breakfast: { target: number; actual: number; items: number };
    lunch: { target: number; actual: number; items: number };
    dinner: { target: number; actual: number; items: number };
    snack: { target: number; actual: number; items: number };
  };
}

export interface WeeklyStats {
  weeklyAverage: number;
  goalHitPercentage: number;
  mostConsistentMeal: string;
  currentStreak: number;
  longestStreak: number;
  totalDaysTracked: number;
  weeklyTrend: number[];
}

export interface MealConsistency {
  breakfast: number;
  lunch: number;
  dinner: number;
  snack: number;
}

export interface SubscriptionInfo {
  planType: 'free' | 'pro';
  billingPeriod?: 'monthly' | 'annual';
  status: 'active' | 'past_due' | 'canceled' | 'trialing';
  currentPeriodStart?: Date;
  currentPeriodEnd?: Date;
  trialEnd?: Date;
}