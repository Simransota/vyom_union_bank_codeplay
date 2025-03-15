"use client"

import { useState } from "react"
import CustomerList from "../components/customer-list"
import BankTicket from "../components/bank-ticket"
import FinancialSnapshot from "../components/financial-snapshot"
import AiRecommendations from "../components/ai-recommendations"
import { customers } from "@/lib/data"
import type { Customer } from "@/lib/types"

export default function BankDashboard() {
  const [selectedCustomer, setSelectedCustomer] = useState<Customer | null>(null)

  return (
    <div className="grid grid-cols-1 md:grid-cols-12 gap-4 p-4 h-[calc(100vh-8rem)]">
      {/* Left Sidebar - Customer List (20% width) */}
      <div className="md:col-span-3 lg:col-span-3 h-full overflow-hidden">
        <CustomerList
          customers={customers}
          selectedCustomer={selectedCustomer}
          onSelectCustomer={setSelectedCustomer}
        />
      </div>

      {/* Middle Section - Service Ticket & Financial Snapshot (55% width) */}
      <div className="md:col-span-6 lg:col-span-6 h-full overflow-auto">
        {selectedCustomer ? (
          <div className="space-y-4">
            <BankTicket
          ticketId="UB-2023-78945"
          customerName="Vatsalya"
          customerId="1234567890"
          priority="high"
          requestType="Loan Assistance"
          queryDescription="Requesting details on home loan eligibility and repayment options."
          dateTime="2023-06-15 | 10:30 AM"
          status="in-progress"
          estimatedTime="24-48 hours"
          agentName="Sarah Johnson"
          agentId="EMP-4567"
        />
            <FinancialSnapshot customer={selectedCustomer} />
          </div>
        ) : (
          <div className="h-full flex items-center justify-center bg-card rounded-lg shadow p-6">
            <div className="text-center">
              <h3 className="text-xl font-medium text-muted-foreground mb-2">No Customer Selected</h3>
              <p className="text-muted-foreground">Select a customer from the list to view their details.</p>
            </div>
          </div>
        )}
      </div>

      {/* Right Sidebar - AI Recommendations (25% width) */}
      <div className="md:col-span-3 lg:col-span-3 h-full overflow-auto">
        {selectedCustomer ? (
          <AiRecommendations customer={selectedCustomer} />
        ) : (
          <div className="h-full flex items-center justify-center bg-card rounded-lg shadow p-6">
            <div className="text-center">
              <h3 className="text-xl font-medium text-muted-foreground mb-2">AI Recommendations</h3>
              <p className="text-muted-foreground">Select a customer to view personalized offers.</p>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

