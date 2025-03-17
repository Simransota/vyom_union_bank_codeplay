import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vyom/screens/voice_asstance/voice_chat_bubble.dart';

class CreditInsightsScreen extends StatefulWidget {
  const CreditInsightsScreen({Key? key}) : super(key: key);

  @override
  State<CreditInsightsScreen> createState() => _CreditInsightsScreenState();
}

class _CreditInsightsScreenState extends State<CreditInsightsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Insights'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: Stack(
        children: [Column(
          children: [
         
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCreditBreakdownTab(),
                  _buildFinancialHealthTab(),
                  _buildSpendingOptimizationTab(),
                ],
              ),
            ),
          ],
        ),
        //  VoiceChatBubble(
        //   onMessageReceived: (message) {
        //     // Handle received message
        //     print("Assistant: $message");
        //   },
        //   onUserMessage: (message) {
        //     // Handle user message
        //     print("User: $message");
        //   },
        // ),
        ],
      ),
    );
  }

 
  
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF233B99),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF233B99),
        tabs: const [
            Tab(
            icon: Icon(Icons.analytics_outlined),
            text: 'Breakdown',
          ),
          Tab(
            icon: Icon(Icons.health_and_safety_outlined),
            text: ' Health',
          ),
          Tab(
            icon: Icon(Icons.account_balance_wallet_outlined),
            text: 'Spending',
          ),
        ],
      ),
    );
  }

  Widget _buildCreditBreakdownTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Credit Score Analysis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF233B99),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Our AI has analyzed your credit history and identified the following factors affecting your score:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          
          // Credit factors breakdown
          _buildCreditFactorCard(
            icon: Icons.payment,
            title: 'Payment History',
            score: 'Moderate Impact',
            description: 'You have 2 late payments in the last 12 months. This is negatively affecting your score.',
            actionText: 'Set up automatic payments',
            impactPercentage: 35,
            impactColor: Colors.amber,
          ),
          
          _buildCreditFactorCard(
            icon: Icons.account_balance,
            title: 'Credit Utilization',
            score: 'High Impact',
            description: 'Your credit utilization is at 72%, which is above the recommended 30%.',
            actionText: 'Reduce your credit card balances',
            impactPercentage: 30,
            impactColor: Colors.redAccent,
          ),
          
          _buildCreditFactorCard(
            icon: Icons.history,
            title: 'Length of Credit History',
            score: 'Positive Impact',
            description: 'Your average account age is 6 years, which is good for your credit score.',
            actionText: 'Maintain your oldest accounts',
            impactPercentage: 15,
            impactColor: Colors.green,
          ),
          
          _buildCreditFactorCard(
            icon: Icons.add_card,
            title: 'New Credit',
            score: 'Slight Impact',
            description: 'You have 3 credit inquiries in the last 6 months, which may be affecting your score.',
            actionText: 'Limit new credit applications',
            impactPercentage: 10,
            impactColor: Colors.orangeAccent,
          ),
          
          _buildCreditFactorCard(
            icon: Icons.diversity_3,
            title: 'Credit Mix',
            score: 'Neutral Impact',
            description: 'You have a good mix of credit types including credit cards and a personal loan.',
            actionText: 'Maintain diverse credit types',
            impactPercentage: 10,
            impactColor: Colors.lightGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildCreditFactorCard({
    required IconData icon,
    required String title,
    required String score,
    required String description,
    required String actionText,
    required double impactPercentage,
    required Color impactColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF233B99)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: impactColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    score,
                    style: TextStyle(
                      color: impactColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: impactPercentage / 100,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(impactColor),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${impactPercentage.toInt()}% Impact',
                  style: TextStyle(
                    color: impactColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(actionText),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF233B99),
                side: const BorderSide(color: Color(0xFF233B99)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialHealthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personalized Financial Health Tips',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF233B99),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Based on your financial behavior, our AI has generated these personalized recommendations:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          
          // Financial health score
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Your Financial Health Score',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFinancialHealthIndicator(
                        'Debt-to-Income',
                        '42%',
                        Colors.orange,
                        Icons.trending_down,
                      ),
                      _buildFinancialHealthIndicator(
                        'Emergency Fund',
                        '1.5 months',
                        Colors.red,
                        Icons.warning_amber,
                      ),
                      _buildFinancialHealthIndicator(
                        'Savings Rate',
                        '8%',
                        Colors.amber,
                        Icons.savings,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Priority recommendations
          const Text(
            'Priority Recommendations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF233B99),
            ),
          ),
          const SizedBox(height: 12),
          
          _buildRecommendationCard(
            title: 'Build Your Emergency Fund',
            description: 'Your emergency fund covers only 1.5 months of expenses. Aim for 3-6 months.',
            actionText: 'Create Savings Plan',
            priority: 'High Priority',
            priorityColor: Colors.red,
            icon: Icons.account_balance,
          ),
          
          _buildRecommendationCard(
            title: 'Reduce Credit Card Debt',
            description: 'You\'re paying approximately ₹12,000 in interest annually on your credit cards.',
            actionText: 'View Debt Reduction Plan',
            priority: 'High Priority',
            priorityColor: Colors.red,
            icon: Icons.credit_card,
          ),
          
          _buildRecommendationCard(
            title: 'Optimize Tax Savings',
            description: 'You could save up to ₹32,000 annually by maximizing your tax-saving investments.',
            actionText: 'Explore Tax Options',
            priority: 'Medium Priority',
            priorityColor: Colors.amber,
            icon: Icons.savings,
          ),
          
          _buildRecommendationCard(
            title: 'Review Insurance Coverage',
            description: 'Your health insurance may be insufficient for your family needs.',
            actionText: 'Compare Insurance Plans',
            priority: 'Medium Priority',
            priorityColor: Colors.amber,
            icon: Icons.health_and_safety,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialHealthIndicator(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecommendationCard({
    required String title,
    required String description,
    required String actionText,
    required String priority,
    required Color priorityColor,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5DCF8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF233B99)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          priority,
                          style: TextStyle(
                            color: priorityColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF233B99),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingOptimizationTab() {
    // Sample spending data
    final List<double> monthlySpending = [42000, 38000, 45000, 39000, 41000, 36000];
    final Map<String, double> spendingCategories = {
      'Housing': 15000,
      'Food': 8000,
      'Transportation': 5000,
      'Entertainment': 4000,
      'Shopping': 6000,
      'Others': 3000,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spending Optimization',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF233B99),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Our AI has analyzed your spending patterns to help you optimize your budget:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          
          // Monthly spending trend
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Spending Trend',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                String text = '';
                                if (value == 0) {
                                  text = '₹0';
                                } else if (value == 20000) {
                                  text = '₹20K';
                                } else if (value == 40000) {
                                  text = '₹40K';
                                } else if (value == 60000) {
                                  text = '₹60K';
                                }
                                return Text(
                                  text,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                                if (value.toInt() >= 0 && value.toInt() < months.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      months[value.toInt()],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: 5,
                        minY: 0,
                        maxY: 60000,
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              monthlySpending.length,
                              (index) => FlSpot(index.toDouble(), monthlySpending[index]),
                            ),
                            isCurved: true,
                            color: const Color(0xFF233B99),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: const Color(0xFF233B99).withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSpendingStatCard(
                        'Monthly Average',
                        '₹40,167',
                        Icons.analytics,
                      ),
                      const SizedBox(width: 16),
                      _buildSpendingStatCard(
                        'Trend',
                        'Decreasing',
                        Icons.trending_down,
                        isPositive: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Spending breakdown
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Spending Breakdown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _getPieChartSections(spendingCategories),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _getLegendItems(spendingCategories),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Budget recommendations
          const Text(
            'Budget Recommendations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF233B99),
            ),
          ),
          const SizedBox(height: 12),
          
          _buildBudgetRecommendationCard(
            category: 'Entertainment',
            currentSpending: 4000,
            recommendedSpending: 3000,
            description: 'You\'re spending 33% more on entertainment than similar users. Consider reducing streaming subscriptions.',
            savingsPotential: 1000,
          ),
          
          _buildBudgetRecommendationCard(
            category: 'Food',
            currentSpending: 8000,
            recommendedSpending: 6500,
            description: 'Eating out accounts for 60% of your food budget. Try meal prepping to reduce expenses.',
            savingsPotential: 1500,
          ),
          
          _buildBudgetRecommendationCard(
            category: 'Shopping',
            currentSpending: 6000,
            recommendedSpending: 4500,
            description: 'Your shopping expenses are higher than your financial peers. Consider a 30-day purchase rule.',
            savingsPotential: 1500,
          ),
          
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF233B99),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Create Optimized Budget Plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingStatCard(String title, String value, IconData icon, {bool isPositive = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFD5DCF8).withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isPositive ? Colors.green : const Color(0xFF233B99),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.green : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections(Map<String, double> categories) {
    final List<Color> colors = [
      const Color(0xFF233B99),
      const Color(0xFF4CAF50),
      const Color(0xFFFFC107),
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
      const Color(0xFF607D8B),
    ];
    
    final double total = categories.values.fold(0, (sum, value) => sum + value);
    
    return List.generate(categories.length, (index) {
      final String category = categories.keys.elementAt(index);
      final double value = categories.values.elementAt(index);
      final double percentage = (value / total) * 100;
      
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  List<Widget> _getLegendItems(Map<String, double> categories) {
    final List<Color> colors = [
      const Color(0xFF233B99),
      const Color(0xFF4CAF50),
      const Color(0xFFFFC107),
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
      const Color(0xFF607D8B),
    ];
    
    return List.generate(categories.length, (index) {
      final String category = categories.keys.elementAt(index);
      final double value = categories.values.elementAt(index);
      
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$category: ₹${value.toInt()}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBudgetRecommendationCard({
    required String category,
    required double currentSpending,
    required double recommendedSpending,
    required String description,
    required double savingsPotential,
  }) {
    final double savingsPercentage = (savingsPotential / currentSpending) * 100;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Save ₹${savingsPotential.toInt()} (${savingsPercentage.toStringAsFixed(0)}%)',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        '₹${currentSpending.toInt()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.grey,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Recommended',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        '₹${recommendedSpending.toInt()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: recommendedSpending / currentSpending,
                backgroundColor: Colors.red.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF233B99),
                side: const BorderSide(color: Color(0xFF233B99)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('View Detailed Suggestions'),
            ),
          ],
        ),
      ),
    );
  }
}
