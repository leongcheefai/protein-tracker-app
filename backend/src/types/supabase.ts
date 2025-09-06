export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      user_profiles: {
        Row: {
          id: string
          display_name: string | null
          email: string | null
          age: number | null
          weight: number | null
          height: number | null
          daily_protein_goal: number | null
          activity_level: string | null
          dietary_restrictions: string[] | null
          units: string
          notifications_enabled: boolean
          privacy_level: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id: string
          display_name?: string | null
          email?: string | null
          age?: number | null
          weight?: number | null
          height?: number | null
          daily_protein_goal?: number | null
          activity_level?: string | null
          dietary_restrictions?: string[] | null
          units?: string
          notifications_enabled?: boolean
          privacy_level?: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          display_name?: string | null
          email?: string | null
          age?: number | null
          weight?: number | null
          height?: number | null
          daily_protein_goal?: number | null
          activity_level?: string | null
          dietary_restrictions?: string[] | null
          units?: string
          notifications_enabled?: boolean
          privacy_level?: string
          created_at?: string
          updated_at?: string
        }
      }
      foods: {
        Row: {
          id: string
          name: string
          category: string | null
          brand: string | null
          barcode: string | null
          nutrition_per_100g: Json
          common_portions: Json | null
          verified: boolean
          user_id: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          category?: string | null
          brand?: string | null
          barcode?: string | null
          nutrition_per_100g: Json
          common_portions?: Json | null
          verified?: boolean
          user_id?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          category?: string | null
          brand?: string | null
          barcode?: string | null
          nutrition_per_100g?: Json
          common_portions?: Json | null
          verified?: boolean
          user_id?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      meals: {
        Row: {
          id: string
          user_id: string
          meal_type: string
          timestamp: string
          photo_url: string | null
          notes: string | null
          total_nutrition: Json | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          meal_type: string
          timestamp?: string
          photo_url?: string | null
          notes?: string | null
          total_nutrition?: Json | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          meal_type?: string
          timestamp?: string
          photo_url?: string | null
          notes?: string | null
          total_nutrition?: Json | null
          created_at?: string
          updated_at?: string
        }
      }
      meal_foods: {
        Row: {
          id: string
          meal_id: string
          food_id: string
          quantity: number
          unit: string
          nutrition_data: Json | null
          created_at: string
        }
        Insert: {
          id?: string
          meal_id: string
          food_id: string
          quantity: number
          unit: string
          nutrition_data?: Json | null
          created_at?: string
        }
        Update: {
          id?: string
          meal_id?: string
          food_id?: string
          quantity?: number
          unit?: string
          nutrition_data?: Json | null
          created_at?: string
        }
      }
      food_detections: {
        Row: {
          id: string
          user_id: string
          image_url: string
          detected_foods: Json
          confidence_scores: Json | null
          processed_at: string
          status: string
        }
        Insert: {
          id?: string
          user_id: string
          image_url: string
          detected_foods: Json
          confidence_scores?: Json | null
          processed_at?: string
          status?: string
        }
        Update: {
          id?: string
          user_id?: string
          image_url?: string
          detected_foods?: Json
          confidence_scores?: Json | null
          processed_at?: string
          status?: string
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      meal_type: 'breakfast' | 'lunch' | 'dinner' | 'snack'
      activity_level: 'sedentary' | 'lightly_active' | 'moderately_active' | 'very_active' | 'extra_active'
      units: 'metric' | 'imperial'
      privacy_level: 'public' | 'friends' | 'private'
    }
  }
}

// Helper types for easier usage
export type UserProfile = Database['public']['Tables']['user_profiles']['Row'];
export type Food = Database['public']['Tables']['foods']['Row'];
export type Meal = Database['public']['Tables']['meals']['Row'];
export type MealFood = Database['public']['Tables']['meal_foods']['Row'];
export type FoodDetection = Database['public']['Tables']['food_detections']['Row'];

export type InsertUserProfile = Database['public']['Tables']['user_profiles']['Insert'];
export type InsertFood = Database['public']['Tables']['foods']['Insert'];
export type InsertMeal = Database['public']['Tables']['meals']['Insert'];
export type InsertMealFood = Database['public']['Tables']['meal_foods']['Insert'];
export type InsertFoodDetection = Database['public']['Tables']['food_detections']['Insert'];

export type UpdateUserProfile = Database['public']['Tables']['user_profiles']['Update'];
export type UpdateFood = Database['public']['Tables']['foods']['Update'];
export type UpdateMeal = Database['public']['Tables']['meals']['Update'];
export type UpdateMealFood = Database['public']['Tables']['meal_foods']['Update'];

// Nutrition data structure
export interface NutritionData {
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
  fiber?: number;
  sugar?: number;
  sodium?: number;
}

// Common portion structure
export interface CommonPortion {
  name: string;
  grams: number;
}

// Detected food structure
export interface DetectedFood {
  name: string;
  confidence: number;
  nutritionData: NutritionData;
  boundingBox?: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
}