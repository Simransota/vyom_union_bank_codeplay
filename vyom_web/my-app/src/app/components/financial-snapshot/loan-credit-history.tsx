"use client"

import { ResponsiveLine } from "@nivo/line"
import { ResponsivePie } from "@nivo/pie"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"
import type { Customer } from "@/lib/types"
import { formatCurrency } from "@/lib/utils"

interface LoanCreditHistoryProps {
  customer: Customer
}

export default function LoanCreditHistory({ customer }: LoanCreditHistoryProps) {
  // Past Loan Performance Data for Line Chart
  const pastLoanPerformanceData = [
    {
      id: "EMI Payments",
      color: "hsl(152, 70%, 50%)",
      data: customer.loanHistory.emiPaymentHistory.map((item) => ({
        x: item.month,
        y: item.onTime ? 1 : 0,
      })),
    },
  ]

  // Credit Card Utilization Data for Donut Chart
  const creditCardUtilizationData = Object.entries(customer.creditCardUtilization).map(([name, value]) => ({
    id: name,
    label: name,
    value,
  }))

  // Calculate percentage of loan repaid
  const repaidPercentage = (customer.loanHistory.totalRepaid / customer.loanHistory.totalTaken) * 100

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-base">Loan Overview</CardTitle>
        </CardHeader>
        <CardContent>
          {/* Custom Loan Overview visualization */}
          <div className="space-y-4">
            <div className="space-y-1">
              <div className="flex justify-between text-sm">
                <span>Total Taken</span>
                <span className="font-medium">{formatCurrency(customer.loanHistory.totalTaken)}</span>
              </div>
              <Progress value={100} className="h-2 bg-gray-200" />
            </div>

            <div className="space-y-1">
              <div className="flex justify-between text-sm">
                <span>Total Repaid</span>
                <span className="font-medium text-green-600">{formatCurrency(customer.loanHistory.totalRepaid)}</span>
              </div>
              <Progress value={repaidPercentage} className="h-2 bg-gray-200" />
            </div>

            <div className="space-y-1">
              <div className="flex justify-between text-sm">
                <span>Outstanding</span>
                <span className="font-medium text-red-600">
                  {formatCurrency(customer.loanHistory.totalOutstanding)}
                </span>
              </div>
              <Progress
                value={(customer.loanHistory.totalOutstanding / customer.loanHistory.totalTaken) * 100}
                className="h-2 bg-gray-200"
              />
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-base">Past Loan Performance</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="h-40">
            <ResponsiveLine
              data={pastLoanPerformanceData}
              margin={{ top: 10, right: 10, bottom: 30, left: 30 }}
              xScale={{ type: "point" }}
              yScale={{ type: "linear", min: 0, max: 1 }}
              curve="monotoneX"
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
                tickValues: [0, 1],
                format: (value) => (value === 1 ? "On Time" : "Late"),
              }}
              enableGridX={false}
              enableGridY={true}
              colors={["#22c55e"]}
              pointSize={10}
              pointColor={{ theme: "background" }}
              pointBorderWidth={2}
              pointBorderColor={{ from: "serieColor" }}
              enableArea={true}
              areaOpacity={0.15}
              useMesh={true}
              theme={{
                labels: {
                  text: {
                    fill: "var(--foreground)",
                  },
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
            />
          </div>
          <div className="text-center mt-2">
            <div className="text-xs text-muted-foreground">
              {customer.loanHistory.emiPaymentHistory.filter((item) => item.onTime).length} on-time payments out of{" "}
              {customer.loanHistory.emiPaymentHistory.length} in the last 6 months
            </div>
          </div>
        </CardContent>
      </Card>

      <Card className="md:col-span-2">
        <CardHeader className="pb-2">
          <CardTitle className="text-base">Credit Card Utilization</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="h-64">
            <ResponsivePie
              data={creditCardUtilizationData}
              margin={{ top: 40, right: 80, bottom: 40, left: 80 }}
              innerRadius={0.5}
              padAngle={0.7}
              cornerRadius={3}
              activeOuterRadiusOffset={8}
              colors={{ scheme: "paired" }}
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
    </div>
  )
}

