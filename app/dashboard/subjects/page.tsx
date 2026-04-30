import { createClient } from "@/lib/supabase/server"
import { SubjectsManager } from "@/components/subjects/subjects-manager"

export default async function SubjectsPage() {
  const supabase = await createClient()
  
  const [{ data: subjects }, { data: exams }] = await Promise.all([
    supabase.from("subjects").select("*").order("code"),
    supabase.from("exams").select("*, subject:subjects(*)").order("created_at", { ascending: false }),
  ])

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Subjects & Exams</h1>
        <p className="text-muted-foreground">
          Manage subjects and create exams with configurable scoring
        </p>
      </div>

      <SubjectsManager subjects={subjects ?? []} exams={exams ?? []} />
    </div>
  )
}
