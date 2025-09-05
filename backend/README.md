# Protein Tracker Backend API

A comprehensive Node.js/Express.js backend API for the Protein Tracker mobile application, built with TypeScript, Prisma ORM, and PostgreSQL.

## Features

### Core Functionality
- **User Management**: Registration, authentication, profile management
- **Food Detection**: AI-powered food recognition from photos (mock implementation)
- **Food Logging**: Manual and photo-based protein intake tracking
- **Progress Tracking**: Daily protein goals, streaks, and meal breakdowns
- **Analytics**: Comprehensive statistics, trends, and insights
- **Premium Features**: Advanced analytics, data export, unlimited history

### Technical Features
- **Authentication**: JWT-based auth with refresh tokens
- **File Upload**: Secure image upload with validation
- **Rate Limiting**: API protection and abuse prevention
- **Validation**: Comprehensive input validation and sanitization
- **Error Handling**: Centralized error handling with detailed logging
- **Database**: PostgreSQL with Prisma ORM
- **TypeScript**: Full type safety throughout the application

## Architecture

### Database Schema
```
Users ←→ UserSettings
Users ←→ Subscription
Users ←→ FoodItems ←→ Foods
Users ←→ DailyProgress ←→ MealProgress
Users ←→ DetectedFoods
```

### API Structure
```
/api/auth/*        - Authentication endpoints
/api/user/*        - User management
/api/food/*        - Food detection and logging
/api/progress/*    - Progress tracking
/api/analytics/*   - Statistics and insights
```

## Setup Instructions

### Prerequisites
- Node.js (v18 or higher)
- PostgreSQL (v13 or higher)
- npm or yarn package manager

### 1. Clone and Install Dependencies
```bash
cd backend
npm install
```

### 2. Environment Configuration
Copy `.env.example` to `.env` and configure:
```bash
cp .env.example .env
```

Update `.env` with your settings:
```env
DATABASE_URL="postgresql://username:password@localhost:5432/protein_tracker?schema=public"
JWT_SECRET="your-super-secret-jwt-key"
PORT=3000
NODE_ENV="development"
```

### 3. Database Setup
```bash
# Generate Prisma client
npm run db:generate

# Create database tables
npm run db:push

# Or run migrations (for production)
npm run db:migrate
```

### 4. Start Development Server
```bash
npm run dev
```

The API will be available at `http://localhost:3000`

## API Documentation

### Authentication Endpoints

#### POST /api/auth/register
Register a new user account.
```json
{
  "email": "user@example.com",
  "password": "SecurePass123",
  "name": "John Doe"
}
```

#### POST /api/auth/login
Login with email and password.
```json
{
  "email": "user@example.com",
  "password": "SecurePass123"
}
```

#### GET /api/auth/profile
Get current user profile (requires authentication).

### Food Endpoints

#### POST /api/food/detect
Upload image for food detection.
- Content-Type: `multipart/form-data`
- Field name: `image`
- Supported formats: JPEG, PNG, WebP
- Max file size: 5MB

#### POST /api/food/log
Log a food item.
```json
{
  "customName": "Grilled Chicken Breast",
  "portionSize": 150,
  "proteinContent": 46.5,
  "mealType": "lunch",
  "calories": 165,
  "isQuickAdd": true
}
```

#### GET /api/food/recent
Get recent food items with pagination.
- Query params: `limit`, `offset`

### Progress Endpoints

#### GET /api/progress/daily/:date?
Get daily progress for specific date (defaults to today).

#### GET /api/progress/history
Get historical progress data.
- Query params: `startDate`, `endDate`, `limit`, `offset`

### Analytics Endpoints

#### GET /api/analytics/stats
Get comprehensive statistics overview.

#### GET /api/analytics/export (Premium)
Export user data in JSON or CSV format.
- Query params: `format` (json|csv)

## Data Models

### User Profile
```typescript
{
  id: string
  email: string
  name?: string
  height?: number        // cm
  weight?: number        // kg
  trainingMultiplier?: number  // 1.0-3.0
  goal: 'maintain' | 'bulk' | 'cut'
  dailyProteinTarget?: number  // grams
}
```

### Food Item
```typescript
{
  id: string
  customName?: string
  portionSize: number    // grams
  proteinContent: number // grams
  calories?: number
  mealType: 'breakfast' | 'lunch' | 'dinner' | 'snack'
  imagePath?: string
  dateLogged: Date
  isQuickAdd: boolean
}
```

### Daily Progress
```typescript
{
  date: string
  totalProtein: number
  dailyTarget: number
  goalMet: boolean
  streakCount: number
  achievementPercentage: number
  mealBreakdown: {
    breakfast: { target: number, actual: number, items: number }
    lunch: { target: number, actual: number, items: number }
    dinner: { target: number, actual: number, items: number }
    snack: { target: number, actual: number, items: number }
  }
}
```

## Development

### Available Scripts
```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run start        # Start production server
npm run test         # Run tests
npm run db:generate  # Generate Prisma client
npm run db:push      # Push schema changes to database
npm run db:migrate   # Run database migrations
npm run db:studio    # Open Prisma Studio
```

### Project Structure
```
src/
├── controllers/     # Request handlers
│   ├── authController.ts
│   ├── userController.ts
│   ├── foodController.ts
│   ├── progressController.ts
│   └── analyticsController.ts
├── middleware/      # Custom middleware
│   ├── auth.ts
│   ├── validation.ts
│   ├── errorHandler.ts
│   ├── requestLogger.ts
│   └── upload.ts
├── routes/          # Route definitions
│   ├── auth.ts
│   ├── user.ts
│   ├── food.ts
│   ├── progress.ts
│   └── analytics.ts
├── services/        # Business logic services
├── utils/           # Utility functions
│   └── database.ts
├── types/           # TypeScript type definitions
│   └── index.ts
└── index.ts         # Application entry point
```

### Adding New Features

1. **Define Types**: Add new interfaces in `src/types/index.ts`
2. **Update Schema**: Modify `prisma/schema.prisma` and run migrations
3. **Create Controller**: Add business logic in appropriate controller
4. **Add Validation**: Define validation rules in `middleware/validation.ts`
5. **Create Routes**: Add route definitions
6. **Test**: Write tests for new functionality

### Error Handling
All endpoints return consistent error responses:
```json
{
  "success": false,
  "error": "Error message",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### Authentication
Include JWT token in requests:
```
Authorization: Bearer <your-jwt-token>
```

## Production Deployment

### Environment Variables
Ensure production environment variables are set:
- `DATABASE_URL`: PostgreSQL connection string
- `JWT_SECRET`: Strong secret key for JWT signing
- `NODE_ENV=production`
- `PORT`: Server port (default: 3000)

### Database Migration
```bash
npm run db:migrate
```

### Build and Start
```bash
npm run build
npm start
```

## Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: bcrypt with salt rounds
- **Rate Limiting**: Prevent API abuse
- **Input Validation**: Comprehensive validation and sanitization
- **File Upload Security**: Type validation and size limits
- **CORS Configuration**: Configurable cross-origin access
- **Helmet**: Security headers middleware

## License

This project is licensed under the ISC License.