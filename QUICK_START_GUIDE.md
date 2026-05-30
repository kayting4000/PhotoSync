# 🚀 EduScan Quick Start Guide - v2024.12.19+1

## 📱 Mobile App

### Build & Run
```bash
cd flutter_app
flutter pub get
flutter run
```

### Version
- **Current:** 2024.12.19+1
- **Format:** YYYY.MM.DD+build_number

### Key Features
- ✨ Enhanced glass morphism UI
- 🎬 Smooth animations
- 🎨 Premium color palette
- 📱 Mobile-optimized

---

## 🔧 Backend API

### Start Server
```bash
cd backend
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Access Swagger UI
```
http://localhost:8000/docs
```

### Key Features
- 📊 Hierarchical grades
- 🎓 MSU-TCTO grading
- 📧 Email integration
- 🔍 Student filtering

---

## 📚 New Endpoints

### Grades
```
GET /grades/student/{student_id}
GET /grades/student/{student_id}/subject/{subject_id}
GET /grades/student/{student_id}/gpa
```

### Email
```
POST /email/send-grade-transcript
```

### Students
```
GET /students/?course=BSIT&year_level=2&search=john
```

---

## 🎨 UI Components

### GlassCard
```dart
GlassCard(
  child: Text('Content'),
  onTap: () {},
)
```

### GradientButton
```dart
GradientButton(
  onPressed: () {},
  child: Text('Click'),
)
```

### DynamicAvatar
```dart
DynamicAvatar(text: 'John Doe')
```

---

## 📧 Email Setup

### Gmail Configuration
1. Enable 2FA on Gmail
2. Generate App Password
3. Set environment variables:
```
GMAIL_USER=your-email@gmail.com
GMAIL_PASSWORD=your-app-password
```

---

## 🎯 Testing

### Backend
```bash
# Test endpoints in Swagger UI
# http://localhost:8000/docs
```

### Mobile
```bash
# Run on device/emulator
flutter run
```

---

## 📖 Documentation

### Backend
- `backend/GRADES_AND_EMAIL_FEATURES.md`
- `backend/BACKEND_GUIDE.md`

### Mobile
- `flutter_app/UI_ENHANCEMENTS.md`
- `flutter_app/COMPONENT_REFERENCE.md`

### Project
- `CHANGELOG_2024_12_19.md`
- `UPDATE_SUMMARY.md`

---

## 🚀 Deployment

### Backend
```bash
# Deploy to production
# Update environment variables
# Run migrations if needed
```

### Mobile
```bash
# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

---

## 🐛 Troubleshooting

### Backend Issues
- Check `.env` file
- Verify Gmail credentials
- Check Supabase connection

### Mobile Issues
- Run `flutter clean`
- Run `flutter pub get`
- Check device logs

---

## 📞 Support

- Check documentation files
- Review code comments
- Test on multiple devices
- Report with device specs

---

**Version:** 2024.12.19+1
**Status:** ✅ Production Ready

