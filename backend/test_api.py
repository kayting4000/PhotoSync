"""
test_api.py — Smoke tests for EduScan API endpoints.
Run: python test_api.py
Requires the server to be running at http://localhost:8000
"""

import httpx

BASE = "http://localhost:8000"
PASS = "\033[92m✓\033[0m"
FAIL = "\033[91m✗\033[0m"

_created = {}


def check(label: str, res: httpx.Response, expected: int):
    ok = res.status_code == expected
    print(f"  {PASS if ok else FAIL} {label} [{res.status_code}]")
    if not ok:
        print(f"    → {res.text[:200]}")
    return ok


def run():
    print("\n=== EduScan API Tests ===\n")

    # Health
    print("[Health]")
    check("GET /", httpx.get(f"{BASE}/"), 200)

    # Students CRUD
    print("\n[Students]")
    r = httpx.post(f"{BASE}/students/", json={
        "student_id": "TEST-001", "first_name": "Jane", "last_name": "Doe",
        "course": "BSCS", "year_level": 2, "email": "jane@test.com"
    })
    if check("POST /students/", r, 200):
        sid = r.json()["id"]
        _created["student_id"] = sid
        check("GET  /students/", httpx.get(f"{BASE}/students/"), 200)
        check("PUT  /students/{id}", httpx.put(f"{BASE}/students/{sid}",
              json={"year_level": 3}), 200)

    # Subjects CRUD
    print("\n[Subjects]")
    r = httpx.post(f"{BASE}/subjects/", json={"code": "CS101", "name": "Intro to CS", "units": 3})
    if check("POST /subjects/", r, 200):
        subj_id = r.json()["id"]
        _created["subject_id"] = subj_id
        check("GET  /subjects/", httpx.get(f"{BASE}/subjects/"), 200)
        check("PUT  /subjects/{id}", httpx.put(f"{BASE}/subjects/{subj_id}",
              json={"units": 4}), 200)

    # Exams CRUD
    print("\n[Exams]")
    if "subject_id" in _created:
        r = httpx.post(f"{BASE}/exams/", json={
            "subject_id": _created["subject_id"], "name": "Midterm",
            "exam_type": "written", "total_items": 50, "points_per_item": 2.0
        })
        if check("POST /exams/", r, 200):
            _created["exam_id"] = r.json()["id"]
            check("GET  /exams/", httpx.get(f"{BASE}/exams/"), 200)

    # Results CRUD
    print("\n[Results]")
    if "student_id" in _created and "exam_id" in _created:
        r = httpx.post(f"{BASE}/results/", json={
            "student_id": _created["student_id"], "exam_id": _created["exam_id"],
            "correct_answers": 40, "total_score": 80.0, "percentage": 80.0
        })
        if check("POST /results/", r, 200):
            _created["result_id"] = r.json()["id"]
            check("GET  /results/", httpx.get(f"{BASE}/results/"), 200)

    # Dashboard & GPA
    print("\n[Dashboard & GPA]")
    check("GET /dashboard/", httpx.get(f"{BASE}/dashboard/"), 200)
    check("GET /gpa/",       httpx.get(f"{BASE}/gpa/"), 200)

    # Cleanup (delete in reverse order)
    print("\n[Cleanup]")
    if "result_id"  in _created: check("DELETE /results/{id}",  httpx.delete(f"{BASE}/results/{_created['result_id']}"),  200)
    if "exam_id"    in _created: check("DELETE /exams/{id}",    httpx.delete(f"{BASE}/exams/{_created['exam_id']}"),      200)
    if "subject_id" in _created: check("DELETE /subjects/{id}", httpx.delete(f"{BASE}/subjects/{_created['subject_id']}"), 200)
    if "student_id" in _created: check("DELETE /students/{id}", httpx.delete(f"{BASE}/students/{_created['student_id']}"), 200)

    print("\n=== Done ===\n")


if __name__ == "__main__":
    run()
