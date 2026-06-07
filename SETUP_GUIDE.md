# Quick Setup Guide for PhotoSync

## 1. Environment Configuration (CRITICAL)

### Backend Setup

1. Navigate to the backend directory:
```bash
cd backend
```

2. Copy the example environment file:
```bash
cp .env.example .env
```

3. Edit `.env` and fill in the required values:
```
DATABASE_URL=postgresql://user:password@localhost:5432/photosync
JWT_SECRET=your-secret-key-min-32-chars-recommended
ROBOFLOW_API_KEY=your-roboflow-key
ROBOFLOW_WORKSPACE=your-workspace
ROBOFLOW_WORKFLOW_ID=your-workflow-id
RESEND_API_KEY=re_your_api_key  # Optional - for email
```

### Frontend Setup

1. In the root directory, copy the example:
```bash
cp .env.local.example .env.local
```

2. Edit `.env.local`:
```
NEXT_PUBLIC_API_URL=http://localhost:8000
```

For network access from another device:
```
NEXT_PUBLIC_API_URL=http://YOUR_IP_ADDRESS:8000
```

## 2. Database Setup

- Use Neon PostgreSQL or local PostgreSQL
- The backend will auto-create tables on startup
- Ensure `DATABASE_URL` points to a valid database

## 3. Running the Application

### Backend
```bash
cd backend
python -m uvicorn main:app --host 127.0.0.1 --port 8000
```

### Frontend
```bash
pnpm dev
```

## 4. Testing

1. Go to `http://localhost:3000`
2. Create an account
3. Test features:
   - Add students and sections
   - Create exams and subjects
   - Upload scan (requires Roboflow setup)
   - Send grade reports (requires RESEND_API_KEY)

## 5. Troubleshooting

### Backend won't start
- Check DATABASE_URL is valid
- Verify Python virtual environment is activated
- Ensure all required packages are installed: `pip install -r requirements.txt`

### API calls fail with 404
- Check `NEXT_PUBLIC_API_URL` in `.env.local`
- Ensure backend is running on the configured port
- Check CORS is enabled (should be by default)

### Email won't send
- Set `RESEND_API_KEY` in `.env` 
- Without it, sending will fail with a clear error message
- Visit https://resend.com to get an API key

### Scanner not working
- Verify `ROBOFLOW_API_KEY`, `ROBOFLOW_WORKSPACE`, and `ROBOFLOW_WORKFLOW_ID` are set
- Use images at least 100x100 pixels
- Check Roboflow project is properly configured

## 6. Issues Fixed

- ✅ Problem #1: Missing environment variables (now has .env.example)
- ✅ Problem #5: Scanner error handling (now validates image size)
- ✅ Problem #7: Email silent failures (now shows clear errors)
- ✅ Problem #11: No .env.example files (now provided)

## 7. Next Steps

1. Configure environment files
2. Start the backend
3. Start the frontend
4. Create test data
5. Run through TESTING_GUIDE.md

See [BUG_REPORT.md](BUG_REPORT.md) for full list of issues and fixes.
