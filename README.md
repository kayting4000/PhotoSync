# 📱 EduScan - Complete Project

Welcome to EduScan! This is a complete, production-ready application with both **Next.js Web** and **Flutter Mobile** versions sharing the same Supabase backend.

## 🚀 Quick Start

### For Web (Next.js)
```bash
pnpm install
pnpm dev
# Open http://localhost:3000
```

### For Mobile (Flutter)
```bash
cd flutter_app
flutter pub get
# Update credentials in lib/main.dart
flutter run
```

**First time? Read [DOWNLOAD_INSTRUCTIONS.md](./DOWNLOAD_INSTRUCTIONS.md) →**

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **DOWNLOAD_INSTRUCTIONS.md** | 👈 **START HERE** - How to download and set up |
| **COMPLETE_SETUP_GUIDE.md** | Comprehensive setup & development guide |
| **FLUTTER_APP_GUIDE.md** | Flutter-specific information |
| **FLUTTER_VS_WEB_COMPARISON.md** | Compare web and mobile versions |
| **flutter_app/README.md** | Flutter app technical details |
| **flutter_app/DEPLOYMENT.md** | Build and publish guide |

---

## ✨ Features

### 🔐 Authentication
- Secure login/signup
- Email-based authentication
- Session management

### 👥 Student Management
- Add, edit, delete students
- Track student ID, name, course, year level
- Email management

### 📚 Subject Management
- Create subjects with codes
- Configure units/credits
- Link subjects to students

### 📸 Test Paper Scanner
- Upload test paper images
- Automatic check mark detection
- Canvas-based image processing
- Manual score override
- Configurable scoring rules

### 📊 Grades & GPA
- Track all exam results
- Calculate weighted GPA
- View grade distributions
- Filter by subject
- Export grade reports

### 📧 Email Reports
- Send grades to students
- Customizable messages
- Batch email functionality
- Email preview

### 📈 Dashboard
- Statistics overview
- Quick action buttons
- Real-time data sync

---

## 🎯 Project Structure

```
EduScan/
├── 📁 app/                           # Next.js Web Application
│   ├── 📁 dashboard/                 # Dashboard pages
│   ├── 📁 api/                       # API routes
│   └── 📁 auth/                      # Authentication pages
├── 📁 components/                    # React components
├── 📁 lib/                          # Web utilities
├── 📁 flutter_app/                  # Flutter Mobile App
│   ├── 📁 lib/
│   │   ├── models/                  # Data models
│   │   ├── providers/               # State management
│   │   ├── screens/                 # UI screens
│   │   └── main.dart                # Entry point
│   ├── 📁 android/                  # Android config
│   ├── 📁 ios/                      # iOS config
│   ├── 📁 web/                      # Web config
│   └── pubspec.yaml                 # Dependencies
├── 📁 scripts/                      # Database scripts
└── 📚 Documentation files
```

---

## 🛠 Technology Stack

### Web Version
- **Framework**: Next.js 15 (React)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Components**: shadcn/ui
- **Backend**: Supabase
- **Hosting**: Vercel

### Mobile Version
- **Framework**: Flutter 3.0+
- **Language**: Dart
- **State Management**: Provider
- **Navigation**: GoRouter
- **Backend**: Supabase SDK
- **Platforms**: iOS, Android, Web, Desktop

### Shared Backend
- **Database**: PostgreSQL (Supabase)
- **Authentication**: Supabase Auth
- **API**: REST + Realtime subscriptions
- **Storage**: Supabase Storage

---

## 📦 What's Included

✅ **Complete Source Code**
- Next.js web app with all features
- Flutter mobile app with all features
- Shared Supabase backend configuration

✅ **Database Schema**
- Pre-configured tables
- Indexes for performance
- Row Level Security policies

✅ **Documentation**
- Setup guides
- Deployment guides
- API documentation
- Troubleshooting guides

✅ **Ready to Deploy**
- Web: Deploy to Vercel in 1 click
- Mobile: Build scripts included
- Database: Migrations provided

---

## 🔒 Security Features

- ✅ Supabase Authentication
- ✅ Row Level Security (RLS)
- ✅ Environment variables for credentials
- ✅ Password hashing
- ✅ Secure session management
- ✅ HTTPS enforcement

---

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| 🍎 iOS | ✅ Ready | Build for App Store |
| 🤖 Android | ✅ Ready | Build for Google Play |
| 💻 Web | ✅ Ready | Deploy to Vercel |
| 🖥️ Windows | ✅ Ready | Desktop app |
| 🍎 macOS | ✅ Ready | Desktop app |
| 🐧 Linux | ✅ Ready | Desktop app |

---

## 🚀 Getting Started Steps

1. **Read**: [DOWNLOAD_INSTRUCTIONS.md](./DOWNLOAD_INSTRUCTIONS.md)
2. **Get Supabase credentials**: 2-5 minutes
3. **Configure web app**: 1 minute
4. **Configure mobile app**: 1 minute
5. **Run web**: `pnpm dev`
6. **Run mobile**: `flutter run`
7. **Test features**: 5-10 minutes

**Total setup time: ~15 minutes**

---

## 📖 Learn More

- [Flutter Documentation](https://flutter.dev/docs)
- [Next.js Documentation](https://nextjs.org/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [Tailwind CSS Guide](https://tailwindcss.com/docs)
- [Material Design](https://material.io/design)

---

## 🐛 Need Help?

1. **Check documentation** - Most answers are in the guides
2. **Run `flutter doctor`** - Diagnose Flutter issues
3. **Check browser console** - Web app errors
4. **Verify credentials** - Supabase URL and keys
5. **Check Supabase dashboard** - Database and API status

---

## 📝 License

This project is provided for educational and commercial use.

---

## ✅ Next Step

👉 **Start here**: [DOWNLOAD_INSTRUCTIONS.md](./DOWNLOAD_INSTRUCTIONS.md)

The document will guide you through:
- Downloading the project
- Setting up Supabase
- Running both versions
- Building for production

---

**Ready to build something amazing?** Let's go! 🚀

*Created with ❤️ using Next.js, Flutter, and Supabase*
