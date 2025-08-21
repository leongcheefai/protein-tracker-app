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

### **Phase 2: Core Camera Flow (Week 2-4)**
*Milestone: M2 – Camera Flow*

#### 2.1 Camera Launch Screen
- **Purpose:** Primary app entry point, direct camera access
- **Elements:**
  - Full-screen camera preview
  - Capture button (large, centered bottom)
  - Flash toggle (top right)
  - Camera flip button (top right)
  - Permission request overlay (if needed)
- **States:** Camera active, permission denied, camera error
- **Navigation:** → Photo Capture

#### 2.2 Photo Capture
- **Purpose:** Take photo of meal for AI analysis
- **Elements:**
  - Live camera preview
  - Capture button (pulsing animation)
  - Focus indicator
  - Grid overlay (optional, toggle in settings)
  - "Retake" button (after capture)
  - "Use Photo" button (after capture)
- **Navigation:** → Processing Screen

#### 2.3 Processing Screen
- **Purpose:** Show AI analysis progress
- **Elements:**
  - Captured photo thumbnail
  - Loading spinner
  - Status text: "Analyzing your meal..."
  - Progress bar (if possible)
  - Cancel button
- **States:** Uploading, processing, analyzing
- **Navigation:** → Food Detection Results

#### 2.4 Food Detection Results
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

#### 2.5 Portion Selection
- **Purpose:** Confirm food portions and calculate protein
- **Elements:**
  - Food name and confidence
  - Portion chips (100g, 150g, 200g, Custom)
  - Custom input field (grams)
  - Protein calculation display (e.g., "150g chicken × 31g/100g ≈ 46g")
  - "Next" button
- **States:** Standard portions, custom input, validation errors
- **Navigation:** → Meal Assignment

#### 2.6 Meal Assignment
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

#### 2.7 Confirmation Screen
- **Purpose:** Final confirmation before saving
- **Elements:**
  - Success checkmark
  - Summary: "Added 46g protein to Lunch"
  - Updated meal progress
  - "Log Another Food" button
  - "Done" button
- **Navigation:** → Today Dashboard or Camera Launch

---

### **Phase 3: Dashboard & Management (Week 4-5)**
*Milestone: M3 – Today Dashboard*

#### 3.1 Today Dashboard
- **Purpose:** Main app screen showing daily progress
- **Elements:**
  - Header with date and profile icon
  - Large daily protein ring (center)
    - Current vs. target (e.g., "89g / 144g")
    - Percentage completion
  - Per-meal mini-rings (horizontal scroll):
    - Breakfast progress
    - Lunch progress
    - Dinner progress
    - Snack progress (if enabled)
  - Recent items list (last 3-5 logged foods)
  - Floating action button (camera icon)
- **States:** Empty (first time), partial progress, goal met
- **Navigation:** → Camera Launch, Item Edit, Profile

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

#### 4.5 Profile Settings
- **Purpose:** Update personal information and goals
- **Elements:**
  - Profile photo (optional)
  - Height/weight inputs
  - Training frequency selector
  - Goal selector
  - "Save Changes" button
- **Navigation:** → Settings Menu

#### 4.6 Notification Settings
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

#### 4.7 Privacy Settings
- **Purpose:** Manage data and privacy preferences
- **Elements:**
  - "Data Export" button
  - "Delete Account" button (with confirmation)
  - Privacy policy link
  - Terms of service link
  - Contact support link
- **Navigation:** → Settings Menu

#### 4.8 About & Help
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

#### 4.9 Permission Denied Screens
- **Purpose:** Handle denied permissions gracefully
- **Elements:**
  - Permission type (Camera, Notifications)
  - Why it's needed explanation
  - "Open Settings" button
  - "Maybe Later" button
- **States:** Camera denied, notifications denied, storage denied

#### 4.10 Network Error States
- **Purpose:** Handle offline/connection issues
- **Elements:**
  - Error icon
  - "Connection Error" message
  - "Retry" button
  - Offline mode indicator
- **States:** No internet, API error, timeout

#### 4.11 Empty States
- **Purpose:** Guide first-time users and show no-data scenarios
- **Elements:**
  - Illustrative icon
  - Helpful message
  - Action button
  - Tips or guidance
- **States:** First time, no data, no results

#### 4.12 Loading States
- **Purpose:** Show progress and prevent blank screens
- **Elements:**
  - Skeleton screens
  - Progress indicators
  - Loading messages
  - Shimmer effects
- **States:** Initial load, data fetch, processing

---

## Navigation Structure

### **Bottom Tab Bar (Main App)**
1. **Today** (Home) - Daily dashboard
2. **History** - Past days and stats
3. **Quick Add** - Fast protein logging
4. **Profile** - Settings and account

### **Modal Overlays**
- Camera launch (full screen)
- Food detection results
- Portion selection
- Meal assignment
- Item editing

### **Navigation Flow**