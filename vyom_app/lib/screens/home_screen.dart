import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:vyom/screens/credit_insights_page/credit_insights_page.dart';
import 'package:vyom/screens/offers_page/offers_page.dart';
import 'package:vyom/screens/query_page/query_history_screen.dart';

import 'package:vyom/screens/query_page/query_screen.dart';
import 'package:vyom/screens/query_page/query_tracking_screen.dart';
import 'package:vyom/screens/video_call/join_page.dart';
import 'package:vyom/widgets/chat_bot.dart';

import '../widgets/financial_card.dart';
import '../widgets/recommendation_item.dart';
import '../widgets/query_item.dart';
import '../widgets/calender_widget.dart';

class HomeScreen extends StatefulWidget {
  final GoogleTranslator translator;

  const HomeScreen({Key? key, required this.translator}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentLanguage = 'en';
  final Map<String, String> _languages = {
    'en': 'English',
    'hi': 'हिंदी (Hindi)',
    'ta': 'தமிழ் (Tamil)',
    'te': 'తెలుగు (Telugu)',
    'bn': 'বাংলা (Bengali)',
    'mr': 'मराठी (Marathi)',
    'gu': 'ગુજરાતી (Gujarati)',
    'kn': 'ಕನ್ನಡ (Kannada)',
    'ml': 'മലയാളം (Malayalam)',
    'pa': 'ਪੰਜਾਬੀ (Punjabi)',
    'or': 'ଓଡ଼ିଆ (Odia)',
  };

  Future<String> _translateText(String text) async {
    if (_currentLanguage == 'en') {
      return text;
    } else {
      try {
        var translation = await widget.translator
            .translate(text, from: 'en', to: _currentLanguage);
        return translation.text;
      } catch (e) {
        print('Translation error: $e');
        return text; // Fallback to English if translation fails
      }
    }
  }

  void _showLanguageSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Language'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _languages.length,
              itemBuilder: (BuildContext context, int index) {
                String langCode = _languages.keys.elementAt(index);
                String langName = _languages[langCode]!;

                return ListTile(
                  title: Text(langName),
                  selected: _currentLanguage == langCode,
                  onTap: () {
                    setState(() {
                      _currentLanguage = langCode;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        actions: [
          TextButton.icon(
            icon: Icon(Icons.language, color: theme.colorScheme.onBackground),
            label: Text(
                _languages[_currentLanguage]?.split(' ').first ?? 'English',
                style: TextStyle(color: theme.colorScheme.onBackground)),
            onPressed: () {
              _showLanguageSelector(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_none,
                color: theme.colorScheme.onBackground),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person_outline,
                color: theme.colorScheme.onBackground),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Menu',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.question_mark),
              title: Text('My Queries'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QueryHistoryScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.insights),
              title: Text('Credit Insights'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreditInsightsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.local_offer),
              title: Text('Offers'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OffersPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.video_call),
              title: Text('Join Video Call'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JoinScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.language),
              title: Text('Change Language'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              FutureBuilder<String>(
                future: _translateText('Welcome, Simran'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Text(
                      snapshot.data ?? 'Welcome, Simran',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground,
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              const SizedBox(height: 24),

              // Financial Summary Card
              FutureBuilder<String>(
                future: _translateText('Financial Summary'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return FinancialCard(
                      title: snapshot.data ?? 'Financial Summary',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<String>(
                            future: _translateText('Credit Health'),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return Text(
                                  snapshot.data ?? 'Credit Health',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onBackground,
                                  ),
                                );
                              } else {
                                return const CircularProgressIndicator();
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  theme.colorScheme.secondary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '750',
                                  style: TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder<String>(
                                      future: _translateText('CIBIL Score'),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          return Text(
                                            snapshot.data ?? 'CIBIL Score',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: theme
                                                  .colorScheme.onBackground
                                                  .withOpacity(0.7),
                                            ),
                                          );
                                        } else {
                                          return const CircularProgressIndicator();
                                        }
                                      },
                                    ),
                                    FutureBuilder<String>(
                                      future: _translateText('Excellent'),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          return Text(
                                            snapshot.data ?? 'Excellent',
                                            style: TextStyle(
                                              fontSize: 22,
                                              color: theme
                                                  .colorScheme.onBackground
                                                  .withOpacity(0.7),
                                            ),
                                          );
                                        } else {
                                          return const CircularProgressIndicator();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // FutureBuilder<String>(
                          //   future: _translateText('Loan Eligibility'),
                          //   builder: (context, snapshot) {
                          //     if (snapshot.connectionState == ConnectionState.done) {
                          //       return Text(
                          //         snapshot.data ?? 'Loan Eligibility',
                          //         style: TextStyle(
                          //           fontSize: 22,
                          //           fontWeight: FontWeight.bold,
                          //           color: theme.colorScheme.onBackground,
                          //         ),
                          //       );
                          //     } else {
                          //       return const CircularProgressIndicator();
                          //     }
                          //   },
                          // ),
                          // const SizedBox(height: 16),
                          // Container(
                          //   height: 200,
                          //   decoration: BoxDecoration(
                          //     color: theme.colorScheme.secondary.withOpacity(0.3),
                          //     borderRadius: BorderRadius.circular(12),
                          //   ),
                          //   child: Center(
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //       children: [
                          //         _buildBarChart('XYZ Bank', 0.8, theme.colorScheme.primary),
                          //         _buildBarChart('ABC Bank', 0.9, theme.colorScheme.primary),
                          //         _buildBarChart('PQR Bank', 0.85, theme.colorScheme.primary),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(height: 24),
                          // FutureBuilder<String>(
                          //   future: _translateText('Spending Insights'),
                          //   builder: (context, snapshot) {
                          //     if (snapshot.connectionState == ConnectionState.done) {
                          //       return Text(
                          //         snapshot.data ?? 'Spending Insights',
                          //         style: TextStyle(
                          //           fontSize: 22,
                          //           fontWeight: FontWeight.bold,
                          //           color: theme.colorScheme.onBackground,
                          //         ),
                          //       );
                          //     } else {
                          //       return const CircularProgressIndicator();
                          //     }
                          //   },
                          // ),
                          // const SizedBox(height: 16),
                          // Container(
                          //   height: 200,
                          //   decoration: BoxDecoration(
                          //     color: theme.colorScheme.secondary.withOpacity(0.3),
                          //     borderRadius: BorderRadius.circular(12),
                          //   ),
                          //   padding: const EdgeInsets.all(16),
                          //   child: _buildLineChart(theme),
                          // ),
                        ],
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              const SizedBox(height: 24),

              // Proactive Banking Alert
              FutureBuilder<String>(
                future: _translateText('Proactive Banking Alert'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data ?? 'Proactive Banking Alert',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<String>(
                            future: _translateText(
                                'Your CIBIL score is 750. You\'re eligible for a personal loan at 9.5% interest from XYZ Bank.'),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return Text(
                                  snapshot.data ??
                                      'Your CIBIL score is 750. You\'re eligible for a personal loan at 9.5% interest from XYZ Bank.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(0.7),
                                  ),
                                );
                              } else {
                                return const CircularProgressIndicator();
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              const SizedBox(height: 24),

              // Financial Health Recommendations
              FutureBuilder<String>(
                future: _translateText('Financial Health Recommendations'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return FinancialCard(
                      title:
                          snapshot.data ?? 'Financial Health Recommendations',
                      child: Column(
                        children: [
                          RecommendationItem(
                            icon: Icons.credit_card,
                            title: 'Reduce credit card debt',
                            description:
                                'Pay off 20% of your credit card balance within the next 30 days to improve your credit score.',
                            progress: 0.2,
                            progressColor: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          RecommendationItem(
                            icon: Icons.savings,
                            title: 'Increase savings',
                            description:
                                'Consider automating monthly savings of ₹5,000 to build your emergency fund.',
                            progress: 0.5,
                            progressColor: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          RecommendationItem(
                            icon: Icons.trending_up,
                            title: 'Improve credit mix',
                            description:
                                'Diversifying your credit sources can help improve your score over time.',
                            progress: 0.15,
                            progressColor: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  theme.colorScheme.secondary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<String>(
                                  future: _translateText(
                                      'Personalized Financial Goal'),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      return Text(
                                        snapshot.data ??
                                            'Personalized Financial Goal',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onBackground,
                                        ),
                                      );
                                    } else {
                                      return const CircularProgressIndicator();
                                    }
                                  },
                                ),
                                const SizedBox(height: 8),
                                FutureBuilder<String>(
                                  future: _translateText(
                                      'Save ₹10,000 by the end of this quarter'),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      return Text(
                                        snapshot.data ??
                                            'Save ₹10,000 by the end of this quarter',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: theme.colorScheme.onBackground
                                              .withOpacity(0.7),
                                        ),
                                      );
                                    } else {
                                      return const CircularProgressIndicator();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              const SizedBox(height: 24),

              // Query & Complaint Tracking
              FutureBuilder<String>(
                future: _translateText('Query & Complaint Tracking'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return FinancialCard(
                      title: snapshot.data ?? 'Query & Complaint Tracking',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<String>(
                            future: _translateText('Active Queries'),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return Text(
                                  snapshot.data ?? 'Active Queries',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onBackground,
                                  ),
                                );
                              } else {
                                return const CircularProgressIndicator();
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          QueryItem(
                            icon: Icons.error_outline,
                            iconColor: Colors.red,
                            title: 'Unauthorized Transaction',
                            status: 'Under Review - Est. 2 days',
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          QueryItem(
                            icon: Icons.access_time,
                            iconColor: theme.colorScheme.primary,
                            title: 'Loan Application',
                            status: 'Processing - Est. 3 days',
                            onTap: () {},
                          ),
                          const SizedBox(height: 24),
                          FutureBuilder<String>(
                            future: _translateText('Resolved Queries'),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return Text(
                                  snapshot.data ?? 'Resolved Queries',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onBackground,
                                  ),
                                );
                              } else {
                                return const CircularProgressIndicator();
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          QueryItem(
                            icon: Icons.check_circle_outline,
                            iconColor: Colors.green,
                            title: 'Account Statement Request',
                            status: 'Resolved on 2023-05-15',
                            onTap: () {},
                            showButton: false,
                          ),
                          const SizedBox(height: 12),
                          QueryItem(
                            icon: Icons.check_circle_outline,
                            iconColor: Colors.green,
                            title: 'Credit Limit Increase',
                            status: 'Resolved on 2023-05-10',
                            onTap: () {},
                            showButton: false,
                          ),
                          const SizedBox(height: 16),
                          // In your HomeScreen file, update the "Chat with AI Assistant" button:

                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    translator: widget.translator,
                                    currentLanguage: _currentLanguage,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat_bubble_outline,
                                      color: theme.colorScheme.onPrimary),
                                  const SizedBox(width: 8),
                                  FutureBuilder<String>(
                                    future: _translateText(
                                        'Chat with AI Assistant'),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        return Text(
                                          snapshot.data ??
                                              'Chat with AI Assistant',
                                          style: TextStyle(
                                            color: theme.colorScheme.onPrimary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        );
                                      } else {
                                        return const CircularProgressIndicator();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              const SizedBox(height: 24),

              // AI-Powered Insights & Alerts
              FutureBuilder<String>(
                future: _translateText('AI-Powered Insights & Alerts'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return FinancialCard(
                      title: snapshot.data ?? 'AI-Powered Insights & Alerts',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE0F2E9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.shield_outlined,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder<String>(
                                      future: _translateText(
                                          'Fraud Detection Alerts'),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          return Text(
                                            snapshot.data ??
                                                'Fraud Detection Alerts',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: theme
                                                  .colorScheme.onBackground,
                                            ),
                                          );
                                        } else {
                                          return const CircularProgressIndicator();
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 4),
                                    FutureBuilder<String>(
                                      future: _translateText(
                                          'No suspicious activity detected in the last 30 days.'),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          return Text(
                                            snapshot.data ??
                                                'No suspicious activity detected in the last 30 days.',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: theme
                                                  .colorScheme.onBackground
                                                  .withOpacity(0.7),
                                            ),
                                          );
                                        } else {
                                          return const CircularProgressIndicator();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFF8E1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.warning_amber_outlined,
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder<String>(
                                      future: _translateText(
                                          'Security Recommendation'),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          return Text(
                                            snapshot.data ??
                                                'Security Recommendation',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: theme
                                                  .colorScheme.onBackground,
                                            ),
                                          );
                                        } else {
                                          return const CircularProgressIndicator();
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 4),
                                    FutureBuilder<String>(
                                      future: _translateText(
                                          'It\'s been 3 months since you last updated your password. Consider changing it for enhanced security.'),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          return Text(
                                            snapshot.data ??
                                                'It\'s been 3 months since you last updated your password. Consider changing it for enhanced security.',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: theme
                                                  .colorScheme.onBackground
                                                  .withOpacity(0.7),
                                            ),
                                          );
                                        } else {
                                          return const CircularProgressIndicator();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.secondary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: FutureBuilder<String>(
                                future: _translateText('Update Password'),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return Text(
                                      snapshot.data ?? 'Update Password',
                                      style: TextStyle(
                                        color: theme.colorScheme.onSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  color: theme.colorScheme.onBackground),
                              const SizedBox(width: 12),
                              FutureBuilder<String>(
                                future:
                                    _translateText('Predictive Bill Reminders'),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return Text(
                                      snapshot.data ??
                                          'Predictive Bill Reminders',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onBackground,
                                      ),
                                    );
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CalendarWidget(),
                          const SizedBox(height: 12),
                          FutureBuilder<String>(
                            future: _translateText(
                                'Upcoming bill: Electricity payment due on 25th'),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return Text(
                                  snapshot.data ??
                                      'Upcoming bill: Electricity payment due on 25th',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(0.7),
                                  ),
                                );
                              } else {
                                return const CircularProgressIndicator();
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
