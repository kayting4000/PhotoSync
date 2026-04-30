# EduScan Flutter App

A cross-platform Flutter application for test paper scanning and student information management using the Supabase backend.

## Features

- **Authentication** - Secure login and signup with Supabase Auth
- **Student Management** - Add, view, edit, and delete student records
- **Subject Management** - Create and manage course subjects
- **Test Paper Scanner** - Scan test papers and detect check marks
- **Grades & GPA** - View exam results, calculate GPA
- **Email Results** - Send grade reports to students via email
- **Cross-platform** - Runs on iOS, Android, and Web

## Setup

### Prerequisites
- Flutter 3.0+ installed
- Dart 3.0+ installed
- Supabase project created

### Installation

1. **Clone the project and navigate to flutter_app directory:**
```bash
cd flutter_app
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Update Supabase credentials:**
Edit `lib/main.dart` and replace:
```dart
const String supabaseUrl = 'https://YOUR_SUPABASE_URL.supabase.co';
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

With your actual Supabase project credentials from your Supabase dashboard.

4. **Run the app:**

For development:
```bash
flutter run
```

For iOS:
```bash
flutter run -d ios
```

For Android:
```bash
flutter run -d android
```

For Web:
```bash
flutter run -d chrome
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── student.dart
│   ├── subject.dart
│   ├── exam.dart
│   └── exam_result.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── student_provider.dart
│   ├── subject_provider.dart
│   └── exam_provider.dart
└── screens/                  # UI screens
    ├── auth/
    │   ├── login_screen.dart
    │   └── signup_screen.dart
    ├── dashboard_screen.dart
    ├── students_screen.dart
    ├── subjects_screen.dart
    ├── scanner_screen.dart
    ├── grades_screen.dart
    └── email_screen.dart
```

## Database Schema

The app uses the following Supabase tables:
- `students` - Student records
- `subjects` - Course subjects
- `exams` - Exam definitions
- `exam_results` - Student exam results
- `student_subjects` - Student course enrollments
- `scoring_rules` - Configurable scoring rules

## Dependencies

- **supabase_flutter** - Database and authentication
- **provider** - State management
- **go_router** - Navigation
- **image_picker** - Camera and gallery access
- **image** - Image processing for scanner
- **camera** - Camera integration
- **http** - HTTP requests
- **dio** - Advanced HTTP client

## Building for Production

### iOS
```bash
flutter build ios
```

### Android
```bash
flutter build apk
# or for App Bundle
flutter build appbundle
```

### Web
```bash
flutter build web
```

## Troubleshooting

### Build Issues
- Run `flutter clean` and `flutter pub get`
- Ensure Flutter and Dart versions are up to date
- Check that Supabase credentials are correct

### Authentication Issues
- Verify Supabase Auth is enabled in your project
- Check that the redirect URL is configured correctly
- Ensure Row Level Security (RLS) policies are set

### Camera/Image Issues
- Grant camera and storage permissions in app settings
- For Android, ensure permissions are declared in AndroidManifest.xml
- For iOS, ensure Info.plist has required keys

## License

This project is open source and available for educational use.

## Support

For issues or questions, contact your development team or refer to:
- Flutter docs: https://flutter.dev
- Supabase docs: https://supabase.com/docs
