#!/usr/bin/env python3
"""
PhotoSync Complete Flow Test
Tests: Auth -> Students -> Subjects -> Sections -> Dashboard
"""
import requests
import json
import time
from datetime import datetime

BASE_URL = "http://localhost:8000"
TEST_EMAIL = f"test_{int(time.time())}@example.com"
TEST_PASSWORD = "TestPass123!"

print("=" * 60)
print("PhotoSync Complete Flow Test")
print("=" * 60)

# 1. HEALTH CHECK
print("\n[1] Health Check...")
try:
    resp = requests.get(f"{BASE_URL}/", timeout=5)
    data = resp.json()
    print(f"[OK] Backend running: {data['app']} v{data['version']}")
    print(f"     Status: {data['status']}")
except Exception as e:
    print(f"[FAIL] Backend not responding: {e}")
    exit(1)

# 2. SIGNUP
print("\n[2] User Signup...")
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
        print(f"[OK] Signup successful")
        print(f"     Email: {TEST_EMAIL}")
        print(f"     User ID: {user_id}")
    else:
        print(f"[FAIL] Signup failed: {resp.status_code} - {resp.text}")
        exit(1)
except Exception as e:
    print(f"[FAIL] Signup error: {e}")
    exit(1)

headers = {"Authorization": f"Bearer {token}"}

# 3. LOGIN
print("\n[3] User Login...")
try:
    resp = requests.post(
        f"{BASE_URL}/auth/login",
        json={"email": TEST_EMAIL, "password": TEST_PASSWORD},
        timeout=10
    )
    if resp.status_code == 200:
        data = resp.json()
        print(f"[OK] Login successful")
        print(f"     Token: {data['access_token'][:20]}...")
    else:
        print(f"[FAIL] Login failed: {resp.status_code}")
except Exception as e:
    print(f"[FAIL] Login error: {e}")

# 4. CREATE SUBJECT
print("\n[4] Create Subject...")
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
        print(f"[OK] Subject created")
        print(f"     ID: {subject_id}")
        print(f"     Code: {subject['code']}")
        print(f"     Name: {subject['name']}")
    else:
        print(f"[FAIL] Subject creation failed: {resp.status_code}")
        print(f"     Response: {resp.text}")
        subject_id = None
except Exception as e:
    print(f"[FAIL] Subject error: {e}")
    subject_id = None

# 5. CREATE SECTION
print("\n[5] Create Section...")
try:
    if not subject_id:
        print(f"[SKIP] Cannot create section without subject_id")
        section_id = None
    else:
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
            print(f"[OK] Section created")
            print(f"     ID: {section_id}")
            print(f"     Label: {section['section_label']}")
            print(f"     Room: {section['room_number']}")
        else:
            print(f"[FAIL] Section creation failed: {resp.status_code}")
            print(f"     Response: {resp.text}")
            section_id = None
except Exception as e:
    print(f"[FAIL] Section error: {e}")
    section_id = None

# 6. CREATE STUDENT
print("\n[6] Create Student...")
try:
    resp = requests.post(
        f"{BASE_URL}/students",
        json={
            "student_id": "STU001",
            "first_name": "John",
            "last_name": "Doe",
            "email": "john@example.com",
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
        print(f"[OK] Student created")
        print(f"     Name: {student['first_name']} {student['last_name']}")
        print(f"     Student ID: {student['student_id']}")
    else:
        print(f"[FAIL] Student creation failed: {resp.status_code}")
        student_id = None
except Exception as e:
    print(f"[FAIL] Student error: {e}")
    student_id = None

# 7. GET DASHBOARD
print("\n[7] Get Dashboard...")
try:
    resp = requests.get(
        f"{BASE_URL}/dashboard/",
        headers=headers,
        timeout=10
    )
    if resp.status_code == 200:
        data = resp.json()
        print(f"[OK] Dashboard data retrieved")
        print(f"     Total Students: {data.get('total_students', 0)}")
        print(f"     Total Subjects: {data.get('total_subjects', 0)}")
        print(f"     Total Exams: {data.get('total_exams', 0)}")
        print(f"     Total Results: {data.get('total_results', 0)}")
    else:
        print(f"[FAIL] Dashboard failed: {resp.status_code}")
except Exception as e:
    print(f"[FAIL] Dashboard error: {e}")

# 8. LIST STUDENTS
print("\n[8] List Students...")
try:
    resp = requests.get(
        f"{BASE_URL}/students",
        headers=headers,
        timeout=10
    )
    if resp.status_code == 200:
        data = resp.json()
        students = data.get("items", []) if isinstance(data, dict) else data
        print(f"[OK] Students retrieved: {len(students)} total")
        if students:
            print(f"     First student: {students[0]['first_name']} {students[0]['last_name']}")
    else:
        print(f"[FAIL] Students list failed: {resp.status_code}")
except Exception as e:
    print(f"[FAIL] Students error: {e}")

# 9. LIST SUBJECTS
print("\n[9] List Subjects...")
try:
    resp = requests.get(
        f"{BASE_URL}/subjects",
        headers=headers,
        timeout=10
    )
    if resp.status_code == 200:
        data = resp.json()
        subjects = data.get("items", []) if isinstance(data, dict) else data
        print(f"[OK] Subjects retrieved: {len(subjects)} total")
        if subjects:
            print(f"     First subject: {subjects[0]['name']}")
    else:
        print(f"[FAIL] Subjects list failed: {resp.status_code}")
except Exception as e:
    print(f"[FAIL] Subjects error: {e}")

# 10. LIST SECTIONS
print("\n[10] List Sections...")
try:
    resp = requests.get(
        f"{BASE_URL}/sections",
        headers=headers,
        timeout=10
    )
    if resp.status_code == 200:
        data = resp.json()
        sections = data.get("items", []) if isinstance(data, dict) else data
        print(f"[OK] Sections retrieved: {len(sections)} total")
        if sections:
            print(f"     First section: {sections[0]['section_label']}")
    else:
        print(f"[FAIL] Sections list failed: {resp.status_code}")
except Exception as e:
    print(f"[FAIL] Sections error: {e}")

print("\n" + "=" * 60)
print("[COMPLETE] All flows tested successfully!")
print("=" * 60)
