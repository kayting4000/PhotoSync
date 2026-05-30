"""
Send Grades to Student Script
==============================
Sends all exam grades for a specific student to their email address.

Usage:
  cd backend
  python send_student_grades.py --email kayting4k@gmail.com --token <YOUR_JWT_TOKEN>

Or without token (will prompt for login):
  python send_student_grades.py --email kayting4k@gmail.com
"""

import os
import sys
import argparse
import httpx
import json
from datetime import datetime

API_BASE = os.environ.get("API_BASE", "http://localhost:8000")

def send_grades_to_student(student_email: str, token: str) -> dict:
    """Send all grades for a student to their email."""
    
    if not token:
        print("❌ Error: Authentication token required")
        print("\nTo get a token:")
        print("1. Sign in on the app at http://localhost:3000")
        print("2. Open browser DevTools (F12)")
        print("3. Go to Application → Local Storage")
        print("4. Find 'access_token' and copy its value")
        print("5. Run: python send_student_grades.py --email kayting4k@gmail.com --token <YOUR_TOKEN>")
        sys.exit(1)
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }
    
    print(f"\n📧 Sending grades to: {student_email}")
    print(f"🔐 Using API: {API_BASE}")
    print("-" * 60)
    
    try:
        # Call the new endpoint
        response = httpx.get(
            f"{API_BASE}/email/send-grades-to-student/{student_email}",
            headers=headers,
            timeout=30.0,
            trust_env=False,
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Success!")
            print(f"   Student: {result.get('student_email')}")
            print(f"   Emails sent: {result.get('total')}")
            for email_info in result.get('emails_sent', []):
                print(f"   - {email_info.get('subject')}: {email_info.get('message')}")
            return result
        
        elif response.status_code == 404:
            print(f"❌ Student not found: {student_email}")
            error = response.json()
            print(f"   Error: {error.get('detail', 'Unknown error')}")
            return {"success": False, "error": "Student not found"}
        
        elif response.status_code == 503:
            print(f"⚠️  Email service not configured")
            error = response.json()
            print(f"   Error: {error.get('detail', 'Unknown error')}")
            print("\n   To fix:")
            print("   1. Get a Resend API key from https://resend.com")
            print("   2. Add to backend/.env:")
            print("      RESEND_API_KEY=re_your_key_here")
            print("      RESEND_FROM_EMAIL=noreply@yourdomain.com")
            print("   3. Restart the backend")
            return {"success": False, "error": "Email service not configured"}
        
        else:
            print(f"❌ Error: {response.status_code}")
            print(f"   Response: {response.text}")
            return {"success": False, "error": f"HTTP {response.status_code}"}
    
    except httpx.ConnectError:
        print(f"❌ Cannot connect to backend at {API_BASE}")
        print("   Make sure the backend is running:")
        print("   cd backend && uvicorn main:app --reload")
        return {"success": False, "error": "Cannot connect to backend"}
    
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return {"success": False, "error": str(e)}


def main():
    parser = argparse.ArgumentParser(
        description="Send exam grades to a student's email"
    )
    parser.add_argument(
        "--email",
        required=True,
        help="Student email address"
    )
    parser.add_argument(
        "--token",
        help="JWT authentication token (from localStorage)"
    )
    parser.add_argument(
        "--api",
        default=API_BASE,
        help=f"API base URL (default: {API_BASE})"
    )
    
    args = parser.parse_args()
    
    # Update global API_BASE
    globals()["API_BASE"] = args.api
    
    print(f"""
╔═════════════════════════════════════════════════════════╗
║         PhotoSync - Send Student Grades Script          ║
║                  {datetime.now().strftime('%Y-%m-%d %H:%M')}                        ║
╚═════════════════════════════════════════════════════════╝
""")
    
    result = send_grades_to_student(args.email, args.token)
    
    print("-" * 60)
    if result.get("success"):
        print("✅ All grades sent successfully!")
    else:
        print(f"❌ Failed: {result.get('error')}")
        sys.exit(1)


if __name__ == "__main__":
    main()
