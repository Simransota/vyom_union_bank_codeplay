"use client"

import { useState } from "react"
import { format, addDays, subDays } from "date-fns"
import {
  Calendar,
  Clock,
  ChevronLeft,
  ChevronRight,
  Plus,
  Link,
  CheckSquare,
  Users,
  FileText,
  AlertCircle,
} from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { Calendar as CalendarComponent } from "@/components/ui/calendar"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Checkbox } from "@/components/ui/checkbox"
import { Textarea } from "@/components/ui/textarea"

interface Appointment {
  id: string
  customerName: string
  customerPhone: string
  customerEmail: string
  appointmentType: string
  startTime: string
  endTime: string
  representative: string
  status: "scheduled" | "completed" | "cancelled" | "no-show"
  notes?: string
  color: string
}

interface Representative {
  id: string
  name: string
  expertise: string[]
  avatar: string
}

const representatives: Representative[] = [
  {
    id: "rep1",
    name: "John Carpenter",
    expertise: ["Loans", "Mortgages", "Investments"],
    avatar: "/placeholder.svg?height=40&width=40",
  },
  {
    id: "rep2",
    name: "Sarah Johnson",
    expertise: ["Credit Cards", "Personal Banking", "Savings"],
    avatar: "/placeholder.svg?height=40&width=40",
  },
  {
    id: "rep3",
    name: "Michael Rodriguez",
    expertise: ["Fraud Resolution", "Dispute Management", "Security"],
    avatar: "/placeholder.svg?height=40&width=40",
  },
]

const mockAppointments: Appointment[] = [
  {
    id: "apt1",
    customerName: "Emily Parker",
    customerPhone: "+1 (555) 123-4567",
    customerEmail: "emily.parker@example.com",
    appointmentType: "Mortgage Application Review",
    startTime: "8:00AM",
    endTime: "9:15AM",
    representative: "John Carpenter",
    status: "scheduled",
    color: "bg-purple-100 border-purple-300",
  },
  {
    id: "apt2",
    customerName: "David Thompson",
    customerPhone: "+1 (555) 987-6543",
    customerEmail: "david.thompson@example.com",
    appointmentType: "Loan Application Review",
    startTime: "7:15AM",
    endTime: "8:00AM",
    representative: "Sarah Johnson",
    status: "scheduled",
    color: "bg-green-100 border-green-300",
  },
  {
    id: "apt3",
    customerName: "Sophia Martinez",
    customerPhone: "+1 (555) 456-7890",
    customerEmail: "sophia.martinez@example.com",
    appointmentType: "Credit Card Dispute",
    startTime: "7:15AM",
    endTime: "8:15AM",
    representative: "Michael Rodriguez",
    status: "scheduled",
    color: "bg-blue-100 border-blue-300",
  },
  {
    id: "apt4",
    customerName: "James Wilson",
    customerPhone: "+1 (555) 234-5678",
    customerEmail: "james.wilson@example.com",
    appointmentType: "Investment Portfolio Review",
    startTime: "8:30AM",
    endTime: "9:15AM",
    representative: "Sarah Johnson",
    status: "scheduled",
    color: "bg-green-100 border-green-300",
  },
  {
    id: "apt5",
    customerName: "Olivia Brown",
    customerPhone: "+1 (555) 876-5432",
    customerEmail: "olivia.brown@example.com",
    appointmentType: "Fraud Investigation",
    startTime: "10:15AM",
    endTime: "12:00PM",
    representative: "John Carpenter",
    status: "scheduled",
    color: "bg-purple-100 border-purple-300",
  },
  {
    id: "apt6",
    customerName: "Ethan Davis",
    customerPhone: "+1 (555) 345-6789",
    customerEmail: "ethan.davis@example.com",
    appointmentType: "Mortgage Restructuring",
    startTime: "9:15AM",
    endTime: "11:45AM",
    representative: "Michael Rodriguez",
    status: "scheduled",
    color: "bg-blue-100 border-blue-300",
  },
]

