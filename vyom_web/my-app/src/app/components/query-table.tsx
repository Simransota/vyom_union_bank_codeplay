"use client"

import { useState } from "react"
import { ArrowUpDown, MoreHorizontal, AlertCircle, Clock, CheckCircle2 } from "lucide-react"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"

type QueryStatus = "open" | "in-progress" | "resolved"
type QueryPriority = "low" | "medium" | "high" | "urgent"
type QueryCategory = "loan" | "credit-card" | "fraud" | "other"

interface Query {
  id: string
  customer: {
    name: string
    email: string
    avatar?: string
  }
  subject: string
  category: QueryCategory
  priority: QueryPriority
  status: QueryStatus
  assignedTo?: string
  createdAt: string
}

const mockQueries: Query[] = [
  {
    id: "Q-1001",
    customer: {
      name: "Sarah Johnson",
      email: "sarah.j@example.com",
      avatar: "/placeholder.svg?height=32&width=32",
    },
    subject: "Loan application status inquiry",
    category: "loan",
    priority: "medium",
    status: "in-progress",
    assignedTo: "John Doe",
    createdAt: "2023-09-15T10:30:00Z",
  },
  {
    id: "Q-1002",
    customer: {
      name: "Michael Chen",
      email: "m.chen@example.com",
    },
    subject: "Unauthorized credit card transaction",
    category: "fraud",
    priority: "urgent",
    status: "open",
    createdAt: "2023-09-15T09:45:00Z",
  },
  {
    id: "Q-1003",
    customer: {
      name: "Emily Rodriguez",
      email: "e.rodriguez@example.com",
      avatar: "/placeholder.svg?height=32&width=32",
    },
    subject: "Credit card payment issue",
    category: "credit-card",
    priority: "high",
    status: "in-progress",
    assignedTo: "Jane Smith",
    createdAt: "2023-09-14T16:20:00Z",
  },
  {
    id: "Q-1004",
    customer: {
      name: "David Wilson",
      email: "d.wilson@example.com",
    },
    subject: "Mortgage restructuring options",
    category: "loan",
    priority: "medium",
    status: "resolved",
    assignedTo: "John Doe",
    createdAt: "2023-09-14T11:15:00Z",
  },
  {
    id: "Q-1005",
    customer: {
      name: "Lisa Thompson",
      email: "l.thompson@example.com",
      avatar: "/placeholder.svg?height=32&width=32",
    },
    subject: "Credit limit increase request",
    category: "credit-card",
    priority: "low",
    status: "resolved",
    assignedTo: "Jane Smith",
    createdAt: "2023-09-13T14:50:00Z",
  },
]

const getCategoryLabel = (category: QueryCategory) => {
  switch (category) {
    case "loan":
      return "Loan-related"
    case "credit-card":
      return "Credit Card"
    case "fraud":
      return "Fraud & Dispute"
    case "other":
      return "Other"
  }
}

const getPriorityBadge = (priority: QueryPriority) => {
  switch (priority) {
    case "low":
      return <Badge variant="outline">Low</Badge>
    case "medium":
      return <Badge variant="secondary">Medium</Badge>
    case "high":
      return <Badge variant="default">High</Badge>
    case "urgent":
      return <Badge variant="destructive">Urgent</Badge>
  }
}

const getStatusIcon = (status: QueryStatus) => {
  switch (status) {
    case "open":
      return <AlertCircle className="h-4 w-4 text-yellow-500" />
    case "in-progress":
      return <Clock className="h-4 w-4 text-blue-500" />
    case "resolved":
      return <CheckCircle2 className="h-4 w-4 text-green-500" />
  }
}

const getStatusLabel = (status: QueryStatus) => {
  switch (status) {
    case "open":
      return "Open"
    case "in-progress":
      return "In Progress"
    case "resolved":
      return "Resolved"
  }
}

export function QueryTable({ status }: { status?: QueryStatus }) {
  const [sortColumn, setSortColumn] = useState<string | null>(null)
  const [sortDirection, setSortDirection] = useState<"asc" | "desc">("asc")

  const handleSort = (column: string) => {
    if (sortColumn === column) {
      setSortDirection(sortDirection === "asc" ? "desc" : "asc")
    } else {
      setSortColumn(column)
      setSortDirection("asc")
    }
  }

  const filteredQueries = status ? mockQueries.filter((query) => query.status === status) : mockQueries

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead className="w-[250px]">
            <Button variant="ghost" onClick={() => handleSort("customer")}>
              Customer
              <ArrowUpDown className="ml-2 h-4 w-4" />
            </Button>
          </TableHead>
          <TableHead>
            <Button variant="ghost" onClick={() => handleSort("subject")}>
              Subject
              <ArrowUpDown className="ml-2 h-4 w-4" />
            </Button>
          </TableHead>
          <TableHead>Category</TableHead>
          <TableHead>
            <Button variant="ghost" onClick={() => handleSort("priority")}>
              Priority
              <ArrowUpDown className="ml-2 h-4 w-4" />
            </Button>
          </TableHead>
          <TableHead>
            <Button variant="ghost" onClick={() => handleSort("status")}>
              Status
              <ArrowUpDown className="ml-2 h-4 w-4" />
            </Button>
          </TableHead>
          <TableHead className="text-right">Actions</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {filteredQueries.map((query) => (
          <TableRow key={query.id}>
            <TableCell>
              <div className="flex items-center gap-3">
                <Avatar className="h-8 w-8">
                  <AvatarImage src={query.customer.avatar} />
                  <AvatarFallback>
                    {query.customer.name
                      .split(" ")
                      .map((n) => n[0])
                      .join("")}
                  </AvatarFallback>
                </Avatar>
                <div>
                  <div className="font-medium">{query.customer.name}</div>
                  <div className="text-xs text-muted-foreground">{query.customer.email}</div>
                </div>
              </div>
            </TableCell>
            <TableCell>{query.subject}</TableCell>
            <TableCell>{getCategoryLabel(query.category)}</TableCell>
            <TableCell>{getPriorityBadge(query.priority)}</TableCell>
            <TableCell>
              <div className="flex items-center gap-2">
                {getStatusIcon(query.status)}
                <span>{getStatusLabel(query.status)}</span>
              </div>
            </TableCell>
            <TableCell className="text-right">
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button variant="ghost" size="icon">
                    <MoreHorizontal className="h-4 w-4" />
                    <span className="sr-only">Open menu</span>
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end">
                  <DropdownMenuLabel>Actions</DropdownMenuLabel>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem>View details</DropdownMenuItem>
                  <DropdownMenuItem>Assign to me</DropdownMenuItem>
                  <DropdownMenuItem>Schedule call</DropdownMenuItem>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem>Mark as resolved</DropdownMenuItem>
                  <DropdownMenuItem>Escalate query</DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  )
}

