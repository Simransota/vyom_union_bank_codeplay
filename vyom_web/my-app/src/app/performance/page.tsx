"use client"

import { useState } from "react"
import { Calendar, Download, Filter, Moon, Sun, Users, MessageSquare, Award, TrendingUp } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"

// Import Nivo chart components
import { ResponsiveLine } from "@nivo/line"
import { ResponsiveBar } from "@nivo/bar"
import { ResponsivePie } from "@nivo/pie"

export default function Dashboard() {
  const [theme, setTheme] = useState<"light" | "dark">("light")

  const toggleTheme = () => {
    const newTheme = theme === "light" ? "dark" : "light"
    setTheme(newTheme)
    document.documentElement.classList.toggle("dark")
  }

  // Sample data for charts
  const csatData = [
    { month: "Jan", score: 4.2 },
    { month: "Feb", score: 4.3 },
    { month: "Mar", score: 4.1 },
    { month: "Apr", score: 4.4 },
    { month: "May", score: 4.6 },
    { month: "Jun", score: 4.5 },
  ]

  const topIssuesData = [
    { name: "Long Wait Times", value: 35 },
    { name: "Product Knowledge", value: 25 },
    { name: "Resolution Time", value: 20 },
    { name: "Follow-up", value: 15 },
    { name: "System Issues", value: 5 },
  ]

  const employeePerformanceData = [
    { name: "Sarah Johnson", resolutionTime: 12, satisfactionScore: 4.8, callsHandled: 245 },
    { name: "Michael Chen", resolutionTime: 15, satisfactionScore: 4.7, callsHandled: 230 },
    { name: "Jessica Williams", resolutionTime: 10, satisfactionScore: 4.9, callsHandled: 210 },
    { name: "David Rodriguez", resolutionTime: 18, satisfactionScore: 4.5, callsHandled: 195 },
    { name: "Emily Thompson", resolutionTime: 14, satisfactionScore: 4.6, callsHandled: 220 },
  ]

  const weeklyTrendsData = [
    { day: "Mon", calls: 120, resolutions: 110 },
    { day: "Tue", calls: 132, resolutions: 125 },
    { day: "Wed", calls: 145, resolutions: 135 },
    { day: "Thu", calls: 140, resolutions: 130 },
    { day: "Fri", calls: 160, resolutions: 145 },
    { day: "Sat", calls: 85, resolutions: 80 },
    { day: "Sun", calls: 65, resolutions: 60 },
  ]

  const COLORS = ["#0088FE", "#00C49F", "#FFBB28", "#FF8042", "#8884D8"]

  return (
    <div className={theme}>
      <div className="flex min-h-screen flex-col bg-background">
        <header className="sticky top-0 z-10 border-b bg-background">
          <div className="flex h-16 items-center px-4 md:px-6">
            <h1 className="text-lg font-semibold md:text-2xl">Performance Dashboard</h1>
            <div className="ml-auto flex items-center gap-2">
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button variant="outline" size="icon">
                    <Filter className="h-4 w-4" />
                    <span className="sr-only">Filter</span>
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end">
                  <DropdownMenuItem>Last 7 days</DropdownMenuItem>
                  <DropdownMenuItem>Last 30 days</DropdownMenuItem>
                  <DropdownMenuItem>Last 90 days</DropdownMenuItem>
                  <DropdownMenuItem>Custom range</DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
              <Button variant="outline" size="icon">
                <Download className="h-4 w-4" />
                <span className="sr-only">Download</span>
              </Button>
              <Button variant="outline" size="icon" onClick={toggleTheme}>
                {theme === "light" ? <Moon className="h-4 w-4" /> : <Sun className="h-4 w-4" />}
                <span className="sr-only">Toggle theme</span>
              </Button>
            </div>
          </div>
        </header>
        <main className="flex-1 p-4 md:p-6">
          <Tabs defaultValue="customer-feedback">
            <TabsList className="mb-4">
              <TabsTrigger value="customer-feedback" className="flex items-center gap-2">
                <MessageSquare className="h-4 w-4" />
                <span className="hidden sm:inline">Customer Feedback</span>
              </TabsTrigger>
              <TabsTrigger value="employee-performance" className="flex items-center gap-2">
                <Users className="h-4 w-4" />
                <span className="hidden sm:inline">Employee Performance</span>
              </TabsTrigger>
              <TabsTrigger value="incentives" className="flex items-center gap-2">
                <Award className="h-4 w-4" />
                <span className="hidden sm:inline">Incentives & Rewards</span>
              </TabsTrigger>
              <TabsTrigger value="trends" className="flex items-center gap-2">
                <TrendingUp className="h-4 w-4" />
                <span className="hidden sm:inline">Performance Trends</span>
              </TabsTrigger>
            </TabsList>

            {/* Customer Feedback Tab */}
            <TabsContent value="customer-feedback">
              <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                <Card className="col-span-1 lg:col-span-2">
                  <CardHeader>
                    <CardTitle>Customer Satisfaction Trend</CardTitle>
                    <CardDescription>Monthly CSAT scores over time</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="h-80">
                      <ResponsiveLine
                        data={[
                          {
                            id: "CSAT Score",
                            data: csatData.map((d) => ({ x: d.month, y: d.score })),
                          },
                        ]}
                        margin={{ top: 20, right: 20, bottom: 50, left: 60 }}
                        xScale={{ type: "point" }}
                        yScale={{
                          type: "linear",
                          min: 3.5,
                          max: 5,
                          stacked: false,
                          reverse: false,
                        }}
                        axisTop={null}
                        axisRight={null}
                        axisBottom={{
                          tickSize: 5,
                          tickPadding: 5,
                          tickRotation: 0,
                          legend: "Month",
                          legendOffset: 36,
                          legendPosition: "middle",
                        }}
                        axisLeft={{
                          tickSize: 5,
                          tickPadding: 5,
                          tickRotation: 0,
                          legend: "CSAT Score",
                          legendOffset: -40,
                          legendPosition: "middle",
                        }}
                        colors={{ scheme: "category10" }}
                        pointSize={10}
                        pointColor={{ theme: "background" }}
                        pointBorderWidth={2}
                        pointBorderColor={{ from: "serieColor" }}
                        pointLabelYOffset={-12}
                        useMesh={true}
                        legends={[
                          {
                            anchor: "bottom",
                            direction: "row",
                            justify: false,
                            translateX: 0,
                            translateY: 50,
                            itemsSpacing: 0,
                            itemDirection: "left-to-right",
                            itemWidth: 80,
                            itemHeight: 20,
                            itemOpacity: 0.75,
                            symbolSize: 12,
                            symbolShape: "circle",
                            symbolBorderColor: "rgba(0, 0, 0, .5)",
                            effects: [
                              {
                                on: "hover",
                                style: {
                                  itemBackground: "rgba(0, 0, 0, .03)",
                                  itemOpacity: 1,
                                },
                              },
                            ],
                          },
                        ]}
                      />
                    </div>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader>
                    <CardTitle>Top Customer Issues</CardTitle>
                    <CardDescription>Most common complaints</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="h-80">
                      <ResponsivePie
                        data={topIssuesData.map((item) => ({
                          id: item.name,
                          label: item.name,
                          value: item.value,
                        }))}
                        margin={{ top: 40, right: 80, bottom: 80, left: 80 }}
                        innerRadius={0.5}
                        padAngle={0.7}
                        cornerRadius={3}
                        activeOuterRadiusOffset={8}
                        borderWidth={1}
                        borderColor={{ from: "color", modifiers: [["darker", 0.2]] }}
                        arcLinkLabelsSkipAngle={10}
                        arcLinkLabelsTextColor={{ theme: "labels.text.fill" }}
                        arcLinkLabelsThickness={2}
                        arcLinkLabelsColor={{ from: "color" }}
                        arcLabelsSkipAngle={10}
                        arcLabelsTextColor={{ theme: "background" }}
                        colors={{ scheme: "category10" }}
                        legends={[
                          {
                            anchor: "bottom",
                            direction: "row",
                            justify: false,
                            translateX: 0,
                            translateY: 56,
                            itemsSpacing: 0,
                            itemWidth: 100,
                            itemHeight: 18,
                            itemTextColor: "#999",
                            itemDirection: "left-to-right",
                            itemOpacity: 1,
                            symbolSize: 18,
                            symbolShape: "circle",
                          },
                        ]}
                      />
                    </div>
                  </CardContent>
                </Card>
              </div>
              <div className="mt-4 grid gap-4 md:grid-cols-2">
                <Card>
                  <CardHeader>
                    <CardTitle>Common Feedback Themes</CardTitle>
                    <CardDescription>Word cloud of customer feedback</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="flex flex-wrap gap-2 p-4">
                      {[
                        "Wait Times",
                        "Product Knowledge",
                        "Friendly Staff",
                        "Resolution Speed",
                        "Follow-up",
                        "System Issues",
                        "Professionalism",
                        "Communication",
                        "Clarity",
                        "Helpfulness",
                        "Responsiveness",
                        "Accuracy",
                        "Empathy",
                        "Technical Support",
                        "Billing Issues",
                      ].map((word, i) => (
                        <div
                          key={i}
                          className="rounded-full bg-primary/10 px-3 py-1 text-sm font-medium"
                          style={{
                            fontSize: `${Math.random() * 0.8 + 0.8}rem`,
                            opacity: Math.random() * 0.5 + 0.5,
                          }}
                        >
                          {word}
                        </div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader>
                    <CardTitle>Feedback Analysis</CardTitle>
                    <CardDescription>Sentiment breakdown</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="h-64">
                      <ResponsiveBar
                        data={[
                          { name: "Positive", value: 65 },
                          { name: "Neutral", value: 25 },
                          { name: "Negative", value: 10 },
                        ]}
                        keys={["value"]}
                        indexBy="name"
                        margin={{ top: 20, right: 20, bottom: 50, left: 60 }}
                        padding={0.3}
                        valueScale={{ type: "linear" }}
                        indexScale={{ type: "band", round: true }}
                        colors={({ id, data }) => {
                          if (data.name === "Positive") return "#4ade80"
                          if (data.name === "Neutral") return "#facc15"
                          return "#f87171"
                        }}
                        borderColor={{ from: "color", modifiers: [["darker", 1.6]] }}
                        axisTop={null}
                        axisRight={null}
                        axisBottom={{
                          tickSize: 5,
                          tickPadding: 5,
                          tickRotation: 0,
                          legend: "Sentiment",
                          legendPosition: "middle",
                          legendOffset: 32,
                        }}
                        axisLeft={{
                          tickSize: 5,
                          tickPadding: 5,
                          tickRotation: 0,
                          legend: "Percentage",
                          legendPosition: "middle",
                          legendOffset: -40,
                        }}
                        labelSkipWidth={12}
                        labelSkipHeight={12}
                        labelTextColor={{ from: "color", modifiers: [["darker", 1.6]] }}
                        role="application"
                      />
                    </div>
                  </CardContent>
                </Card>
              </div>
            </TabsContent>

            {/* Employee Performance Tab */}
            <TabsContent value="employee-performance">
              <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                <Card className="col-span-2">
                  <CardHeader>
                    <CardTitle>Top Performers</CardTitle>
                    <CardDescription>Based on resolution time and satisfaction</CardDescription>
                  </CardHeader>
                  <CardContent>
                    {/* Replace the Top Performers bar chart with Nivo Bar chart */}
                    <div className="h-80">
                      <ResponsiveBar
                        data={employeePerformanceData.map((emp) => ({
                          name: emp.name,
                          "Satisfaction Score": emp.satisfactionScore,
                          "Resolution Time": emp.resolutionTime,
                        }))}
                        keys={["Satisfaction Score", "Resolution Time"]}
                        indexBy="name"
                        margin={{ top: 20, right: 20, bottom: 50, left: 120 }}
                        padding={0.3}
                        layout="horizontal"
                        valueScale={{ type: "linear" }}
                        indexScale={{ type: "band", round: true }}
                        colors={{ scheme: "paired" }}
                        borderColor={{ from: "color", modifiers: [["darker", 1.6]] }}
                        axisTop={null}
                        axisRight={null}
                        axisBottom={{
                          tickSize: 5,
                          tickPadding: 5,
                          tickRotation: 0,
                          legend: "Value",
                          legendPosition: "middle",
                          legendOffset: 32,
                        }}
                        axisLeft={{
                          tickSize: 5,
                          tickPadding: 5,
                          tickRotation: 0,
                          legend: "Employee",
                          legendPosition: "middle",
                          legendOffset: -100,
                        }}
                        labelSkipWidth={12}
                        labelSkipHeight={12}
                        labelTextColor={{ from: "color", modifiers: [["darker", 1.6]] }}
                        legends={[
                          {
                            dataFrom: "keys",
                            anchor: "bottom",
                            direction: "row",
                            justify: false,
                            translateX: 0,
                            translateY: 50,
                            itemsSpacing: 2,
                            itemWidth: 100,
                            itemHeight: 20,
                            itemDirection: "left-to-right",
                            itemOpacity: 0.85,
                            symbolSize: 20,
                            effects: [
                              {
                                on: "hover",
                                style: {
                                  itemOpacity: 1,
                                },
                              },
                            ],
                          },
                        ]}
                      />
                    </div>
                  </CardContent>
                </Card>
                <Card className="col-span-2">
                  <CardHeader>
                    <CardTitle>Call Volume Handled</CardTitle>
                    <CardDescription>Total calls handled by each agent</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="h-80">
                      <ResponsiveBar
                        data={employeePerformanceData.map((emp) => ({
                          name: emp.name,
                          "Calls Handled": emp.callsHandled,
                        }))}
                        keys={["Calls Handled"]}
                        indexBy="name"
                        margin={{ top: 20, right: 20, bottom: 50, left: 60 }}
                        padding={0.3}
                        valueScale={{ type: "linear" }}
                        indexScale={{ type: "band", round: true }}
                        colors={{ scheme: "purple_blue" }}
                        borderColor={{ from: "color", modifiers: [["darker", 1.6]] }}
                        axisTop={null}
                        axisRight={null}
                        axisBottom={{
                          tickSize: 5,
                          tickPadding: 5,
                          tickRotation: 0,
                          legend: "Employee",
                          legendPosition: "middle",
                          legendOffset: 32,
                        }}
                        axisLeft={{
                          tickSize: 5,
                          tickPadding: 5,
                          tickRotation: 0,
                          legend: "Calls Handled",
                          legendPosition: "middle",
                          legendOffset: -40,
                        }}
                        labelSkipWidth={12}
                        labelSkipHeight={12}
                        labelTextColor={{ from: "color", modifiers: [["darker", 1.6]] }}
                        role="application"
                      />
                    </div>
                  </CardContent>
                </Card>
              </div>
              <div className="mt-4">
                <Card>
                  <CardHeader>
                    <CardTitle>Employee Performance Details</CardTitle>
                    <CardDescription>Detailed metrics for all agents</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>Name</TableHead>
                          <TableHead>Avg. Resolution Time (min)</TableHead>
                          <TableHead>Satisfaction Score</TableHead>
                          <TableHead>Calls Handled</TableHead>
                          <TableHead>First Call Resolution</TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {employeePerformanceData.map((employee) => (
                          <TableRow key={employee.name}>
                            <TableCell className="font-medium">{employee.name}</TableCell>
                            <TableCell>{employee.resolutionTime}</TableCell>
                            <TableCell>{employee.satisfactionScore}</TableCell>
                            <TableCell>{employee.callsHandled}</TableCell>
                            <TableCell>{Math.round(Math.random() * 20 + 75)}%</TableCell>
                          </TableRow>
                        ))}
                      </TableBody>
                    </Table>
                  </CardContent>
                </Card>
              </div>
            </TabsContent>

            {/* Incentives & Rewards Tab */}
            <TabsContent value="incentives">
              <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                <Card className="col-span-1 lg:col-span-2">
                  <CardHeader>
                    <CardTitle>Reward Eligibility</CardTitle>
                    <CardDescription>Performance-based bonus tiers</CardDescription>
                  </CardHeader>
                  <CardContent>
                    {/* Replace the Reward Eligibility bar chart with Nivo Bar chart */}
                    <div className="h-80">
                      <ResponsiveBar
                        data={employeePerformanceData.map((emp) => ({
                          name: emp.name,
                          "Bonus Points": Math.round(emp.satisfactionScore * 20 + (250 - emp.resolutionTime) * 0.5),
                        }))}
                        keys={["Bonus Points"]}
                        indexBy="name"
                        margin={{ top: 20, right: 20, bottom: 50, left: 60 }}
                        padding={0.3}
                        valueScale={{ type: "linear" }}
                        indexScale={{ type: "band", round: true }}
                        colors={({ id, data, index }) => {
                          if (index === 0) return "#FFD700"
                          if (index === 1) return "#C0C0C0"
                          if (index === 2) return "#CD7F32"
                          return "#8884d8"
                        }}
                        borderColor={{ from: "color", modifiers: [["darker", 1.6]] }}
                        axisTop={null}
                        axisRight={null}
                        axisBottom={{
                          tickSize: 5,
                          tickPadding: 5,
                          tickRotation: 0,
                          legend: "Employee",
                          legendPosition: "middle",
                          legendOffset: 32,
                        }}
                        axisLeft={{
                          tickSize: 5,
                          tickPadding: 5,
                          tickRotation: 0,
                          legend: "Bonus Points",
                          legendPosition: "middle",
                          legendOffset: -40,
                        }}
                        labelSkipWidth={12}
                        labelSkipHeight={12}
                        labelTextColor={{ from: "color", modifiers: [["darker", 1.6]] }}
                        role="application"
                      />
                    </div>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader>
                    <CardTitle>Reward Tiers</CardTitle>
                    <CardDescription>Bonus structure</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-4">
                      <div className="flex items-center justify-between rounded-lg bg-primary/10 p-3">
                        <div className="flex items-center gap-2">
                          <div className="rounded-full bg-yellow-500 p-1.5">
                            <Award className="h-4 w-4 text-primary-foreground" />
                          </div>
                          <span className="font-medium">Gold Tier</span>
                        </div>
                        <span>$500 Bonus</span>
                      </div>
                      <div className="flex items-center justify-between rounded-lg bg-primary/10 p-3">
                        <div className="flex items-center gap-2">
                          <div className="rounded-full bg-gray-300 p-1.5">
                            <Award className="h-4 w-4 text-primary-foreground" />
                          </div>
                          <span className="font-medium">Silver Tier</span>
                        </div>
                        <span>$300 Bonus</span>
                      </div>
                      <div className="flex items-center justify-between rounded-lg bg-primary/10 p-3">
                        <div className="flex items-center gap-2">
                          <div className="rounded-full bg-amber-700 p-1.5">
                            <Award className="h-4 w-4 text-primary-foreground" />
                          </div>
                          <span className="font-medium">Bronze Tier</span>
                        </div>
                        <span>$150 Bonus</span>
                      </div>
                      <div className="flex items-center justify-between rounded-lg bg-primary/10 p-3">
                        <div className="flex items-center gap-2">
                          <div className="rounded-full bg-blue-500 p-1.5">
                            <Award className="h-4 w-4 text-primary-foreground" />
                          </div>
                          <span className="font-medium">Standard Tier</span>
                        </div>
                        <span>$50 Bonus</span>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </div>
              <div className="mt-4">
                <Card>
                  <CardHeader>
                    <CardTitle>Leaderboard</CardTitle>
                    <CardDescription>Top performers this month</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>Rank</TableHead>
                          <TableHead>Name</TableHead>
                          <TableHead>Performance Score</TableHead>
                          <TableHead>Bonus Tier</TableHead>
                          <TableHead>Bonus Amount</TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {employeePerformanceData
                          .sort((a, b) => b.satisfactionScore - a.satisfactionScore)
                          .map((employee, index) => (
                            <TableRow key={employee.name}>
                              <TableCell className="font-medium">{index + 1}</TableCell>
                              <TableCell>{employee.name}</TableCell>
                              <TableCell>{(employee.satisfactionScore * 20).toFixed(1)}</TableCell>
                              <TableCell>
                                {index === 0 ? (
                                  <span className="flex items-center gap-1 text-yellow-500">
                                    <Award className="h-4 w-4" /> Gold
                                  </span>
                                ) : index === 1 ? (
                                  <span className="flex items-center gap-1 text-gray-400">
                                    <Award className="h-4 w-4" /> Silver
                                  </span>
                                ) : index === 2 ? (
                                  <span className="flex items-center gap-1 text-amber-700">
                                    <Award className="h-4 w-4" /> Bronze
                                  </span>
                                ) : (
                                  <span className="flex items-center gap-1 text-blue-500">
                                    <Award className="h-4 w-4" /> Standard
                                  </span>
                                )}
                              </TableCell>
                              <TableCell>
                                {index === 0 ? "$500" : index === 1 ? "$300" : index === 2 ? "$150" : "$50"}
                              </TableCell>
                            </TableRow>
                          ))}
                      </TableBody>
                    </Table>
                  </CardContent>
                </Card>
              </div>
            </TabsContent>

            {/* Performance Trends Tab */}
            <TabsContent value="trends">
              <div className="mb-4 flex flex-col gap-4 sm:flex-row sm:items-center">
                <div className="flex items-center gap-2">
                  <Select defaultValue="weekly">
                    <SelectTrigger className="w-[180px]">
                      <SelectValue placeholder="Select period" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="daily">Daily</SelectItem>
                      <SelectItem value="weekly">Weekly</SelectItem>
                      <SelectItem value="monthly">Monthly</SelectItem>
                      <SelectItem value="quarterly">Quarterly</SelectItem>
                    </SelectContent>
                  </Select>
                  <Button variant="outline" size="icon">
                    <Calendar className="h-4 w-4" />
                    <span className="sr-only">Calendar</span>
                  </Button>
                </div>
                <Button variant="outline" className="ml-auto">
                  <Download className="mr-2 h-4 w-4" />
                  Export Report
                </Button>
              </div>
              <div className="grid gap-4 md:grid-cols-2">
                <Card>
                  <CardHeader>
                    <CardTitle>Weekly Call Volume</CardTitle>
                    <CardDescription>Calls vs. Resolutions</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="h-80">
                      <ResponsiveBar
                        data={weeklyTrendsData.map((item) => ({
                          day: item.day,
                          "Total Calls": item.calls,
                          "Resolved Calls": item.resolutions,
                        }))}
                        keys={["Total Calls", "Resolved Calls"]}
                        indexBy="day"
                        margin={{ top: 20, right: 20, bottom: 50, left: 60 }}
                        padding={0.3}
                        groupMode="grouped"
                        valueScale={{ type: "linear" }}
                        indexScale={{ type: "band", round: true }}
                        colors={{ scheme: "paired" }}
                        borderColor={{ from: "color", modifiers: [["darker", 1.6]] }}
                        axisTop={null}
                        axisRight={null}
                        axisBottom={{
                          tickSize: 5,
                          tickPadding: 5,
                          tickRotation: 0,
                          legend: "Day",
                          legendPosition: "middle",
                          legendOffset: 32,
                        }}
                        axisLeft={{
                          tickSize: 5,
                          tickPadding: 5,
                          tickRotation: 0,
                          legend: "Count",
                          legendPosition: "middle",
                          legendOffset: -40,
                        }}
                        labelSkipWidth={12}
                        labelSkipHeight={12}
                        labelTextColor={{ from: "color", modifiers: [["darker", 1.6]] }}
                        legends={[
                          {
                            dataFrom: "keys",
                            anchor: "bottom",
                            direction: "row",
                            justify: false,
                            translateX: 0,
                            translateY: 50,
                            itemsSpacing: 2,
                            itemWidth: 100,
                            itemHeight: 20,
                            itemDirection: "left-to-right",
                            itemOpacity: 0.85,
                            symbolSize: 20,
                            effects: [
                              {
                                on: "hover",
                                style: {
                                  itemOpacity: 1,
                                },
                              },
                            ],
                          },
                        ]}
                      />
                    </div>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader>
                    <CardTitle>Resolution Rate Trend</CardTitle>
                    <CardDescription>Percentage of calls resolved</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="h-80">
                      <ResponsiveLine
                        data={[
                          {
                            id: "Resolution Rate",
                            data: weeklyTrendsData.map((item) => ({
                              x: item.day,
                              y: ((item.resolutions / item.calls) * 100).toFixed(1),
                            })),
                          },
                        ]}
                        margin={{ top: 20, right: 20, bottom: 50, left: 60 }}
                        xScale={{ type: "point" }}
                        yScale={{
                          type: "linear",
                          min: 80,
                          max: 100,
                          stacked: false,
                          reverse: false,
                        }}
                        axisTop={null}
                        axisRight={null}
                        axisBottom={{
                          tickSize: 5,
                          tickPadding: 5,
                          tickRotation: 0,
                          legend: "Day",
                          legendOffset: 36,
                          legendPosition: "middle",
                        }}
                        axisLeft={{
                          tickSize: 5,
                          tickPadding: 5,
                          tickRotation: 0,
                          legend: "Resolution Rate (%)",
                          legendOffset: -40,
                          legendPosition: "middle",
                        }}
                        colors={{ scheme: "category10" }}
                        pointSize={10}
                        pointColor={{ theme: "background" }}
                        pointBorderWidth={2}
                        pointBorderColor={{ from: "serieColor" }}
                        pointLabelYOffset={-12}
                        useMesh={true}
                        legends={[
                          {
                            anchor: "bottom",
                            direction: "row",
                            justify: false,
                            translateX: 0,
                            translateY: 50,
                            itemsSpacing: 0,
                            itemDirection: "left-to-right",
                            itemWidth: 80,
                            itemHeight: 20,
                            itemOpacity: 0.75,
                            symbolSize: 12,
                            symbolShape: "circle",
                            symbolBorderColor: "rgba(0, 0, 0, .5)",
                            effects: [
                              {
                                on: "hover",
                                style: {
                                  itemBackground: "rgba(0, 0, 0, .03)",
                                  itemOpacity: 1,
                                },
                              },
                            ],
                          },
                        ]}
                      />
                    </div>
                  </CardContent>
                </Card>
              </div>
              <div className="mt-4">
                <Card>
                  <CardHeader>
                    <CardTitle>Performance Metrics Over Time</CardTitle>
                    <CardDescription>Key metrics trend analysis</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="h-80">
                      <ResponsiveLine
                        data={[
                          {
                            id: "CSAT Score",
                            data: [
                              { x: "Jan", y: 4.2 },
                              { x: "Feb", y: 4.3 },
                              { x: "Mar", y: 4.1 },
                              { x: "Apr", y: 4.4 },
                              { x: "May", y: 4.6 },
                              { x: "Jun", y: 4.5 },
                            ],
                          },
                          {
                            id: "Avg. Resolution Time",
                            data: [
                              { x: "Jan", y: 15 },
                              { x: "Feb", y: 14 },
                              { x: "Mar", y: 16 },
                              { x: "Apr", y: 13 },
                              { x: "May", y: 12 },
                              { x: "Jun", y: 12.5 },
                            ],
                          },
                          {
                            id: "First Call Resolution",
                            data: [
                              { x: "Jan", y: 78 },
                              { x: "Feb", y: 80 },
                              { x: "Mar", y: 75 },
                              { x: "Apr", y: 82 },
                              { x: "May", y: 85 },
                              { x: "Jun", y: 83 },
                            ],
                          },
                        ]}
                        margin={{ top: 20, right: 20, bottom: 50, left: 60 }}
                        xScale={{ type: "point" }}
                        yScale={{
                          type: "linear",
                          min: "auto",
                          max: "auto",
                          stacked: false,
                          reverse: false,
                        }}
                        axisTop={null}
                        axisRight={null}
                        axisBottom={{
                          tickSize: 5,
                          tickPadding: 5,
                          tickRotation: 0,
                          legend: "Month",
                          legendOffset: 36,
                          legendPosition: "middle",
                        }}
                        axisLeft={{
                          tickSize: 5,
                          tickPadding: 5,
                          tickRotation: 0,
                          legend: "Value",
                          legendOffset: -40,
                          legendPosition: "middle",
                        }}
                        colors={{ scheme: "category10" }}
                        pointSize={10}
                        pointColor={{ theme: "background" }}
                        pointBorderWidth={2}
                        pointBorderColor={{ from: "serieColor" }}
                        pointLabelYOffset={-12}
                        useMesh={true}
                        legends={[
                          {
                            anchor: "bottom",
                            direction: "row",
                            justify: false,
                            translateX: 0,
                            translateY: 50,
                            itemsSpacing: 0,
                            itemDirection: "left-to-right",
                            itemWidth: 100,
                            itemHeight: 20,
                            itemOpacity: 0.75,
                            symbolSize: 12,
                            symbolShape: "circle",
                            symbolBorderColor: "rgba(0, 0, 0, .5)",
                            effects: [
                              {
                                on: "hover",
                                style: {
                                  itemBackground: "rgba(0, 0, 0, .03)",
                                  itemOpacity: 1,
                                },
                              },
                            ],
                          },
                        ]}
                      />
                    </div>
                  </CardContent>
                </Card>
              </div>
            </TabsContent>
          </Tabs>
        </main>
      </div>
    </div>
  )
}

