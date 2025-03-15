"use client"

import { useState } from "react"
import { Bell, Calendar, Check, Clock, Mail, MessageSquare, Plus, Send, X } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Switch } from "@/components/ui/switch"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Textarea } from "@/components/ui/textarea"
import { Badge } from "@/components/ui/badge"

interface Reminder {
  id: string
  customerName: string
  customerEmail: string
  appointmentType: string
  appointmentDate: string
  appointmentTime: string
  status: "scheduled" | "sent" | "failed"
  channels: ("email" | "sms" | "push")[]
  message: string
}

const mockReminders: Reminder[] = [
  {
    id: "rem1",
    customerName: "Emily Parker",
    customerEmail: "emily.parker@example.com",
    appointmentType: "Mortgage Application Review",
    appointmentDate: "2023-09-20",
    appointmentTime: "10:30 AM",
    status: "scheduled",
    channels: ["email", "sms"],
    message:
      "Reminder: Your mortgage application review appointment is tomorrow at 10:30 AM. Please bring your identification and proof of income documents.",
  },
  {
    id: "rem2",
    customerName: "David Thompson",
    customerEmail: "david.thompson@example.com",
    appointmentType: "Loan Application Review",
    appointmentDate: "2023-09-18",
    appointmentTime: "2:15 PM",
    status: "sent",
    channels: ["email", "sms", "push"],
    message:
      "Reminder: Your loan application review appointment is tomorrow at 2:15 PM. Please bring your identification and proof of income documents.",
  },
  {
    id: "rem3",
    customerName: "Sophia Martinez",
    customerEmail: "sophia.martinez@example.com",
    appointmentType: "Credit Card Dispute",
    appointmentDate: "2023-09-19",
    appointmentTime: "11:00 AM",
    status: "scheduled",
    channels: ["email"],
    message:
      "Reminder: Your credit card dispute appointment is tomorrow at 11:00 AM. Please bring any relevant transaction records.",
  },
]

