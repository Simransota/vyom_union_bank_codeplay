"use client"

import { useState } from "react"
import { Search, AlertCircle, Clock, CheckCircle2 } from "lucide-react"
import { Avatar } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { ScrollArea } from "@/components/ui/scroll-area"
import { cn } from "@/lib/utils"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"

type QueryStatus = "new" | "in-progress" | "resolved"

type CustomerQuery = {
  id: string
  customerId: string
  customerName: string
  subject: string
  category: string
  priority: "low" | "medium" | "high"
  status: QueryStatus
  createdAt: Date
  hasUnread: boolean
}

// Mock customer queries
const CUSTOMER_QUERIES: CustomerQuery[] = [
  {
    id: "query_1",
    customerId: "cust_1",
    customerName: "John Smith",
    subject: "Loan Application Status",
    category: "Loans",
    priority: "medium",
    status: "new",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 24), // 1 day ago
    hasUnread: false,
  },
  {
    id: "query_2",
    customerId: "cust_2",
    customerName: "Sarah Johnson",
    subject: "Unauthorized Transaction",
    category: "Fraud",
    priority: "high",
    status: "in-progress",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 12), // 12 hours ago
    hasUnread: true,
  },
  {
    id: "query_3",
    customerId: "cust_3",
    customerName: "Michael Brown",
    subject: "Mortgage Rate Inquiry",
    category: "Mortgage",
    priority: "low",
    status: "new",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 3), // 3 hours ago
    hasUnread: false,
  },
  {
    id: "query_4",
    customerId: "cust_4",
    customerName: "Emily Davis",
    subject: "Credit Card Application",
    category: "Credit Cards",
    priority: "medium",
    status: "resolved",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 48), // 2 days ago
    hasUnread: false,
  },
  {
    id: "query_5",
    customerId: "cust_5",
    customerName: "Robert Wilson",
    subject: "Account Statement Request",
    category: "Accounts",
    priority: "low",
    status: "resolved",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 36), // 36 hours ago
    hasUnread: false,
  },
]

interface CustomerQueryListProps {
  onSelectQuery: (queryId: string) => void
  selectedQueryId: string | null
}

