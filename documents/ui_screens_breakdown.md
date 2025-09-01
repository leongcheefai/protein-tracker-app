# Protein Pace — UI Screens Breakdown

## Overview
This document breaks down the UI development phases and individual screens for the Protein Pace app, organized by development milestones from the masterplan.

---

## Development Phases & UI Screens

### **Phase 1: Foundation & Onboarding (Week 1-2)**
*Milestone: M1 – Onboarding & Targets*

#### 1.1 Splash Screen
- **Purpose:** App launch, branding, loading state
- **Elements:**
  - App logo (Protein Pace)
  - Loading spinner
  - Version number (bottom)
- **Navigation:** Auto-advance to Welcome after 2-3 seconds
- **States:** Loading, error (fallback to Welcome)

#### 1.2 Welcome Screen
- **Purpose:** App introduction, user motivation
- **Elements:**
  - Hero image (person with healthy meal)
  - App tagline: "Track protein intake with just a photo"
  - Key benefits (3 bullet points)
  - "Get Started" button (primary)
  - Privacy note: "Your photos are never stored"
- **Navigation:** → Height/Weight Input

#### 1.3 Height/Weight Input
- **Purpose:** Collect basic body metrics for protein calculation
- **Elements:**
  - Form title: "Let's calculate your protein needs"
  - Height input (cm, with slider + manual input)
  - Weight input (kg, with slider + manual input)
  - Unit display (metric only for v1)
  - "Next" button (enabled when both fields filled)
- **Validation:** Height 100-250cm, Weight 30-200kg
- **Navigation:** → Training Frequency Selection

#### 1.4 Training Frequency Selection
- **Purpose:** Determine activity level for protein multiplier
- **Elements:**
  - Title: "How often do you train?"
  - 4 activity cards:
    - **Light** (1-2x/week): "Occasional workouts, light activity"
    - **Moderate** (3-4x/week): "Regular training, moderate intensity"
    - **Heavy** (5-6x/week): "Frequent training, high intensity"
    - **Very Heavy** (6-7x/week): "Daily training, cutting phase"
  - Protein multiplier display (e.g., "Moderate: 1.8g/kg")
- **Navigation:** → Goal Setting

#### 1.5 Goal Setting
- **Purpose:** Set fitness objective and calculate daily protein target
- **Elements:**
  - Title: "What's your goal?"
  - 3 goal options:
    - **Maintain** (default): "Keep current muscle mass"
    - **Bulk**: "Build muscle and strength"
    - **Cut**: "Lose fat, preserve muscle"
  - Calculated daily target display (e.g., "Your daily target: 144g protein")
  - Manual override input (optional)
  - "Next" button
- **Navigation:** → Meal Selection

#### 1.6 Meal Selection
- **Purpose:** Configure which meals to track and split targets
- **Elements:**
  - Title: "Which meals do you want to track?"
  - 4 meal toggles with protein targets:
    - **Breakfast** (e.g., 36g) - enabled by default
    - **Lunch** (e.g., 36g) - enabled by default
    - **Dinner** (e.g., 36g) - enabled by default
    - **Snack** (e.g., 36g) - optional toggle
  - Total daily target confirmation
  - "Start Tracking" button (primary)
- **Navigation:** → Camera Launch (main app)

---

### **Phase 2: User Home & Camera Modal Flow (Week 2-4)**
*Milestone: M2 – User Home Dashboard*

#### 2.1 User Home Screen
- **Purpose:** Main app dashboard after user setup, central hub for all functionality
- **Elements:**
  - **Header:** App title "Protein Pace" with settings icon
  - **Welcome Section:** Personalized greeting with user avatar and motivational message
  - **Daily Progress Card:** 
    - Current vs. target protein (e.g., "89g / 144g")
    - Visual progress bar with percentage
    - Goal and training level display
  - **Quick Actions Grid (2x2):**
    - Upload Photo (primary action, triggers camera modal)
    - View History
    - Edit Goals
    - Analytics
  - **Meal Progress Breakdown:** Individual progress for each enabled meal
    - Breakfast, Lunch, Dinner, Snack (if enabled)
    - Progress percentage per meal
    - Color-coded status (green=complete, amber=close, red=behind)
  - **Recent Activity:** Placeholder for tracking user actions
- **States:** First time (empty progress), partial progress, goal met
- **Navigation:** → Camera Modal, History, Goals, Analytics, Settings

