import { createClient } from "@/lib/supabase/server"
import { EmailManager } from "@/components/email/email-manager"

export default async function EmailPage() {
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
        <h1 className="text-3xl font-bold tracking-tight">Email Results</h1>
        <p className="text-muted-foreground">
          Send exam results and grade reports to students via email
        </p>
      </div>

      <EmailManager 
        students={students ?? []} 
        results={results ?? []} 
        subjects={subjects ?? []}
      />
    </div>
  )
}
