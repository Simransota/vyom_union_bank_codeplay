"use client"

import { ResponsivePie } from "@nivo/pie"
import { ResponsiveLine } from "@nivo/line"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import type { Customer } from "@/lib/types"
import { formatCurrency } from "@/lib/utils"
import { ReactElement, JSXElementConstructor, ReactNode, ReactPortal, Key } from "react"

interface SpendingPatternsProps {
  customer: Customer
}

export default function SpendingPatterns({ customer }: SpendingPatternsProps) {
  // Category-wise breakdown data for Pie Chart
  const categoryData = Object.entries(customer.spendingPatterns.byCategory).map(([category, amount]) => ({
    id: category,
    label: category,
    value: amount,
  }))

  // Monthly expenditure data for Line Chart
  const monthlyExpenditureData = [
    {
      id: "Monthly Expenditure",
      color: "hsl(211, 70%, 50%)",
      data: customer.spendingPatterns.monthlyExpenditure.map((item: { month: any; amount: any }) => ({
        x: item.month,
        y: item.amount,
      })),
    },
  ]

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-base">Category-Wise Breakdown</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="h-64">
            <ResponsivePie
              data={categoryData}
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
              legends={[
                {
                  anchor: "right",
                  direction: "column",
                  justify: false,
                  translateX: 0,
                  translateY: 0,
                  itemWidth: 100,
                  itemHeight: 20,
                  itemsSpacing: 0,
                  symbolSize: 20,
                  itemDirection: "left-to-right",
                  symbolShape: "circle",
                  effects: [
                    {
                      on: "hover",
                      style: {
                        itemTextColor: "var(--foreground)",
                      },
                    },
                  ],
                },
              ]}
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
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-base">Monthly Expenditure Trends</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="h-64">
            <ResponsiveLine
              data={monthlyExpenditureData}
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
        </CardContent>
      </Card>

      <Card className="md:col-span-2">
        <CardHeader className="pb-2">
          <CardTitle className="text-base">Recurring Payments & Subscriptions</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Service</TableHead>
                <TableHead>Category</TableHead>
                <TableHead>Frequency</TableHead>
                <TableHead className="text-right">Amount</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {customer.spendingPatterns.recurringPayments.map((payment: { service: string | number | bigint | boolean | ReactElement<unknown, string | JSXElementConstructor<any>> | Iterable<ReactNode> | ReactPortal | Promise<string | number | bigint | boolean | ReactPortal | ReactElement<unknown, string | JSXElementConstructor<any>> | Iterable<ReactNode> | null | undefined> | null | undefined; category: string | number | bigint | boolean | ReactElement<unknown, string | JSXElementConstructor<any>> | Iterable<ReactNode> | ReactPortal | Promise<string | number | bigint | boolean | ReactPortal | ReactElement<unknown, string | JSXElementConstructor<any>> | Iterable<ReactNode> | null | undefined> | null | undefined; frequency: string | number | bigint | boolean | ReactElement<unknown, string | JSXElementConstructor<any>> | Iterable<ReactNode> | ReactPortal | Promise<string | number | bigint | boolean | ReactPortal | ReactElement<unknown, string | JSXElementConstructor<any>> | Iterable<ReactNode> | null | undefined> | null | undefined; amount: number }, index: Key | null | undefined) => (
                <TableRow key={index}>
                  <TableCell className="font-medium">{payment.service}</TableCell>
                  <TableCell>{payment.category}</TableCell>
                  <TableCell>{payment.frequency}</TableCell>
                  <TableCell className="text-right">{formatCurrency(payment.amount)}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
          <div className="text-center mt-4">
            <div className="text-sm font-medium">Total Monthly Subscriptions</div>
            <div className="text-lg font-bold">
              {formatCurrency(
                customer.spendingPatterns.recurringPayments
                  .filter((payment: { frequency: string }) => payment.frequency === "Monthly")
                  .reduce((sum: any, payment: { amount: any }) => sum + payment.amount, 0),
              )}
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

