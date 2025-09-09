import supabase from '../config/supabase';
import { Database } from '../types/supabase';

// Export Supabase client for database operations
export { supabase };

// Helper functions for common database operations
export class DatabaseService {
  // User operations
  static async getUserProfile(userId: string) {
    const { data, error } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('id', userId)
      .single();
    
    if (error) throw error;
    return data;
  }

  static async createUserProfile(profile: Database['public']['Tables']['user_profiles']['Insert']) {
    const { data, error } = await supabase
      .from('user_profiles')
      .insert([profile])
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }

  // Get user profile with user context (to bypass RLS)
  static async getUserProfileWithContext(userId: string, userToken: string) {
    const { createClient } = require('@supabase/supabase-js');
    const supabaseUrl = process.env.SUPABASE_URL!;
    const supabaseAnonKey = process.env.SUPABASE_ANON_KEY!;
    
    // Create a new client with the user's token
    const userClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: {
        headers: {
          Authorization: `Bearer ${userToken}`
        }
      }
    });

    const { data, error } = await userClient
      .from('user_profiles')
      .select('*')
      .eq('id', userId)
      .single();
    
    if (error) throw error;
    return data;
  }

  // Create user profile with user context (to bypass RLS)
  static async createUserProfileWithContext(profile: Database['public']['Tables']['user_profiles']['Insert'], userToken: string) {
    const { createClient } = require('@supabase/supabase-js');
    const supabaseUrl = process.env.SUPABASE_URL!;
    const supabaseAnonKey = process.env.SUPABASE_ANON_KEY!;
    
    // Create a new client with the user's token
    const userClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: {
        headers: {
          Authorization: `Bearer ${userToken}`
        }
      }
    });

    const { data, error } = await userClient
      .from('user_profiles')
      .insert([profile])
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }

  static async updateUserProfile(userId: string, updates: Database['public']['Tables']['user_profiles']['Update']) {
    const { data, error } = await supabase
      .from('user_profiles')
      .update({ ...updates, updated_at: new Date().toISOString() })
      .eq('id', userId)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }

  // Food operations
  static async searchFoods(query: string, limit = 20) {
    const { data, error } = await supabase
      .from('foods')
      .select('*')
      .ilike('name', `%${query}%`)
      .order('verified', { ascending: false })
      .order('name')
      .limit(limit);
    
    if (error) throw error;
    return data;
  }

  static async createFood(food: Database['public']['Tables']['foods']['Insert']) {
    const { data, error } = await supabase
      .from('foods')
      .insert([food])
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }

  // Meal operations
  static async createMeal(meal: Database['public']['Tables']['meals']['Insert']) {
    const { data, error } = await supabase
      .from('meals')
      .insert([meal])
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }

  static async getUserMeals(userId: string, startDate?: string, endDate?: string) {
    let query = supabase
      .from('meals')
      .select(`
        *,
        meal_foods (
          *,
          foods (*)
        )
      `)
      .eq('user_id', userId)
      .order('timestamp', { ascending: false });

    if (startDate) {
      query = query.gte('timestamp', startDate);
    }
    if (endDate) {
      query = query.lte('timestamp', endDate);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data;
  }

  // Food detection operations
  static async createFoodDetection(detection: Database['public']['Tables']['food_detections']['Insert']) {
    const { data, error } = await supabase
      .from('food_detections')
      .insert([detection])
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }

  static async getFoodDetection(id: string) {
    const { data, error } = await supabase
      .from('food_detections')
      .select('*')
      .eq('id', id)
      .single();
    
    if (error) throw error;
    return data;
  }

  // Additional meal food operations
  static async createMealFood(mealFood: Database['public']['Tables']['meal_foods']['Insert']) {
    const { data, error } = await supabase
      .from('meal_foods')
      .insert([mealFood])
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }

  static async getMealFoods(mealId: string) {
    const { data, error } = await supabase
      .from('meal_foods')
      .select(`
        *,
        foods (*)
      `)
      .eq('meal_id', mealId);
    
    if (error) throw error;
    return data;
  }

  static async deleteMealFood(id: string) {
    const { data, error } = await supabase
      .from('meal_foods')
      .delete()
      .eq('id', id)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }

  static async updateMeal(mealId: string, updates: Database['public']['Tables']['meals']['Update']) {
    const { data, error } = await supabase
      .from('meals')
      .update({ ...updates, updated_at: new Date().toISOString() })
      .eq('id', mealId)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }

  static async deleteMeal(mealId: string) {
    const { data, error } = await supabase
      .from('meals')
      .delete()
      .eq('id', mealId)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }

  static async getFoodById(id: string) {
    const { data, error } = await supabase
      .from('foods')
      .select('*')
      .eq('id', id)
      .single();
    
    if (error) throw error;
    return data;
  }
}

// Connection test function
export async function testConnection() {
  try {
    const { data, error } = await supabase
      .from('user_profiles')
      .select('count')
      .limit(1);
    
    if (error) {
      console.error('Database connection failed:', error.message);
      return false;
    }
    
    console.log('Database connection successful');
    return true;
  } catch (error) {
    console.error('Database connection test failed:', error);
    return false;
  }
}