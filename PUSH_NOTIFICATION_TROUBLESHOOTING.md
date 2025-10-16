# Push Notification Troubleshooting Guide

## Issues Found and Solutions

### 1. ✅ APNS Token Retrieval Fixed
- Updated the notification service to properly retrieve APNS token for iOS devices
- Added detailed logging to track token retrieval

### 2. ⚠️ Push Notifications Capability Not Enabled in Xcode
**This is likely your main issue!**

To fix this:
1. Open your project in Xcode
2. Select the Runner target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability" button
5. Add "Push Notifications" capability
6. This will automatically update your project file and entitlements

### 3. ✅ Xcode Build Configuration - Updated
Your scheme was changed from "Release" to "Debug" for better debugging capabilities. However, **push notifications work on BOTH Debug and Release configurations**.

**If you can only run on Release configuration:**
- That's perfectly fine! Push notifications will work on Release builds
- The configuration doesn't affect push notification functionality
- The only difference is you won't see as detailed debug information

**Common reasons why Debug configuration might not work:**
- Code signing issues (check your provisioning profiles)
- Different bundle identifiers between Debug and Release
- Missing development certificates
- Swift/Objective-C optimization settings

**This does NOT affect push notifications** - they work the same on both configurations!

### 4. Firebase APNS Configuration Checklist
Ensure you have completed these steps in Firebase Console:

1. **Upload APNS Authentication Key (Recommended)** or **APNS Certificate**:
   - Go to Firebase Console > Project Settings > Cloud Messaging
   - Under "Apple app configuration", upload your APNS Authentication Key (.p8 file)
   - Or upload your APNS certificates for both Development and Production

2. **APNS Key Method (Recommended)**:
   - Generate key from Apple Developer Portal > Keys
   - Download the .p8 file
   - Note the Key ID
   - Upload to Firebase with your Team ID

### 5. Testing Push Notifications

**Important:** Push notifications work on BOTH Debug and Release configurations. The build configuration does NOT affect whether push notifications will work.

Run this command to see the debug output:
```bash
flutter clean && flutter run --verbose
```

Look for these log messages:
- 🔔 NotificationService: Starting initialization...
- 🔔 Permission status: authorized
- ✅ Push notifications permission authorized
- APNS Token: [token value - should NOT be null]
- FCM Token: [token value - should NOT be null]

### 6. Common Issues and Solutions

**Issue: APNS token is null**
- Ensure you're testing on a real device (not simulator)
- Check that Push Notifications capability is enabled
- Verify provisioning profile includes push notifications

**Issue: Permission denied**
- User has denied permission - need to guide them to Settings
- Reset permissions: Settings > General > Reset > Reset Location & Privacy

**Issue: Not receiving notifications**
- Check Firebase Console for successful sends
- Verify APNS certificate/key is correctly configured
- Ensure device has internet connection
- Check if app is in foreground (foreground notifications need special handling)

### 7. Testing with Firebase Console

1. Go to Firebase Console > Cloud Messaging
2. Click "Send your first message"
3. Enter notification details
4. Target your app
5. Send test message
6. Check Xcode console for any error messages

### 8. Additional Debugging

Add this temporary code to test sending a notification to yourself:
```dart
// Add this after getting the FCM token
if (token != null) {
  print('Send a test notification to this token using Firebase Console or API:');
  print(token);
}
```

### 9. Verify Your Setup

**In Xcode:**
- [ ] Push Notifications capability is enabled
- [ ] Correct bundle identifier (com.xedtcg.rift)
- [ ] Valid provisioning profile with push notifications enabled
- [ ] Build configuration set to Debug (for debugging)

**In Firebase Console:**
- [ ] APNS Authentication Key or Certificates uploaded
- [ ] Correct Team ID (if using Auth Key)
- [ ] Correct Bundle ID matches your app

**In Your Code:**
- [ ] FirebaseApp.configure() is called in AppDelegate
- [ ] Notification permissions are requested
- [ ] FCM token is retrieved successfully

## Quick Test Steps

1. **Enable Push Notifications in Xcode** (if not done)
2. **Run the app** on a physical device
3. **Accept notification permissions** when prompted
4. **Check console** for token logs
5. **Copy the FCM token** from console
6. **Send test notification** from Firebase Console using the token

## Common Misconceptions

**You do NOT need to:**
- Upload to App Store Connect for push notifications to work
- Have a published app for testing push notifications
- Use TestFlight for basic push notification testing

Push notifications work perfectly fine in development when running from Xcode!

## Still Not Working?

If notifications still don't work after following all steps:

1. Check if your Apple Developer account has push notification entitlement
2. Try deleting and regenerating your APNS key/certificate
3. Check Firebase Cloud Messaging API is enabled in Google Cloud Console
4. Ensure your device has a stable internet connection
5. Try uninstalling and reinstalling the app

Remember: Push notifications will NOT work on iOS Simulator - you must use a real device!
