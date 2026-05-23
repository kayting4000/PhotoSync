"""
Seed Test Data Script for PhotoSync
=====================================
Generates test data: subjects, students, exams, and exam results.

Run:  cd backend && python seed_test_data.py

This will create:
- 3 subjects (e.g., Math, English, Science)
- 5 students with realistic name/email/course data
- 1 exam per subject for 3 semesters (preliminary, midsemester, final)
- Randomized exam results (scores/grades) for each student per exam

All data will be associated with the user you sign in with.
You will be prompted for your auth token after signing in on the app.
"""

import os
import sys
import uuid
import random
import json
from datetime import datetime, timezone

# --- Configuration ---
API_BASE = os.environ.get("API_BASE", "http://localhost:8000")

# Sample data
SUBJECTS = [
    {"code": "MATH101", "name": "Calculus I", "units": 3},
    {"code": "ENG101", "name": "English Composition", "units": 3},
    {"code": "SCI101", "name": "General Science", "units": 4},
]

STUDENTS = [
    {"student_id": "2020-0001", "first_name": "Juan", "last_name": "Dela Cruz", "email": "juan.delacruz@example.com", "course": "BS Computer Science", "year_level": 3},
    {"student_id": "2020-0002", "first_name": "Maria", "last_name": "Santos", "email": "maria.santos@example.com", "course": "BS Information Technology", "year_level": 3},
    {"student_id": "2021-0001", "first_name": "Pedro", "last_name": "Gonzales", "email": "pedro.gonzales@example.com", "course": "BS Computer Science", "year_level": 2},
    {"student_id": "2021-0002", "first_name": "Ana", "last_name": "Reyes", "email": "ana.reyes@example.com", "course": "BS Information Systems", "year_level": 2},
    {"student_id": "2022-0001", "first_name": "Jose", "last_name": "Mendoza", "email": "jose.mendoza@example.com", "course": "BS Computer Science", "year_level": 1},
]

EXAM_TYPES = ["preliminary", "midsemester", "final"]
EXAM_NAMES = {
    "preliminary": "Preliminary Term",
    "midsemester": "Mid-Semester Term",
    "final": "Final Term",
}


def grade_from_percentage(pct):
    """Convert percentage to letter grade and grade point."""
    if pct >= 90:   return "A+", 1.00
    if pct >= 85:   return "A", 1.25
    if pct >= 80:   return "B+", 1.50
    if pct >= 75:   return "B", 2.00
    if pct >= 70:   return "C+", 2.50
    if pct >= 65:   return "C", 3.00
    if pct >= 60:   return "D", 3.50
    return "F", 5.00


def api_call(method, path, data=None, token=None):
    """Simple API call using Python's urllib (no requests dependency)."""
    import urllib.request
    import urllib.error

    url = f"{API_BASE}{path}"
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"

    if data is not None:
        body = json.dumps(data).encode("utf-8")
        req = urllib.request.Request(url, data=body, headers=headers, method=method)
    else:
        req = urllib.request.Request(url, headers=headers, method=method)

    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        print(f"  ⛔ API Error ({e.code}): {e.read().decode('utf-8')}")
        return None
    except urllib.error.URLError as e:
        print(f"  ⛔ Connection Error: {e.reason}")
        print(f"     Is the backend running at {API_BASE}?")
        return None


def main():
    print("=" * 60)
    print("  PhotoSync Test Data Generator")
    print("=" * 60)
    print()
    print(f"  API Base: {API_BASE}")
    print()
    print("  First, sign up / sign in on the app.")
    print("  Then open browser DevTools (F12) → Application → Local Storage")
    print("  and copy your auth_token value.")
    print()

    token = input("  Enter your auth token: ").strip()
    if not token:
        print("  ❌ No token provided. Exiting.")
        sys.exit(1)

    print()
    print("  🚀 Generating test data...")
    print()

    # 1. Create Subjects
    print("  📚 Creating Subjects...")
    subject_ids = {}
    for subj in SUBJECTS:
        result = api_call("POST", "/subjects/", subj, token)
        if result:
            sid = result.get("id")
            subject_ids[subj["code"]] = sid
            print(f"    ✅ {subj['code']}: {subj['name']} ({subj['units']} units) → {sid}")
        else:
            print(f"    ❌ Failed to create subject {subj['code']}")

    if not subject_ids:
        print("  ❌ No subjects created. Check your token and backend.")
        sys.exit(1)

    # 2. Create Exams for each subject
    print()
    print("  📝 Creating Exams (3 semesters per subject)...")
    exam_ids = []
    for subj_code, subj_id in subject_ids.items():
        for exam_type in EXAM_TYPES:
            exam_name = f"{subj_code} - {EXAM_NAMES[exam_type]}"
            total_items = random.choice([20, 30, 40, 50])
            exam_data = {
                "subject_id": subj_id,
                "name": exam_name,
                "exam_type": exam_type,
                "total_items": total_items,
                "points_per_item": 1.0,
                "passing_score": total_items * 0.6,
            }
            result = api_call("POST", "/exams/", exam_data, token)
            if result:
                eid = result.get("id")
                exam_ids.append(eid)
                print(f"    ✅ {exam_name} ({total_items} items)")
            else:
                print(f"    ❌ Failed to create exam {exam_name}")

    if not exam_ids:
        print("  ❌ No exams created.")
        sys.exit(1)

    # 3. Create Students
    print()
    print("  👨‍🎓 Creating Students...")
    student_ids = []
    for stud in STUDENTS:
        result = api_call("POST", "/students/", stud, token)
        if result:
            sid = result.get("id")
            student_ids.append(sid)
            print(f"    ✅ {stud['student_id']}: {stud['first_name']} {stud['last_name']} ({stud['course']})")
        else:
            print(f"    ❌ Failed to create student {stud['student_id']}")

    if not student_ids:
        print("  ❌ No students created.")
        sys.exit(1)

    # 4. Create Exam Results
    print()
    print("  📊 Creating Exam Results (randomized scores)...")
    total_results = 0
    for student_id in student_ids:
        for exam_id in exam_ids:
            # Random score between 40-100
            score = random.randint(40, 100)
            correct_answers = score
            total_score = 100.0
            percentage = float(score)
            grade, grade_point = grade_from_percentage(percentage)

            result = api_call("POST", "/exam-results/", {
                "student_id": student_id,
                "exam_id": exam_id,
                "correct_answers": correct_answers,
                "total_score": total_score,
                "percentage": percentage,
                "grade": grade,
                "grade_point": grade_point,
                "remarks": "Passed" if percentage >= 60 else "Failed",
            }, token)

            if result:
                total_results += 1

    print(f"    ✅ Created {total_results} exam results")
    print()
    print("=" * 60)
    print("  ✅ TEST DATA GENERATION COMPLETE!")
    print(f"     Subjects: {len(subject_ids)}")
    print(f"     Exams: {len(exam_ids)}")
    print(f"     Students: {len(student_ids)}")
    print(f"     Exam Results: {total_results}")
    print()
    print("  📱 Restart the app and you'll see all data!")
    print("=" * 60)


if __name__ == "__main__":
    main()