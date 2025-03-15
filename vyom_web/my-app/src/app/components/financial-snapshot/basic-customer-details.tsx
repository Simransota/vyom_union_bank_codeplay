"use client"

import { User } from "lucide-react"
import { Badge } from "@/components/ui/badge"
import type { Customer } from "../../../lib/types"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"

interface BasicCustomerDetailsProps {
  customer: Customer
}

export default function BasicCustomerDetails({ customer }: BasicCustomerDetailsProps) {
  const getPriorityBadge = (priority: string) => {
    switch (priority) {
      case "high":
        return <Badge className="bg-red-100 text-red-800 hover:bg-red-200 border-red-200">🔴 High Priority</Badge>
      case "medium":
        return (
          <Badge className="bg-yellow-100 text-yellow-800 hover:bg-yellow-200 border-yellow-200">
            🟡 Medium Priority
          </Badge>
        )
      case "low":
        return (
          <Badge className="bg-green-100 text-green-800 hover:bg-green-200 border-green-200">🟢 Low Priority</Badge>
        )
      default:
        return <Badge>Unknown Priority</Badge>
    }
  }

  const getPriorityDescription = (priority: string) => {
    switch (priority) {
      case "high":
        return "Significant assets, eligible for premium products"
      case "medium":
        return "Stable finances, potential for growth"
      case "low":
        return "Needs financial improvement"
      default:
        return ""
    }
  }

  return (
    <div className="flex items-start space-x-4">
      <Avatar className="h-16 w-16">
        <AvatarImage src={customer.profilePhoto} alt={customer.name} />
        <AvatarFallback className="text-lg">
          <User className="h-8 w-8" />
        </AvatarFallback>
      </Avatar>

      <div className="space-y-2">
        <div>
          <h2 className="text-xl font-bold">{customer.name}</h2>
          <div className="flex flex-col space-y-1 text-sm text-muted-foreground">
            <span>Customer ID: {customer.id}</span>
            <span>
              Age: {customer.age} • Location: {customer.location}
            </span>
          </div>
        </div>

        <div className="space-y-1">
          {getPriorityBadge(customer.priority)}
          <p className="text-xs text-muted-foreground">{getPriorityDescription(customer.priority)}</p>
        </div>
      </div>
    </div>
  )
}

