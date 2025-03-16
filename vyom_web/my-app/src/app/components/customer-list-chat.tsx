"use client"

import { useState } from "react"
import { Search } from "lucide-react"
import { Avatar } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { ScrollArea } from "@/components/ui/scroll-area"
import { cn } from "@/lib/utils"

type Customer = {
  id: string
  name: string
  email: string
  lastActive: string
  status: "online" | "offline" | "away"
}

// Mock customer data
const CUSTOMERS: Customer[] = [
  {
    id: "cust_1",
    name: "John Smith",
    email: "john.smith@example.com",
    lastActive: "2 min ago",
    status: "online",
  },
  {
    id: "cust_2",
    name: "Sarah Johnson",
    email: "sarah.j@example.com",
    lastActive: "5 min ago",
    status: "online",
  },
  {
    id: "cust_3",
    name: "Michael Brown",
    email: "michael.b@example.com",
    lastActive: "1 hour ago",
    status: "away",
  },
  {
    id: "cust_4",
    name: "Emily Davis",
    email: "emily.d@example.com",
    lastActive: "3 hours ago",
    status: "offline",
  },
  {
    id: "cust_5",
    name: "Robert Wilson",
    email: "robert.w@example.com",
    lastActive: "1 day ago",
    status: "offline",
  },
]

interface CustomerListProps {
    onSelectCustomer: (customerId: string) => void  // Keep this as string
    selectedCustomerId: string | null
  }

  export function CustomerList({ onSelectCustomer, selectedCustomerId }: CustomerListProps) {
  const [searchQuery, setSearchQuery] = useState("")

  const filteredCustomers = CUSTOMERS.filter(
    (customer) =>
      customer.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      customer.email.toLowerCase().includes(searchQuery.toLowerCase()),
  )

  return (
    <div className="w-80 border-r h-screen flex flex-col">
      <div className="p-4 border-b">
        <h2 className="font-semibold text-lg mb-4">Customers</h2>
        <div className="relative">
          <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
          <Input
            placeholder="Search customers..."
            className="pl-8"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
      </div>

      <ScrollArea className="flex-1">
        <div className="p-2">
          {filteredCustomers.length > 0 ? (
            filteredCustomers.map((customer) => (
              <Button
                key={customer.id}
                variant="ghost"
                className={cn("w-full justify-start px-2 py-6 mb-1", selectedCustomerId === customer.id && "bg-muted")}
                onClick={() => onSelectCustomer(customer.id)}
              >
                <div className="flex items-center w-full">
                  <div className="relative">
                    <Avatar className="h-9 w-9 mr-3">
                      <span>{customer.name.charAt(0)}</span>
                    </Avatar>
                    <span
                      className={cn(
                        "absolute bottom-0 right-2 h-2.5 w-2.5 rounded-full border-2 border-background",
                        customer.status === "online" && "bg-green-500",
                        customer.status === "away" && "bg-yellow-500",
                        customer.status === "offline" && "bg-gray-400",
                      )}
                    />
                  </div>
                  <div className="flex flex-col items-start">
                    <span className="font-medium">{customer.name}</span>
                    <span className="text-xs text-muted-foreground">{customer.lastActive}</span>
                  </div>
                </div>
              </Button>
            ))
          ) : (
            <div className="text-center p-4 text-muted-foreground">No customers found</div>
          )}
        </div>
      </ScrollArea>
    </div>
  )
}

