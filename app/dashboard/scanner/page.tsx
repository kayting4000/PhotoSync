import { createClient } from "@/lib/supabase/server"
import { TestScanner } from "@/components/scanner/test-scanner"

export default async function ScannerPage() {
  const supabase = await createClient()
  
  const [{ data: students }, { data: exams }] = await Promise.all([
    supabase.from("students").select("*").order("student_id"),
    supabase.from("exams").select("*, subject:subjects(*)").order("created_at", { ascending: false }),
  ])

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Test Paper Scanner</h1>
        <p className="text-muted-foreground">
          Scan test papers to detect check marks and automatically calculate scores
        </p>
      </div>

      <TestScanner students={students ?? []} exams={exams ?? []} />
    </div>
  )
}
