import { createClient } from '@supabase/supabase-js';
import { Database } from '../types/supabase';

// Environment variables - you'll need to add these to your .env file
const supabaseUrl = process.env.SUPABASE_URL!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;

if (!supabaseUrl || !supabaseServiceKey) {
  throw new Error('Missing Supabase environment variables');
}

// Create Supabase client with service role key for server-side operations
export const supabase = createClient<Database>(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

// Create client for user operations (with anon key)
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY!;
export const supabaseClient = createClient<Database>(supabaseUrl, supabaseAnonKey);

export default supabase;