export function ReminderSystem() {
  const [activeTab, setActiveTab] = useState("upcoming")
  const [isCreatingReminder, setIsCreatingReminder] = useState(false)
  const [selectedChannels, setSelectedChannels] = useState<("email" | "sms" | "push")[]>(["email"])

  const toggleChannel = (channel: "email" | "sms" | "push") => {
    if (selectedChannels.includes(channel)) {
      setSelectedChannels(selectedChannels.filter((c) => c !== channel))
    } else {
      setSelectedChannels([...selectedChannels, channel])
    }
  }

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "scheduled":
        return (
          <Badge variant="outline" className="bg-blue-50 text-blue-700 border-blue-200">
            Scheduled
          </Badge>
        )
      case "sent":
        return (
          <Badge variant="outline" className="bg-green-50 text-green-700 border-green-200">
            Sent
          </Badge>
        )
      case "failed":
        return (
          <Badge variant="outline" className="bg-red-50 text-red-700 border-red-200">
            Failed
          </Badge>
        )
      default:
        return null
    }
  }

  return (
    <Card className="w-full">
      <CardHeader>
        <div className="flex items-center justify-between">
          <div>
            <CardTitle>Appointment Reminders</CardTitle>
            <CardDescription>Schedule and manage customer appointment reminders</CardDescription>
          </div>
          <Button onClick={() => setIsCreatingReminder(!isCreatingReminder)}>
            {isCreatingReminder ? (
              <>
                <X className="mr-2 h-4 w-4" />
                Cancel
              </>
            ) : (
              <>
                <Plus className="mr-2 h-4 w-4" />
                New Reminder
              </>
            )}
          </Button>
        </div>
      </CardHeader>
      <CardContent>
        {isCreatingReminder ? (
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label htmlFor="customer">Customer</Label>
                <Select>
                  <SelectTrigger id="customer">
                    <SelectValue placeholder="Select customer" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="emily">Emily Parker</SelectItem>
                    <SelectItem value="david">David Thompson</SelectItem>
                    <SelectItem value="sophia">Sophia Martinez</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div>
                <Label htmlFor="appointment">Appointment</Label>
                <Select>
                  <SelectTrigger id="appointment">
                    <SelectValue placeholder="Select appointment" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="mortgage">Mortgage Application Review (Sep 20, 10:30 AM)</SelectItem>
                    <SelectItem value="loan">Loan Application Review (Sep 18, 2:15 PM)</SelectItem>
                    <SelectItem value="credit">Credit Card Dispute (Sep 19, 11:00 AM)</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div>
              <Label>Reminder Channels</Label>
              <div className="flex items-center gap-4 mt-2">
                <div className="flex items-center space-x-2">
                  <Switch
                    id="email"
                    checked={selectedChannels.includes("email")}
                    onCheckedChange={() => toggleChannel("email")}
                  />
                  <Label htmlFor="email" className="flex items-center gap-1">
                    <Mail className="h-4 w-4" />
                    Email
                  </Label>
                </div>
                <div className="flex items-center space-x-2">
                  <Switch
                    id="sms"
                    checked={selectedChannels.includes("sms")}
                    onCheckedChange={() => toggleChannel("sms")}
                  />
                  <Label htmlFor="sms" className="flex items-center gap-1">
                    <MessageSquare className="h-4 w-4" />
                    SMS
                  </Label>
                </div>
                <div className="flex items-center space-x-2">
                  <Switch
                    id="push"
                    checked={selectedChannels.includes("push")}
                    onCheckedChange={() => toggleChannel("push")}
                  />
                  <Label htmlFor="push" className="flex items-center gap-1">
                    <Bell className="h-4 w-4" />
                    Push
                  </Label>
                </div>
              </div>
            </div>

            <div>
              <Label htmlFor="schedule">Send Reminder</Label>
              <Select defaultValue="day-before">
                <SelectTrigger id="schedule">
                  <SelectValue placeholder="Select schedule" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="day-before">1 day before appointment</SelectItem>
                  <SelectItem value="hours-before">2 hours before appointment</SelectItem>
                  <SelectItem value="week-before">1 week before appointment</SelectItem>
                  <SelectItem value="custom">Custom schedule</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div>
              <Label htmlFor="message">Reminder Message</Label>
              <Textarea
                id="message"
                placeholder="Enter reminder message"
                className="min-h-[100px]"
                defaultValue="Reminder: Your appointment is scheduled for [DATE] at [TIME]. Please bring your identification and any relevant documents. Reply CONFIRM to confirm or RESCHEDULE to reschedule."
              />
              <p className="text-xs text-muted-foreground mt-1">
                Use [DATE], [TIME], [NAME], and [TYPE] as placeholders that will be automatically filled.
              </p>
            </div>

            <div className="flex justify-end gap-2">
              <Button variant="outline" onClick={() => setIsCreatingReminder(false)}>
                Cancel
              </Button>
              <Button onClick={() => setIsCreatingReminder(false)}>
                <Send className="mr-2 h-4 w-4" />
                Schedule Reminder
              </Button>
            </div>
          </div>
        ) : (
          <Tabs defaultValue="upcoming" onValueChange={setActiveTab}>
            <TabsList className="grid w-full grid-cols-3">
              <TabsTrigger value="upcoming">Upcoming</TabsTrigger>
              <TabsTrigger value="sent">Sent</TabsTrigger>
              <TabsTrigger value="templates">Templates</TabsTrigger>
            </TabsList>

            <TabsContent value="upcoming" className="space-y-4 pt-4">
              {mockReminders
                .filter((reminder) => reminder.status === "scheduled")
                .map((reminder) => (
                  <div key={reminder.id} className="flex items-start gap-4 p-4 border rounded-lg">
                    <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary/10">
                      <Calendar className="h-5 w-5 text-primary" />
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center justify-between">
                        <h4 className="font-medium">{reminder.customerName}</h4>
                        {getStatusBadge(reminder.status)}
                      </div>
                      <p className="text-sm text-muted-foreground">{reminder.appointmentType}</p>
                      <div className="flex items-center gap-2 mt-1 text-sm">
                        <Clock className="h-3.5 w-3.5 text-muted-foreground" />
                        <span>
                          {reminder.appointmentDate} at {reminder.appointmentTime}
                        </span>
                      </div>
                      <div className="flex items-center gap-2 mt-2">
                        {reminder.channels.includes("email") && (
                          <Badge variant="outline" className="bg-blue-50 text-blue-700 border-blue-200">
                            <Mail className="mr-1 h-3 w-3" />
                            Email
                          </Badge>
                        )}
                        {reminder.channels.includes("sms") && (
                          <Badge variant="outline" className="bg-green-50 text-green-700 border-green-200">
                            <MessageSquare className="mr-1 h-3 w-3" />
                            SMS
                          </Badge>
                        )}
                        {reminder.channels.includes("push") && (
                          <Badge variant="outline" className="bg-purple-50 text-purple-700 border-purple-200">
                            <Bell className="mr-1 h-3 w-3" />
                            Push
                          </Badge>
                        )}
                      </div>
                    </div>
                    <div className="flex gap-2">
                      <Button variant="outline" size="sm">
                        Edit
                      </Button>
                      <Button size="sm">Send Now</Button>
                    </div>
                  </div>
                ))}
            </TabsContent>

            <TabsContent value="sent" className="space-y-4 pt-4">
              {mockReminders
                .filter((reminder) => reminder.status === "sent")
                .map((reminder) => (
                  <div key={reminder.id} className="flex items-start gap-4 p-4 border rounded-lg">
                    <div className="flex h-10 w-10 items-center justify-center rounded-full bg-green-100">
                      <Check className="h-5 w-5 text-green-600" />
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center justify-between">
                        <h4 className="font-medium">{reminder.customerName}</h4>
                        {getStatusBadge(reminder.status)}
                      </div>
                      <p className="text-sm text-muted-foreground">{reminder.appointmentType}</p>
                      <div className="flex items-center gap-2 mt-1 text-sm">
                        <Clock className="h-3.5 w-3.5 text-muted-foreground" />
                        <span>
                          {reminder.appointmentDate} at {reminder.appointmentTime}
                        </span>
                      </div>
                      <div className="flex items-center gap-2 mt-2">
                        {reminder.channels.includes("email") && (
                          <Badge variant="outline" className="bg-blue-50 text-blue-700 border-blue-200">
                            <Mail className="mr-1 h-3 w-3" />
                            Email
                          </Badge>
                        )}
                        {reminder.channels.includes("sms") && (
                          <Badge variant="outline" className="bg-green-50 text-green-700 border-green-200">
                            <MessageSquare className="mr-1 h-3 w-3" />
                            SMS
                          </Badge>
                        )}
                        {reminder.channels.includes("push") && (
                          <Badge variant="outline" className="bg-purple-50 text-purple-700 border-purple-200">
                            <Bell className="mr-1 h-3 w-3" />
                            Push
                          </Badge>
                        )}
                      </div>
                    </div>
                    <div className="flex gap-2">
                      <Button variant="outline" size="sm">
                        View Details
                      </Button>
                      <Button variant="outline" size="sm">
                        Resend
                      </Button>
                    </div>
                  </div>
                ))}
            </TabsContent>

            <TabsContent value="templates" className="space-y-4 pt-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="border rounded-lg p-4">
                  <h4 className="font-medium">Standard Appointment Reminder</h4>
                  <p className="text-sm text-muted-foreground mt-1">
                    Reminder: Your [TYPE] appointment is scheduled for [DATE] at [TIME]. Please bring your
                    identification and any relevant documents.
                  </p>
                  <div className="flex justify-end mt-4">
                    <Button variant="outline" size="sm">
                      Use Template
                    </Button>
                  </div>
                </div>

                <div className="border rounded-lg p-4">
                  <h4 className="font-medium">Loan Application Reminder</h4>
                  <p className="text-sm text-muted-foreground mt-1">
                    Reminder: Your loan application review is scheduled for [DATE] at [TIME]. Please bring your ID,
                    proof of income, and bank statements.
                  </p>
                  <div className="flex justify-end mt-4">
                    <Button variant="outline" size="sm">
                      Use Template
                    </Button>
                  </div>
                </div>

                <div className="border rounded-lg p-4">
                  <h4 className="font-medium">Credit Card Dispute Reminder</h4>
                  <p className="text-sm text-muted-foreground mt-1">
                    Reminder: Your credit card dispute appointment is on [DATE] at [TIME]. Please bring transaction
                    records and any communication with the merchant.
                  </p>
                  <div className="flex justify-end mt-4">
                    <Button variant="outline" size="sm">
                      Use Template
                    </Button>
                  </div>
                </div>

                <div className="border rounded-lg p-4">
                  <h4 className="font-medium">Mortgage Application Reminder</h4>
                  <p className="text-sm text-muted-foreground mt-1">
                    Reminder: Your mortgage application review is on [DATE] at [TIME]. Please bring property details,
                    ID, and financial documents.
                  </p>
                  <div className="flex justify-end mt-4">
                    <Button variant="outline" size="sm">
                      Use Template
                    </Button>
                  </div>
                </div>
              </div>

              <div className="flex justify-end mt-4">
                <Button>
                  <Plus className="mr-2 h-4 w-4" />
                  Create New Template
                </Button>
              </div>
            </TabsContent>
          </Tabs>
        )}
      </CardContent>
    </Card>
  )
}

