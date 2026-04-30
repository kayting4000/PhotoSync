# EduScan - Download & Installation Instructions

## What You Have

✅ **Complete Next.js Web Application**
- Already built and deployable
- Full feature set implemented
- Database schema configured
- Ready for production

✅ **Complete Flutter Mobile Application**
- Cross-platform (iOS, Android, Web)
- Native performance
- Same features as web version
- Ready to build and publish

## Download Your Project

### Option 1: Download as ZIP
1. In v0, click the three dots menu in top right
2. Select "Download ZIP"
3. Extract the ZIP file
4. You'll have the complete project

### Option 2: Git Repository
1. Initialize git (if not already done):
```bash
git init
git add .
git commit -m "Initial EduScan project"
```

2. Push to GitHub:
```bash
git remote add origin your-github-url
git push -u origin main
```

## File Structure After Download

```
eduscan-project/
├── app/                           # Next.js Web App
├── components/                    # React Components
├── lib/                          # Utilities
├── flutter_app/                  # Flutter Mobile App
│   ├── lib/                      # Dart source code
│   ├── android/                  # Android config
│   ├── ios/                      # iOS config
│   ├── web/                      # Web config
│   ├── pubspec.yaml              # Dependencies
│   └── README.md                 # Flutter setup guide
├── scripts/                      # Database migration
├── COMPLETE_SETUP_GUIDE.md       # Main setup guide
├── FLUTTER_APP_GUIDE.md          # Flutter specific
├── FLUTTER_VS_WEB_COMPARISON.md  # Comparison
└── Other documentation files
```

## Immediate Next Steps

### 1. Get Supabase Credentials (2 minutes)

Required for BOTH web and mobile versions!

1. Go to https://supabase.com
2. Sign up or log in
3. Create a new project or select existing
4. Go to Settings → API
5. Copy:
   - **Project URL** 
   - **Anon Key**

### 2. For Web Development

```bash
# Navigate to project root
cd eduscan-project

# Install dependencies
pnpm install

# Create environment file
echo 'NEXT_PUBLIC_SUPABASE_URL=YOUR_PROJECT_URL' > .env.local
echo 'NEXT_PUBLIC_SUPABASE_ANON_KEY=YOUR_ANON_KEY' >> .env.local

# Start development server
pnpm dev

# Open browser
# http://localhost:3000
```

### 3. For Mobile Development

```bash
# Install Flutter (if not already installed)
# https://flutter.dev/docs/get-started/install

# Navigate to Flutter app
cd eduscan-project/flutter_app

# Install dependencies
flutter pub get

# Edit lib/main.dart
# Replace YOUR_SUPABASE_URL and YOUR_SUPABASE_ANON_KEY

# Run on device/emulator
flutter run
```

## Build & Deploy

### Deploy Web to Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
cd eduscan-project
vercel
```

Or connect your GitHub repo to Vercel for automatic deployments.

### Build Mobile Apps

#### iOS
```bash
cd flutter_app
flutter build ios --release
# Then open in Xcode and submit to App Store
```

#### Android
```bash
cd flutter_app
flutter build appbundle --release
# Upload to Google Play Console
```

## Documentation to Read

1. **COMPLETE_SETUP_GUIDE.md** - Comprehensive setup and usage
2. **FLUTTER_APP_GUIDE.md** - Flutter specific setup
3. **flutter_app/README.md** - Flutter app documentation
4. **flutter_app/DEPLOYMENT.md** - Build and deployment guide
5. **FLUTTER_VS_WEB_COMPARISON.md** - Compare both versions

## Features Included

✅ User Authentication (Login/Signup)
✅ Student Management (Add/Edit/Delete)
✅ Subject Management
✅ Test Paper Scanner with check mark detection
✅ Grades & GPA Calculator
✅ Email Grade Reports
✅ Dashboard with statistics
✅ Responsive design (works on all devices)
✅ Cross-platform support (Web, iOS, Android, Desktop)

## System Requirements

### For Web Development
- Node.js 18+ or pnpm installed
- Code editor (VS Code recommended)
- Modern web browser

### For Mobile Development
- Flutter 3.0+ installed
- Android Studio (for Android development)
- Xcode (for iOS development on macOS)
- iOS/Android device or emulator

## Troubleshooting

### Can't find Flutter?
```bash
# Check if Flutter is installed
flutter --version

# If not, download from:
# https://flutter.dev/docs/get-started/install
```

### Port 3000 already in use?
```bash
pnpm dev -- -p 3001  # Use different port
```

### Supabase connection fails?
- Verify credentials in code
- Check project is active
- Ensure network/firewall allows connection

### Flutter build fails?
```bash
flutter clean
flutter pub get
flutter run
```

## First Time Running

### Web App
1. Go to http://localhost:3000
2. Click "Sign up"
3. Enter test email and password
4. You're logged in!
5. Click "Manage Students" to start

### Mobile App
1. App starts at login screen
2. Tap "Sign up"
3. Enter test email and password
4. Dashboard loads with stats
5. Tap "Manage Students" to start

## Testing With Sample Data

1. **Add Students:**
   - ID: S001, Name: John Doe, Course: BSIT, Year: 1
   - ID: S002, Name: Jane Smith, Course: BSCS, Year: 2

2. **Add Subjects:**
   - Code: CS101, Name: Intro to CS, Units: 3
   - Code: MATH201, Name: Calculus, Units: 4

3. **Scan Paper:**
   - Use scanner to upload test image
   - Check mark detection runs automatically

4. **View Grades:**
   - All results appear with GPA calculation

5. **Send Emails:**
   - Select subject
   - Send reports to all students

## Security Notes

1. **Never commit credentials** to version control
2. **Use environment variables** for sensitive data
3. **Enable Row Level Security** in Supabase
4. **Change default passwords** before production
5. **Use HTTPS** everywhere

## Support Resources

- **Flutter**: https://flutter.dev/docs
- **Next.js**: https://nextjs.org/docs
- **Supabase**: https://supabase.com/docs
- **Tailwind CSS**: https://tailwindcss.com/docs

## Next Steps After Download

1. ✅ Download and extract project
2. ✅ Set up Supabase account
3. ✅ Get Supabase credentials
4. ✅ Configure web app (.env)
5. ✅ Configure mobile app (lib/main.dart)
6. ✅ Run web dev server (pnpm dev)
7. ✅ Run mobile app (flutter run)
8. ✅ Test all features
9. ✅ Deploy to production

## Questions?

- Check the documentation files
- Run `flutter doctor` for mobile issues
- Check browser console for web issues
- Verify Supabase credentials

---

**You're all set!** 🚀

Everything you need to run, develop, and deploy EduScan is included. Start with COMPLETE_SETUP_GUIDE.md for detailed instructions.
