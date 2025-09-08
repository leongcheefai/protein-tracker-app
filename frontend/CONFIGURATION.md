# Supabase Configuration Guide

This guide explains how to securely configure your Supabase credentials using `.env` files.

## 🔐 Security First

We use the `flutter_dotenv` package to load environment variables from a `.env` file, keeping sensitive credentials out of source code.

## 📋 Prerequisites

1. A Supabase project (create one at [supabase.com](https://supabase.com))
2. Your Supabase project URL and anonymous key

## 🚀 Quick Setup

### 1. Get Your Supabase Credentials

1. Go to your [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project
3. Go to **Settings** → **API**
4. Copy your:
   - **Project URL** (e.g., `https://your-project-id.supabase.co`)
   - **Anon/Public key** (starts with `eyJ...`)

### 2. Configure Your Environment

#### Method 1: Using .env file (Recommended)
1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
2. Edit `.env` and add your credentials:
   ```env
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```
3. Run your app:
   ```bash
   flutter run
   ```

#### VS Code Integration
- Use VS Code's Run and Debug panel (Ctrl/Cmd + Shift + D)
- Select "Flutter (Development)" and click play ▶️
- No additional configuration needed!

## 🏗️ Building for Production

### iOS
```bash
flutter build ios
```

### Android
```bash
flutter build apk
```

## 🔍 Troubleshooting

### App Won't Start?
If you see an error like "Supabase configuration missing", check:

1. ✅ `.env` file exists in the root directory
2. ✅ Your URL starts with `https://`
3. ✅ Your anon key starts with `eyJ`
4. ✅ No typos in your credentials
5. ✅ `.env` is listed in `pubspec.yaml` assets

### Debug Mode Help
In development, the app will show helpful error messages:
```
❌ Supabase initialization failed: ...
Supabase Configuration Status:
  URL: ❌ Missing  
  Anon Key: ❌ Missing

To configure:
  1. Create a .env file in the root directory
  2. Add your Supabase credentials:
     SUPABASE_URL=https://your-project.supabase.co
     SUPABASE_ANON_KEY=your-anon-key
```

## 🔒 Security Notes

- ✅ **Supabase Anon Key**: Safe to use in client apps (public-facing by design)
- ✅ **Project URL**: Safe to be public
- ⚠️ **Never commit**: Service role keys or sensitive credentials
- 🛡️ **RLS Protection**: Your database is protected by Row Level Security policies
- 📁 **Add .env to .gitignore**: Keep your credentials out of version control

## 🌍 Environment Management

For teams or multiple environments, you can use different `.env` files:

```bash
# Development
cp .env.dev .env && flutter run

# Staging  
cp .env.staging .env && flutter run

# Production
cp .env.prod .env && flutter build ios
```

## 📁 File Structure
```
frontend/
├── .env              # Your environment variables (not in git)
├── .env.example      # Template file (committed to git)
├── .gitignore        # Make sure .env is ignored
└── pubspec.yaml      # .env added to assets
```

## 🎯 Benefits of .env Approach

- ✅ **Simple**: No complex command-line arguments
- ✅ **VS Code friendly**: Works with standard launch configs
- ✅ **Team friendly**: Easy to share .env.example
- ✅ **Secure**: Credentials never committed to git
- ✅ **Flexible**: Easy to switch between environments

## 📚 Additional Resources

- [flutter_dotenv Documentation](https://pub.dev/packages/flutter_dotenv)
- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Supabase Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)