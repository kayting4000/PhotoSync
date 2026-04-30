# Complete EduScan Project Setup Guide

Welcome! You now have a complete EduScan application with both a Next.js web version and a Flutter mobile version, all powered by the same Supabase backend.

## Project Contents

```
eduscan_project/
├── app/                              # Next.js Web Application
│   ├── (auth)/                       # Authentication pages
│   ├── dashboard/                    # Dashboard and features
│   ├── api/                          # API routes
│   └── globals.css                   # Global styles
├── components/                       # React components
├── lib/                              # Utilities and helpers
├── flutter_app/                      # Flutter Mobile App
│   ├── lib/                          # Flutter source code
│   ├── android/                      # Android configuration
│   ├── ios/                          # iOS configuration
│   ├── web/                          # Web configuration
│   └── pubspec.yaml                  # Flutter dependencies
├── scripts/                          # Database migrations
└── Documentation files               # Guides and manuals
```

## Quick Start: 5 Minutes

### For Web Application (Next.js)

Already deployed! Access it at: [Your Vercel URL]

To run locally:
```bash
pnpm install
pnpm dev
```

Then open http://localhost:3000

### For Mobile Application (Flutter)

1. **Install Flutter** (5 min):
   - Download from https://flutter.dev/docs/get-started/install
   - Follow platform-specific instructions for Windows/Mac/Linux

2. **Clone/Setup Project**:
   ```bash
   cd flutter_app
   flutter pub get
   ```

3. **Configure Supabase** (2 min):
   - Edit `lib/main.dart`
   - Replace `YOUR_SUPABASE_URL` with your project URL
   - Replace `YOUR_SUPABASE_ANON_KEY` with your anon key
   - Find these in Supabase Dashboard → Settings → API

4. **Run App**:
   ```bash
   flutter run
   ```

## Getting Supabase Credentials

1. Go to https://supabase.com/dashboard
2. Select your project
3. Go to Settings → API
4. Copy:
   - Project URL → `supabaseUrl`
   - Anon Key → `supabaseAnonKey`
5. Paste into appropriate files:
   - Next.js: Environment variables are auto-configured
   - Flutter: `lib/main.dart`

## Features Available

### ✅ User Management
- Sign up with email/password
- Secure login
- Logout functionality

### ✅ Student Management
- Add new students
- View all students
- Edit student information
- Delete students
- Student ID, name, course, year level

### ✅ Subject Management
- Create subjects
- Set subject code and name
- Configure units/credits
- Delete subjects

### ✅ Test Paper Scanner
- Upload test paper images
- Automatic check mark detection
- Manual score override
- Configurable scoring rules
- Save results to database

### ✅ Grades & GPA
- View all exam results
- Filter by subject
- Calculate weighted GPA
- Grade distribution charts
- Grading scale reference (A+ to F)

### ✅ Email Results
- Select students by subject
- Compose custom messages
- Send grade reports via email
- Email preview functionality

## Development Workflow

### Web Development
```bash
# Install dependencies
pnpm install

# Start development server
pnpm dev

# Build for production
pnpm run build

# Deploy to Vercel
pnpm install -g vercel
vercel
```

### Mobile Development

#### iOS (macOS only)
```bash
cd flutter_app

# Run on simulator
flutter run -d iphone

# Build for App Store
flutter build ios --release
```

#### Android (Windows/Mac/Linux)
```bash
cd flutter_app

# Run on emulator/device
flutter run

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

#### Web (Cross-platform)
```bash
cd flutter_app

# Run web version
flutter run -d chrome

# Build web
flutter build web
```

## Database Schema

All versions share the same Supabase database:

```sql
-- Students table
students (id, student_id, first_name, last_name, email, course, year_level)

-- Subjects table
subjects (id, code, name, units)

-- Exams table
exams (id, subject_id, name, exam_type, total_items, points_per_item)

-- Exam Results table
exam_results (id, student_id, exam_id, correct_answers, total_score, percentage, grade)

-- Student-Subject enrollment
student_subjects (id, student_id, subject_id, semester, academic_year, final_grade)

-- Scoring rules
scoring_rules (id, exam_id, section_name, item_start, item_end, points_per_item)
```

## Deployment Guides

### Web (Next.js)

**Deployed on Vercel:**
1. Push code to GitHub
2. Connect repository to Vercel
3. Vercel auto-deploys on push
4. Set environment variables in Vercel dashboard

**Or deploy anywhere:**
```bash
# Build
pnpm run build

