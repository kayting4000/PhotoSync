# 🔒 Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | ✅ Yes             |
| < 1.0   | ❌ No              |

---

## 🛡 Reporting a Vulnerability

The EduScan team takes security seriously. We appreciate your efforts to responsibly disclose any security concerns.

### How to Report

**Please do NOT report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to: **kayting4000@gmail.com**

Please include the following information in your report:

- **Description** of the vulnerability
- **Type of issue** (e.g., buffer overflow, SQL injection, cross-site scripting, etc.)
- **Affected components** (e.g., backend API, web frontend, Flutter app)
- **Step-by-step instructions** to reproduce the issue
- **Proof of concept** (if possible)
- **Impact** assessment
- **Suggested fix** (if available)

---

## 📋 What to Include

### For API/Backend Vulnerabilities:
- Affected endpoints (e.g., `POST /auth/login`)
- Authentication details needed to reproduce
- Potential data exposure risks

### For Frontend/Mobile Vulnerabilities:
- Affected pages/screens
- Browser/device information
- Screenshot or video of the vulnerability

### For Authentication/Authorization Issues:
- Account role details
- Access control bypass methods
- Session management concerns

---

## ⏱ Response Timeline

| Action | Timeline |
|--------|----------|
| Acknowledgment of report | Within 48 hours |
| Initial assessment | Within 5 business days |
| Fix development | Within 30 days (depending on severity) |
| Public disclosure | After fix is released |

---

## ✅ Security Best Practices

### For Developers
- Never commit credentials or API keys to the repository
- Use environment variables for sensitive configuration
- Follow secure coding practices
- Validate and sanitize all user inputs
- Use parameterized queries to prevent SQL injection
- Implement proper authentication and authorization checks
- Use HTTPS for all API communications

### For Users
- Keep your application updated to the latest version
- Use strong, unique passwords
- Enable two-factor authentication where available
- Report any suspicious activity immediately

---

## 🔐 Security Features

EduScan includes the following security features:

- **Supabase Authentication** — Secure user authentication
- **Row Level Security (RLS)** — Database-level access control
- **Environment Variables** — Credentials stored securely
- **Password Hashing** — Passwords are never stored in plain text
- **HTTPS Enforcement** — All communications encrypted
- **CORS Protection** — Cross-origin request filtering
- **Input Validation** — Pydantic schema validation on all inputs
- **SQL Injection Prevention** — SQLAlchemy ORM usage

---

## 📝 Disclosure Policy

When we receive a security bug report, we will:

1. Confirm the vulnerability and determine its impact
2. Develop and test a fix
3. Release the fix as soon as possible
4. Publish a security advisory after the fix is released
5. Credit the reporter (unless they prefer to remain anonymous)

---

## 🙏 Acknowledgments

We thank all security researchers and community members who help improve the security of EduScan. Your efforts are greatly appreciated.

---

**Thank you for helping keep EduScan and its users safe!** 🔒