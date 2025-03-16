"use client"

import { useState } from "react"
import { motion } from "framer-motion"
import {
  Clock,
  User,
  CreditCard,
  Home,
  CheckCircle,
  AlertCircle,
  Clock3,
  QrCode,
  Phone,
  UserCheck,
  Scissors,
} from "lucide-react"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import Image from "next/image"

interface BankTicketProps {
  ticketId: string
  customerName: string
  customerId: string
  priority: "high" | "medium" | "low"
  requestType: string
  queryDescription: string
  dateTime: string
  status: "open" | "in-progress" | "closed"
  estimatedTime: string
  agentName: string
  agentId: string
}

export default function BankTicket({
  ticketId,
  customerName,
  customerId,
  priority,
  requestType,
  queryDescription,
  dateTime,
  status,
  estimatedTime,
  agentName,
  agentId,
}: BankTicketProps) {
  const [isTorn, setIsTorn] = useState(false)

  const getPriorityBadge = (priority: string) => {
    switch (priority) {
      case "high":
        return <Badge className="bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-100">🟢 High</Badge>
      case "medium":
        return (
          <Badge className="bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-100">🟡 Medium</Badge>
        )
      case "low":
        return <Badge className="bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-100">🔴 Low</Badge>
      default:
        return <Badge>Unknown</Badge>
    }
  }

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "open":
        return <Badge className="bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-100">🟢 Open</Badge>
      case "in-progress":
        return (
          <Badge className="bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-100">
            🟡 In Progress
          </Badge>
        )
      case "closed":
        return <Badge className="bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-100">🔴 Closed</Badge>
      default:
        return <Badge>Unknown</Badge>
    }
  }

  const getRequestTypeIcon = (type: string) => {
    if (type.toLowerCase().includes("loan")) return <Home className="h-4 w-4" />
    if (type.toLowerCase().includes("credit")) return <CreditCard className="h-4 w-4" />
    if (type.toLowerCase().includes("card")) return <CreditCard className="h-4 w-4" />
    return <AlertCircle className="h-4 w-4" />
  }

  return (
    <div className="relative">
      <motion.div
        className="flex flex-col md:flex-row rounded-lg overflow-hidden bg-card shadow-lg"
        animate={isTorn ? { x: "-100%", opacity: 0 } : {}}
        transition={{ duration: 0.5 }}
      >
        {/* Main Ticket Section */}
        <div className="flex-grow p-6 border border-border">
          <div className="flex justify-between items-center mb-4">
            <div className="flex items-center">
              <div className="w-10 h-10 relative mr-2">
                {/* <Image
                  src="/placeholder.svg?height=40&width=40"
                  alt="Union Bank Logo"
                  width={40}
                  height={40}
                  className="rounded-full"
                /> */}
              </div>
              <h2 className="text-lg font-semibold">Union Bank</h2>
            </div>
            <div className="text-sm text-muted-foreground">Service Request</div>
          </div>

          <div className="text-center mb-6">
            <h1 className="text-2xl font-bold">{ticketId}</h1>
          </div>

          <div className="space-y-4">
            <div className="bg-muted/50 p-3 rounded-md">
              <h3 className="text-sm font-medium mb-2 flex items-center">
                <User className="h-4 w-4 mr-2" /> Customer Details
              </h3>
              <div className="grid grid-cols-2 gap-2">
                <div>
                  <p className="text-xs text-muted-foreground">Name</p>
                  <p className="font-medium">{customerName}</p>
                </div>
                <div>
                  <p className="text-xs text-muted-foreground">Customer ID</p>
                  <p className="font-medium">{customerId}</p>
                </div>
                <div className="col-span-2">
                  <p className="text-xs text-muted-foreground">Priority</p>
                  <div className="mt-1">{getPriorityBadge(priority)}</div>
                </div>
              </div>
            </div>

            <div className="bg-muted/50 p-3 rounded-md">
              <h3 className="text-sm font-medium mb-2 flex items-center">
                <AlertCircle className="h-4 w-4 mr-2" /> Query Information
              </h3>
              <div className="space-y-2">
                <div>
                  <p className="text-xs text-muted-foreground">Request Type</p>
                  <p className="font-medium flex items-center">
                    {getRequestTypeIcon(requestType)}
                    <span className="ml-1">{requestType}</span>
                  </p>
                </div>
                <div>
                  <p className="text-xs text-muted-foreground">Description</p>
                  <p className="text-sm">{queryDescription}</p>
                </div>
                <div className="grid grid-cols-2 gap-2">
                  <div>
                    <p className="text-xs text-muted-foreground">Date & Time</p>
                    <p className="text-sm font-medium flex items-center">
                      <Clock className="h-3 w-3 mr-1" />
                      {dateTime}
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-muted-foreground">Status</p>
                    <div className="mt-1">{getStatusBadge(status)}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Perforated Line */}
        <div className="hidden md:flex flex-col items-center justify-center px-1 bg-background">
          <div className="h-full flex items-center">
            <div className="h-full border-l border-dashed border-border"></div>
          </div>
          <Scissors className="text-muted-foreground my-2" />
          <div className="h-full flex items-center">
            <div className="h-full border-l border-dashed border-border"></div>
          </div>
        </div>

        {/* Mobile Perforated Line */}
        <div className="md:hidden w-full h-px border-t border-dashed border-border my-2 relative">
          <div className="absolute left-1/2 top-1/2 transform -translate-x-1/2 -translate-y-1/2 bg-background px-2">
            <Scissors className="text-muted-foreground" />
          </div>
        </div>

        {/* Ticket Stub */}
        <div className="w-full md:w-64 p-4 bg-muted/30 border border-border">
          <div className="flex justify-center mb-4">
            <div className="p-2 bg-white rounded-md">
              <QrCode className="h-24 w-24" />
            </div>
          </div>

          <div className="space-y-3">
            <div>
              <p className="text-xs text-muted-foreground">Ticket ID</p>
              <p className="font-medium">{ticketId}</p>
            </div>

            <div>
              <p className="text-xs text-muted-foreground flex items-center">
                <Clock3 className="h-3 w-3 mr-1" /> Estimated Resolution Time
              </p>
              <p className="text-sm">Response expected in {estimatedTime}</p>
            </div>

            <div>
              <p className="text-xs text-muted-foreground flex items-center">
                <UserCheck className="h-3 w-3 mr-1" /> Assigned Agent
              </p>
              <p className="text-sm font-medium">{agentName}</p>
              <p className="text-xs text-muted-foreground">{agentId}</p>
            </div>

            <div className="pt-2">
              <p className="text-xs text-muted-foreground flex items-center">
                <Phone className="h-3 w-3 mr-1" /> Helpline
              </p>
              <p className="text-sm font-medium">1-800-UNION-BANK</p>
              <p className="text-xs text-muted-foreground">Available 24/7</p>
            </div>
          </div>
        </div>
      </motion.div>

      {/* Close Ticket Button */}
      {/* <div className="mt-6 flex justify-center">
        <Button variant="destructive" onClick={() => setIsTorn(true)} disabled={isTorn}>
          {isTorn ? "Ticket Closed" : "Close Ticket"}
        </Button>
      </div> */}

      {/* Reset Button (appears after tearing) */}
      {isTorn && (
        <motion.div
          className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2"
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.3 }}
        >
          <div className="text-center space-y-4">
            <CheckCircle className="h-16 w-16 text-green-500 mx-auto" />
            <h2 className="text-xl font-bold">Ticket Closed</h2>
            <p className="text-muted-foreground">Thank you for using Union Bank services</p>
            <Button onClick={() => setIsTorn(false)}>Create New Ticket</Button>
          </div>
        </motion.div>
      )}
    </div>
  )
}

