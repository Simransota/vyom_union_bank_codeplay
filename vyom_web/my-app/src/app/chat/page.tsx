"use client"

import { useState } from "react"
import { CustomerQueryList } from "../components/customer-query-list"
import { EmployeeChat } from "../components/chat"

export default function BankStaffPortal() {
  const [selectedQueryId, setSelectedQueryId] = useState<string | null>(null)

  return (
    <div className="flex h-screen w-full overflow-hidden bg-background">
      <CustomerQueryList onSelectQuery={(id) => setSelectedQueryId(id)} selectedQueryId={selectedQueryId} />
      <div className="flex-1">
        {selectedQueryId ? (
          <EmployeeChat queryId={selectedQueryId} />
        ) : (
          <div className="flex h-full items-center justify-center text-muted-foreground">
            <div className="text-center">
              <h3 className="text-lg font-medium mb-2">Select a customer query</h3>
              <p className="text-sm">Choose a customer query from the list to start responding</p>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