export function AppointmentScheduler() {
  const [currentDate, setCurrentDate] = useState(new Date())
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false)
  const [isDatePickerOpen, setIsDatePickerOpen] = useState(false)
  const [isPostAppointmentOpen, setIsPostAppointmentOpen] = useState(false)
  const [selectedAppointment, setSelectedAppointment] = useState<Appointment | null>(null)

  const formattedDate = format(currentDate, "EEEE, MMMM do yyyy")

  const handlePreviousDay = () => {
    setCurrentDate(subDays(currentDate, 1))
  }

  const handleNextDay = () => {
    setCurrentDate(addDays(currentDate, 1))
  }

  const handleAppointmentClick = (appointment: Appointment) => {
    setSelectedAppointment(appointment)
    setIsPostAppointmentOpen(true)
  }

  const timeSlots = [
    "7:00AM",
    "7:15AM",
    "7:30AM",
    "7:45AM",
    "8:00AM",
    "8:15AM",
    "8:30AM",
    "8:45AM",
    "9:00AM",
    "9:15AM",
    "9:30AM",
    "9:45AM",
    "10:00AM",
    "10:15AM",
    "10:30AM",
    "10:45AM",
    "11:00AM",
    "11:15AM",
    "11:30AM",
    "11:45AM",
    "12:00PM",
    "12:15PM",
    "12:30PM",
    "12:45PM",
    "1:00PM",
    "1:15PM",
    "1:30PM",
    "1:45PM",
    "2:00PM",
    "2:15PM",
    "2:30PM",
    "2:45PM",
    "3:00PM",
    "3:15PM",
    "3:30PM",
    "3:45PM",
    "4:00PM",
    "4:15PM",
    "4:30PM",
    "4:45PM",
    "5:00PM",
  ]

  return (
    <div className="flex flex-col h-full">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <h2 className="text-2xl font-bold">Calendar</h2>
          <Badge variant="outline" className="ml-2">
            Up to Date
          </Badge>
        </div>
        <div className="flex items-center gap-2">
          <Input type="search" placeholder="Type a command or search..." className="w-64" />
          <Button variant="outline">
            <Calendar className="mr-2 h-4 w-4" />
            My Bookings
          </Button>
          <Select defaultValue="john">
            <SelectTrigger className="w-[180px]">
              <SelectValue placeholder="Select Representative" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="john">John Carpenter</SelectItem>
              <SelectItem value="sarah">Sarah Johnson</SelectItem>
              <SelectItem value="michael">Michael Rodriguez</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      <div className="flex items-center gap-2 mb-4">
        <Button variant="outline" size="sm">
          <Users className="mr-2 h-4 w-4" />
          Filter
        </Button>
        <Button variant="outline" size="sm">
          <FileText className="mr-2 h-4 w-4" />
          Transactions
        </Button>
        <Button variant="outline" size="sm">
          <FileText className="mr-2 h-4 w-4" />
          All Notes
        </Button>
        <Button variant="outline" size="sm">
          <CheckSquare className="mr-2 h-4 w-4" />
          Opened
        </Button>
        <Button variant="outline" size="sm">
          <FileText className="mr-2 h-4 w-4" />
          Excel
        </Button>
        <Button variant="outline" size="sm">
          <Calendar className="mr-2 h-4 w-4" />
          Edit Schedules
        </Button>
        <Button variant="outline" size="sm">
          <FileText className="mr-2 h-4 w-4" />
          Add Note
        </Button>
        <Button variant="outline" size="sm">
          <Calendar className="mr-2 h-4 w-4" />
          Add Block Time
        </Button>
        <Button variant="outline" size="sm">
          <Calendar className="mr-2 h-4 w-4" />
          Manage Bookings
        </Button>
      </div>

      <div className="flex items-center justify-between mb-4">
        <h3 className="text-xl font-semibold">{formattedDate}</h3>
        <div className="flex items-center gap-2">
          <Select defaultValue="service">
            <SelectTrigger className="w-[200px]">
              <SelectValue placeholder="View" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="service">View: Service Provider</SelectItem>
              <SelectItem value="customer">View: Customer</SelectItem>
              <SelectItem value="appointment">View: Appointment Type</SelectItem>
            </SelectContent>
          </Select>
          <Button variant="outline" size="sm">
            Show Today
          </Button>
          <Button variant="ghost" size="icon" onClick={handlePreviousDay}>
            <ChevronLeft className="h-4 w-4" />
          </Button>
          <Button variant="ghost" size="icon" onClick={handleNextDay}>
            <ChevronRight className="h-4 w-4" />
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-3 gap-4 flex-1 overflow-auto">
        {representatives.map((rep) => (
          <div key={rep.id} className="flex flex-col border rounded-md">
            <div className="flex items-center gap-2 p-3 border-b">
              <div className="w-8 h-8 rounded-full overflow-hidden">
                <img src={rep.avatar || "/placeholder.svg"} alt={rep.name} className="w-full h-full object-cover" />
              </div>
              <span className="font-medium">{rep.name}</span>
            </div>

            <div className="flex-1 relative">
              {timeSlots.map((time, index) => (
                <div
                  key={time}
                  className={`absolute w-full border-b text-xs px-2 ${index % 4 === 0 ? "font-medium" : ""}`}
                  style={{ top: `${index * 30}px`, height: "30px" }}
                >
                  {index % 4 === 0 && <span className="text-gray-500">{time}</span>}
                </div>
              ))}

              {mockAppointments
                .filter((apt) => apt.representative === rep.name)
                .map((appointment) => {
                  const startIndex = timeSlots.findIndex((t) => t === appointment.startTime)
                  const endIndex = timeSlots.findIndex((t) => t === appointment.endTime)
                  const height = (endIndex - startIndex) * 30

                  return (
                    <div
                      key={appointment.id}
                      className={`absolute left-[15%] right-[5%] ${appointment.color} border rounded-md p-2 cursor-pointer hover:opacity-90 transition-opacity`}
                      style={{
                        top: `${startIndex * 30}px`,
                        height: `${height}px`,
                      }}
                      onClick={() => handleAppointmentClick(appointment)}
                    >
                      <div className="font-medium">{appointment.customerName}</div>
                      <div className="text-xs">{appointment.appointmentType}</div>
                      <div className="text-xs">
                        {appointment.startTime} - {appointment.endTime}
                      </div>
                      <div className="text-xs">{appointment.customerPhone}</div>
                      <div className="text-xs truncate">{appointment.customerEmail}</div>
                    </div>
                  )
                })}
            </div>
          </div>
        ))}
      </div>

      {/* Add Appointment Dialog */}
      <Dialog open={isAddDialogOpen} onOpenChange={setIsAddDialogOpen}>
        <DialogContent className="sm:max-w-[500px]">
          <DialogHeader>
            <DialogTitle>Add Schedule</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <Input placeholder="New Event Title" />

            <Popover open={isDatePickerOpen} onOpenChange={setIsDatePickerOpen}>
              <PopoverTrigger asChild>
                <Button variant="outline" className="w-full justify-start text-left">
                  <Calendar className="mr-2 h-4 w-4" />
                  {format(currentDate, "EEEE, MMM dd yyyy")}
                </Button>
              </PopoverTrigger>
              <PopoverContent className="w-auto p-0">
                <CalendarComponent
                  mode="single"
                  selected={currentDate}
                  onSelect={(date) => {
                    if (date) {
                      setCurrentDate(date)
                      setIsDatePickerOpen(false)
                    }
                  }}
                  initialFocus
                />
              </PopoverContent>
            </Popover>

            <div className="flex gap-2">
              <div className="flex-1">
                <Select defaultValue="8:00AM">
                  <SelectTrigger>
                    <Clock className="mr-2 h-4 w-4" />
                    <SelectValue placeholder="Start Time" />
                  </SelectTrigger>
                  <SelectContent>
                    {timeSlots.map((time) => (
                      <SelectItem key={time} value={time}>
                        {time}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="flex items-center">to</div>
              <div className="flex-1">
                <Select defaultValue="9:00AM">
                  <SelectTrigger>
                    <Clock className="mr-2 h-4 w-4" />
                    <SelectValue placeholder="End Time" />
                  </SelectTrigger>
                  <SelectContent>
                    {timeSlots.map((time) => (
                      <SelectItem key={time} value={time}>
                        {time}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div>
              <Button variant="outline" className="w-full justify-start text-left">
                <Plus className="mr-2 h-4 w-4" />
                Add Guest
              </Button>
            </div>

            <div>
              <div className="relative">
                <Link className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                <Input
                  placeholder="http://zoom.channel.com"
                  className="pl-10 w-full"
                />
              </div>
            </div>

            <Select defaultValue="john">
              <SelectTrigger className="w-full">
                <SelectValue placeholder="Assign Representative" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="john">John Carpenter (Loans, Mortgages)</SelectItem>
                <SelectItem value="sarah">Sarah Johnson (Credit Cards, Personal Banking)</SelectItem>
                <SelectItem value="michael">Michael Rodriguez (Fraud Resolution, Disputes)</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setIsAddDialogOpen(false)}>
              Cancel
            </Button>
            <Button onClick={() => setIsAddDialogOpen(false)}>Save</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Post-Appointment Dialog */}
      <Dialog open={isPostAppointmentOpen} onOpenChange={setIsPostAppointmentOpen}>
        <DialogContent className="sm:max-w-[600px]">
          <DialogHeader>
            <DialogTitle>Post-Appointment Summary</DialogTitle>
          </DialogHeader>

          {selectedAppointment && (
            <div className="space-y-4 py-2">
              <div className="flex items-center gap-2 p-3 border rounded-md bg-muted/50">
                <div className="flex-1">
                  <h3 className="font-medium">{selectedAppointment.customerName}</h3>
                  <p className="text-sm">{selectedAppointment.appointmentType}</p>
                  <p className="text-sm text-muted-foreground">
                    {selectedAppointment.startTime} - {selectedAppointment.endTime}
                  </p>
                </div>
                <Badge variant={selectedAppointment.status === "completed" ? "outline" : "default"}>
                  {selectedAppointment.status.charAt(0).toUpperCase() + selectedAppointment.status.slice(1)}
                </Badge>
              </div>

              <Tabs defaultValue="summary">
                <TabsList className="grid grid-cols-3 w-full">
                  <TabsTrigger value="summary">AI Summary</TabsTrigger>
                  <TabsTrigger value="checklist">Action Items</TabsTrigger>
                  <TabsTrigger value="notes">Notes</TabsTrigger>
                </TabsList>

                <TabsContent value="summary" className="space-y-4 pt-4">
                  <div className="p-4 border rounded-md bg-muted/30">
                    <h4 className="font-medium mb-2 flex items-center">
                      <FileText className="mr-2 h-4 w-4" />
                      AI-Generated Summary
                    </h4>
                    <p className="text-sm">
                      Customer {selectedAppointment.customerName} discussed their{" "}
                      {selectedAppointment.appointmentType.toLowerCase()}. The main concerns were about interest rates
                      and payment schedules. Customer expressed interest in a 30-year fixed rate option and requested
                      additional information about closing costs.
                    </p>
                    <p className="text-sm mt-2">Key points discussed:</p>
                    <ul className="text-sm list-disc pl-5 mt-1">
                      <li>Current interest rate options (3.5% - 4.2%)</li>
                      <li>Monthly payment estimates ($1,450 - $1,650)</li>
                      <li>Documentation requirements for final approval</li>
                    </ul>
                    <p className="text-sm mt-2">Customer sentiment: Positive, but concerned about timing.</p>
                  </div>

                  <div className="flex justify-end gap-2">
                    <Button variant="outline" size="sm">
                      Edit Summary
                    </Button>
                    <Button size="sm">Approve Summary</Button>
                  </div>
                </TabsContent>

                <TabsContent value="checklist" className="space-y-4 pt-4">
                  <div className="space-y-2">
                    <div className="flex items-center space-x-2">
                      <Checkbox id="task1" />
                      <label
                        htmlFor="task1"
                        className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                      >
                        Customer needs to upload proof of income
                      </label>
                    </div>
                    <div className="flex items-center space-x-2">
                      <Checkbox id="task2" />
                      <label
                        htmlFor="task2"
                        className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                      >
                        Send follow-up email with rate comparison sheet
                      </label>
                    </div>
                    <div className="flex items-center space-x-2">
                      <Checkbox id="task3" />
                      <label
                        htmlFor="task3"
                        className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                      >
                        Schedule follow-up call in 5 business days
                      </label>
                    </div>
                    <div className="flex items-center space-x-2">
                      <Checkbox id="task4" />
                      <label
                        htmlFor="task4"
                        className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                      >
                        Update customer profile with new contact preferences
                      </label>
                    </div>
                    <div className="flex items-center space-x-2">
                      <Checkbox id="task5" />
                      <label
                        htmlFor="task5"
                        className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                      >
                        Verify all required documentation is in the system
                      </label>
                    </div>
                  </div>

                  <div className="pt-2">
                    <Button variant="outline" size="sm" className="gap-1">
                      <Plus className="h-4 w-4" />
                      Add Action Item
                    </Button>
                  </div>
                </TabsContent>

                <TabsContent value="notes" className="space-y-4 pt-4">
                  <Textarea placeholder="Add your notes about the appointment here..." className="min-h-[150px]" />
                  <div className="flex justify-end">
                    <Button>Save Notes</Button>
                  </div>
                </TabsContent>
              </Tabs>

              <div className="flex justify-between pt-2">
                <div className="flex gap-2">
                  <Button variant="outline" size="sm">
                    <AlertCircle className="mr-2 h-4 w-4" />
                    Report Issue
                  </Button>
                  <Button variant="outline" size="sm">
                    <Calendar className="mr-2 h-4 w-4" />
                    Reschedule
                  </Button>
                </div>
                <div className="flex gap-2">
                  <Button variant="outline" onClick={() => setIsPostAppointmentOpen(false)}>
                    Close
                  </Button>
                  <Button onClick={() => setIsPostAppointmentOpen(false)}>Complete & Send Summary</Button>
                </div>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>

      <Button
        className="fixed bottom-6 right-6 rounded-full h-12 w-12 p-0 shadow-lg"
        onClick={() => setIsAddDialogOpen(true)}
      >
        <Plus className="h-6 w-6" />
      </Button>
    </div>
  )
}

