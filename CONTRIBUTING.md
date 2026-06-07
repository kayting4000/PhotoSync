# 🤝 Contributing to PhotoSync

Thank you for your interest in contributing to PhotoSync! This document provides guidelines and information for contributors.

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Commit Message Guidelines](#commit-message-guidelines)

---

## 📜 Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md). We are committed to providing a welcoming and inclusive experience for everyone.

---

## 🚀 Getting Started

1. **Fork** the repository on GitHub
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/your-username/PhotoSync.git
   cd PhotoSync
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/kayting4000/PhotoSync.git
   ```
4. **Create a branch** for your feature/fix:
   ```bash
   git checkout -b feature/your-feature-name
   ```

---

## 🛠 Development Setup

### Prerequisites

- **Node.js** 18+ and **pnpm**
- **Python** 3.10+ and **pip**
- **Flutter** 3.0+ (for mobile app)
- **PostgreSQL** database (or Supabase account)
- **Git**

### Web Frontend (Next.js)
```bash
pnpm install
pnpm dev
# Open http://localhost:3000
```

### Backend (Python/FastAPI)
```bash
cd backend
pip install -r requirements.txt
python -m uvicorn main:app --reload
# Open http://localhost:8000/docs
```

### Flutter Mobile App
```bash
cd flutter_app
flutter pub get
flutter run
```

---

## 🎯 How to Contribute

### 🐛 Bug Reports

1. Check existing [Issues](https://github.com/kayting4000/PhotoSync/issues) first
2. If not found, create a new issue with the **Bug Report** template
3. Include:
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - Screenshots (if applicable)
   - Environment details (OS, browser, Flutter version, etc.)

### 💡 Feature Requests

1. Check existing [Issues](https://github.com/kayting4000/PhotoSync/issues) first
2. Create a new issue with the **Feature Request** template
3. Describe the problem and proposed solution

### 🔧 Code Contributions

1. Pick an issue labeled `good first issue` or `help wanted`
2. Fork and create a branch
3. Make your changes following the coding standards
4. Test your changes thoroughly
5. Submit a pull request

---

## 📬 Pull Request Process

1. **Update your branch** with the latest upstream changes:
   ```bash
   git fetch upstream
   git merge upstream/main
   ```

2. **Ensure your code**:
   - Follows the project's coding standards
   - Doesn't break existing functionality
   - Includes relevant documentation updates
   - Has proper error handling

3. **Write a clear PR description**:
   - What the change does
   - Why the change is needed
   - How it was tested
   - Related issue numbers (e.g., `Closes #42`)

4. **Request a review** from a maintainer

5. **Address review feedback** promptly

---

## 📐 Coding Standards

### Python (Backend)
- Follow **PEP 8** style guide
- Use **type hints** for function parameters and return values
- Write **docstrings** for public functions and classes
- Keep functions focused and under 50 lines when possible
- Use **snake_case** for variables and functions

### TypeScript/React (Web Frontend)
- Follow the project's ESLint configuration
- Use **TypeScript** for type safety
- Use **functional components** with hooks
- Use **Tailwind CSS** for styling
- Follow the existing component patterns

### Dart/Flutter (Mobile App)
- Follow **Dart linting rules** (`analysis_options.yaml`)
- Use **meaningful variable names**
- Keep widgets small and focused
- Use **Provider** for state management
- Follow Material Design guidelines

### General
- Write meaningful commit messages
- Keep changes focused (one feature/fix per PR)
- Don't commit auto-generated files
- Remove unused imports and variables

---

## 📝 Commit Message Guidelines

Use the following format:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation changes |
| `style` | Formatting, missing semi-colons, etc. |
| `refactor` | Code refactoring |
| `test` | Adding or updating tests |
| `chore` | Maintenance tasks |
| `perf` | Performance improvements |
| `ci` | CI/CD changes |

### Examples

```
feat(backend): add student GPA calculation endpoint

fix(flutter): resolve scanner crash on large images

docs: update README with new setup instructions

refactor(backend): simplify grade calculation logic
```

---

## 🏷 Issue Labels

| Label | Description |
|-------|-------------|
| `bug` | Something isn't working |
| `enhancement` | New feature or request |
| `documentation` | Documentation improvements |
| `good first issue` | Good for newcomers |
| `help wanted` | Extra attention is needed |
| `question` | Further information is requested |
| `wontfix` | This will not be worked on |
| `duplicate` | This issue already exists |

---

## ❓ Questions?

If you have questions about contributing, feel free to:
- Open a [Discussion](https://github.com/kayting4000/PhotoSync/discussions)
- Check existing documentation
- Review the codebase for patterns

Thank you for contributing to PhotoSync! 🎓
