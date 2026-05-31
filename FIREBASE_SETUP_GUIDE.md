# Firebase Setup Guide for Push Notifications

## Overview

This guide walks through setting up Firebase Cloud Messaging (FCM) for push notifications in the EduScan Flutter app.

---

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `EduScan`
4. Accept terms and click "Create project"
5. Wait for project creation to complete

---

## Step 2: Add Flutter App to Firebase

### For Android:

1. In Firebase Console, click "Add app" → Select "Android"
2. Enter package name: `com.eduscan.app`
3. Enter app nickname: `EduScan Android`
4. Click "Register app"
5. Download `google-services.json`
6. Place it in: `flutter_app/android/app/google-services.json`

### For iOS:

1. In Firebase Console, click "Add app" → Select "iOS"
2. Enter bundle ID: `com.eduscan.app`
3. Enter app nickname: `EduScan iOS`
4. Click "Register app"
5. Download `GoogleService-Info.plist`
6. Open `flutter_app/ios/Runner.xcworkspace` in Xcode
7. Drag `GoogleService-Info.plist` into Xcode project
8. Make sure it's added to Runner target

---

## Step 3: Configure FlutterFire

Run FlutterFire CLI to automatically configure your Flutter app:

```bash
cd flutter_app

# Install FlutterFire CLI (if not already installed)
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure --project=eduscan
```

This will:
- Detect your platforms (Android, iOS, Web)
- Create Firebase configuration files
- Update `pubspec.yaml` if needed

---

## Step 4: Enable Cloud Messaging

1. In Firebase Console, go to "Cloud Messaging"
2. Click "Enable" if not already enabled
3. Note your **Server API Key** (you'll need this for backend)

---

## Step 5: Android Configuration

### Update android/build.gradle:

```gradle
buildscript {
    ext {
        kotlin_version = '1.9.0'
    }
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.0.0'
        classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version'
        classpath 'com.google.gms:google-services:4.4.0'  // Add this line
    }
}
```

### Update android/app/build.gradle:

```gradle
plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'com.google.gms.google-services'  // Add this line
}

android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.eduscan.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"
    }
}

dependencies {
    // Firebase
    implementation 'com.google.firebase:firebase-messaging:23.4.0'
}
```

---

## Step 6: iOS Configuration

### Update ios/Podfile:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_NOTIFICATIONS=1',
      ]
    end
  end
end
```

### Enable Push Notifications in Xcode:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Runner" project
3. Select "Runner" target
4. Go to "Signing & Capabilities"
5. Click "+ Capability"
6. Add "Push Notifications"
7. Add "Background Modes" → Enable "Remote notifications"

---

## Step 7: Initialize Firebase in Flutter

Update `flutter_app/lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:your_app/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize push notifications
  final pushService = PushNotificationService();
  await pushService.init();
  
  runApp(const MyApp());
}
```

---

## Step 8: Test Push Notifications

### Get Device Token:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Get FCM token
  String? token = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $token');
  
  runApp(const MyApp());
}
```

### Send Test Notification from Firebase Console:

1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Enter notification title and body
4. Click "Send test message"
5. Select your device from the list
6. Click "Test"

---

## Step 9: Backend Integration

### Send Notifications from Python Backend:

```python
from firebase_admin import messaging
import firebase_admin
from firebase_admin import credentials

# Initialize Firebase Admin SDK
cred = credentials.Certificate('path/to/serviceAccountKey.json')
firebase_admin.initialize_app(cred)

def send_grade_notification(student_id: str, grade: str, subject: str):
    """Send grade notification to student."""
    message = messaging.Message(
        notification=messaging.Notification(
            title='New Grade Posted',
            body=f'You received a {grade} in {subject}',
        ),
        data={
            'grade': grade,
            'subject': subject,
            'type': 'grade_notification',
        },
        topic=f'student_{student_id}',
    )
    
    response = messaging.send(message)
    print(f'Successfully sent message: {response}')
    return response
```

### Get Service Account Key:

1. In Firebase Console, go to "Project Settings"
2. Click "Service Accounts"
3. Click "Generate New Private Key"
4. Save as `serviceAccountKey.json` in backend folder
5. Add to `.gitignore` (don't commit!)

---

## Step 10: Subscribe to Topics

In your Flutter app, subscribe students to notifications:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

class StudentProvider extends ChangeNotifier {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  Future<void> subscribeToGradeNotifications(String studentId) async {
    try {
      // Subscribe to student-specific topic
      await _messaging.subscribeToTopic('student_$studentId');
      print('Subscribed to student_$studentId');
      
      // Also subscribe to general grades topic
      await _messaging.subscribeToTopic('grades');
      print('Subscribed to grades');
    } catch (e) {
      print('Error subscribing to topics: $e');
    }
  }
  
  Future<void> unsubscribeFromGradeNotifications(String studentId) async {
    try {
      await _messaging.unsubscribeFromTopic('student_$studentId');
      await _messaging.unsubscribeFromTopic('grades');
    } catch (e) {
      print('Error unsubscribing: $e');
    }
  }
}
```

---

## Troubleshooting

### Issue: "google-services.json not found"
**Solution**: Make sure the file is in `flutter_app/android/app/` directory

### Issue: "Firebase not initialized"
**Solution**: Call `Firebase.initializeApp()` before using Firebase services

### Issue: "Notifications not received"
**Solution**:
1. Check device has internet connection
2. Verify app has notification permissions
3. Check Firebase Console for errors
4. Ensure device token is subscribed to topic

### Issue: "Pod install fails"
**Solution**: Run `cd ios && pod repo update && pod install && cd ..`

---

## Files Modified

- `flutter_app/pubspec.yaml` - Added Firebase dependencies
- `flutter_app/lib/main.dart` - Initialize Firebase
- `flutter_app/android/app/build.gradle` - Google Services plugin
- `flutter_app/ios/Runner.xcworkspace` - Push Notifications capability

---

## Next Steps

1. ✅ Create Firebase project
2. ✅ Add Flutter app to Firebase
3. ✅ Configure FlutterFire
4. ✅ Enable Cloud Messaging
5. ✅ Configure Android & iOS
6. ✅ Initialize Firebase in app
7. ✅ Test notifications
8. ✅ Integrate with backend
9. 🔄 Deploy to production

---

**Status**: ✅ Setup Complete
**Version**: 1.0
**Last Updated**: December 19, 2024
