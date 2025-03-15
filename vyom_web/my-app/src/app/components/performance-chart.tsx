"use client"

import { Bar, BarChart, CartesianGrid, Legend, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts"

const data = [
  {
    name: "Mon",
    "Resolution Time (min)": 45,
    "Customer Satisfaction": 85,
  },
  {
    name: "Tue",
    "Resolution Time (min)": 38,
    "Customer Satisfaction": 88,
  },
  {
    name: "Wed",
    "Resolution Time (min)": 42,
    "Customer Satisfaction": 86,
  },
  {
    name: "Thu",
    "Resolution Time (min)": 35,
    "Customer Satisfaction": 90,
  },
  {
    name: "Fri",
    "Resolution Time (min)": 40,
    "Customer Satisfaction": 87,
  },
  {
    name: "Sat",
    "Resolution Time (min)": 30,
    "Customer Satisfaction": 92,
  },
  {
    name: "Sun",
    "Resolution Time (min)": 28,
    "Customer Satisfaction": 94,
  },
]

export function PerformanceChart() {
  return (
    <div className="h-[300px] w-full">
      <ResponsiveContainer width="100%" height="100%">
        <BarChart
          data={data}
          margin={{
            top: 5,
            right: 30,
            left: 20,
            bottom: 5,
          }}
        >
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="name" />
          <YAxis yAxisId="left" orientation="left" stroke="#8884d8" />
          <YAxis yAxisId="right" orientation="right" stroke="#82ca9d" />
          <Tooltip />
          <Legend />
          <Bar yAxisId="left" dataKey="Resolution Time (min)" fill="#8884d8" />
          <Bar yAxisId="right" dataKey="Customer Satisfaction" fill="#82ca9d" />
        </BarChart>
      </ResponsiveContainer>
    </div>
  )
}

