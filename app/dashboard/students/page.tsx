"use client"

import { useEffect, useState } from "react"
import { apiClient } from "@/lib/api-client"
import { StudentsTable } from "@/components/students/students-table"
import { AddStudentDialog } from "@/components/students/add-student-dialog"
import type { Student } from "@/lib/types"

interface StudentsResponse {
  items: Student[]
  total: number
}

export default function StudentsPage() {
  const [students, setStudents] = useState<Student[]>([])
  const [loading, setLoading] = useState(true)

  const fetchStudents = () => {
    setLoading(true)
    apiClient<StudentsResponse>("/students/")
      .then((res) => setStudents(res.items))
      .catch(() => {})
      .finally(() => setLoading(false))
  }

  useEffect(() => {
    fetchStudents()
  }, [])

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Students</h1>
          <p className="text-muted-foreground">
            Manage student records and information
          </p>
        </div>
        <AddStudentDialog onCreated={fetchStudents} />
      </div>

      {loading ? (
        <p className="text-muted-foreground">Loading students…</p>
      ) : (
        <StudentsTable students={students} onRefresh={fetchStudents} />
      )}
    </div>
  )
}