# Deploy to your server
# (Follow your hosting provider's instructions)
```

### Mobile (Flutter)

See `flutter_app/DEPLOYMENT.md` for detailed instructions:

**iOS:**
- Build in Xcode
- Sign with developer certificate
- Upload to App Store Connect
- Submit for review

**Android:**
- Build signed APK/AAB
- Upload to Google Play Console
- Submit for review

**Web:**
```bash
cd flutter_app
flutter build web
# Deploy build/web/ to your hosting
```

## Environment Setup

### For Web Development
```bash
# Copy .env template (if exists)
cp .env.example .env.local

# Add your Supabase credentials
NEXT_PUBLIC_SUPABASE_URL=your_url_here
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_key_here
```

### For Mobile Development
Edit `flutter_app/lib/main.dart`:
```dart
const String supabaseUrl = 'https://your-project.supabase.co';
const String supabaseAnonKey = 'your-anon-key';
```

## Testing the Application

### Web App
1. Open http://localhost:3000
2. Sign up with test email
3. Add test students
4. Add test subjects
5. Test scanner with sample image
6. View grades and GPA

### Mobile App
1. Run `flutter run` on target device
2. Follow same testing steps
3. Test platform-specific features:
   - Camera access (mobile)
   - Permissions handling
   - Offline functionality

## Common Issues & Solutions

### Web Issues

**Port 3000 already in use:**
```bash
pnpm dev -- -p 3001
```

**Dependencies not installing:**
```bash
pnpm install --force
```

### Mobile Issues

**Flutter not found:**
- Ensure Flutter is in PATH
- Run `flutter doctor` to diagnose

**Supabase connection fails:**
- Check credentials in code
- Ensure Supabase project is active
- Check firewall/VPN blocking

**Build fails:**
```bash
flutter clean
flutter pub get
flutter run
```

## Adding New Features

### Web (React/Next.js)
1. Create component in `components/`
2. Create API route in `app/api/`
3. Create page in `app/`
4. Add navigation link

### Mobile (Flutter)
1. Create model if needed
2. Create provider for state
3. Create screen
4. Add route to router in main.dart

## Security Considerations

1. **Never commit credentials** - Use environment variables
2. **Enable RLS** - Row Level Security in Supabase
3. **Validate input** - Both client and server
4. **HTTPS only** - Always use secure connections
5. **Secure storage** - Don't store sensitive data locally
6. **Keep dependencies updated** - Regular security updates

## Performance Tips

- Use image optimization
- Cache API responses
- Lazy load screens
- Use indexed database queries
- Monitor bundle size
- Test on slow networks

## Monitoring & Analytics

1. Set up Supabase logs
2. Monitor API usage
3. Track app crashes
4. Analyze user behavior
5. Performance monitoring

## Support & Resources

- **Flutter Docs**: https://flutter.dev/docs
- **Next.js Docs**: https://nextjs.org/docs
- **Supabase Docs**: https://supabase.com/docs
- **Material Design**: https://material.io/design
- **Tailwind CSS**: https://tailwindcss.com/docs

## Project Maintenance

### Regular Tasks
- Update dependencies monthly
- Monitor security advisories
- Check Supabase quota usage
- Backup database
- Test on new OS versions

### Version Control
```bash
git init
git add .
git commit -m "Initial EduScan project"
git remote add origin your-repo-url
git push -u origin main
```

## Next Steps

1. ✅ Customize branding (logo, colors)
2. ✅ Add more features as needed
3. ✅ Test on multiple devices
4. ✅ Set up CI/CD pipeline
5. ✅ Deploy to app stores
6. ✅ Monitor and iterate

## File Organization Tips

```
Project/
├── README.md                    # Project documentation
├── SETUP.md                     # This file
├── FLUTTER_APP_GUIDE.md         # Flutter specific
├── FLUTTER_VS_WEB_COMPARISON.md # Comparison guide
├── web-app/                     # Next.js code
│   └── [Web app files]
├── flutter_app/                 # Flutter code
│   └── [Flutter app files]
└── shared/                      # Shared resources
    ├── database-schema.sql
    └── API-documentation.md
```

## License & Attribution

This project uses:
- Flutter (Google)
- Next.js (Vercel)
- Supabase (Open Source)
- shadcn/ui (Open Source)
- Material Design (Google)

## Support

For issues:
1. Check documentation files
2. Run `flutter doctor` (mobile)
3. Check browser console (web)
4. Review Supabase logs
5. Check GitHub issues

---

## Quick Command Reference

```bash
# Web Development
pnpm install              # Install web dependencies
pnpm dev                 # Start web dev server
pnpm build               # Build web for production

# Mobile Development
flutter pub get          # Install mobile dependencies
flutter run              # Run on device/emulator
flutter build apk        # Build Android APK
flutter build ios        # Build iOS app
flutter build web        # Build web version

# General
git add .
git commit -m "message"
git push
```

Happy coding! 🚀
