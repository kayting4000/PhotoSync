"""
Simple Gmail SMTP connection test.
Verifies credentials are correct before sending emails.
"""
import os
import smtplib
from dotenv import load_dotenv

load_dotenv()

GMAIL_USER = os.getenv("GMAIL_USER")
GMAIL_PASSWORD = os.getenv("GMAIL_PASSWORD")
GMAIL_SMTP_SERVER = "smtp.gmail.com"
GMAIL_SMTP_PORT = 587

print("=" * 60)
print("[TEST] Gmail SMTP Connection Test")
print("=" * 60)
print(f"\nGmail User: {GMAIL_USER}")
print(f"Gmail Password: {'*' * len(GMAIL_PASSWORD)}")

try:
    print("\n[CONNECTING] Connecting to Gmail SMTP server...")
    with smtplib.SMTP(GMAIL_SMTP_SERVER, GMAIL_SMTP_PORT) as server:
        print("[SUCCESS] Connected to SMTP server")
        
        print("[UPGRADING] Upgrading to TLS...")
        server.starttls()
        print("[SUCCESS] TLS upgrade successful")
        
        print("[AUTHENTICATING] Authenticating with credentials...")
        server.login(GMAIL_USER, GMAIL_PASSWORD)
        print("[SUCCESS] Authentication successful!")
        
        print("\n" + "=" * 60)
        print("[RESULT] Gmail credentials are VALID and working!")
        print("=" * 60)
        
except smtplib.SMTPAuthenticationError as e:
    print(f"\n[ERROR] Authentication failed: {str(e)}")
    print("\nPossible solutions:")
    print("1. Check if app password is correct (16 characters)")
    print("2. Verify 2-Factor Authentication is enabled")
    print("3. Regenerate app password at https://myaccount.google.com/apppasswords")
    print("4. Make sure you're using app password, not regular password")
    
except smtplib.SMTPException as e:
    print(f"\n[ERROR] SMTP error: {str(e)}")
    
except Exception as e:
    print(f"\n[ERROR] Connection failed: {str(e)}")
