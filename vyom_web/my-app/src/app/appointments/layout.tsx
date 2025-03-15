import type React from "react"
import { DashboardSidebar } from "../components/dashboard-sidebar"
import { SidebarProvider } from "@/components/ui/sidebar"

export default function AppointmentsLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <SidebarProvider>
      <div className="flex h-screen bg-background">
        <DashboardSidebar />
        <div className="flex-1 overflow-auto">{children}</div>
      </div>
    </SidebarProvider>
  )
}

