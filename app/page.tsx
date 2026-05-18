import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { GraduationCap, ScanLine, Users, Calculator, Mail, ArrowRight, CheckCircle } from "lucide-react"
import Link from "next/link"

export default function HomePage() {
  const features = [
    {
      icon: ScanLine,
      title: "Test Paper Scanner",
      description: "Scan test papers to detect check marks and automatically calculate scores",
    },
    {
      icon: Users,
      title: "Student Management",
      description: "Organize student records with ID, course, subjects, and exam history",
    },
    {
      icon: Calculator,
      title: "GPA Calculator",
      description: "Automatically calculate GPA based on recorded grades and units",
    },
    {
      icon: Mail,
      title: "Email Results",
      description: "Send grade reports directly to students via email",
    },
  ]

  const benefits = [
    "Reduce manual grading time by up to 80%",
    "Eliminate calculation errors",
    "Centralized student records",
    "Flexible scoring for different exam types",
    "Instant grade reports via email",
    "Secure cloud-based storage",
  ]

  return (
    <div className="min-h-screen bg-gradient-to-b from-background to-muted/30">
      <header className="container mx-auto px-4 py-6">
        <nav className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <GraduationCap className="h-8 w-8 text-primary" />
            <span className="text-xl font-bold">PhotoSync</span>
          </div>
          <div className="flex items-center gap-4">
            <Link href="/auth/login">
              <Button variant="ghost">Login</Button>
            </Link>
            <Link href="/auth/sign-up">
              <Button>Get Started</Button>
            </Link>
          </div>
        </nav>
      </header>

      <main>
        <section className="container mx-auto px-4 py-20 text-center">
          <div className="mx-auto max-w-3xl space-y-6">
            <h1 className="text-4xl font-bold tracking-tight sm:text-5xl md:text-6xl text-balance">
              Test Paper Scanner & Student Management System
            </h1>
            <p className="text-xl text-muted-foreground text-pretty">
              Modernize your academic workflow with automated test scanning, centralized student records, GPA calculation, and instant grade distribution.
            </p>
            <div className="flex items-center justify-center gap-4 pt-4">
              <Link href="/auth/sign-up">
                <Button size="lg" className="gap-2">
                  Start Free <ArrowRight className="h-4 w-4" />
                </Button>
              </Link>
              <Link href="/auth/login">
                <Button size="lg" variant="outline">
                  Sign In
                </Button>
              </Link>
            </div>
          </div>
        </section>

        <section className="container mx-auto px-4 py-16">
          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
            {features.map((feature) => {
              const Icon = feature.icon
              return (
                <Card key={feature.title} className="relative overflow-hidden">
                  <CardHeader>
                    <div className="mb-2 flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10">
                      <Icon className="h-6 w-6 text-primary" />
                    </div>
                    <CardTitle className="text-xl">{feature.title}</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <CardDescription className="text-base">
                      {feature.description}
                    </CardDescription>
                  </CardContent>
                </Card>
              )
            })}
          </div>
        </section>

        <section className="bg-muted/50 py-16">
          <div className="container mx-auto px-4">
            <div className="mx-auto max-w-2xl text-center mb-12">
              <h2 className="text-3xl font-bold tracking-tight mb-4">
                Why Choose PhotoSync?
              </h2>
              <p className="text-muted-foreground">
                Built by educators, for educators. Streamline your grading workflow today.
              </p>
            </div>
            <div className="mx-auto max-w-3xl">
              <div className="grid gap-4 sm:grid-cols-2">
                {benefits.map((benefit) => (
                  <div key={benefit} className="flex items-center gap-3 rounded-lg bg-background p-4">
                    <CheckCircle className="h-5 w-5 text-primary flex-shrink-0" />
                    <span>{benefit}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>

        <section className="container mx-auto px-4 py-16 text-center">
          <div className="mx-auto max-w-2xl space-y-6">
            <h2 className="text-3xl font-bold tracking-tight">
              Ready to Transform Your Grading Process?
            </h2>
            <p className="text-muted-foreground">
              Join educators who are saving hours every week with PhotoSync.
            </p>
            <Link href="/auth/sign-up">
              <Button size="lg" className="gap-2">
                Get Started for Free <ArrowRight className="h-4 w-4" />
              </Button>
            </Link>
          </div>
        </section>
      </main>

      <footer className="border-t py-8">
        <div className="container mx-auto px-4 text-center text-sm text-muted-foreground">
          <p>PhotoSync - Test Paper Scanner and Student Information Management System</p>
          <p className="mt-1">Built by Hareeja A. Montenegro, Mohd. Shaffiqh Annang, Habibun-najal Kayting</p>
        </div>
      </footer>
    </div>
  )
}
