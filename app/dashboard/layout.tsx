"use client"

import { useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import { DashboardNav } from "@/components/dashboard/nav"

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const router = useRouter()
  const [user, setUser] = useState<{ id: string; email: string } | null>(null)
  const [ready, setReady] = useState(false)

  useEffect(() => {
    const token = localStorage.getItem("access_token")
    const raw = localStorage.getItem("user")
    if (!token || !raw) {
      router.replace("/auth/login")
      return
    }
    try {
      setUser(JSON.parse(raw))
    } catch {
      router.replace("/auth/login")
      return
    }
    setReady(true)
  }, [router])

  if (!ready) return null

  return (
    <div className="min-h-screen neu-page-bg">
      <DashboardNav user={user!} />
      <main className="container mx-auto px-4 py-6">
        {children}
      </main>
    </div>
  )
}