#### 2.2 Camera Settings Modal
- **Purpose:** Modal overlay for choosing photo upload method
- **Elements:**
  - **Modal Header:** "Upload Photo" title with handle bar
  - **Description:** "Choose how you want to add your meal"
  - **Two Options:**
    - **Take Photo:** Camera icon with "Use your camera to take a new photo"
    - **Choose from Gallery:** Gallery icon with "Select an existing photo from your gallery"
  - **Cancel Button:** Dismisses modal
- **Design:** Bottom sheet modal (60% screen height)
- **Navigation:** → Photo Capture (camera) or Gallery Picker

#### 2.3 Photo Capture Screen
- **Purpose:** Take photo of meal for AI analysis
- **Elements:**
  - Live camera preview
  - Capture button (pulsing animation)
  - Focus indicator
  - Grid overlay (optional, toggle in settings)
  - "Retake" button (after capture)
  - "Use Photo" button (after capture)
- **Navigation:** → Processing Screen

#### 2.4 Processing Screen
- **Purpose:** Show AI analysis progress
- **Elements:**
  - Captured photo thumbnail
  - Loading spinner
  - Status text: "Analyzing your meal..."
  - Progress bar (if possible)
  - Cancel button
- **States:** Uploading, processing, analyzing
- **Navigation:** → Food Detection Results

#### 2.5 Food Detection Results
- **Purpose:** Display AI-detected foods and confidence scores
- **Elements:**
  - Photo thumbnail (top)
  - "Detected Foods" title
  - List of detected items:
    - Food name
    - Confidence percentage
    - Estimated protein (if available)
  - "Add More Foods" button
  - "Continue" button
- **States:** Multiple foods, single food, no detection
- **Navigation:** → Portion Selection

#### 2.6 Portion Selection
- **Purpose:** Confirm food portions and calculate protein
- **Elements:**
  - Food name and confidence
  - Portion chips (100g, 150g, 200g, Custom)
  - Custom input field (grams)
  - Protein calculation display (e.g., "150g chicken × 31g/100g ≈ 46g")
  - "Next" button
- **States:** Standard portions, custom input, validation errors
- **Navigation:** → Meal Assignment

#### 2.7 Meal Assignment
- **Purpose:** Assign logged food to specific meal
- **Elements:**
  - Food summary (name, portion, protein)
  - Meal selection chips:
    - Breakfast (with current progress)
    - Lunch (with current progress)
    - Dinner (with current progress)
    - Snack (if enabled)
  - Auto-suggested meal (based on time)
  - "Save" button
- **Navigation:** → Confirmation Screen

#### 2.8 Confirmation Screen
- **Purpose:** Final confirmation before saving
- **Elements:**
  - Success checkmark
  - Summary: "Added 46g protein to Lunch"
  - Updated meal progress
  - "Log Another Food" button
  - "Done" button
- **Navigation:** → User Home Screen (updated dashboard)

---

### **Phase 3: Enhanced Dashboard & Management (Week 4-5)**
*Milestone: M3 – Enhanced User Home Features*

#### 3.1 User Home Screen (Enhanced)
- **Purpose:** Enhanced main app screen with advanced progress tracking and analytics
- **Elements:**
  - **Enhanced Header:** Date display, profile icon, quick stats
  - **Advanced Progress Visualization:** 
    - Large daily protein ring (center) with animations
    - Current vs. target with trend indicators
    - Weekly progress comparison
  - **Per-meal Mini-rings (horizontal scroll):**
    - Breakfast, Lunch, Dinner, Snack progress
    - Color-coded status indicators
    - Tap to expand meal details
  - **Recent Items List:** Last 3-5 logged foods with quick actions
  - **Floating Action Button:** Camera icon for quick photo upload
  - **Quick Stats Panel:** Weekly average, streak counter, goal hit rate
- **States:** Empty (first time), partial progress, goal met, streak milestones
- **Navigation:** → Camera Modal, Item Edit, Profile, Detailed Analytics

#### 3.2 Recent Items List
- **Purpose:** Show recently logged foods with quick actions
- **Elements:**
  - "Today's Foods" section header
  - Food item cards:
    - Food name and meal
    - Portion and protein
    - Timestamp
    - Edit/delete buttons
  - "View All" button (→ History)
- **States:** Empty, items present, loading
- **Navigation:** → Item Edit, History

#### 3.3 Quick Add Screen
- **Purpose:** Fast protein logging without photo
- **Elements:**
  - Title: "Quick Add Protein"
  - Protein input field (grams)
  - Meal selection chips
  - "Add" button
  - "Cancel" button
- **Navigation:** → Today Dashboard

#### 3.4 Item Edit Screen
- **Purpose:** Modify logged food items
- **Elements:**
  - Food name (read-only)
  - Portion adjustment (grams)
  - Meal reassignment
  - Delete button (with confirmation)
  - "Save Changes" button
  - "Cancel" button
