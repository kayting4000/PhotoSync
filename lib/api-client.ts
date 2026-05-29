const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000"

/**
 * Client-side API helper that attaches the JWT token from localStorage.
 */
export async function apiClient<T = unknown>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> {
  const token =
    typeof window !== "undefined" ? localStorage.getItem("access_token") : null

  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    ...(options.headers as Record<string, string>),
  }

  if (token) {
    headers["Authorization"] = `Bearer ${token}`
  }

  const res = await fetch(`${API_URL}${endpoint}`, {
    ...options,
    headers,
  })

  if (!res.ok) {
    const body = await res.json().catch(() => ({}))
    throw new Error(body.detail || `API error ${res.status}`)
  }

  return res.json() as Promise<T>
}

/**
 * Server-side fetch helper for use in Server Components.
 * Reads token from an explicit parameter (cookies can't be accessed
 * without next/headers, so the caller must pass the token).
 */
export async function serverApiClient<T = unknown>(
  endpoint: string,
  token: string,
  options: RequestInit = {}
): Promise<T> {
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    ...(options.headers as Record<string, string>),
  }

  if (token) {
    headers["Authorization"] = `Bearer ${token}`
  }

  const res = await fetch(`${API_URL}${endpoint}`, {
    ...options,
    headers,
    cache: "no-store",
  })

  if (!res.ok) {
    const body = await res.json().catch(() => ({}))
    throw new Error(body.detail || `API error ${res.status}`)
  }

  return res.json() as Promise<T>
}