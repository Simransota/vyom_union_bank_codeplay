"use client"

import { ResponsivePie } from "@nivo/pie"
import { ResponsiveBar } from "@nivo/bar"
import { Card, CardContent } from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import type { Customer } from "@/lib/types"
import { formatCurrency } from "@/lib/utils"

interface KeyFinancialMetricsProps {
  customer: Customer
}

export default function KeyFinancialMetrics({ customer }: KeyFinancialMetricsProps) {
  // Assets vs Liabilities Data
  const assetsLiabilitiesData = [
    {
      id: "Assets",
      label: "Assets",
      value: customer.totalAssets,
      color: "hsl(152, 70%, 50%)",
    },
    {
      id: "Liabilities",
      label: "Liabilities",
      value: customer.totalLiabilities,
      color: "hsl(0, 70%, 50%)",
    },
  ]

  // Spending vs Income Data
  const spendingIncomeData = customer.spendingVsIncome.map((item) => ({
    month: item.month,
    Income: item.income,
    Spending: item.spending,
  }))

  return (
    <div className="space-y-2">
      <Tabs defaultValue="credit-score">
        <TabsList className="grid w-full grid-cols-3">
          <TabsTrigger value="credit-score">Credit Score</TabsTrigger>
          <TabsTrigger value="assets-liabilities">Assets vs Liabilities</TabsTrigger>
          <TabsTrigger value="spending-income">Spending vs Income</TabsTrigger>
        </TabsList>

        <TabsContent value="credit-score">
          <Card>
            <CardContent className="p-4">
              <div className="h-40 relative">
                {/* Custom Credit Score Gauge */}
                <div className="absolute inset-0 flex flex-col items-center justify-center">
                  <div className="relative w-32 h-16 overflow-hidden">
                    <div className="absolute inset-0 bg-gray-200 rounded-t-full"></div>
                    <div
                      className="absolute bottom-0 bg-gradient-to-r from-red-500 via-yellow-500 to-green-500 rounded-t-full"
                      style={{
                        width: "100%",
                        height: "100%",
                        clipPath: `polygon(0 0, 100% 0, 100% 100%, 0% 100%)`,
                      }}
                    ></div>
                    <div
                      className="absolute bottom-0 left-1/2 w-1 h-8 bg-black transform -translate-x-1/2"
                      style={{
                        transform: `translateX(${((customer.creditScore - 300) / (850 - 300)) * 100 - 50}%) rotate(0deg)`,
                        transformOrigin: "bottom center",
                      }}
                    ></div>
                  </div>
                  <div className="text-center mt-4">
                    <div className="text-2xl font-bold">{customer.creditScore}</div>
                    <div className="text-xs text-muted-foreground mt-1">
                      {customer.creditScore < 580
                        ? "Poor"
                        : customer.creditScore < 670
                          ? "Fair"
                          : customer.creditScore < 740
                            ? "Good"
                            : customer.creditScore < 800
                              ? "Very Good"
                              : "Excellent"}
                    </div>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="assets-liabilities">
          <Card>
            <CardContent className="p-4">
              <div className="h-40">
                <ResponsivePie
                  data={assetsLiabilitiesData}
                  margin={{ top: 10, right: 10, bottom: 10, left: 10 }}
                  innerRadius={0.5}
                  padAngle={0.7}
                  cornerRadius={3}
                  activeOuterRadiusOffset={8}
                  colors={{ scheme: "set2" }}
                  borderWidth={1}
                  borderColor={{ from: "color", modifiers: [["darker", 0.2]] }}
                  arcLabelsSkipAngle={10}
                  arcLabelsTextColor={{ from: "color", modifiers: [["darker", 2]] }}
                  theme={{
                    labels: {
                      text: {
                        fill: "var(--foreground)",
                      },
                    },
                    tooltip: {
                      container: {
                        background: "var(--background)",
                        color: "var(--foreground)",
                        fontSize: 12,
                      },
                    },
                  }}
                />
              </div>
              <div className="grid grid-cols-2 gap-2 mt-2 text-center">
                <div>
                  <div className="text-sm font-medium">Total Assets</div>
                  <div className="text-lg font-bold text-green-600">{formatCurrency(customer.totalAssets)}</div>
                </div>
                <div>
                  <div className="text-sm font-medium">Total Liabilities</div>
                  <div className="text-lg font-bold text-red-600">{formatCurrency(customer.totalLiabilities)}</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="spending-income">
          <Card>
            <CardContent className="p-4">
              <div className="h-40">
                <ResponsiveBar
                  data={spendingIncomeData}
                  keys={["Income", "Spending"]}
                  indexBy="month"
                  margin={{ top: 10, right: 10, bottom: 20, left: 40 }}
                  padding={0.3}
                  groupMode="grouped"
                  valueScale={{ type: "linear" }}
                  indexScale={{ type: "band", round: true }}
                  colors={["#22c55e", "#ef4444"]}
                  borderColor={{ from: "color", modifiers: [["darker", 1.6]] }}
                  axisTop={null}
                  axisRight={null}
                  axisBottom={{
                    tickSize: 5,
                    tickPadding: 5,
                    tickRotation: 0,
                  }}
                  axisLeft={{
                    tickSize: 5,
                    tickPadding: 5,
                    tickRotation: 0,
                    format: (value) => `$${value / 1000}k`,
                  }}
                  labelSkipWidth={12}
                  labelSkipHeight={12}
                  labelTextColor={{ from: "color", modifiers: [["darker", 1.6]] }}
                  theme={{
                    text: {
                      fill: "var(--foreground)",
                    },
                    axis: {
                      domain: {
                        line: {
                          stroke: "var(--muted-foreground)",
                        },
                      },
                      ticks: {
                        line: {
                          stroke: "var(--muted-foreground)",
                        },
                        text: {
                          fill: "var(--muted-foreground)",
                        },
                      },
                    },
                    grid: {
                      line: {
                        stroke: "var(--border)",
                      },
                    },
                    tooltip: {
                      container: {
                        background: "var(--background)",
                        color: "var(--foreground)",
                        fontSize: 12,
                      },
                    },
                  }}
                  tooltip={({ id, value, color }) => (
                    <div
                      style={{
                        padding: 12,
                        background: "var(--background)",
                        color: "var(--foreground)",
                        border: "1px solid var(--border)",
                        borderRadius: 4,
                      }}
                    >
                      <span style={{ color }}>●</span> {id}: {formatCurrency(value)}
                    </div>
                  )}
                />
              </div>
              <div className="text-center mt-2">
                <div className="text-sm font-medium">6-Month Trend</div>
                <div className="text-xs text-muted-foreground mt-1">
                  {customer.spendingVsIncome[5].income > customer.spendingVsIncome[5].spending
                    ? "Positive cash flow in the latest month"
                    : "Negative cash flow in the latest month"}
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  )
}

