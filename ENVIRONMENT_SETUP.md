# Environment Configuration Guide

This guide will help you set up the required environment variables to run EduScan locally and on network.

## Quick Start

### Step 1: Backend Setup (backend/.env)

Create a file named `.env` in the `backend/` folder:

```env
# Database Configuration
DATABASE_URL=postgresql://user:password@host/database

# JWT Authentication
JWT_SECRET=your-secret-key-change-in-production

# Roboflow Scanner Configuration
ROBOFLOW_API_KEY=your-roboflow-api-key
ROBOFLOW_WORKSPACE=your-workspace-id
ROBOFLOW_WORKFLOW_ID=your-workflow-id

# Email Configuration (Optional)
RESEND_API_KEY=your-resend-api-key
RESEND_FROM_EMAIL=PhotoSync <onboarding@resend.dev>
```

**Getting Your Credentials:**

- **DATABASE_URL**: From your Neon PostgreSQL connection string
- **JWT_SECRET**: Generate a random string: `openssl rand -base64 32`
- **ROBOFLOW_API_KEY**: From [Roboflow Dashboard](https://roboflow.com)
- **RESEND_API_KEY**: From [Resend Dashboard](https://resend.com)

### Step 2: Frontend Setup (.env.local)

Create a file named `.env.local` in the root folder:

```env
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key

# Backend API URL (for network access)
NEXT_PUBLIC_API_URL=http://YOUR_IP_ADDRESS:8000

# Email Configuration
RESEND_API_KEY=your-resend-api-key
```

**Getting Your Credentials:**

- **SUPABASE_URL & ANON_KEY**: From [Supabase Dashboard](https://supabase.com)
- **YOUR_IP_ADDRESS**: 
  - Windows: Run `ipconfig` and find your IPv4 address (e.g., `192.168.1.100`)
  - macOS/Linux: Run `ifconfig` or `hostname -I`

---

## For Development (Localhost Only)

If you're developing locally and don't need network access:

```env
# .env.local
NEXT_PUBLIC_API_URL=http://localhost:8000
```

---

## For Production (Network/External Access)

When accessing from other devices on your network or from the internet:

```env
# .env.local
NEXT_PUBLIC_API_URL=http://192.168.1.100:8000
# or for external access:
NEXT_PUBLIC_API_URL=https://your-domain.com/api
```

---

## Complete Environment Variables Reference

### Backend (.env)

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `DATABASE_URL` | ✅ Yes | PostgreSQL connection string | `postgresql://user:pass@localhost/eduscan` |
| `JWT_SECRET` | ✅ Yes | Secret key for JWT signing | `your-random-secret-key` |
| `ROBOFLOW_API_KEY` | ✅ Yes | Roboflow API key for scanner | `abc123...` |
| `ROBOFLOW_WORKSPACE` | ✅ Yes | Roboflow workspace ID | `workspace-name` |
| `ROBOFLOW_WORKFLOW_ID` | ✅ Yes | Roboflow workflow ID | `workflow-id` |
| `RESEND_API_KEY` | ❌ Optional | Resend API key for emails | `re_abc123...` |
| `RESEND_FROM_EMAIL` | ❌ Optional | Email sender address | `PhotoSync <admin@photosync.com>` |

### Frontend (.env.local)

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `NEXT_PUBLIC_API_URL` | ✅ Yes | Backend API URL | `http://localhost:8000` |
| `RESEND_API_KEY` | ❌ Optional | Resend API key | `re_abc123...` |

---

## Getting Required Credentials

### 2. Getting Your Credentials

The application uses JWT authentication with a backend API. Here's what you need:

#### Database (Neon PostgreSQL)

1. Go to [Neon Console](https://console.neon.tech/)
2. Create a new project or select existing
3. Copy the connection string from "Connection string"
4. Should look like: `postgresql://user:password@ep-xxx.us-east-1.neon.tech/database?sslmode=require`

#### Roboflow

1. Go to [Roboflow Dashboard](https://app.roboflow.com/)
2. Create workspace if not exists
3. Create or select a workflow
4. Go to **Workspace Settings**
5. Copy:
   - API Key → `ROBOFLOW_API_KEY`
   - Workspace ID → `ROBOFLOW_WORKSPACE`
   - Workflow ID → `ROBOFLOW_WORKFLOW_ID`

### 4. Resend (Optional)

1. Go to [Resend Dashboard](https://resend.com/)
2. Create account and API key
3. Copy:
   - API Key → `RESEND_API_KEY`
   - Verified sender email → `RESEND_FROM_EMAIL`

#### JWT Secret
#
Generate a secure random string:

**Windows (PowerShell)**:
```powershell
[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((Get-Random -Count 32 | ForEach-Object {[char]$_})))
```

**macOS/Linux**:
```bash
openssl rand -base64 32
```

---

## Verification Checklist

After setting up `.env` files, verify everything works:

- [ ] Backend can connect to database: `python backend/main.py` should start without errors
- [ ] Frontend environment variables loaded: Check `http://localhost:3000`
- [ ] Can access API: Try accessing `http://localhost:8000/docs` (FastAPI docs)
- [ ] Authentication works: Try signing up at `http://localhost:3000/auth/sign-up`
- [ ] API calls work: Monitor DevTools Network tab for successful requests

---

## Troubleshooting

### Backend won't start

```
ERROR: DATABASE_URL is not set in .env
```
**Solution**: Verify `.env` file exists in `backend/` folder (not root folder)

### Frontend environment variables not working

```
NEXT_PUBLIC_SUPABASE_URL is undefined
```API_URL is undefined
```
**Solution**: 
1. Create `.env.local` in project root
2. Restart dev server: `pnpm dev`
3. Check browser console: `console.log(process.env.NEXT_PUBLIC_API
### API calls fail from network

```
Failed to fetch http://192.168.1.100:8000/...
```
**Solution**:
1. Verify `NEXT_PUBLIC_API_URL` is set correctly
2. Check backend is running: `python backend/main.py`
3. Verify Windows Firewall allows port 8000 and 3000

### Email not sending

```
"Email simulated (RESEND_API_KEY not configured)"
```
**Solution**: 
- This is expected if `RESEND_API_KEY` is not set
- Set `RESEND_API_KEY` to enable email sending
- Or leave unset for development (emails won't send)

---

## Next Steps

1. ✅ Create `backend/.env` file with required credentials
2. ✅ Create `.env.local` file in root with API URL
3. ✅ Start backend: `cd backend && python main.py`
4. ✅ Start frontend: `pnpm dev`
5. ✅ Test at `http://localhost:3000`
6. ✅ Test network access using your IP address
7. ✅ See [CROSS_DEVICE_SETUP.md](CROSS_DEVICE_SETUP.md) for network access instructions

---

## Security Notes

⚠️ **Important for Production**:
1. Never commit `.env` files to Git
2. Use strong `JWT_SECRET` (minimum 32 characters)
3. Restrict CORS origins to specific domains
4. Use HTTPS in production
5. Rotate keys regularly
6. Use environment secrets management (GitHub Secrets, AWS Secrets Manager, etc.)

For local development, the provided defaults are acceptable.
