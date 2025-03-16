"use client"

import { useState, useEffect, useRef } from "react"
import { Send, FileText, X, CheckCircle2, Clock, AlertCircle } from "lucide-react"
import { Avatar } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { Card } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { cn } from "@/lib/utils"
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu"
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogClose } from "@/components/ui/dialog"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip"

type Message = {
  id: string
  content: string
  sender: "customer" | "employee"
  timestamp: Date
  status?: "sent" | "delivered" | "read"
}

type CustomerDocument = {
  id: string
  type: string
  name: string
  date: string
  fileSize: string
}

type QueryStatus = "new" | "in-progress" | "resolved"

type CustomerQuery = {
  id: string
  customerId: string
  subject: string
  description: string
  category: string
  priority: "low" | "medium" | "high"
  status: QueryStatus
  createdAt: Date
  documents: CustomerDocument[]
}

type Customer = {
  id: string
  name: string
  email: string
  phone: string
  accountNumber: string
}

// Mock data
const CUSTOMERS: Record<string, Customer> = {
  cust_1: {
    id: "cust_1",
    name: "John Smith",
    email: "john.smith@example.com",
    phone: "+1 (555) 123-4567",
    accountNumber: "1234-5678-9012",
  },
  cust_2: {
    id: "cust_2",
    name: "Sarah Johnson",
    email: "sarah.j@example.com",
    phone: "+1 (555) 987-6543",
    accountNumber: "2345-6789-0123",
  },
  cust_3: {
    id: "cust_3",
    name: "Michael Brown",
    email: "michael.b@example.com",
    phone: "+1 (555) 456-7890",
    accountNumber: "3456-7890-1234",
  },
}

const CUSTOMER_QUERIES: Record<string, CustomerQuery> = {
  query_1: {
    id: "query_1",
    customerId: "cust_1",
    subject: "Loan Application Status",
    description:
      "I submitted a loan application last week (reference #LN-2025-03-42) and would like to know its current status.",
    category: "Loans",
    priority: "medium",
    status: "new",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 24), // 1 day ago
    documents: [
      { id: "doc_1", type: "application", name: "Loan Application Form", date: "2025-03-10", fileSize: "2.3 MB" },
    ],
  },
  query_2: {
    id: "query_2",
    customerId: "cust_2",
    subject: "Unauthorized Transaction",
    description:
      "I noticed an unauthorized transaction of $250 on my account from yesterday. I did not make this purchase and need assistance resolving this issue.",
    category: "Fraud",
    priority: "high",
    status: "in-progress",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 12), // 12 hours ago
    documents: [
      { id: "doc_2", type: "statement", name: "Transaction Receipt", date: "2025-03-16", fileSize: "0.5 MB" },
    ],
  },
  query_3: {
    id: "query_3",
    customerId: "cust_3",
    subject: "Mortgage Rate Inquiry",
    description:
      "I'm interested in refinancing my mortgage and would like to know the current rates available for my situation.",
    category: "Mortgage",
    priority: "low",
    status: "new",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 3), // 3 hours ago
    documents: [],
  },
}

// Mock chat history
const CHAT_HISTORY: Record<string, Message[]> = {
  query_1: [],
  query_2: [
    {
      id: "msg_1",
      content:
        "Hello Ms. Johnson, I'm reviewing your report about an unauthorized transaction. Could you confirm when you first noticed this charge?",
      sender: "employee",
      timestamp: new Date(Date.now() - 1000 * 60 * 60 * 6), // 6 hours ago
      status: "read",
    },
    {
      id: "msg_2",
      content:
        "I noticed it this morning when I checked my account. The transaction was made yesterday evening at an online store I've never used.",
      sender: "customer",
      timestamp: new Date(Date.now() - 1000 * 60 * 60 * 5), // 5 hours ago
    },
  ],
  query_3: [],
}

