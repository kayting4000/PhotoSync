import { createClient } from "@/lib/supabase/server"
import { StudentsTable } from "@/components/students/students-table"
import { AddStudentDialog } from "@/components/students/add-student-dialog"

export default async function StudentsPage() {
  const supabase = await createClient()
  const { data: students } = await supabase
    .from("students")
    .select("*")
    .order("created_at", { ascending: false })

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Students</h1>
          <p className="text-muted-foreground">
            Manage student records and information
          </p>
        </div>
        <AddStudentDialog />
      </div>

      <StudentsTable students={students ?? []} />
    </div>
  )
}