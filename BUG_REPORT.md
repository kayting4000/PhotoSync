# Bug Report and Issues Found in PhotoSync

## Status: SUPABASE REMOVED ✅

All Supabase dependencies have been removed. The application now uses **JWT authentication** exclusively.

---

## Critical Issues 🔴

### 1. **Missing Environment Variables**
**Severity**: CRITICAL  
**Location**: `.env` and `.env.local` files (not present)

**Required Variables Missing**:

**Backend** (`backend/.env`):
```
DATABASE_URL=             # Required - PostgreSQL connection
JWT_SECRET=              # Required - for JWT token generation
ROBOFLOW_API_KEY=        # Required - for scanner
ROBOFLOW_WORKSPACE=      # Required - for scanner
ROBOFLOW_WORKFLOW_ID=    # Required - for scanner
RESEND_API_KEY=          # Optional - for email
RESEND_FROM_EMAIL=       # Optional - for email (default provided)
```

**Frontend** (`.env.local`):
```
NEXT_PUBLIC_API_URL=             # Required - Backend URL
RESEND_API_KEY=                  # Optional - Email service
```

**Problem**: 
- Application won't run without these values
- Blocking all functionality

---

### 2. **Missing Backend Connection Configuration**
**Severity**: CRITICAL  
**Location**: Frontend API calls vs Backend services

**Issue**:
- Email manager calls `/api/email/send` (Next.js API route)
- This needs to properly forward to the backend's `/email/send-grade-report` endpoint
- `NEXT_PUBLIC_API_URL` environment variable must be configured

**Problem**: 
- Without proper configuration, email distribution won't work
- API calls will fail with 404 or CORS errors

**Fix Required**:
1. Create `.env.local` with `NEXT_PUBLIC_API_URL=http://localhost:8000`
2. Verify `/api/email/send` route.ts forwards to backend
3. For network access, set to your IP: `NEXT_PUBLIC_API_URL=http://192.168.1.100:8000`

---

## Major Bugs 🟠

### 3. **Scanner Endpoint Not Accessible from Network**
**Severity**: HIGH  
**Location**: `backend/controllers/scanner.py`

**Issue**:
- Scanner uses Roboflow API but endpoint configuration is hardcoded
- When accessing from a different device with IP address (e.g., `http://192.168.1.100:3000`), API calls might fail

**Fix Required**:
1. Ensure `NEXT_PUBLIC_API_URL` is set correctly for network access
2. Verify the Next.js wrapper forwards to the backend correctly
3. Check firewall allows port 8000

---

### 4. **GPA Calculation May Have Division By Zero**
**Severity**: MEDIUM  
**Location**: `backend/controllers/grades.py`, line 47-60

**Code**:
```python
if total_units == 0:
    return {"gpa": None, "total_units": 0, "subjects_counted": len(results)}

gpa = round(weighted_sum / total_units, 4)  # This is safe
```

**Status**: ✅ Actually handled correctly with the check above

---

### 5. **Missing Error Handling in Scanner Detection**
**Severity**: MEDIUM  
**Location**: `components/scanner/test-scanner.tsx`, line 135+

**Issue**:
```javascript
const cellSize = Math.min(width, height) / 20

for (const pixel of darkPixels) {
  const cellX = Math.floor(pixel.x / cellSize)
  // ... may have undefined behavior if cellSize is 0
```

**Problem**: 
- If `cellSize` is 0 (very small image), division issues occur
- No validation that image is reasonable size

**Fix Required**:
```typescript
const cellSize = Math.max(1, Math.min(width, height) / 20)
if (width < 100 || height < 100) {
  throw new Error("Image too small to scan")
}
```

---

### 6. **Exam Results Grade Assignment Race Condition**
**Severity**: MEDIUM  
**Location**: `backend/controllers/results.py`, line 63-82

**Issue**:
```python
@router.post("/")
def create_result(...):
    data = body.model_dump()
    if data.get("percentage") is not None and not data.get("grade"):
        grade, gp, remarks = _assign_grade(data["percentage"])
```

**Problem**: 
- If multiple requests are made simultaneously with same percentage, they might get different grade assignments
- No transaction protection

---

## Minor Issues 🟡

### 7. **Email Sends Silently Fail Without RESEND_API_KEY**
**Severity**: LOW  
**Location**: `backend/controllers/email.py`, line 34-39

**Code**:
```python
if not RESEND_API_KEY:
    return {
        "success": True,
        "message": "Email simulated (RESEND_API_KEY not configured)",
    }
```

**Problem**: 
- User thinks email was sent but it wasn't
- No warning in the UI

**Fix Required**:
- Show a warning in UI when RESEND_API_KEY is missing
- OR return `success: false`

---

### 8. **Dashboard Queries May Return Null**
**Severity**: LOW  
**Location**: `app/dashboard/page.tsx`, line 12-19

**Code**:
```javascript
const [
    { count: studentsCount },
    // ...
] = await Promise.all([...])
```

**Problem**: 
- If database queries fail, `count` might be `null` or `undefined`
- Already handled with `?? 0` but good to verify

---

### 9. **Missing Validation on Student Email**
**Severity**: LOW  
**Location**: `backend/controllers/email.py`, line 43

**Code**:
```python
if not student.email:
    raise HTTPException(status_code=400, detail="Student has no email address")
```

**Status**: ✅ Properly validated

---

## Configuration Issues 🔧

### 10. **API Endpoint Hardcoding for Network Access**
**Severity**: HIGH  
**Location**: Frontend API calls vs Backend URL configuration

**Problem**:
- Email manager and scanner components use relative URLs or hardcoded URLs
- When accessing from another device on network (e.g., `192.168.1.100:3000`), the backend at `localhost:8000` won't be accessible

**Fix Required** (Already provided in CROSS_DEVICE_SETUP.md):
- Create `.env.local` with: `NEXT_PUBLIC_API_URL=http://<YOUR_IP>:8000`
- Update all API calls to use this environment variable
- Or use a proxy to forward `/api/` requests to the backend

---

### 11. **Missing .env.example Files**
**Severity**: MEDIUM  
**Location**: Root and backend directories

**Problem**:
- New developers don't know what environment variables are needed
- Easy to miss required credentials

**Fix Required**:
1. Create `backend/.env.example` with template
2. Create `.env.local.example` with template
3. Add to .gitignore

---

## Testing Recommendations

### Before Going Live:
1. ✅ **Setup .env files** with all required variables
2. ✅ **Test authentication** (signup and login)
3. ✅ **Test API endpoints** from different devices
4. ✅ **Verify email sending** works (or displays proper error)
5. ✅ **Test scanner** with various image sizes
6. ✅ **Verify database connection** and tables exist
7. ✅ **Test GPA calculation** with various grade combinations
8. ✅ **Test cross-device access** using IP address

---

## Priority Fix Order

1. **FIRST**: Set up `.env` and `.env.local` files with required credentials
2. **SECOND**: Test authentication (sign up and login)
3. **THIRD**: Configure API URL for network access
4. **FOURTH**: Fix scanner error handling
5. **FIFTH**: Fix email silent failure issue
6. **SIXTH**: Add proper error boundaries in UI
7. **SEVENTH**: Create `.env.example` files

---

## Next Steps

See [ENVIRONMENT_SETUP.md](ENVIRONMENT_SETUP.md) for environment configuration guide.
See [TESTING_GUIDE.md](TESTING_GUIDE.md) for testing procedures.
See [PROCESS_FLOW.md](PROCESS_FLOW.md) for expected application flow.
