#!/bin/bash

echo "🧹 Cleaning iOS project..."
cd "$(dirname "$0")"

# Clean Flutter
echo "📱 Cleaning Flutter..."
flutter clean

# Clean iOS build
echo "🍎 Cleaning iOS build..."
rm -rf build/
rm -rf .symlinks/
rm -rf Pods/
rm -rf Podfile.lock

# Clean Xcode derived data (optional)
echo "🗑️  Cleaning Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Reinstall pods
echo "📦 Reinstalling pods..."
pod install

# Clean and get Flutter packages
echo "📦 Getting Flutter packages..."
cd ..
flutter pub get

echo "✅ Clean and rebuild complete!"
echo "🚀 Now run: flutter run"
