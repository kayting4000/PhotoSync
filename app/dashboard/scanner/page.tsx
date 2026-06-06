import { Suspense } from "react"
import { createClient } from "@/lib/supabase/server"
import { Skeleton } from "@/components/ui/skeleton"
import ClientScannerWrapper from "@/components/scanner/client-scanner-wrapper"

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

      <Suspense fallback={
        <div className="grid gap-6 lg:grid-cols-2">
          <Skeleton className="h-[500px]" />
          <Skeleton className="h-[500px]" />
        </div>
      }>
        <ClientScannerWrapper students={students ?? []} exams={exams ?? []} />
      </Suspense>
    </div>
  )
}
