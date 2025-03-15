export interface Customer {
    id: string
    name: string
    age: number
    location: string
    profilePhoto: string
    priority: string
    creditScore: number
    totalAssets: number
    totalLiabilities: number
    spendingVsIncome: {
      month: string
      income: number
      spending: number
    }[]
    loanHistory: {
      totalTaken: number
      totalRepaid: number
      totalOutstanding: number
      emiPaymentHistory: {
        month: string
        onTime: boolean
      }[]
    }
    creditCardUtilization: {
      [key: string]: number
    }
    spendingPatterns: SpendingPattern
    transactions: Transaction[]
    anomalies: string[]
    aiInsights: {
      financialHealthScore: number
      investmentSuggestions: {
        name: string
        description: string
        riskLevel: string
        expectedReturn: number
        minInvestment: number
      }[]
      loanRecommendations: {
        type: string
        description: string
        amount: number
        interestRate: number
        term: string
        emi: number
      }[]
      debtRepaymentPlan: {
        currentPlan: {
          month: string
          amount: number
        }[]
        optimizedPlan: {
          month: string
          amount: number
        }[]
        totalSavings: number
      }
      upcomingPayments: {
        description: string
        dueDate: string
        amount: number
        isOverdue: boolean
      }[]
    }
  }
  
  export interface Transaction {
    id: string
    date: string
    description: string
    merchant: string
    category: string
    amount: number
    type: string
    isAnomalous: boolean
  }
  
  export interface Loan {
    id: string
    type: string
    startDate: string
    endDate: string | null
    amount: number
    interestRate: number
    amountPaid: number
    status: string
  }
  
  export interface SpendingPattern {
    monthlyExpenditure: any
    recurringPayments: any
    byCategory: {
      [key: string]: number
    }
    monthly: {
      month: string
      amount: number
    }[]
  }
  
  