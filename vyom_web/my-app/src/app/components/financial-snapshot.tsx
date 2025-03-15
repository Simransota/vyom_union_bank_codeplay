"use client"

import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"
import { ResponsivePie } from "@nivo/pie"
import { ResponsiveLine } from "@nivo/line"
import type { Customer } from "@/lib/types"
import { formatCurrency, formatDate } from "@/lib/utils"

interface FinancialSnapshotProps {
  customer: Customer
}

export default function FinancialSnapshot({ customer }: FinancialSnapshotProps) {
  // Credit Score visualization
  const getCreditScoreColor = (score: number) => {
    if (score < 580) return "bg-red-500"
    if (score < 670) return "bg-orange-500"
    if (score < 740) return "bg-yellow-500"
    if (score < 800) return "bg-green-400"
    return "bg-green-600"
  }

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

  // Spending by Category Data
  const spendingCategoryData = Object.entries(customer.spendingPatterns.byCategory).map(([name, value]) => ({
    id: name,
    label: name,
    value,
    color: `hsl(${Math.floor(Math.random() * 360)}, 70%, 50%)`,
  }))

  // Monthly Spending Data
  const monthlySpendingData = [
    {
      id: "Monthly Spending",
      color: "hsl(211, 70%, 50%)",
      data: customer.spendingPatterns.monthlyExpenditure.map((item: { month: any; amount: any }) => ({
        x: item.month,
        y: item.amount,
      })),
    },
  ]

  return (
    <div className="space-y-4">
      <Card>
        <CardHeader>
          <CardTitle>Financial Snapshot</CardTitle>
          <CardDescription>Overview of {customer.name}'s financial health</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {/* Credit Score */}
            <div className="space-y-2">
              <h3 className="text-sm font-medium">Credit Score</h3>
              <div className="space-y-1">
                <div className="flex justify-between text-sm">
                  <span>Score</span>
                  <span className="font-medium">{customer.creditScore}/850</span>
                </div>
                <Progress
                  value={(customer.creditScore / 850) * 100}
                  className={`h-3 ${getCreditScoreColor(customer.creditScore)}`}
                />
                <div className="text-xs text-muted-foreground text-center">
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

            {/* Total Balance */}
            <div className="space-y-2">
              <h3 className="text-sm font-medium">Net Worth</h3>
              <div className="flex flex-col items-center justify-center h-20">
                <div className="text-2xl font-bold">
                  {formatCurrency(customer.totalAssets - customer.totalLiabilities)}
                </div>
                <div className="text-xs text-muted-foreground">
                  Assets: {formatCurrency(customer.totalAssets)} | Liabilities:{" "}
                  {formatCurrency(customer.totalLiabilities)}
                </div>
              </div>
            </div>

            {/* Monthly Income vs Spending */}
            <div className="space-y-2">
              <h3 className="text-sm font-medium">Monthly Cash Flow</h3>
              <div className="flex flex-col items-center justify-center h-20">
                <div className="text-2xl font-bold">
                  {formatCurrency(customer.spendingVsIncome[5].income - customer.spendingVsIncome[5].spending)}
                </div>
                <div className="text-xs text-muted-foreground">
                  Income: {formatCurrency(customer.spendingVsIncome[5].income)} | Spending:{" "}
                  {formatCurrency(customer.spendingVsIncome[5].spending)}
                </div>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      <Tabs defaultValue="assets">
        <TabsList className="grid grid-cols-3 mb-4">
          <TabsTrigger value="assets">Assets & Liabilities</TabsTrigger>
          <TabsTrigger value="spending">Spending Patterns</TabsTrigger>
          <TabsTrigger value="history">Transaction History</TabsTrigger>
        </TabsList>

        <TabsContent value="assets">
          <Card>
            <CardHeader>
              <CardTitle>Assets & Liabilities</CardTitle>
              <CardDescription>Balance sheet overview</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="h-80">
                <ResponsivePie
                  data={assetsLiabilitiesData}
                  margin={{ top: 40, right: 80, bottom: 40, left: 80 }}
                  innerRadius={0.5}
                  padAngle={0.7}
                  cornerRadius={3}
                  activeOuterRadiusOffset={8}
                  colors={{ scheme: "set2" }}
                  borderWidth={1}
                  borderColor={{ from: "color", modifiers: [["darker", 0.2]] }}
                  arcLinkLabelsSkipAngle={10}
                  arcLinkLabelsTextColor="var(--foreground)"
                  arcLinkLabelsThickness={2}
                  arcLinkLabelsColor={{ from: "color" }}
                  arcLabelsSkipAngle={10}
                  arcLabelsTextColor={{ from: "color", modifiers: [["darker", 2]] }}
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
                      itemTextColor: "var(--foreground)",
                      itemDirection: "left-to-right",
                      itemOpacity: 1,
                      symbolSize: 18,
                      symbolShape: "circle",
                    },
                  ]}
                  theme={{
                    text: {
                      fill: "var(--foreground)",
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
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="spending">
          <Card>
            <CardHeader>
              <CardTitle>Spending Patterns</CardTitle>
              <CardDescription>Analysis of spending habits</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="h-80">
                  <h3 className="text-sm font-medium mb-2">Spending by Category</h3>
                  <ResponsivePie
                    data={spendingCategoryData}
                    margin={{ top: 40, right: 80, bottom: 40, left: 80 }}
                    innerRadius={0.5}
                    padAngle={0.7}
                    cornerRadius={3}
                    activeOuterRadiusOffset={8}
                    colors={{ scheme: "category10" }}
                    borderWidth={1}
                    borderColor={{ from: "color", modifiers: [["darker", 0.2]] }}
                    arcLinkLabelsSkipAngle={10}
                    arcLinkLabelsTextColor="var(--foreground)"
                    arcLinkLabelsThickness={2}
                    arcLinkLabelsColor={{ from: "color" }}
                    arcLabelsSkipAngle={10}
                    arcLabelsTextColor={{ from: "color", modifiers: [["darker", 2]] }}
                    theme={{
                      text: {
                        fill: "var(--foreground)",
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
                <div className="h-80">
                  <h3 className="text-sm font-medium mb-2">Monthly Spending Trends</h3>
                  <ResponsiveLine
                    data={monthlySpendingData}
                    margin={{ top: 20, right: 20, bottom: 50, left: 50 }}
                    xScale={{ type: "point" }}
                    yScale={{ type: "linear", min: "auto", max: "auto", stacked: false, reverse: false }}
                    curve="cardinal"
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
                      legend: "Amount",
                      legendOffset: -40,
                      legendPosition: "middle",
                      format: (value) => `$${value / 1000}k`,
                    }}
                    enableGridX={false}
                    colors={["#3b82f6"]}
                    pointSize={10}
                    pointColor={{ theme: "background" }}
                    pointBorderWidth={2}
                    pointBorderColor={{ from: "serieColor" }}
                    pointLabelYOffset={-12}
                    useMesh={true}
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
                        legend: {
                          text: {
                            fill: "var(--muted-foreground)",
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
                    tooltip={({ point }) => (
                      <div
                        style={{
                          padding: 12,
                          background: "var(--background)",
                          color: "var(--foreground)",
                          border: "1px solid var(--border)",
                          borderRadius: 4,
                        }}
                      >
                        {String(point.data.x)}: {formatCurrency(point.data.y as number)}
                      </div>
                    )}
                  />
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="history">
          <Card>
            <CardHeader>
              <CardTitle>Transaction History</CardTitle>
              <CardDescription>Recent financial activity</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="overflow-x-auto">
                <table className="w-full border-collapse">
                  <thead>
                    <tr className="border-b">
                      <th className="text-left py-2 px-4 font-medium">Date</th>
                      <th className="text-left py-2 px-4 font-medium">Description</th>
                      <th className="text-left py-2 px-4 font-medium">Category</th>
                      <th className="text-right py-2 px-4 font-medium">Amount</th>
                    </tr>
                  </thead>
                  <tbody>
                    {customer.transactions.slice(0, 5).map((transaction) => (
                      <tr key={transaction.id} className="border-b">
                        <td className="py-2 px-4">{formatDate(transaction.date)}</td>
                        <td className="py-2 px-4">{transaction.description}</td>
                        <td className="py-2 px-4">{transaction.category}</td>
                        <td
                          className={`py-2 px-4 text-right ${
                            transaction.type === "credit" ? "text-green-600" : "text-red-600"
                          }`}
                        >
                          {transaction.type === "credit" ? "+" : "-"}
                          {formatCurrency(transaction.amount)}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  )
}

