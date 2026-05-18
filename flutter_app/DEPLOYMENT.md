# PhotoSync Flutter App - Deployment & Build Guide

## Building for iOS

### Prerequisites
- macOS with Xcode installed
- Apple Developer account for signing

### Build Steps

1. Navigate to project directory:
```bash
cd flutter_app
```

2. Get dependencies:
```bash
flutter pub get
```

3. Build for iOS:
```bash
flutter build ios
```

4. Open Xcode project:
```bash
open ios/Runner.xcworkspace
```

5. Configure signing and build settings
6. Build and archive in Xcode
7. Upload to App Store Connect

## Building for Android

### Prerequisites
- Android Studio installed
- Android SDK configured
- Keystore file for signing

### Build Steps

1. Navigate to project directory:
```bash
cd flutter_app
```

2. Get dependencies:
```bash
flutter pub get
```

3. Build APK:
```bash
flutter build apk --release
```

Or build App Bundle:
```bash
flutter build appbundle --release
```

4. Sign with your release keystore
5. Upload to Google Play Console

## Building for Web

### Prerequisites
- Chrome or other web browser
- Web dependencies configured

### Build Steps

1. Navigate to project directory:
```bash
cd flutter_app
```

2. Enable web support (first time only):
```bash
flutter config --enable-web
```

3. Build web version:
```bash
flutter build web
```

4. The build output will be in `build/web/`

5. Deploy to your web hosting (Vercel, Firebase, etc.):
```bash
# For Vercel
vercel deploy build/web
```

## Build Configuration

### Update Version
Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Change this for releases
```

### Code Signing

#### For iOS
1. Go to Xcode > Runner > Signing & Capabilities
2. Select your team
3. Set bundle identifier
4. Configure provisioning profiles

#### For Android
1. Create keystore (first time):
```bash
keytool -genkey -v -keystore key.jks -alias key -keyalg RSA -keysize 2048 -validity 10000
```

2. Create `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=key
storeFile=../../key.jks
```

3. Update `android/app/build.gradle` to use signing config

## Environment Configuration

Update credentials in `lib/main.dart`:

```dart
const String supabaseUrl = 'https://your-project.supabase.co';
const String supabaseAnonKey = 'your-anon-key';
```

For different environments (dev, staging, production):
- Create separate config files
- Use environment variables
- Use Flutter flavor system

## Testing Before Release

1. Test on multiple devices
2. Test all features with real Supabase data
3. Test offline mode
4. Check image sizes and performance
5. Verify permissions are properly configured

## App Store Submission

### iOS (App Store)
1. Complete app information in Xcode
2. Configure screenshots and description
3. Set up TestFlight testing
4. Submit for review

### Android (Google Play)
1. Complete app listing details
2. Add screenshots and graphics
3. Set content rating
4. Create rollout strategy
5. Submit for review

## Post-Launch Monitoring

1. Monitor crash reports
2. Track user analytics
3. Respond to user feedback
4. Plan updates and improvements

## Performance Optimization

- Enable release mode: `flutter run --release`
- Analyze build size: `flutter build apk --analyze-size`
- Use Android profiling tools
- Monitor iOS performance with Instruments

## Troubleshooting

### Build Failures
- Run `flutter clean`
- Delete `pubspec.lock`
- Run `flutter pub get` again
- Check Flutter version: `flutter --version`

### Signing Issues
- Verify certificate/keystore is valid
- Check provisioning profiles for iOS
- Ensure Java keystore path is correct for Android

### Dependency Issues
- Update dependencies: `flutter pub upgrade`
- Check pubspec.yaml for version conflicts
- Verify Supabase package compatibility

## Continuous Integration

Consider setting up CI/CD with:
- GitHub Actions
- Codemagic
- Firebase App Distribution

Example GitHub Actions workflow included in `.github/workflows/` (if created)

## Resources

- Flutter Build Documentation: https://flutter.dev/docs/deployment
- iOS App Store Guide: https://developer.apple.com/app-store/submission/
- Google Play Developer Guide: https://developer.android.com/guide/playcore
- Supabase Documentation: https://supabase.com/docs