- **Navigation:** → Today Dashboard

---

### **Phase 4: History & Insights (Week 6)**
*Milestone: M5 – History Tab*

#### 4.1 History Tab
- **Purpose:** View past days and track progress over time
- **Elements:**
  - Tab header with date range selector
  - Default: Last 7 days
  - Date picker for custom ranges
  - "Today" quick access button
- **Navigation:** → Daily Summary Cards

#### 4.2 Daily Summary Cards
- **Purpose:** Show protein progress for each day
- **Elements:**
  - Date header
  - Daily protein ring (smaller)
  - Goal percentage
  - Streak indicator
  - Meal breakdown (B/L/D/S icons with progress)
  - Tap to expand
- **States:** Goal met, partial, missed, no data
- **Navigation:** → Meal Breakdown View

#### 4.3 Meal Breakdown View
- **Purpose:** Detailed view of specific day's meals
- **Elements:**
  - Date header
  - Daily total and goal
  - Per-meal sections:
    - Meal name and target
    - Food items list
    - Meal total vs. target
  - "Back" button
- **Navigation:** → History Tab

#### 4.4 Stats Overview
- **Purpose:** Show trends and patterns
- **Elements:**
  - Weekly average protein
  - Goal hit percentage
  - Most consistent meal
  - Streak information
  - "Export Data" button (Pro feature)
- **Navigation:** → History Tab

---

### **Phase 5: Settings & Profile (Week 6-7)**
*Milestone: M6 – Notifications*

#### 5.1 Profile Settings
- **Purpose:** Update personal information and goals
- **Elements:**
  - Profile photo (optional)
  - Height/weight inputs
  - Training frequency selector
  - Goal selector
  - "Save Changes" button
- **Navigation:** → Settings Menu

#### 5.2 Notification Settings
- **Purpose:** Configure meal reminders and timing
- **Elements:**
  - "Enable Notifications" toggle
  - Meal reminder times:
    - Breakfast (08:00)
    - Lunch (12:30)
    - Snack (16:00)
    - Dinner (19:00)
  - Do-not-disturb settings (22:00-07:00)
  - Nightly summary toggle (21:30)
  - "Save" button
- **Navigation:** → Settings Menu

#### 5.3 Privacy Settings
- **Purpose:** Manage data and privacy preferences
- **Elements:**
  - "Data Export" button
  - "Delete Account" button (with confirmation)
  - Privacy policy link
  - Terms of service link
  - Contact support link
- **Navigation:** → Settings Menu

#### 5.4 About & Help
- **Purpose:** App information and support
- **Elements:**
  - App version
  - Privacy policy
  - Terms of service
  - Support contact
  - Rate app link
- **Navigation:** → Settings Menu

---

### **Phase 6: Error & Edge Cases (Week 7-8)**
*Milestone: M7 – Polish & Beta*

#### 6.1 Permission Denied Screens
- **Purpose:** Handle denied permissions gracefully
- **Elements:**
  - Permission type (Camera, Notifications)
  - Why it's needed explanation
  - "Open Settings" button
  - "Maybe Later" button
- **States:** Camera denied, notifications denied, storage denied

#### 6.2 Network Error States
- **Purpose:** Handle offline/connection issues
- **Elements:**
  - Error icon
  - "Connection Error" message
  - "Retry" button
  - Offline mode indicator
- **States:** No internet, API error, timeout

#### 6.3 Empty States
- **Purpose:** Guide first-time users and show no-data scenarios
- **Elements:**
  - Illustrative icon
  - Helpful message
  - Action button
  - Tips or guidance
- **States:** First time, no data, no results

#### 6.4 Loading States
- **Purpose:** Show progress and prevent blank screens
- **Elements:**
  - Skeleton screens
  - Progress indicators
  - Loading messages
  - Shimmer effects
- **States:** Initial load, data fetch, processing

---

### **Phase 7: Monetization & Premium Features (Week 8-9)**
*Milestone: M8 – Premium Features & Monetization*

#### 7.1 Pricing Plans Screen
- **Purpose:** Display subscription options and premium features
- **Elements:**
  - **Header:** "Choose Your Plan" with close button
  - **Free Plan Card:**
    - "Free" badge
    - Basic features list (5 items max, photo tracking, basic history)
    - "Current Plan" indicator (if user is on free)
    - "Continue with Free" button
  - **Pro Plan Card (Featured):**
    - "Pro" badge with "Most Popular" tag
    - Monthly price (e.g., "$4.99/month")
    - Annual price with savings (e.g., "$39.99/year - Save 33%")
    - Premium features list (unlimited history, advanced analytics, export data, custom goals)
    - "Start Free Trial" button (7-day trial)
  - **Feature Comparison Table:**
    - Side-by-side comparison of Free vs Pro features
    - Clear checkmarks and X marks
  - **Terms & Privacy links** (bottom)
