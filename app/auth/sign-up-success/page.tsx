import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { CheckCircle, Mail } from "lucide-react"
import Link from "next/link"

export default function SignUpSuccessPage() {
  return (
    <div className="flex min-h-svh w-full items-center justify-center p-6 md:p-10">
      <Card className="w-full max-w-md">
        <CardHeader className="text-center">
          <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-primary/10">
            <CheckCircle className="h-6 w-6 text-primary" />
          </div>
          <CardTitle className="text-2xl">Check your email</CardTitle>
          <CardDescription>
            We&apos;ve sent you a confirmation link to verify your account.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center justify-center gap-2 rounded-lg bg-muted p-4 text-sm text-muted-foreground">
            <Mail className="h-4 w-4" />
            <span>Please check your inbox and spam folder</span>
          </div>
          <div className="flex justify-center">
            <Button asChild variant="outline">
              <Link href="/auth/login">Back to Login</Link>
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
