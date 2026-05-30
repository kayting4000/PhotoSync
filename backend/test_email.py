#!/usr/bin/env python3
"""
PhotoSync Email Sending Test
Tests the email functionality with a real student
"""
import requests
import json
import time

BASE_URL = "http://localhost:8000"
TEST_EMAIL = f"test_{int(time.time())}@example.com"
TEST_PASSWORD = "TestPass123!"

print("=" * 70)
print("PhotoSync Email Sending Test")
print("=" * 70)

# 1. SIGNUP
print("\n[1] Creating test user...")
try:
    resp = requests.post(
        f"{BASE_URL}/auth/signup",
        json={"email": TEST_EMAIL, "password": TEST_PASSWORD},
        timeout=10
    )
    if resp.status_code == 200:
        data = resp.json()
        token = data["access_token"]
        user_id = data["user"]["id"]
        print(f"[OK] User created: {TEST_EMAIL}")
    else:
        print(f"[FAIL] Signup failed: {resp.status_code}")
        exit(1)
except Exception as e:
    print(f"[FAIL] Error: {e}")
    exit(1)

headers = {"Authorization": f"Bearer {token}"}

# 2. CREATE SUBJECT
print("\n[2] Creating subject...")
try:
    resp = requests.post(
        f"{BASE_URL}/subjects",
        json={
            "code": "CS101",
            "name": "Introduction to Computer Science",
            "units": 3
        },
        headers=headers,
        timeout=10
    )
    if resp.status_code == 200:
        subject = resp.json()
        subject_id = subject["id"]
        print(f"[OK] Subject created: {subject['code']}")
    else:
        print(f"[FAIL] Subject creation failed: {resp.status_code}")
        exit(1)
except Exception as e:
    print(f"[FAIL] Error: {e}")
    exit(1)

# 3. CREATE SECTION
print("\n[3] Creating section...")
try:
    resp = requests.post(
        f"{BASE_URL}/sections",
        json={
            "subject_id": subject_id,
            "section_label": "A",
            "room_number": "Room 101"
        },
        headers=headers,
        timeout=10
    )
    if resp.status_code == 200:
        section = resp.json()
        section_id = section["id"]
        print(f"[OK] Section created: {section['section_label']}")
    else:
        print(f"[FAIL] Section creation failed: {resp.status_code}")
        exit(1)
except Exception as e:
    print(f"[FAIL] Error: {e}")
    exit(1)

# 4. CREATE STUDENT WITH EMAIL
print("\n[4] Creating student with email...")
try:
    student_email = "student@example.com"
    resp = requests.post(
        f"{BASE_URL}/students",
        json={
            "student_id": "STU001",
            "first_name": "John",
            "last_name": "Doe",
            "email": student_email,
            "course": "BS Computer Science",
            "year_level": 1,
            "section_id": section_id
        },
        headers=headers,
        timeout=10
    )
    if resp.status_code == 200:
        student = resp.json()
        student_id = student["id"]
        print(f"[OK] Student created: {student['first_name']} {student['last_name']}")
        print(f"     Email: {student_email}")
    else:
        print(f"[FAIL] Student creation failed: {resp.status_code}")
        exit(1)
except Exception as e:
    print(f"[FAIL] Error: {e}")
    exit(1)

# 5. CREATE EXAM
print("\n[5] Creating exam...")
try:
    resp = requests.post(
        f"{BASE_URL}/exams",
        json={
            "subject_id": subject_id,
            "name": "Midterm Exam",
            "component_type": "exam",
            "total_items": 50,
            "points_per_item": 2.0,
            "passing_score": 60.0
        },
        headers=headers,
        timeout=10
    )
    if resp.status_code == 200:
        exam = resp.json()
        exam_id = exam["id"]
        print(f"[OK] Exam created: {exam['name']}")
    else:
        print(f"[FAIL] Exam creation failed: {resp.status_code}")
        print(f"     Response: {resp.text}")
        exam_id = None
except Exception as e:
    print(f"[FAIL] Error: {e}")
    exam_id = None

# 6. CREATE EXAM RESULT
print("\n[6] Creating exam result...")
try:
    if not exam_id:
        print(f"[SKIP] Cannot create result without exam")
    else:
        resp = requests.post(
            f"{BASE_URL}/results",
            json={
                "exam_id": exam_id,
                "student_id": student_id,
                "correct_items": 45,
                "percentage": 90.0,
                "grade": "A",
                "grade_point": 4.0
            },
            headers=headers,
            timeout=10
        )
        if resp.status_code == 200:
            result = resp.json()
            print(f"[OK] Exam result created")
            print(f"     Percentage: {result.get('percentage', 'N/A')}%")
            print(f"     Grade: {result.get('grade', 'N/A')}")
        else:
            print(f"[FAIL] Result creation failed: {resp.status_code}")
            print(f"     Response: {resp.text}")
except Exception as e:
    print(f"[FAIL] Error: {e}")

# 7. SEND GRADE REPORT EMAIL
print("\n[7] Sending grade report email...")
try:
    resp = requests.post(
        f"{BASE_URL}/email/send-grade-report",
        json={
            "student_id": student_id,
            "exam_name": "Midterm Exam",
            "subject_code": "CS101",
            "subject_name": "Introduction to Computer Science",
            "percentage": 90.0,
            "grade": "A",
            "grade_point": 4.0,
            "remarks": "Passed",
            "custom_message": "Excellent performance! Keep up the good work."
        },
        headers=headers,
        timeout=15
    )
    if resp.status_code == 200:
        data = resp.json()
        print(f"[OK] Email sent successfully!")
        print(f"     Message: {data['message']}")
        print(f"     Recipient: {student_email}")
    else:
        print(f"[FAIL] Email sending failed: {resp.status_code}")
        print(f"     Response: {resp.text}")
except Exception as e:
    print(f"[FAIL] Error: {e}")

# 8. SEND GRADE TRANSCRIPT EMAIL
print("\n[8] Sending grade transcript email...")
try:
    resp = requests.post(
        f"{BASE_URL}/email/send-grade-transcript",
        params={
            "student_id": student_id,
            "custom_message": "This is your official grade transcript for the semester."
        },
        headers=headers,
        timeout=15
    )
    if resp.status_code == 200:
        data = resp.json()
        print(f"[OK] Transcript email sent successfully!")
        print(f"     Message: {data['message']}")
        print(f"     GPA: {data.get('gpa', 'N/A')}")
    else:
        print(f"[FAIL] Transcript email sending failed: {resp.status_code}")
        print(f"     Response: {resp.text}")
except Exception as e:
    print(f"[FAIL] Error: {e}")

print("\n" + "=" * 70)
print("[COMPLETE] Email test finished!")
print("=" * 70)
print("\nNote: Check your email inbox for the sent emails.")
print("If emails don't arrive, verify:")
print("  1. GMAIL_USER and GMAIL_PASSWORD are set in backend/.env")
print("  2. Gmail account has 'Less secure app access' enabled")
print("  3. Student email address is correct")
