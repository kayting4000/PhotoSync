# EduScan Backend — 5-Minute Presentation Script

---

Good morning/afternoon, everyone. Today I'm presenting EduScan — a Test Paper Scanner and Grade Management System for MSU-Tawi-Tawi.

Here's the problem: professors currently compute grades manually using spreadsheets. It's slow, it's error-prone, and it doesn't scale when you have multiple subjects and hundreds of students.

Our solution is a FastAPI backend that automates everything — student management, exam tracking, grade computation, and GPA calculation — all following the official MSU grading scale.

---

Let me walk you through our tech stack.

For our framework, we chose FastAPI. It gives us automatic Swagger documentation, async support for handling many requests at once, and built-in validation through Pydantic — all with zero extra code.

For the database, we use Supabase — a managed PostgreSQL service with a free tier. It gives us a REST API on top of Postgres, plus built-in authentication and Row Level Security. We never write raw SQL — our backend just makes clean HTTP requests to Supabase.

For validation, we use Pydantic v2 — every request body is type-checked automatically. If a field is missing or the wrong type, the API rejects it with a clear error message. We don't write any validation code manually.

And we run everything on Uvicorn, a fast ASGI server with hot-reload for development.

---

Now let me show you our MVC architecture. This is the folder structure:

The Models folder defines our four database tables using SQLAlchemy ORM — students, subjects, exams, and exam_results. Each model has all columns documented, including foreign keys connecting the tables.

The Schemas folder holds all our Pydantic models — these define what data comes in and goes out of the API. For each entity we have a Create schema with required fields, and an Update schema where all fields are optional so you only send what you want to change. Our auth schemas use EmailStr for automatic email validation.

The Controllers folder has seven route handler files. Auth handles signup and login through Supabase Auth. Students, Subjects, Exams, and Results each have full CRUD — that's GET, POST, PUT, and DELETE on all four entities. The Results controller also contains our automatic grade assignment logic using the MSU scale. Grades handles weighted GPA computation. And Dashboard returns aggregate statistics.

Here's how a request flows through the system. A client sends a POST to slash results with a percentage of 85. Pydantic validates the request body. The controller calls our grading function, which maps 85 percent to a grade of 1.75 with a grade point of 1.75 and remarks "Passed". The response comes back with the grade, grade point, and remarks all auto-filled. The user never computes anything manually.

---

Let me switch to the live Swagger UI to demonstrate.

First, here's GET slash students — I click Execute, and we see all students in the database. Now let me show a full CRUD cycle. POST slash students — I fill in the form with a test student, click Execute, and we get a 200 response with the created student including its UUID. PUT slash students with that ID — I update the year level, Execute, and it's updated. DELETE slash students — Execute, and we get "Student deleted". Full Create, Read, Update, Delete on one entity.

Now let me show the auto-grade feature. POST slash results — I enter a student ID, exam ID, 40 correct answers, total score of 85, and percentage of 85. When I execute, look at the response — it automatically includes grade 1.75, grade point 1.75, and remarks "Passed". We never typed those. The MSU grading scale was applied automatically by the backend.

Next, GPA computation. GET slash gpa — I enter a student ID, and the response shows the weighted GPA. For example, GPA of 1.625 across 8 units with interpretation "Very Good". The formula is sum of grade point times units, divided by total units.

And finally, scroll through the full API — 19 endpoints total, all documented, all interactive. You don't need Postman. You don't need curl. Everything is testable right here in the browser.

---

Here's the MSU grading scale we implemented. 96 to 100 gets a 1.0, 92 to 95 gets 1.25, down to 60 to 67 getting 3.0, and below 60 gets a 5.0 which is Failed.

The GPA formula is simple — sum of grade point multiplied by units, divided by total units. For example, if a student has Math at 3 units with a grade point of 1.5, English at 3 units with 2.0, and PE at 2 units with 1.25 — that's 13.0 weighted points divided by 8 total units, giving a GPA of 1.625, which is interpreted as "Very Good".

---

To wrap up — all Milestone 2 requirements are met. We have the FastAPI framework, strict MVC architecture with models, schemas, and controllers separated, full CRUD on all four primary entities, Pydantic input validation with EmailStr, error handling with HTTPException on every route, Supabase PostgreSQL database connection, automatic Swagger UI documentation at slash docs, a complete test script that verifies all 19 endpoints, and a README with setup instructions.

Here's what the test script output looks like — all endpoints pass with 200 status codes.

The GitHub repository is at github.com slash kayting4000 slash EduScan. The live API is running now at localhost port 8000 with Swagger docs at slash docs.

Thank you. I'm happy to answer any questions or demonstrate any specific endpoint.