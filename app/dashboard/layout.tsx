import { createClient } from "@/lib/supabase/server"
import { redirect } from "next/navigation"
import { DashboardNav } from "@/components/dashboard/nav"

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    redirect("/auth/login")
  }

  // Transform user to match expected type
  const safeUser = {
    id: user.id,
    email: user.email ?? "",
  }

  return (
    <div className="min-h-screen bg-background">
      <DashboardNav user={safeUser} />
      <main className="container mx-auto px-4 py-6">
        {children}
      </main>
    </div>
  )
}
