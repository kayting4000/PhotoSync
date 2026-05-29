"use client"

import { useEffect, useState } from "react"
import { apiClient } from "@/lib/api-client"
import { EmailManager } from "@/components/email/email-manager"
import type { Student, ExamResult, Subject, Exam } from "@/lib/types"

export default function EmailPage() {
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

      const exRes = await apiClient<{ items: Exam[] }>("/exams/")
      const examMap = new Map(
        exRes.items.map((e) => [e.id, { ...e, subject: subjectMap.get(e.subject_id) }]),
      )

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
        <h1 className="text-3xl font-bold tracking-tight">Email Results</h1>
        <p className="text-muted-foreground">
          Send exam results and grade reports to students via email
        </p>
      </div>

      {loading ? (
        <p className="text-muted-foreground">Loading…</p>
      ) : (
        <EmailManager
          students={students}
          results={results}
          subjects={subjects}
        />
      )}
    </div>
  )
}