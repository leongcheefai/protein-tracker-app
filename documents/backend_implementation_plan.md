# Backend Implementation Plan - Protein Tracker

## Overview
This document outlines the comprehensive backend implementation plan for the Protein Tracker mobile application. The backend will support food photo analysis, user management, nutrition tracking, and data analytics.

## Current State
- Basic Express.js server setup with "Hello World" endpoint
- Server runs on port 3000
- Minimal implementation requiring full API development

## Technology Stack
- **Framework**: Node.js with Express.js
- **Database**: PostgreSQL with Supabase
- **Authentication**: Supabase Auth (or Firebase Admin SDK)
- **File Storage**: Supabase Storage (or AWS S3/Google Cloud Storage)
- **AI/ML**: OpenAI GPT-4 Vision API for food recognition
- **Image Processing**: Sharp.js for image optimization
- **Validation**: Joi for request validation
- **Testing**: Jest with Supertest

## Implementation Phases

### Phase 1: Core Infrastructure Setup
**Timeline**: 1-2 weeks

#### Tasks:
1. **Database Configuration**
   - Set up Supabase project and PostgreSQL database
   - Configure environment variables (SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
   - Set up Supabase client with TypeScript types

2. **Project Structure Organization**
   ```
   backend/
   ├── src/
   │   ├── controllers/     # Route handlers
   │   ├── types/          # TypeScript definitions (Supabase schema)
   │   ├── middleware/     # Custom middleware
   │   ├── services/       # Business logic
   │   ├── routes/         # API routes
   │   ├── utils/          # Helper functions (DatabaseService)
   │   └── config/         # Configuration files (Supabase client)
   ├── tests/              # Test files
   ├── uploads/            # Temporary file storage
   ├── supabase_schema.sql # Database schema for Supabase
   └── docs/              # API documentation
   ```

3. **Essential Middleware Setup**
   - CORS configuration
   - Body parsing
   - File upload handling (multer)
   - Error handling middleware
   - Request logging
   - Rate limiting

4. **Environment Configuration**
   - Development, staging, production configs
   - Environment variable validation
   - Supabase project URLs and keys
   - API keys management (OpenAI, AWS S3)

### Phase 2: Authentication & User Management
**Timeline**: 1-2 weeks

#### Tasks:
1. **Supabase Auth Integration**
   - Configure Supabase authentication
   - Create authentication middleware for JWT verification
   - Row Level Security (RLS) policy setup

2. **User Profile Schema & Routes**
   ```sql
   -- User profiles table (extends auth.users)
   CREATE TABLE user_profiles (
     id UUID REFERENCES auth.users PRIMARY KEY,
     display_name TEXT,
     email TEXT,
     age INTEGER CHECK (age >= 13 AND age <= 120),
     weight DECIMAL(5,2) CHECK (weight > 0),
     height DECIMAL(5,2) CHECK (height > 0),
     daily_protein_goal DECIMAL(6,2) CHECK (daily_protein_goal >= 0),
     activity_level activity_level DEFAULT 'moderately_active',
     dietary_restrictions TEXT[],
     units units DEFAULT 'metric',
     notifications_enabled BOOLEAN DEFAULT true,
     privacy_level privacy_level DEFAULT 'private',
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
     updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );
   ```

3. **API Endpoints**
   - `POST /api/auth/verify` - Verify Supabase JWT token
   - `GET /api/users/profile` - Get user profile
   - `PUT /api/users/profile` - Update user profile
   - `DELETE /api/users/account` - Delete user account

### Phase 3: Food Recognition & Analysis
**Timeline**: 2-3 weeks

#### Tasks:
1. **Image Upload System**
   - File upload middleware with validation
   - Image compression and optimization
   - Supabase Storage integration for permanent storage
   - Temporary local storage for processing

2. **AI Integration**
   - OpenAI GPT-4 Vision API integration
   - Food recognition prompt engineering
   - Nutrition data extraction
   - Confidence scoring system

3. **Food Database Schema**
   ```sql
   -- Foods table
   CREATE TABLE foods (
     id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
     name TEXT NOT NULL,
     category TEXT,
     brand TEXT,
     barcode TEXT UNIQUE,
     nutrition_per_100g JSONB NOT NULL,
     common_portions JSONB,
     verified BOOLEAN DEFAULT false,
     user_id UUID REFERENCES auth.users ON DELETE SET NULL,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
     updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );
   
   -- Food detection results table
   CREATE TABLE food_detections (
     id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
     user_id UUID REFERENCES auth.users ON DELETE CASCADE,
     image_url TEXT NOT NULL,
     detected_foods JSONB NOT NULL,
     confidence_scores JSONB,
     processed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
     status TEXT DEFAULT 'completed'
   );
   ```

4. **API Endpoints**
   - `POST /api/food/detect` - Upload and detect food in photo
   - `GET /api/food/search` - Search food database
   - `POST /api/food/log` - Log food item from detection or manual entry

### Phase 4: Meal Logging & Tracking
**Timeline**: 2 weeks

#### Tasks:
1. **Meal Schema**
   ```sql
   -- Meals table
   CREATE TABLE meals (
     id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
     user_id UUID REFERENCES auth.users ON DELETE CASCADE,
     meal_type meal_type NOT NULL,
     timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
     photo_url TEXT,
     notes TEXT,
     total_nutrition JSONB,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
     updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );
   
   -- Meal foods junction table
   CREATE TABLE meal_foods (
     id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
     meal_id UUID REFERENCES meals ON DELETE CASCADE,
     food_id UUID REFERENCES foods ON DELETE CASCADE,
     quantity DECIMAL(8,2) NOT NULL CHECK (quantity > 0),
     unit TEXT NOT NULL,
     nutrition_data JSONB,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );
   ```

2. **Logging System**
   - Meal entry creation with RLS security
   - Nutrition calculation using JSONB aggregation
   - Real-time updates with Supabase subscriptions
   - Data validation with PostgreSQL constraints

3. **API Endpoints**
   - `GET /api/food/recent` - Get recent meals/food items
   - `PUT /api/food/item/:id` - Update meal entry
   - `DELETE /api/food/item/:id` - Delete meal entry
   - `GET /api/meals/daily/:date` - Get daily nutrition summary

### Phase 5: Analytics & Insights
**Timeline**: 2 weeks

#### Tasks:
1. **Analytics Engine**
   - Daily nutrition calculations
   - Weekly/monthly trend analysis
   - Goal progress tracking
   - Streak calculations

2. **Insights Generation**
   - Protein intake patterns
   - Meal timing analysis
   - Nutrition balance recommendations
   - Achievement badges system

3. **API Endpoints**
   - `GET /api/analytics/daily/:date` - Daily nutrition stats
   - `GET /api/analytics/weekly` - Weekly trends
   - `GET /api/analytics/monthly` - Monthly overview
   - `GET /api/analytics/insights` - Personalized insights
   - `GET /api/analytics/streaks` - Tracking streaks

### Phase 6: Advanced Features
**Timeline**: 2-3 weeks

#### Tasks:
1. **Recipe & Meal Planning**
   - Recipe storage and management
   - Meal planning functionality
   - Shopping list generation

2. **Social Features**
   - Progress sharing
   - Achievement system
   - Community challenges

3. **Export & Integration**
   - Data export functionality
   - Third-party app integrations
   - Health app synchronization

## API Design Principles

### RESTful Architecture
- Consistent URL structure
- Proper HTTP methods and status codes
- Resource-based endpoints
- Stateless design

### Request/Response Format
```javascript
// Standard Success Response
{
  success: true,
  data: {...},
  message: "Operation completed successfully"
}

// Standard Error Response
{
  success: false,
  error: {
    code: "VALIDATION_ERROR",
    message: "Invalid input data",
    details: {...}
  }
}
```

### Authentication Flow
1. Frontend authenticates with Supabase Auth
2. Backend verifies Supabase JWT token
3. User data retrieved from user_profiles table with RLS
4. Subsequent requests include verified user context

## Database Schema Design

### Key Tables
- `user_profiles` - User profiles and preferences (extends auth.users)
- `foods` - Food database with nutrition info
- `meals` - User meal entries
- `meal_foods` - Junction table linking meals to foods
- `food_detections` - AI food detection results
- `analytics` - Computed nutrition analytics (future)

### Indexing Strategy
- User-based queries: Automatic UUID indexes
- Date-based queries: `timestamp` indexes with DESC ordering
- Food searches: GIN indexes on food names for full-text search
- JSONB indexes for nutrition data queries
- Composite indexes for user + date queries

## Security & Performance

### Security Measures
- Supabase authentication with JWT verification
- Row Level Security (RLS) policies for data isolation
- Input validation and sanitization
- Rate limiting on API endpoints
- File upload security with type validation
- Environment variable protection
- PostgreSQL constraint validations

### Performance Optimizations
- Supabase connection pooling (built-in)
- Query optimization with proper indexing
- JSONB for efficient nutrition data storage
- Image compression and Supabase Storage CDN
- Response caching where appropriate
- Pagination for large datasets
- Real-time subscriptions for live updates

## Testing Strategy

### Unit Tests
- DatabaseService methods
- Service layer logic
- Utility functions
- Authentication middleware
- TypeScript type safety

### Integration Tests
- API endpoint testing with Supabase
- Database operations with RLS policies
- External service integration (OpenAI, Storage)
- File upload workflows
- Authentication flows

### Load Testing
- API performance under load
- PostgreSQL query optimization
- Image processing bottlenecks
- Supabase connection limits

## Deployment & DevOps

### Environment Setup
- Development: Local development with Supabase project
- Staging: Staging Supabase project with separate database
- Production: Production Supabase project with live data

### CI/CD Pipeline
1. Code commit triggers build
2. Automated testing suite
3. Security scanning
4. Staging deployment
5. Manual production deployment

### Monitoring & Logging
- Application performance monitoring
- Error tracking and alerting
- Supabase dashboard metrics and analytics
- API usage analytics
- PostgreSQL query performance monitoring

## Timeline Summary

| Phase | Duration | Key Deliverables |
|-------|----------|------------------|
| Phase 1 | 1-2 weeks | Supabase setup, core infrastructure ✅ |
| Phase 2 | 1-2 weeks | Authentication, user management |
| Phase 3 | 2-3 weeks | Food recognition, AI integration |
| Phase 4 | 2 weeks | Meal logging, nutrition tracking ✅ |
| Phase 5 | 2 weeks | Analytics, insights engine |
| Phase 6 | 2-3 weeks | Advanced features, integrations |

**Total Estimated Timeline: 10-14 weeks**

## Success Metrics
- API response time < 500ms for most endpoints
- 99.9% uptime availability
- Accurate food recognition (>85% confidence)
- Scalable to 10,000+ concurrent users
- Complete test coverage (>90%)

## Implementation Status & Next Steps

### ✅ Completed (Phase 1 & 4)
1. **Supabase Configuration Complete**
   - Database client setup with TypeScript types
   - Complete SQL schema with RLS policies
   - DatabaseService helper class for common operations

2. **Core API Structure Ready**
   - Food detection, logging, search, update, delete endpoints
   - Authentication middleware structure
   - Error handling and validation

### 🚀 Next Priority Steps
1. **Complete Supabase Setup**
   - Run `npm install @supabase/supabase-js`
   - Create Supabase project and run `supabase_schema.sql`
   - Add credentials to `.env` file

2. **Phase 2: Authentication Integration**
   - Implement Supabase Auth middleware
   - Test user profile creation and management
   - Set up RLS policies testing

3. **Phase 3: AI Integration**
   - OpenAI GPT-4 Vision API setup
   - Food recognition prompt engineering
   - Image upload and processing pipeline

4. **Testing & Documentation**
   - API endpoint testing
   - Database integration tests
   - API documentation with current endpoints