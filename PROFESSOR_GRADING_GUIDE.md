# Professor-Friendly Grading System Guide

## Overview

The updated PhotoSync system now supports a weighted term-based grading system that professors understand:

- **Sections** = Rooms (where classes are held)
- **Terms** = Preliminary, Mid-Semester, Final (with adjustable weights)
- **Components** = Exam, Quiz, Assignment, Oral Recitations
- **Final Grade** = Weighted average of all terms

## Key Features

### 1. Sections (Rooms Only)

Instead of complex course/year information, sections now simply represent **room numbers**:

**Examples:**
- Room 101
- Room 202
- Lab A
- Computer Lab 1

**Setup:**
- Go to Sections in the dashboard
- Click "Add Room"
- Enter room number (e.g., "Room 101")
- Save

### 2. Academic Terms with Weights

Each term has:
- **Name**: Term identifier
- **Term Type**: Preliminary, Mid-Semester, or Final
- **Percentage Weight**: How much this term contributes to final grade (10-90%)
- **Dates**: Start and end dates for the term

**Example Configuration:**
```
Preliminary Term
- Type: preliminary
- Weight: 30%
- Jan 15 - Feb 28

Mid-Semester Term
- Type: mid-semester
- Weight: 35%
- Mar 1 - Apr 15

Final Term
- Type: final
- Weight: 35% (optional)
- May 1 - Jun 15
```

**Important:**
- Total weight of all terms should ideally = 100%
- Final term is optional for professors who don't use it
- Each professor can adjust weights according to their grading policy

### 3. Assessment Components

For each term, you can create assessments of four types:

1. **Exam** (e.g., "Midterm Exam", "Final Exam")
2. **Quiz** (e.g., "Quiz 1", "Pop Quiz")
3. **Assignment** (e.g., "Project 1", "Homework 2")
4. **Oral** (e.g., "Class Presentation", "Recitation")

**Example for Preliminary Term:**
- Exam: Preliminary Exam (50 points)
- Quiz: Quiz 1 (20 points)
- Assignment: Project 1 (30 points)
- Oral: Presentation (10 points)

### 4. Calculating Final Grade

The system automatically calculates the final grade:

**Formula:**
```
Final Grade = (Preliminary Average × 0.30) 
            + (Mid-Semester Average × 0.35) 
            + (Final Average × 0.35)
```

**Example Calculation:**
```
Preliminary Score: 85%
Mid-Semester Score: 88%
Final Score: 90%

Final Grade = (85 × 0.30) + (88 × 0.35) + (90 × 0.35)
           = 25.5 + 30.8 + 31.5
           = 87.8%
```

## Workflow

### 1. Initial Setup

1. **Create Rooms** (Sections)
   - Go to Sections
   - Add each room where you teach
   - Example: Room 101, Room 102, Lab A

2. **Create Terms**
   - Go to Academic Terms
   - Create Preliminary Term (set weight, e.g., 30%)
   - Create Mid-Semester Term (set weight, e.g., 35%)
   - Create Final Term (set weight, e.g., 35%, optional)

### 2. During Each Term

1. **Create Assessments**
   - For each term, create exams, quizzes, assignments, presentations
   - Specify component type (exam/quiz/assignment/oral)
   - Set total points/items for each

2. **Upload Results**
   - Use the scanner or manual entry to record scores
   - System calculates percentage automatically
   - Multiple components per term are averaged

3. **View Grades**
   - Grades screen shows:
     - Individual component scores
     - Term average (all components combined)
     - Final weighted grade

## API Endpoints

### Create Academic Term

```bash
POST /academic-terms/
{
  "name": "Preliminary Term",
  "term_type": "preliminary",
  "percentage_weight": 30,
  "start_date": "2026-01-15",
  "end_date": "2026-02-28",
  "is_current": true
}
```

### Create Exam (Component)

```bash
POST /exams/
{
  "subject_id": "uuid-of-subject",
  "name": "Preliminary Exam",
  "component_type": "exam",
  "total_items": 50,
  "points_per_item": 2.0,
  "term_id": "uuid-of-term"
}
```

### Get Weighted Term Grades

```bash
GET /gpa/weighted/?student_id=uuid&subject_id=uuid
```

**Response:**
```json
{
  "final_grade": 87.8,
  "term_scores": {
    "term-id-1": {
      "term_name": "Preliminary Term",
      "term_type": "preliminary",
      "percentage_weight": 30,
      "average_score": 85,
      "scores": [85, 84, 86]
    },
    "term-id-2": {
      "term_name": "Mid-Semester Term",
      "term_type": "mid-semester",
      "percentage_weight": 35,
      "average_score": 88,
      "scores": [87, 88, 89]
    }
  },
  "total_weight": 100,
  "calculation_method": "weighted_average"
}
```