export function EmployeeChat({ queryId }: { queryId: string }) {
  const [messages, setMessages] = useState<Message[]>([])
  const [newMessage, setNewMessage] = useState("")
  const [isDocumentDialogOpen, setIsDocumentDialogOpen] = useState(false)
  const [selectedDocuments, setSelectedDocuments] = useState<CustomerDocument[]>([])
  const [isLoadingDocuments, setIsLoadingDocuments] = useState(false)
  const [queryStatus, setQueryStatus] = useState<QueryStatus>("new")
  const [isFirstMessageSent, setIsFirstMessageSent] = useState(false)

  const messagesEndRef = useRef<HTMLDivElement>(null)

  const query = CUSTOMER_QUERIES[queryId]
  const customer = query ? CUSTOMERS[query.customerId] : null

  useEffect(() => {
    // Load chat history when query changes
    if (queryId && CHAT_HISTORY[queryId]) {
      setMessages(CHAT_HISTORY[queryId])
      setIsFirstMessageSent(CHAT_HISTORY[queryId].length > 0)
    } else {
      setMessages([])
      setIsFirstMessageSent(false)
    }

    // Set query status
    if (query) {
      setQueryStatus(query.status)
    }
  }, [queryId, query])

  useEffect(() => {
    // Scroll to bottom when messages change
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" })
  }, [messages])

  const handleSendMessage = () => {
    if (!newMessage.trim()) return

    // Create employee message
    const employeeMessage: Message = {
      id: Date.now().toString(),
      content: newMessage,
      sender: "employee",
      timestamp: new Date(),
      status: "sent",
    }

    setMessages([...messages, employeeMessage])
    setNewMessage("")

    // If this is the first message, update query status to in-progress
    if (!isFirstMessageSent) {
      setQueryStatus("in-progress")
      setIsFirstMessageSent(true)
    }

    // Simulate message status updates
    setTimeout(() => {
      setMessages((prev) =>
        prev.map((msg) => (msg.id === employeeMessage.id ? { ...msg, status: "delivered" as const } : msg)),
      )

      // Simulate customer reading the message after some time
      setTimeout(() => {
        setMessages((prev) =>
          prev.map((msg) => (msg.id === employeeMessage.id ? { ...msg, status: "read" as const } : msg)),
        )
      }, 5000)
    }, 2000)
  }

  const fetchDocuments = () => {
    setIsLoadingDocuments(true)

    // Simulate API call to fetch documents
    setTimeout(() => {
      setSelectedDocuments(query?.documents || [])
      setIsLoadingDocuments(false)
      setIsDocumentDialogOpen(true)
    }, 1000)
  }

  const shareDocument = (document: CustomerDocument) => {
    // Add a message with the shared document
    const employeeMessage: Message = {
      id: Date.now().toString(),
      content: `I've shared the document: ${document.name}`,
      sender: "employee",
      timestamp: new Date(),
      status: "sent",
    }

    setMessages([...messages, employeeMessage])
    setIsDocumentDialogOpen(false)

    // If this is the first message, update query status to in-progress
    if (!isFirstMessageSent) {
      setQueryStatus("in-progress")
      setIsFirstMessageSent(true)
    }
  }

  const markAsResolved = () => {
    setQueryStatus("resolved")

    // Add a system message
    const systemMessage: Message = {
      id: Date.now().toString(),
      content: "This query has been marked as resolved.",
      sender: "employee",
      timestamp: new Date(),
    }

    setMessages([...messages, systemMessage])
  }

  if (!query || !customer) {
    return <div className="flex h-full items-center justify-center">Customer query not found</div>
  }

  return (
    <Card className="w-full h-screen flex flex-col overflow-hidden rounded-none border-0">
      <div className="p-4 border-b flex justify-between items-center bg-muted/30">
        <div className="flex items-center gap-3">
          <Avatar className="h-10 w-10">
            <span className="font-semibold">{customer.name.charAt(0)}</span>
          </Avatar>
          <div>
            <div className="flex items-center gap-2">
              <h3 className="font-semibold">{customer.name}</h3>
              <Badge
                variant={
                  query.priority === "high" ? "destructive" : query.priority === "medium" ? "default" : "secondary"
                }
              >
                {query.priority.charAt(0).toUpperCase() + query.priority.slice(1)} Priority
              </Badge>
              <Badge
  variant={
    queryStatus === "new"
      ? "outline"
      : queryStatus === "in-progress"
      ? "default"
      : "secondary"  // Map "success" to "secondary" or another valid variant
  }
>
  {queryStatus === "new" ? "New" : queryStatus === "in-progress" ? "In Progress" : "Completed"}
</Badge>

            </div>
            <div className="text-xs text-muted-foreground flex gap-2">
              <span>Account: {customer.accountNumber}</span>
              <span>•</span>
              <span>{customer.email}</span>
              <span>•</span>
              <span>{customer.phone}</span>
            </div>
          </div>
        </div>

        <div className="flex gap-2">
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" size="sm">
                <FileText className="h-4 w-4 mr-2" />
                Documents
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem onClick={fetchDocuments}>View Customer Documents</DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>

          {queryStatus !== "resolved" && (
            <Button variant="outline" size="sm" onClick={markAsResolved}>
              <CheckCircle2 className="h-4 w-4 mr-2" />
              Mark as Resolved
            </Button>
          )}
        </div>
      </div>

      <div className="p-4 border-b bg-muted/20">
        <div className="flex items-center gap-2 mb-1">
          <h4 className="font-medium">{query.subject}</h4>
          <Badge variant="outline">{query.category}</Badge>
        </div>
        <p className="text-sm text-muted-foreground">{query.description}</p>
        <div className="text-xs text-muted-foreground mt-1">Submitted: {query.createdAt.toLocaleString()}</div>
      </div>

      <ScrollArea className="flex-1 p-4">
        <div className="space-y-4">
          {messages.length === 0 && !isFirstMessageSent && (
            <div className="bg-muted/30 rounded-lg p-4 text-center">
              <AlertCircle className="h-5 w-5 mx-auto mb-2 text-muted-foreground" />
              <p className="text-sm font-medium">No messages yet</p>
              <p className="text-xs text-muted-foreground mt-1">
                Send the first message to start helping this customer
              </p>
            </div>
          )}

{messages.map((message) => (
  <div
    key={message.id}
    className={cn(
      "flex items-start gap-2 max-w-[80%]",
      message.sender === "employee" ? "ml-auto flex-row-reverse" : ""
    )}
  >
    {message.sender === "customer" && (
      <Avatar className="h-8 w-8 bg-secondary text-secondary-foreground">
        <span className="text-xs">{customer.name.charAt(0)}</span>
      </Avatar>
    )}

    <div>
      <div
        className={cn(
          "rounded-lg p-3",
          message.sender === "customer"
            ? "bg-muted text-left"
            : "bg-primary text-primary-foreground text-right"
        )}
      >
        {message.content}
      </div>
      <div className="text-xs text-muted-foreground mt-1 flex items-center gap-1">
        {message.timestamp.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}
        {message.sender === "employee" && message.status && (
          <>
            <span>•</span>
            {message.status === "sent" && <Clock className="h-3 w-3" />}
            {message.status === "delivered" && <CheckCircle2 className="h-3 w-3" />}
            {message.status === "read" && (
              <div className="flex">
                <CheckCircle2 className="h-3 w-3 -mr-1" />
                <CheckCircle2 className="h-3 w-3" />
              </div>
            )}
          </>
        )}
      </div>
    </div>

    {message.sender === "employee" && (
      <Avatar className="h-8 w-8 bg-primary text-primary-foreground">
        <span className="text-xs">You</span>
      </Avatar>
    )}
  </div>
))}

          <div ref={messagesEndRef} />
        </div>
      </ScrollArea>

      <div className="p-4 border-t">
        <form
          onSubmit={(e) => {
            e.preventDefault()
            handleSendMessage()
          }}
          className="flex items-center gap-2"
        >
          <Input
            value={newMessage}
            onChange={(e) => setNewMessage(e.target.value)}
            placeholder={isFirstMessageSent ? "Type your message..." : "Send the first response to this customer..."}
            className="flex-1"
            disabled={queryStatus === "resolved"}
          />
          <TooltipProvider>
            <Tooltip>
              <TooltipTrigger asChild>
                <Button type="submit" size="icon" disabled={queryStatus === "resolved"}>
                  <Send className="h-4 w-4" />
                  <span className="sr-only">Send message</span>
                </Button>
              </TooltipTrigger>
              <TooltipContent side="top">
                {queryStatus === "resolved" ? "This query is resolved" : "Send message"}
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>
        </form>
      </div>

      <Dialog open={isDocumentDialogOpen} onOpenChange={setIsDocumentDialogOpen}>
        <DialogContent className="sm:max-w-[600px]">
          <DialogHeader>
            <DialogTitle className="flex justify-between items-center">
              <span>Customer Documents</span>

            </DialogTitle>
          </DialogHeader>

          <Tabs defaultValue="all">
            <TabsList className="grid w-full grid-cols-3">
              <TabsTrigger value="all">All</TabsTrigger>
              <TabsTrigger value="application">Applications</TabsTrigger>
              <TabsTrigger value="statement">Statements</TabsTrigger>
            </TabsList>

            <TabsContent value="all" className="mt-4">
              {isLoadingDocuments ? (
                <div className="flex justify-center p-4">Loading documents...</div>
              ) : selectedDocuments.length > 0 ? (
                <div className="space-y-2">
                  {selectedDocuments.map((doc) => (
                    <div key={doc.id} className="flex justify-between items-center p-3 border rounded-md">
                      <div>
                        <div className="font-medium">{doc.name}</div>
                        <div className="text-xs text-muted-foreground">
                          {doc.date} • {doc.fileSize}
                        </div>
                      </div>
                      <Button size="sm" onClick={() => shareDocument(doc)}>
                        Share
                      </Button>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="text-center p-4 text-muted-foreground">No documents found</div>
              )}
            </TabsContent>

            <TabsContent value="application" className="mt-4">
              {isLoadingDocuments ? (
                <div className="flex justify-center p-4">Loading applications...</div>
              ) : selectedDocuments.filter((d) => d.type === "application").length > 0 ? (
                <div className="space-y-2">
                  {selectedDocuments
                    .filter((doc) => doc.type === "application")
                    .map((doc) => (
                      <div key={doc.id} className="flex justify-between items-center p-3 border rounded-md">
                        <div>
                          <div className="font-medium">{doc.name}</div>
                          <div className="text-xs text-muted-foreground">
                            {doc.date} • {doc.fileSize}
                          </div>
                        </div>
                        <Button size="sm" onClick={() => shareDocument(doc)}>
                          Share
                        </Button>
                      </div>
                    ))}
                </div>
              ) : (
                <div className="text-center p-4 text-muted-foreground">No applications found</div>
              )}
            </TabsContent>

            <TabsContent value="statement" className="mt-4">
              {isLoadingDocuments ? (
                <div className="flex justify-center p-4">Loading statements...</div>
              ) : selectedDocuments.filter((d) => d.type === "statement").length > 0 ? (
                <div className="space-y-2">
                  {selectedDocuments
                    .filter((doc) => doc.type === "statement")
                    .map((doc) => (
                      <div key={doc.id} className="flex justify-between items-center p-3 border rounded-md">
                        <div>
                          <div className="font-medium">{doc.name}</div>
                          <div className="text-xs text-muted-foreground">
                            {doc.date} • {doc.fileSize}
                          </div>
                        </div>
                        <Button size="sm" onClick={() => shareDocument(doc)}>
                          Share
                        </Button>
                      </div>
                    ))}
                </div>
              ) : (
                <div className="text-center p-4 text-muted-foreground">No statements found</div>
              )}
            </TabsContent>
          </Tabs>
        </DialogContent>
      </Dialog>
    </Card>
  )
}

