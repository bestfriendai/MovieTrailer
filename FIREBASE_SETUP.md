# Firebase Setup Guide for MovieTrailer

This guide walks you through setting up Firebase Authentication and Firestore for the MovieTrailer app.

## Step 1: Add New Files to Xcode Project

The following files have been created but need to be added to the Xcode project manually:

1. Open MovieTrailer.xcodeproj in Xcode
2. Right-click on the appropriate folder and select "Add Files to MovieTrailer..."
3. Add these files:

### Models (add to MovieTrailer/Models/)
- `FirebaseUser.swift`
- `UserSyncData.swift`

### Services (add to MovieTrailer/Services/)
- `AuthenticationManager.swift`
- `FirestoreService.swift`

### Coordinators (add to MovieTrailer/Coordinators/)
- `OnboardingCoordinator.swift`

### Views/Onboarding (create folder and add)
- `OnboardingContainerView.swift`

### Views/Auth (create folder and add)
- `SignInView.swift`
- `EmailSignInView.swift`
- `EmailSignUpView.swift`
- `ProfileView.swift`

## Step 2: Add Firebase SDK

1. In Xcode, go to **File > Add Package Dependencies...**
2. Enter: `https://github.com/firebase/firebase-ios-sdk`
3. Select version **11.0.0** or later
4. Add these products to your app target:
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseAnalytics

## Step 3: Add Google Sign-In SDK

1. In Xcode, go to **File > Add Package Dependencies...**
2. Enter: `https://github.com/google/GoogleSignIn-iOS`
3. Select the latest version
4. Add **GoogleSignIn** and **GoogleSignInSwift** to your app target

## Step 4: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Name your project (e.g., "MovieTrailer")
4. Enable/disable Google Analytics as preferred
5. Click "Create project"

## Step 5: Add iOS App to Firebase

1. In your Firebase project, click "Add app" > iOS
2. Enter your Bundle ID: `com.yourcompany.MovieTrailer`
3. Download `GoogleService-Info.plist`
4. Drag the file into your Xcode project root (MovieTrailer folder)
5. Make sure "Copy items if needed" is checked
6. Ensure it's added to the MovieTrailer target

## Step 6: Enable Authentication Providers

In Firebase Console > Authentication > Sign-in method:

### Enable Apple Sign-In
1. Click "Apple" provider
2. Enable it
3. No additional configuration needed (uses iOS system auth)

### Enable Google Sign-In
1. Click "Google" provider
2. Enable it
3. Copy the "Web client ID" (you'll need this)

### Enable Email/Password
1. Click "Email/Password" provider
2. Enable it

## Step 7: Configure URL Schemes

1. In Xcode, select your project in the navigator
2. Select the "MovieTrailer" target
3. Go to "Info" tab
4. Expand "URL Types"
5. Add a new URL Type:
   - URL Schemes: Paste the **REVERSED_CLIENT_ID** from GoogleService-Info.plist
   - Example: `com.googleusercontent.apps.XXXX-XXXX`

## Step 8: Create Firestore Database

1. In Firebase Console > Firestore Database
2. Click "Create database"
3. Start in "test mode" for development
4. Select a location close to your users
5. Click "Create"

## Step 9: Add Sign in with Apple Capability

1. In Xcode, select your project
2. Select the "MovieTrailer" target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability"
5. Search for and add "Sign in with Apple"

## Step 10: Build and Run

1. Build the project (Cmd+B)
2. Run on simulator or device
3. Test the onboarding flow

## Troubleshooting

### "FirebaseCore not found"
- Make sure Firebase SDK is properly added via SPM
- Clean build folder (Cmd+Shift+K) and rebuild

### "Google Sign-In failed"
- Verify URL scheme is correctly added
- Check that GoogleService-Info.plist is in the project

### "Apple Sign-In not working"
- Ensure capability is added
- Test on a real device (not simulator)

### "Firestore permission denied"
- Check Firestore security rules
- For development, use test mode rules

## Security Rules (Development Only)

For development, use these Firestore rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## What's Implemented

- **Authentication Manager**: Handles Google, Apple, and Email sign-in
- **Firestore Service**: Syncs watchlist, swipe preferences, and streaming services
- **Onboarding Flow**: Welcome, features, streaming setup, and authentication screens
- **Profile View**: User profile with sign-out and account deletion
- **Guest Mode**: Users can skip sign-in and use the app locally

## Data Synced

When users sign in, the following is synced to Firestore:
- Watchlist (movies added, watched status, ratings)
- Swipe preferences (liked, disliked, super-liked movies)
- Selected streaming services
- User preferences (language, region, etc.)
