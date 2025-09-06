-- Protein Tracker Database Schema for Supabase
-- Run this in your Supabase SQL Editor

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Create custom types/enums
create type meal_type as enum ('breakfast', 'lunch', 'dinner', 'snack');
create type activity_level as enum ('sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extra_active');
create type units as enum ('metric', 'imperial');
create type privacy_level as enum ('public', 'friends', 'private');

-- User profiles table (extends auth.users)
create table user_profiles (
  id uuid references auth.users on delete cascade primary key,
  display_name text,
  email text,
  age integer check (age >= 13 and age <= 120),
  weight decimal(5,2) check (weight > 0),
  height decimal(5,2) check (height > 0),
  daily_protein_goal decimal(6,2) check (daily_protein_goal >= 0),
  activity_level activity_level default 'moderately_active',
  dietary_restrictions text[],
  units units default 'metric',
  notifications_enabled boolean default true,
  privacy_level privacy_level default 'private',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Foods database table
create table foods (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  category text,
  brand text,
  barcode text unique,
  nutrition_per_100g jsonb not null, -- {calories, protein, carbs, fat, fiber, sugar, sodium}
  common_portions jsonb, -- [{name: string, grams: number}]
  verified boolean default false,
  user_id uuid references auth.users on delete set null, -- null for verified/system foods
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Meals table
create table meals (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  meal_type meal_type not null,
  timestamp timestamp with time zone default timezone('utc'::text, now()) not null,
  photo_url text,
  notes text,
  total_nutrition jsonb, -- calculated nutrition totals
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Meal foods junction table (many-to-many between meals and foods)
create table meal_foods (
  id uuid default gen_random_uuid() primary key,
  meal_id uuid references meals on delete cascade not null,
  food_id uuid references foods on delete cascade not null,
  quantity decimal(8,2) not null check (quantity > 0),
  unit text not null, -- 'grams', 'cups', 'pieces', etc.
  nutrition_data jsonb, -- calculated nutrition for this specific quantity
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Food detection results table
create table food_detections (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  image_url text not null,
  detected_foods jsonb not null, -- array of detected food objects
  confidence_scores jsonb, -- confidence scores for each detection
  processed_at timestamp with time zone default timezone('utc'::text, now()) not null,
  status text default 'completed' check (status in ('processing', 'completed', 'failed'))
);

-- Create indexes for better performance
create index user_profiles_email_idx on user_profiles(email);
create index foods_name_idx on foods using gin(to_tsvector('english', name));
create index foods_category_idx on foods(category);
create index foods_barcode_idx on foods(barcode);
create index foods_verified_idx on foods(verified);
create index meals_user_id_idx on meals(user_id);
create index meals_timestamp_idx on meals(timestamp desc);
create index meals_user_timestamp_idx on meals(user_id, timestamp desc);
create index meal_foods_meal_id_idx on meal_foods(meal_id);
create index meal_foods_food_id_idx on meal_foods(food_id);
create index food_detections_user_id_idx on food_detections(user_id);
create index food_detections_processed_at_idx on food_detections(processed_at desc);

-- Create updated_at trigger function
create or replace function trigger_set_timestamp()
returns trigger as $$
begin
  new.updated_at = timezone('utc'::text, now());
  return new;
end;
$$ language plpgsql;

-- Add updated_at triggers
create trigger set_timestamp_user_profiles
  before update on user_profiles
  for each row
  execute procedure trigger_set_timestamp();

create trigger set_timestamp_foods
  before update on foods
  for each row
  execute procedure trigger_set_timestamp();

create trigger set_timestamp_meals
  before update on meals
  for each row
  execute procedure trigger_set_timestamp();

-- Row Level Security (RLS) policies
alter table user_profiles enable row level security;
alter table meals enable row level security;
alter table meal_foods enable row level security;
alter table food_detections enable row level security;

-- User profiles policies
create policy "Users can view their own profile" on user_profiles
  for select using (auth.uid() = id);

create policy "Users can update their own profile" on user_profiles
  for update using (auth.uid() = id);

create policy "Users can insert their own profile" on user_profiles
  for insert with check (auth.uid() = id);

-- Foods policies (public read, authenticated users can add custom foods)
create policy "Anyone can view verified foods" on foods
  for select using (verified = true or user_id = auth.uid());

create policy "Users can add custom foods" on foods
  for insert with check (auth.uid() = user_id);

create policy "Users can update their custom foods" on foods
  for update using (auth.uid() = user_id and verified = false);

-- Meals policies
create policy "Users can manage their own meals" on meals
  for all using (auth.uid() = user_id);

-- Meal foods policies (inherit from meals)
create policy "Users can manage their meal foods" on meal_foods
  for all using (
    auth.uid() = (select user_id from meals where id = meal_id)
  );

-- Food detections policies
create policy "Users can manage their own detections" on food_detections
  for all using (auth.uid() = user_id);

-- Insert some sample verified foods
insert into foods (name, category, nutrition_per_100g, common_portions, verified) values
('Chicken Breast (Cooked)', 'Protein', '{"calories": 165, "protein": 31, "carbs": 0, "fat": 3.6, "fiber": 0, "sugar": 0, "sodium": 74}', '[{"name": "1 breast (174g)", "grams": 174}, {"name": "1 oz", "grams": 28}]', true),
('Brown Rice (Cooked)', 'Grains', '{"calories": 111, "protein": 2.6, "carbs": 23, "fat": 0.9, "fiber": 1.8, "sugar": 0.4, "sodium": 5}', '[{"name": "1 cup", "grams": 195}, {"name": "1/2 cup", "grams": 98}]', true),
('Salmon (Cooked)', 'Protein', '{"calories": 206, "protein": 22, "carbs": 0, "fat": 12, "fiber": 0, "sugar": 0, "sodium": 59}', '[{"name": "1 fillet (154g)", "grams": 154}, {"name": "1 oz", "grams": 28}]', true),
('Broccoli (Cooked)', 'Vegetables', '{"calories": 35, "protein": 2.4, "carbs": 7, "fat": 0.4, "fiber": 3.3, "sugar": 1.4, "sodium": 41}', '[{"name": "1 cup chopped", "grams": 156}, {"name": "1 spear", "grams": 31}]', true),
('Greek Yogurt (Plain)', 'Dairy', '{"calories": 97, "protein": 9, "carbs": 3.98, "fat": 5, "fiber": 0, "sugar": 3.98, "sodium": 36}', '[{"name": "1 container (170g)", "grams": 170}, {"name": "1 cup", "grams": 227}]', true);

-- Create function to automatically create user profile on signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.user_profiles (id, email, display_name)
  values (new.id, new.email, new.raw_user_meta_data->>'display_name');
  return new;
end;
$$;

-- Create trigger for new user signup
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();