import 'package:flutter/material.dart';
import 'package:vyom/screens/query_page/query_screen.dart';
import '../../widgets/financial_card.dart';
import '../../widgets/chat_message.dart';

class QueryTrackingScreen extends StatelessWidget {
  const QueryTrackingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Query Details'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Query Status Card
            FinancialCard(
              title: 'Query Status',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Loan Application Review',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reference ID: #LC789012',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildStatusTimeline(theme),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Assigned Agent Card
            // FinancialCard(
            //   title: 'Assigned Agent',
            //   child: Row(
            //     children: [
            //       CircleAvatar(
            //         radius: 30,
            //         backgroundColor: theme.colorScheme.secondary,
            //         child: const Icon(Icons.person_outline, size: 32),
            //       ),
            //       const SizedBox(width: 16),
            //       Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(
            //               'Sarah Johnson',
            //               style: TextStyle(
            //                 fontSize: 18,
            //                 fontWeight: FontWeight.bold,
            //                 color: theme.colorScheme.onBackground,
            //               ),
            //             ),
            //             const SizedBox(height: 4),
            //             Text(
            //               'Senior Loan Officer',
            //               style: TextStyle(
            //                 fontSize: 14,
            //                 color: theme.colorScheme.onBackground.withOpacity(0.7),
            //               ),
            //             ),
            //             const SizedBox(height: 8),
            //             Row(
            //               children: [
            //                 Icon(
            //                   Icons.phone_outlined,
            //                   size: 16,
            //                   color: theme.colorScheme.primary,
            //                 ),
            //                 const SizedBox(width: 8),
            //                 Text(
            //                   '+1 (555) 123-4567',
            //                   style: TextStyle(
            //                     fontSize: 14,
            //                     color: theme.colorScheme.primary,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 16),

            // // Chat Section
            // FinancialCard(
            //   title: 'Live Chat',
            //   child: Column(
            //     children: [
            //       Container(
            //         height: 300,
            //         decoration: BoxDecoration(
            //           color: theme.colorScheme.secondary.withOpacity(0.1),
            //           borderRadius: BorderRadius.circular(12),
            //         ),
            //         child: ListView(
            //           padding: const EdgeInsets.all(16),
            //           children: const [
            //             ChatMessage(
            //               message: 'Hello! I\'ve reviewed your loan application. We\'ll need a few additional documents.',
            //               isAgent: true,
            //               time: '10:30 AM',
            //             ),
            //             ChatMessage(
            //               message: 'Sure, what documents do you need?',
            //               isAgent: false,
            //               time: '10:32 AM',
            //             ),
            //             ChatMessage(
            //               message: 'Please provide your latest salary slip and bank statements for the last 3 months.',
            //               isAgent: true,
            //               time: '10:33 AM',
            //             ),
            //           ],
            //         ),
            //       ),
            //       const SizedBox(height: 16),
            //       Row(
            //         children: [
            //           Expanded(
            //             child: TextField(
            //               decoration: InputDecoration(
            //                 hintText: 'Type your message...',
            //                 border: OutlineInputBorder(
            //                   borderRadius: BorderRadius.circular(12),
            //                   borderSide: BorderSide(
            //                     color: theme.colorScheme.outline,
            //                   ),
            //                 ),
            //                 contentPadding: const EdgeInsets.symmetric(
            //                   horizontal: 16,
            //                   vertical: 12,
            //                 ),
            //               ),
            //             ),
            //           ),
            //           const SizedBox(width: 8),
            //           IconButton(
            //             onPressed: () {},
            //             icon: Icon(
            //               Icons.send_rounded,
            //               color: theme.colorScheme.onSecondary,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 16),

            // Resolution Timeline
            FinancialCard(
              title: 'Resolution Timeline',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expected Resolution',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'March 15, 2024',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '3 days remaining',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Center(
            //   child: ElevatedButton(
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => VideoQueryScreen(),
            //         ),
            //       );
            //     },
            //     child: const Text('New Query'),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(ThemeData theme) {
    return Column(
      children: [
        _buildStatusItem(
          theme,
          icon: Icons.receipt_long_rounded,
          title: 'Query Received',
          date: 'March 10, 2024',
          time: '09:30 AM',
          isCompleted: true,
          isFirst: true,
        ),
        _buildStatusItem(
          theme,
          icon: Icons.person_outline,
          title: 'Agent Assigned',
          date: 'March 10, 2024',
          time: '02:15 PM',
          isCompleted: true,
        ),
        _buildStatusItem(
          theme,
          icon: Icons.pending_outlined,
          title: 'Document Review',
          date: 'March 12, 2024',
          time: '11:45 AM',
          isCompleted: true,
        ),
        _buildStatusItem(
          theme,
          icon: Icons.fact_check_outlined,
          title: 'Final Verification',
          date: 'Expected by March 15',
          isCompleted: false,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildStatusItem(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String date,
    String? time,
    bool isCompleted = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isCompleted
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.secondary.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  if (time != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

