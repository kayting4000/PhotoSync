import { createClient } from "@/lib/supabase/server"
import { GradesManager } from "@/components/grades/grades-manager"

export default async function GradesPage() {
  const supabase = await createClient()
  
  const [{ data: students }, { data: results }, { data: subjects }] = await Promise.all([
    supabase.from("students").select("*").order("student_id"),
    supabase.from("exam_results").select(`
      *,
      student:students(*),
      exam:exams(*, subject:subjects(*))
    `).order("created_at", { ascending: false }),
    supabase.from("subjects").select("*").order("code"),
  ])

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Grades & GPA</h1>
        <p className="text-muted-foreground">
          View exam results and calculate student GPA
        </p>
      </div>

      <GradesManager 
        students={students ?? []} 
        results={results ?? []} 
        subjects={subjects ?? []}
      />
    </div>
  )
}
