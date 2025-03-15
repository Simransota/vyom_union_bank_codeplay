"use client"

import { SidebarProvider } from "@/components/ui/sidebar"
import { DashboardSidebar } from "../components/dashboard-sidebar"
import { DashboardContent } from "../components/dashboard-content"

export function DashboardPage() {
  return (
    <SidebarProvider>
      <div className="flex h-screen bg-background">
        <DashboardSidebar />
        <DashboardContent />
      </div>
    </SidebarProvider>
  )
}