## Database Schema Changes

### Sections Table
```sql
CREATE TABLE sections (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  name VARCHAR NOT NULL,  -- Room number
  created_at TIMESTAMP
);
```

### Academic Terms Table
```sql
CREATE TABLE academic_terms (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  name VARCHAR NOT NULL,
  term_type VARCHAR NOT NULL,  -- 'preliminary', 'mid-semester', 'final'
  percentage_weight INTEGER DEFAULT 33,  -- 10-90
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  is_current BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP
);
```

### Exams Table (Updated)
```sql
CREATE TABLE exams (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  subject_id UUID REFERENCES subjects(id),
  term_id UUID REFERENCES academic_terms(id),
  name VARCHAR NOT NULL,
  component_type VARCHAR NOT NULL,  -- 'exam', 'quiz', 'assignment', 'oral'
  total_items INTEGER NOT NULL,
  points_per_item FLOAT DEFAULT 1.0,
  passing_score FLOAT,
  created_at TIMESTAMP
);
```

## Migration From Old System

If you have existing data:

1. **Sections**: Remove course and year_level, keep only room number in name
2. **Terms**: Add term_type and percentage_weight
   - Existing terms default to 33% weight
   - Manually assign term_type and percentages
3. **Exams**: Rename exam_type to component_type
   - Map old types to: exam, quiz, assignment, oral

**Migration SQL (Example):**
```sql
-- Update sections to remove unnecessary fields
ALTER TABLE sections DROP COLUMN IF EXISTS course;
ALTER TABLE sections DROP COLUMN IF EXISTS year_level;

-- Add new columns to academic_terms
ALTER TABLE academic_terms 
  ADD COLUMN term_type VARCHAR DEFAULT 'preliminary',
  ADD COLUMN percentage_weight INTEGER DEFAULT 33;

-- Rename exam_type to component_type
ALTER TABLE exams 
  RENAME COLUMN exam_type TO component_type;
```

## Grading Best Practices

1. **Weight Distribution**
   - Preliminary: 20-40%
   - Mid-Semester: 30-40%
   - Final: 20-40%
   - Total should = 100%

2. **Component Types**
   - Use all four types: Exam, Quiz, Assignment, Oral
   - Provides holistic student assessment
   - Allows flexibility for different teaching styles

3. **Percentage Weights**
   - Adjust based on your teaching philosophy
   - Example 1: Equal weight (33-33-34%)
   - Example 2: Progressive (20-30-50%)
   - Example 3: Final-heavy (30-30-40%)

4. **Regular Updates**
   - Enter grades after each assessment
   - View progress in real-time
   - Adjust weights mid-semester if needed

## Troubleshooting

**Q: Can I change term weights after I've created them?**
A: Yes, you can edit the term and adjust the percentage_weight. The system will recalculate immediately.

**Q: Do I have to use all three terms?**
A: No, you can use just Preliminary and Mid-Semester, or any combination. The system calculates based on available terms and their weights.

**Q: What if my weights don't add up to 100%?**
A: The system will still calculate, but results may not be accurate. Aim for total weight = 100%.

**Q: Can students see their term breakdown?**
A: Yes, they can see individual components, term averages, and the final weighted grade.

**Q: How do I weight different components (exam vs quiz) within a term?**
A: Each component (exam, quiz, assignment, oral) is currently weighted equally within a term. If you want different weights, you can create multiple instances with different point values.

## Example Grading Policy

**Professor Smith's IT Course:**

**Terms:**
- Preliminary Term (30%): Week 1-7
  - Exam: 1 × 50 points
  - Quizzes: 3 × 10 points each
  - Assignments: 2 × 20 points each

- Mid-Semester Term (35%): Week 8-14
  - Exam: 1 × 50 points
  - Project: 1 × 50 points

- Final Term (35%): Week 15-18
  - Final Exam: 1 × 100 points
  - Final Project: 1 × 50 points

**Calculation Example:**
- Preliminary Average: 82% → 82 × 0.30 = 24.6
- Mid-Semester Average: 88% → 88 × 0.35 = 30.8
- Final Average: 85% → 85 × 0.35 = 29.75
- **Final Grade: 85.15%**

---

For more help, see the main README.md or contact support.