- **States:** Free user, trial user, paid user
- **Navigation:** → Payment Processing, Back to previous screen

#### 7.2 Payment Processing Screen
- **Purpose:** Handle subscription payment and trial activation
- **Elements:**
  - **Plan Summary:** Selected plan details and pricing
  - **Payment Method Section:**
    - Credit card input fields (number, expiry, CVV)
    - Apple Pay/Google Pay buttons (platform-specific)
    - "Save payment method" toggle
  - **Billing Information:**
    - Name, email, address fields
    - Auto-filled from app profile if available
  - **Terms & Conditions:**
    - Subscription terms checkbox
    - Privacy policy checkbox
    - Auto-renewal disclosure
  - **Action Buttons:**
    - "Start Free Trial" (primary)
    - "Cancel" (secondary)
  - **Security badges:** SSL, PCI compliance indicators
- **States:** Payment processing, validation errors, success
- **Navigation:** → Payment Success, Back to Pricing

#### 7.3 Payment Success Screen
- **Purpose:** Confirm successful subscription and guide next steps
- **Elements:**
  - **Success Animation:** Checkmark with celebration
  - **Welcome Message:** "Welcome to Protein Pace Pro!"
  - **Trial Information:** "7-day free trial started" with end date
  - **Next Steps:**
    - "Explore Premium Features" button
    - "Continue to App" button
  - **Account Management:** Link to manage subscription
- **Navigation:** → User Home (with premium features unlocked)

#### 7.4 Subscription Management Screen
- **Purpose:** Manage existing subscription and billing
- **Elements:**
  - **Current Plan Display:**
    - Plan name and status
    - Next billing date
    - Current period progress
  - **Billing History:** List of past payments
  - **Payment Method:** Current payment method with edit option
  - **Plan Actions:**
    - "Change Plan" button
    - "Cancel Subscription" button (with confirmation)
    - "Restore Purchases" button (for app store)
  - **Support Section:** Contact support for billing issues
- **Navigation:** → Pricing Plans, Back to Settings

#### 7.5 Premium Features Unlock Screen
- **Purpose:** Showcase premium features when user upgrades
- **Elements:**
  - **Congratulations Message:** "Unlock Premium Features!"
  - **Feature Highlights:**
    - Advanced analytics and insights
    - Unlimited history and data export
    - Custom protein goals and meal planning
    - Priority support
  - **Upgrade Button:** "Upgrade to Pro" (primary)
  - **Skip Option:** "Maybe Later" (secondary)
- **Triggers:** When user hits free plan limits
- **Navigation:** → Pricing Plans, Back to previous screen

---

## Navigation Structure

### **Bottom Tab Bar (Main App)**
1. **Today** (Home) - Daily dashboard
2. **History** - Past days and stats
3. **Quick Add** - Fast protein logging
4. **Profile** - Settings and account

### **Modal Overlays**
- **Camera Settings Modal:** Photo upload method selection (bottom sheet)
- **Pricing Plans Modal:** Subscription options and payment processing
- Food detection results
- Portion selection
- Meal assignment
- Item editing

### **Navigation Flow**
```
Setup Flow: Splash → Welcome → Height/Weight → Training → Goals → Meals → User Home
Main App: User Home (with camera modal) → Photo Flow → Back to User Home
Premium Flow: Premium Unlock → Pricing Plans → Payment → Success → Enhanced User Home
```

---

## Phase 2 Implementation Summary

### **Key Changes from Original Plan**
- **User Home Screen:** Replaced direct camera launch with comprehensive dashboard
- **Camera Modal:** Camera access now triggered through modal overlay instead of full-screen launch
- **Progressive Disclosure:** Camera functionality only shown when user explicitly chooses to upload photos

### **Benefits of Current Implementation**
1. **Better UX:** Users land on informative dashboard instead of immediate camera request
2. **Permission Management:** Camera permissions requested only when needed
3. **Centralized Hub:** All app functionality accessible from one main screen
4. **Scalable Architecture:** Easy to add new features and analytics
5. **User Control:** Users choose when to access camera functionality

### **Technical Implementation**
- **UserHomeScreen:** New main screen with progress tracking and quick actions
- **Camera Modal:** Bottom sheet modal with photo upload options
- **Navigation Flow:** Updated routing to support new screen structure
- **State Management:** Proper parameter passing between screens