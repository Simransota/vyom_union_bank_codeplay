"use client"

import { Card, CardContent, CardHeader, CardTitle, CardFooter } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import {
  TrendingUp,
  CreditCard,
  AlertCircle,
  Gift,
  Calendar,
  Lightbulb,
  Percent,
  Home,
  Plane,
  Target,
} from "lucide-react"
import type { Customer } from "@/lib/types"
import { formatCurrency } from "@/lib/utils"

interface AiRecommendationsProps {
  customer: Customer
}

export default function AiRecommendations({ customer }: AiRecommendationsProps) {
  // Generate personalized loan offers based on customer data
  const getLoanOffers = () => {
    const offers = []

    // Personal loan offer
    if (customer.creditScore > 700) {
      const loanAmount = Math.min(customer.totalAssets * 0.2, 1000000)
      const interestRate = customer.creditScore > 750 ? 8.5 : 9.5
      offers.push({
        type: "personal",
        title: "Personal Loan",
        amount: loanAmount,
        interestRate: interestRate,
        description: `Pre-approved personal loan with competitive interest rate.`,
        icon: <CreditCard className="h-5 w-5" />,
      })
    }

    // Home loan offer
    if (customer.totalAssets > 500000 && customer.creditScore > 680) {
      const loanAmount = Math.min(customer.totalAssets * 0.8, 5000000)
      const interestRate = customer.creditScore > 750 ? 6.5 : 7.2
      offers.push({
        type: "home",
        title: "Home Loan",
        amount: loanAmount,
        interestRate: interestRate,
        description: `Eligible for home loan with low interest rate and flexible terms.`,
        icon: <Home className="h-5 w-5" />,
      })
    }

    // Education loan offer for younger customers
    if (customer.age < 35 && customer.creditScore > 650) {
      offers.push({
        type: "education",
        title: "Education Loan",
        amount: 500000,
        interestRate: 7.0,
        description: `Invest in your future with our education loan package.`,
        icon: <Target className="h-5 w-5" />,
      })
    }

    return offers
  }

  // Generate investment suggestions based on customer data
  const getInvestmentSuggestions = () => {
    const suggestions = []

    // Fixed deposit for conservative investors
    if (customer.spendingPatterns.byCategory.Savings > 0 || customer.totalAssets > 200000) {
      suggestions.push({
        type: "fd",
        title: "Fixed Deposit",
        returnRate: "6.5% p.a.",
        riskLevel: "Low",
        description: "Your savings habits suggest FD/RD is a safe option for you.",
        icon: <TrendingUp className="h-5 w-5" />,
      })
    }

    // Mutual funds for moderate risk takers
    if (customer.creditScore > 700 && customer.totalAssets > 300000) {
      suggestions.push({
        type: "mutual-fund",
        title: "Mutual Funds",
        returnRate: "10-12% p.a.",
        riskLevel: "Moderate",
        description: "Diversify your portfolio with our curated mutual fund options.",
        icon: <TrendingUp className="h-5 w-5" />,
      })
    }

    // Equity for high risk takers
    if (customer.creditScore > 750 && customer.totalAssets > 500000) {
      suggestions.push({
        type: "equity",
        title: "Equity Investment",
        returnRate: "15-18% p.a.",
        riskLevel: "High",
        description: "Maximize returns with our premium equity investment plans.",
        icon: <TrendingUp className="h-5 w-5" />,
      })
    }

    return suggestions
  }

  // Generate financial nudges based on customer behavior
  const getFinancialNudges = () => {
    const nudges = []

    // Credit card upgrade suggestion
    if (customer.creditScore > 720) {
      nudges.push({
        type: "credit-card",
        title: "Premium Credit Card",
        description: "Your usage pattern makes you eligible for a premium rewards card.",
        icon: <CreditCard className="h-5 w-5" />,
      })
    }

    // Shopping card suggestion
    if (customer.spendingPatterns.byCategory.Shopping > 10000) {
      nudges.push({
        type: "shopping",
        title: "Cashback Card",
        description: "You spent ₹15K on shopping last month. A UBI cashback card can save you 5%.",
        icon: <Percent className="h-5 w-5" />,
      })
    }

    // EMI reminder
    if (customer.loanHistory.totalOutstanding > 0) {
      nudges.push({
        type: "emi",
        title: "EMI Payment Reminder",
        description: "Your EMI is due in 3 days. Avoid late fees by setting up auto-pay.",
        icon: <AlertCircle className="h-5 w-5" />,
      })
    }

    return nudges
  }

  // Generate exclusive offers based on customer profile
  const getExclusiveOffers = () => {
    const offers = []

    // Insurance discount
    offers.push({
      type: "insurance",
      title: "Health Insurance Discount",
      description: "As a loyal UBI customer, get 20% off on health insurance premiums.",
      icon: <Gift className="h-5 w-5" />,
    })

    // Travel card for frequent travelers
    if (customer.spendingPatterns.byCategory.Travel > 5000) {
      offers.push({
        type: "travel",
        title: "Travel Credit Card",
        description: "Frequent traveler? Get 5X rewards on flight and hotel bookings.",
        icon: <Plane className="h-5 w-5" />,
      })
    }

    // Festive offer
    const currentMonth = new Date().getMonth()
    if (currentMonth >= 9 && currentMonth <= 11) {
      // October to December
      offers.push({
        type: "festive",
        title: "Festive Season Offer",
        description: "Get an instant ₹500 cashback on UPI transactions above ₹5000.",
        icon: <Calendar className="h-5 w-5" />,
      })
    }

    return offers
  }

  const loanOffers = getLoanOffers()
  const investmentSuggestions = getInvestmentSuggestions()
  const financialNudges = getFinancialNudges()
  const exclusiveOffers = getExclusiveOffers()

  return (
    <div className="space-y-4 h-full overflow-auto">
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-base flex items-center gap-2">
            <Lightbulb className="h-4 w-4 text-yellow-500" />
            AI-Powered Recommendations
          </CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          <Tabs defaultValue="loans" className="w-full">
            <TabsList className="grid w-full grid-cols-3">
              <TabsTrigger value="loans">Loans</TabsTrigger>
              <TabsTrigger value="investments">Investments</TabsTrigger>
              <TabsTrigger value="nudges">Nudges</TabsTrigger>
              {/* <TabsTrigger value="offers">Offers</TabsTrigger> */}
            </TabsList>

            <TabsContent value="loans" className="p-4 space-y-4">
              <h3 className="text-sm font-medium">Personalized Loan Offers</h3>
              {loanOffers.length > 0 ? (
                <div className="space-y-3">
                  {loanOffers.map((offer, index) => (
                    <div key={index} className="bg-muted/50 p-3 rounded-md">
                      <div className="flex items-center gap-2 mb-1">
                        {offer.icon}
                        <h4 className="font-medium">{offer.title}</h4>
                      </div>
                      <p className="text-sm text-muted-foreground mb-2">{offer.description}</p>
                      <div className="flex justify-between text-sm">
                        <span>Amount: {formatCurrency(offer.amount)}</span>
                        <span>Rate: {offer.interestRate}%</span>
                      </div>
                      <Button size="sm" className="w-full mt-2">
                        Apply Now
                      </Button>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="text-center p-4 text-muted-foreground">
                  No personalized loan offers available at this time.
                </div>
              )}
            </TabsContent>

            <TabsContent value="investments" className="p-4 space-y-4">
              <h3 className="text-sm font-medium">Investment Suggestions</h3>
              {investmentSuggestions.length > 0 ? (
                <div className="space-y-3">
                  {investmentSuggestions.map((suggestion, index) => (
                    <div key={index} className="bg-muted/50 p-3 rounded-md">
                      <div className="flex justify-between items-start">
                        <div className="flex items-center gap-2">
                          {suggestion.icon}
                          <h4 className="font-medium">{suggestion.title}</h4>
                        </div>
                        <Badge variant="outline">{suggestion.riskLevel} Risk</Badge>
                      </div>
                      <p className="text-sm text-muted-foreground my-2">{suggestion.description}</p>
                      <div className="text-sm">
                        <span>Expected Return: {suggestion.returnRate}</span>
                      </div>
                      <Button size="sm" className="w-full mt-2">
                        Explore
                      </Button>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="text-center p-4 text-muted-foreground">
                  No investment suggestions available at this time.
                </div>
              )}
            </TabsContent>

            <TabsContent value="nudges" className="p-4 space-y-4">
              <h3 className="text-sm font-medium">Financial Nudges</h3>
              {financialNudges.length > 0 ? (
                <div className="space-y-3">
                  {financialNudges.map((nudge, index) => (
                    <div key={index} className="bg-muted/50 p-3 rounded-md">
                      <div className="flex items-center gap-2 mb-1">
                        {nudge.icon}
                        <h4 className="font-medium">{nudge.title}</h4>
                      </div>
                      <p className="text-sm text-muted-foreground">{nudge.description}</p>
                      <Button size="sm" variant="outline" className="w-full mt-2">
                        {nudge.type === "emi" ? "Set Up Auto-Pay" : "Learn More"}
                      </Button>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="text-center p-4 text-muted-foreground">No financial nudges available at this time.</div>
              )}
            </TabsContent>

            <TabsContent value="offers" className="p-4 space-y-4">
              <h3 className="text-sm font-medium">Exclusive Offers</h3>
              {exclusiveOffers.length > 0 ? (
                <div className="space-y-3">
                  {exclusiveOffers.map((offer, index) => (
                    <div key={index} className="bg-muted/50 p-3 rounded-md">
                      <div className="flex items-center gap-2 mb-1">
                        {offer.icon}
                        <h4 className="font-medium">{offer.title}</h4>
                      </div>
                      <p className="text-sm text-muted-foreground">{offer.description}</p>
                      <Button size="sm" variant="outline" className="w-full mt-2">
                        Claim Offer
                      </Button>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="text-center p-4 text-muted-foreground">No exclusive offers available at this time.</div>
              )}
            </TabsContent>
          </Tabs>
        </CardContent>
        <CardFooter className="border-t p-4">
          <Button className="w-full">View All Recommendations</Button>
        </CardFooter>
      </Card>
    </div>
  )
}