export function CustomerQueryList({ onSelectQuery, selectedQueryId }: CustomerQueryListProps) {
  const [searchQuery, setSearchQuery] = useState("")
  const [statusFilter, setStatusFilter] = useState<string>("all")
  const [priorityFilter, setPriorityFilter] = useState<string>("all")

  const formatTimeAgo = (date: Date) => {
    const seconds = Math.floor((new Date().getTime() - date.getTime()) / 1000)

    let interval = seconds / 31536000
    if (interval > 1) return Math.floor(interval) + " years ago"

    interval = seconds / 2592000
    if (interval > 1) return Math.floor(interval) + " months ago"

    interval = seconds / 86400
    if (interval > 1) return Math.floor(interval) + " days ago"

    interval = seconds / 3600
    if (interval > 1) return Math.floor(interval) + " hours ago"

    interval = seconds / 60
    if (interval > 1) return Math.floor(interval) + " minutes ago"

    return Math.floor(seconds) + " seconds ago"
  }

  const filteredQueries = CUSTOMER_QUERIES.filter((query) => {
    // Apply search filter
    const matchesSearch =
      query.customerName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      query.subject.toLowerCase().includes(searchQuery.toLowerCase()) ||
      query.category.toLowerCase().includes(searchQuery.toLowerCase())

    // Apply status filter
    const matchesStatus = statusFilter === "all" || query.status === statusFilter

    // Apply priority filter
    const matchesPriority = priorityFilter === "all" || query.priority === priorityFilter

    return matchesSearch && matchesStatus && matchesPriority
  })

  // Sort queries: high priority first, then new, then by date
  const sortedQueries = [...filteredQueries].sort((a, b) => {
    // First sort by priority (high > medium > low)
    const priorityOrder = { high: 0, medium: 1, low: 2 }
    const priorityDiff = priorityOrder[a.priority] - priorityOrder[b.priority]
    if (priorityDiff !== 0) return priorityDiff

    // Then sort by status (new > in-progress > resolved)
    const statusOrder = { new: 0, "in-progress": 1, resolved: 2 }
    const statusDiff = statusOrder[a.status] - statusOrder[b.status]
    if (statusDiff !== 0) return statusDiff

    // Finally sort by date (newest first)
    return b.createdAt.getTime() - a.createdAt.getTime()
  })

  return (
    <div className="w-100 border-r h-screen flex flex-col bg-white">
      <div className="p-4 border-b flex flex-col gap-4">
        <h2 className="font-semibold text-lg text-primary">Customer Queries</h2>
        <div className="relative">
          <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
          <Input
            placeholder="Search queries..."
            className="pl-8 py-2 rounded-lg border-2 border-gray-300"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>

        <div className="flex gap-2 mb-2">
          <div className="w-1/2">
            <Select value={statusFilter} onValueChange={setStatusFilter}>
              <SelectTrigger className="w-full h-10">
                <SelectValue placeholder="Status" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Statuses</SelectItem>
                <SelectItem value="new">New</SelectItem>
                <SelectItem value="in-progress">In Progress</SelectItem>
                <SelectItem value="resolved">Resolved</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <div className="w-1/2">
            <Select value={priorityFilter} onValueChange={setPriorityFilter}>
              <SelectTrigger className="w-full h-10">
                <SelectValue placeholder="Priority" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Priorities</SelectItem>
                <SelectItem value="high">High</SelectItem>
                <SelectItem value="medium">Medium</SelectItem>
                <SelectItem value="low">Low</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>
      </div>

      <ScrollArea className="flex-1 overflow-auto">
        <div className="p-2 space-y-2">
          {sortedQueries.length > 0 ? (
            sortedQueries.map((query) => (
              <Button
                key={query.id}
                variant="ghost"
                className={cn(
                  "w-full justify-start p-3 relative rounded-lg h-24 w-full",
                  selectedQueryId === query.id ? "bg-muted" : "hover:bg-muted/50"
                )}
                onClick={() => onSelectQuery(query.id)}
              >
                <div className="flex items-start w-full">
                  <div className="relative mr-3">
                    <Avatar className="h-10 w-10 text-sm">
                      <span>{query.customerName.charAt(0)}</span>
                    </Avatar>
                    {query.hasUnread && (
                      <span className="absolute -top-1 -right-1 h-3 w-3 rounded-full bg-primary border-2 border-white" />
                    )}
                  </div>
                  
                  <div className="flex flex-col items-start text-left overflow-hidden w-full">
                    <div className="flex items-center justify-between w-full">
                      <span className="font-semibold truncate mr-2">{query.customerName}</span>
                      {query.priority === "high" && <AlertCircle className="h-4 w-4 text-red-500 shrink-0" />}
                    </div>
                    
                    <span className="text-sm text-muted-foreground truncate w-full">{query.subject}</span>
                    
                    <div className="flex items-center justify-between w-full mt-1">
                      <div className="flex items-center gap-1 text-xs text-muted-foreground">
                        <span className="truncate">{query.category}</span>
                        <span>•</span>
                        <span>{formatTimeAgo(query.createdAt)}</span>
                      </div>
                      
                      <div className="ml-2 flex-shrink-0">
                        {query.status === "new" && (
                          <Badge variant="outline" className="text-xs bg-blue-100 text-blue-800 font-medium px-2">
                            New
                          </Badge>
                        )}
                        {query.status === "in-progress" && (
                          <Badge variant="default" className="text-xs bg-yellow-100 text-yellow-800 font-medium px-2 flex items-center">
                            <Clock className="h-3 w-3 mr-1" />
                            In Progress
                          </Badge>
                        )}
                        {query.status === "resolved" && (
                          <Badge variant="secondary" className="text-xs bg-green-100 text-green-800 font-medium px-2 flex items-center">
                            <CheckCircle2 className="h-3 w-3 mr-1" />
                            Resolved
                          </Badge>
                        )}
                      </div>
                    </div>
                  </div>
                </div>
              </Button>
            ))
          ) : (
            <div className="text-center p-4 text-muted-foreground">No queries found</div>
          )}
        </div>
      </ScrollArea>
    </div>
  )
}