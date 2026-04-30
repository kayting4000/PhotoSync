import { createClient } from "@/lib/supabase/server"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Users, BookOpen, FileText, TrendingUp } from "lucide-react"
import Link from "next/link"

export default async function DashboardPage() {
  const supabase = await createClient()

  const [
    { count: studentsCount },
    { count: subjectsCount },
    { count: examsCount },
    { count: resultsCount }
  ] = await Promise.all([
    supabase.from("students").select("*", { count: "exact", head: true }),
    supabase.from("subjects").select("*", { count: "exact", head: true }),
    supabase.from("exams").select("*", { count: "exact", head: true }),
    supabase.from("exam_results").select("*", { count: "exact", head: true }),
  ])

  const stats = [
    { label: "Total Students", value: studentsCount ?? 0, icon: Users, href: "/dashboard/students", color: "text-blue-600" },
    { label: "Subjects", value: subjectsCount ?? 0, icon: BookOpen, href: "/dashboard/subjects", color: "text-emerald-600" },
    { label: "Exams Created", value: examsCount ?? 0, icon: FileText, href: "/dashboard/subjects", color: "text-amber-600" },
    { label: "Results Recorded", value: resultsCount ?? 0, icon: TrendingUp, href: "/dashboard/grades", color: "text-purple-600" },
  ]

  const quickActions = [
    { title: "Add Student", description: "Register a new student", href: "/dashboard/students?action=add" },
    { title: "Scan Test Paper", description: "Scan and score test papers", href: "/dashboard/scanner" },
    { title: "Calculate GPA", description: "View and calculate student GPA", href: "/dashboard/grades" },
    { title: "Send Results", description: "Email grades to students", href: "/dashboard/email" },
  ]

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Dashboard</h1>
        <p className="text-muted-foreground">
          Welcome to EduScan - Test Paper Scanner and Student Information Management System
        </p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => {
          const Icon = stat.icon
          return (
            <Link key={stat.label} href={stat.href}>
              <Card className="hover:bg-muted/50 transition-colors">
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">{stat.label}</CardTitle>
                  <Icon className={`h-4 w-4 ${stat.color}`} />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{stat.value}</div>
                </CardContent>
              </Card>
            </Link>
          )
        })}
      </div>

      <div>
        <h2 className="text-xl font-semibold mb-4">Quick Actions</h2>
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {quickActions.map((action) => (
            <Link key={action.title} href={action.href}>
              <Card className="h-full hover:bg-muted/50 transition-colors cursor-pointer">
                <CardHeader>
                  <CardTitle className="text-lg">{action.title}</CardTitle>
                  <CardDescription>{action.description}</CardDescription>
                </CardHeader>
              </Card>
            </Link>
          ))}
        </div>
      </div>
    </div>
  )
}
