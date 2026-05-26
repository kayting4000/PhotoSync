"""
test_api.py — Smoke tests for PhotoSync API endpoints.
Run: python test_api.py
Requires the server to be running at http://localhost:8000
"""

import httpx
import uuid

BASE = "http://localhost:8000"
PASS = "\033[92m✓\033[0m"
FAIL = "\033[91m✗\033[0m"
HTTPX_OPTIONS = {"trust_env": False, "timeout": 10.0}

_created = {}
_token = None

def auth_headers():
    return {
        "Authorization": f"Bearer {_token}",
        "Content-Type": "application/json",
    }


def post_auth(path: str, json_data: dict):
    return httpx.post(f"{BASE}{path}", json=json_data, headers=auth_headers(), **HTTPX_OPTIONS)


def get_auth(path: str):
    return httpx.get(f"{BASE}{path}", headers=auth_headers(), **HTTPX_OPTIONS)


def put_auth(path: str, json_data: dict):
    return httpx.put(f"{BASE}{path}", json=json_data, headers=auth_headers(), **HTTPX_OPTIONS)


def delete_auth(path: str):
    return httpx.delete(f"{BASE}{path}", headers=auth_headers(), **HTTPX_OPTIONS)


def check(label: str, res: httpx.Response, expected: int):
    ok = res.status_code == expected
    print(f"  {PASS if ok else FAIL} {label} [{res.status_code}]")
    if not ok:
        print(f"    → {res.text[:200]}")
    return ok


def run():
    global _token
    print("\n=== PhotoSync API Tests ===\n")

    # Auth
    print("[Auth]")
    test_email = f"api_test_{uuid.uuid4().hex[:8]}@example.com"
    signup_response = httpx.post(f"{BASE}/auth/signup", json={
        "email": test_email,
        "password": "TestPassword123!",
    }, **HTTPX_OPTIONS)
    if not check("POST /auth/signup", signup_response, 200):
        return
    data = signup_response.json()
    _token = data["access_token"]
    _created["user_email"] = test_email

    # Health
    print("[Health]")
    check("GET /", httpx.get(f"{BASE}/", **HTTPX_OPTIONS), 200)

    # Students CRUD
    print("\n[Students]")
    r = post_auth("/students/", {
        "student_id": "TEST-001", "first_name": "Jane", "last_name": "Doe",
        "course": "BSCS", "year_level": 2, "email": "jane@test.com"
    })
    if check("POST /students/", r, 200):
        sid = r.json()["id"]
        _created["student_id"] = sid
        check("GET  /students/", get_auth("/students/"), 200)
        check("PUT  /students/{id}", put_auth(f"/students/{sid}",
              {"year_level": 3}), 200)

    # Subjects CRUD
    print("\n[Subjects]")
    r = post_auth("/subjects/", {"code": "CS101", "name": "Intro to CS", "units": 3})
    if check("POST /subjects/", r, 200):
        subj_id = r.json()["id"]
        _created["subject_id"] = subj_id
        check("GET  /subjects/", get_auth("/subjects/"), 200)
        check("PUT  /subjects/{id}", put_auth(f"/subjects/{subj_id}", {"units": 4}), 200)

    # Exams CRUD
    print("\n[Exams]")
    if "subject_id" in _created:
        r = post_auth("/exams/", {
            "subject_id": _created["subject_id"], "name": "Midterm",
            "exam_type": "written", "component_type": "exam",
            "total_items": 50, "points_per_item": 2.0
        })
        if check("POST /exams/", r, 200):
            _created["exam_id"] = r.json()["id"]
            check("GET  /exams/", get_auth("/exams/"), 200)
            check("PUT  /exams/{id}", put_auth(f"/exams/{_created['exam_id']}",
                  {"name": "Final Exam", "total_items": 60}), 200)

    # Results CRUD
    print("\n[Results]")
    if "student_id" in _created and "exam_id" in _created:
        r = post_auth("/results/", {
            "student_id": _created["student_id"], "exam_id": _created["exam_id"],
            "correct_answers": 40, "total_score": 80.0, "percentage": 80.0
        })
        if check("POST /results/", r, 200):
            _created["result_id"] = r.json()["id"]
            check("GET  /results/", get_auth("/results/"), 200)
            check("PUT  /results/{id}", put_auth(f"/results/{_created['result_id']}",
                  {"correct_answers": 45, "total_score": 90.0, "percentage": 90.0}), 200)

    # Dashboard & GPA
    print("\n[Dashboard & GPA]")
    check("GET /dashboard/", get_auth("/dashboard/"), 200)
    check("GET /gpa/",       get_auth("/gpa/"), 200)

    # Cleanup (delete in reverse order)
    print("\n[Cleanup]")
    if "result_id"  in _created: check("DELETE /results/{id}",  delete_auth(f"/results/{_created['result_id']}"),  200)
    if "exam_id"    in _created: check("DELETE /exams/{id}",    delete_auth(f"/exams/{_created['exam_id']}"),      200)
    if "subject_id" in _created: check("DELETE /subjects/{id}", delete_auth(f"/subjects/{_created['subject_id']}"), 200)
    if "student_id" in _created: check("DELETE /students/{id}", delete_auth(f"/students/{_created['student_id']}"), 200)

    print("\n=== Done ===\n")


if __name__ == "__main__":
    run()
