"use client"

import { useState } from "react"
import { Search, Filter, ChevronDown } from "lucide-react"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuCheckboxItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import type { Customer } from "@/lib/types"
import { cn } from "@/lib/utils"

interface CustomerListProps {
  customers: Customer[]
  selectedCustomer: Customer | null
  onSelectCustomer: (customer: Customer) => void
}

export default function CustomerList({ customers, selectedCustomer, onSelectCustomer }: CustomerListProps) {
  const [searchQuery, setSearchQuery] = useState("")
  const [priorityFilter, setPriorityFilter] = useState<string[]>([])

  const togglePriorityFilter = (priority: string) => {
    setPriorityFilter((current) =>
      current.includes(priority) ? current.filter((p) => p !== priority) : [...current, priority],
    )
  }

  const filteredCustomers = customers.filter((customer) => {
    const matchesSearch =
      customer.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      customer.id.toLowerCase().includes(searchQuery.toLowerCase())

    const matchesPriority = priorityFilter.length === 0 || priorityFilter.includes(customer.priority)

    return matchesSearch && matchesPriority
  })

  const getPriorityBadge = (priority: string) => {
    switch (priority) {
      case "high":
        return (
          <Badge variant="outline" className="bg-green-100 text-green-800 hover:bg-green-200 border-green-200">
            High
          </Badge>
        )
      case "medium":
        return (
          <Badge variant="outline" className="bg-yellow-100 text-yellow-800 hover:bg-yellow-200 border-yellow-200">
            Medium
          </Badge>
        )
      case "low":
        return (
          <Badge variant="outline" className="bg-red-100 text-red-800 hover:bg-red-200 border-red-200">
            Low
          </Badge>
        )
      default:
        return <Badge variant="outline">Unknown</Badge>
    }
  }

  return (
    <Card className="h-full flex flex-col">
      <CardHeader className="px-4 py-3 space-y-2">
        <CardTitle className="text-lg">Customer List</CardTitle>
        <div className="relative">
          <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
          <Input
            placeholder="Search customers..."
            className="pl-8"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
        <div className="flex items-center justify-between">
          <span className="text-sm text-muted-foreground">Filter by:</span>
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" size="sm" className="h-8 gap-1">
                <Filter className="h-3.5 w-3.5" />
                Priority
                <ChevronDown className="h-3.5 w-3.5" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuCheckboxItem
                checked={priorityFilter.includes("high")}
                onCheckedChange={() => togglePriorityFilter("high")}
              >
                High Priority
              </DropdownMenuCheckboxItem>
              <DropdownMenuCheckboxItem
                checked={priorityFilter.includes("medium")}
                onCheckedChange={() => togglePriorityFilter("medium")}
              >
                Medium Priority
              </DropdownMenuCheckboxItem>
              <DropdownMenuCheckboxItem
                checked={priorityFilter.includes("low")}
                onCheckedChange={() => togglePriorityFilter("low")}
              >
                Low Priority
              </DropdownMenuCheckboxItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </CardHeader>
      <CardContent className="flex-1 overflow-auto p-0">
        {filteredCustomers.length > 0 ? (
          <ul className="divide-y">
            {filteredCustomers.map((customer) => (
              <li
                key={customer.id}
                className={cn(
                  "px-4 py-3 cursor-pointer hover:bg-accent transition-colors",
                  selectedCustomer?.id === customer.id && "bg-accent",
                )}
                onClick={() => onSelectCustomer(customer)}
              >
                <div className="flex justify-between items-center">
                  <div>
                    <h3 className="font-medium">{customer.name}</h3>
                    <p className="text-xs text-muted-foreground">ID: {customer.id}</p>
                  </div>
                  {getPriorityBadge(customer.priority)}
                </div>
              </li>
            ))}
          </ul>
        ) : (
          <div className="p-4 text-center text-muted-foreground">No customers found</div>
        )}
      </CardContent>
    </Card>
  )
}

