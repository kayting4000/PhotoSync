"use client"

import { useEffect, useState } from "react"
import { apiClient } from "@/lib/api-client"
import { GradesManager } from "@/components/grades/grades-manager"
import type { Student, ExamResult, Subject, Exam } from "@/lib/types"

export default function GradesPage() {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const [students, setStudents] = useState<any[]>([])
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const [results, setResults] = useState<any[]>([])
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const [subjects, setSubjects] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  const fetchData = async () => {
    setLoading(true)
    try {
      const [sRes, rRes, subRes] = await Promise.all([
        apiClient<{ items: Student[] }>("/students/"),
        apiClient<{ items: ExamResult[] }>("/results/"),
        apiClient<{ items: Subject[] }>("/subjects/"),
      ])

      const studentMap = new Map(sRes.items.map((s) => [s.id, s]))
      const subjectMap = new Map(subRes.items.map((s) => [s.id, s]))

      // Fetch exams so we can build the nested exam object
      const exRes = await apiClient<{ items: Exam[] }>("/exams/")
      const examMap = new Map(
        exRes.items.map((e) => [e.id, { ...e, subject: subjectMap.get(e.subject_id) }]),
      )

      // Join results with student & exam (with subject)
      const joined = rRes.items.map((r) => ({
        ...r,
        student: studentMap.get(r.student_id) ?? null,
        exam: examMap.get(r.exam_id) ?? null,
      }))

      setStudents(sRes.items)
      setResults(joined)
      setSubjects(subRes.items)
    } catch {
      // ignore
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchData()
  }, [])

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Grades & GPA</h1>
        <p className="text-muted-foreground">
          View exam results and calculate student GPA
        </p>
      </div>

      {loading ? (
        <p className="text-muted-foreground">Loading…</p>
      ) : (
        <GradesManager
          students={students}
          results={results}
          subjects={subjects}
        />
      )}
    </div>
  )
}