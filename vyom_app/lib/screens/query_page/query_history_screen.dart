import 'package:flutter/material.dart';
import 'package:vyom/screens/query_page/query_screen.dart';
import 'package:vyom/screens/voice_asstance/voice_chat_bubble.dart';
import '../../widgets/financial_card.dart';
import './query_tracking_screen.dart';
import '../../widgets/query_filter_sheet.dart';

class QueryHistoryScreen extends StatefulWidget {
  const QueryHistoryScreen({Key? key}) : super(key: key);

  @override
  State<QueryHistoryScreen> createState() => _QueryHistoryScreenState();
}

class _QueryHistoryScreenState extends State<QueryHistoryScreen> {
  String _sortBy = 'Newest';
  String _filterBy = 'All Queries';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  // instead of lastmessage write description of query , add department 
  final List<Map<String, dynamic>> _queries = [
    {
      'title': 'Loan Status Inquiryzz',
      'referenceId': '#LC789012',
      'type': 'Loan',
      'dateCreated': '2024-03-10',
      'lastUpdated': '2024-03-12',
      'status': 'In Progress',
      'estimatedResolution': '2024-03-15',
      'agent': {
        'name': 'Sarah Johnson',
        'designation': 'Senior Loan Officer',

      },
      'lastMessage': 'We need additional documents to process your loan application.',
    },
    {
      'title': 'Credit Card Transaction Dispute',
      'referenceId': '#CC456789',
      'type': 'Credit Card',
      'dateCreated': '2024-03-05',
      'lastUpdated': '2024-03-11',
      'status': 'Pending',
      'estimatedResolution': '2024-03-18',
      'agent': {
        'name': 'Michael Chen',
        'designation': 'Dispute Resolution Specialist',

      },
      'lastMessage': 'We are investigating the transaction with the merchant.',
    },
    {
      'title': 'Account Statement Request',
      'referenceId': '#AS123456',
      'type': 'Account',
      'dateCreated': '2024-03-01',
      'lastUpdated': '2024-03-02',
      'status': 'Resolved',
      'estimatedResolution': '2024-03-03',
      'agent': {
        'name': 'Emily Rodriguez',
        'designation': 'Customer Service Representative',
      },
      'lastMessage': 'Your account statement has been sent to your registered email address.',
    },
    {
      'title': 'Unauthorized Transaction Report',
      'referenceId': '#UT789012',
      'type': 'Security',
      'dateCreated': '2024-03-08',
      'lastUpdated': '2024-03-09',
      'status': 'Resolved',
      'estimatedResolution': 'N/A',
      'agent': {
        'name': 'David Wilson',
        'designation': 'Fraud Prevention Specialist',

      },
      'lastMessage': 'After investigation, we found the transaction was authorized from your registered device.',
    },
    {
      'title': 'Loan Application Status',
      'referenceId': '#LA345678',
      'type': 'Loan',
      'dateCreated': '2024-02-25',
      'lastUpdated': '2024-03-10',
      'status': 'In Progress',
      'estimatedResolution': '2024-03-20',
      'agent': {
        'name': 'James Thompson',
        'designation': 'Loan Processing Officer',

      },
      'lastMessage': 'Your application is under review by our credit team.',
    },
  ];

  List<Map<String, dynamic>> get filteredQueries {
    List<Map<String, dynamic>> result = List.from(_queries);
    
    // Apply search
    if (_searchQuery.isNotEmpty) {
      result = result.where((query) {
        return query['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
               query['referenceId'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
               query['type'].toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    // Apply filter
    if (_filterBy != 'All Queries') {
      if (_filterBy == 'Open Queries') {
        result = result.where((query) => 
          query['status'] == 'Pending' || query['status'] == 'In Progress'
        ).toList();
      } else if (_filterBy == 'Closed Queries') {
        result = result.where((query) => 
          query['status'] == 'Resolved' || query['status'] == 'Rejected'
        ).toList();
      } else {
        // Filter by specific type
        result = result.where((query) => query['type'] == _filterBy).toList();
      }
    }
    
    // Apply sort
    if (_sortBy == 'Newest') {
      result.sort((a, b) => b['dateCreated'].compareTo(a['dateCreated']));
    } else if (_sortBy == 'Oldest') {
      result.sort((a, b) => a['dateCreated'].compareTo(b['dateCreated']));
    } else if (_sortBy == 'Status') {
      result.sort((a, b) => a['status'].compareTo(b['status']));
    }
    
    return result;
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => QueryFilterSheet(
        currentSortBy: _sortBy,
        currentFilterBy: _filterBy,
        onSortChanged: (value) {
          setState(() {
            _sortBy = value;
          });
        },
        onFilterChanged: (value) {
          setState(() {
            _filterBy = value;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('All Queries'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by ID or keywords',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            
            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text(_sortBy),
                    avatar: const Icon(Icons.sort, size: 16),
                    backgroundColor: theme.colorScheme.secondary.withOpacity(0.3),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(_filterBy),
                    avatar: const Icon(Icons.filter_alt, size: 16),
                    backgroundColor: theme.colorScheme.secondary.withOpacity(0.3),
                  ),
                  const Spacer(),
                  Text(
                    '${filteredQueries.length} Queries',
                    style: TextStyle(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // Query List
            Expanded(
              child: filteredQueries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: theme.colorScheme.onBackground.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No queries found',
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.colorScheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredQueries.length,
                      itemBuilder: (context, index) {
                        final query = filteredQueries[index];
                        return _buildQueryCard(context, query);
                      },
                    ),
            ),
          ],
        ),
        VoiceChatBubble(
          onMessageReceived: (message) {
            // Handle received message
            print("Assistant: $message");
          },
          onUserMessage: (message) {
            // Handle user message
            print("User: $message");
          },
        ),
        ],

      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
  floatingActionButton: FloatingActionButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VideoQueryScreen()),
      );
    },
    backgroundColor: theme.colorScheme.primary,
    child: const Icon(Icons.add),
  ),
    );
  }

  Widget _buildQueryCard(BuildContext context, Map<String, dynamic> query) {
    final theme = Theme.of(context);
    
    // Determine status color and icon
    Color statusColor;
    IconData statusIcon;
    
    switch (query['status']) {
      case 'Resolved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Rejected':
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.cancel;
        break;
      case 'In Progress':
        statusColor = Colors.blue;
        statusIcon = Icons.pending_actions;
        break;
      case 'Pending':
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
    }
    
    // Determine query type icon
    IconData typeIcon;
    
    switch (query['type']) {
      case 'Loan':
        typeIcon = Icons.account_balance;
        break;
      case 'Credit Card':
        typeIcon = Icons.credit_card;
        break;
      case 'Account':
        typeIcon = Icons.account_balance_wallet;
        break;
      case 'Security':
        typeIcon = Icons.security;
        break;
      default:
        typeIcon = Icons.help_outline;
        break;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(typeIcon, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        query['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${query['referenceId']} • ${query['type']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        query['status'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Dates
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Created',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onBackground.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        query['dateCreated'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Updated',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onBackground.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        query['lastUpdated'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Est. Resolution',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onBackground.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        query['estimatedResolution'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Agent info
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.secondary,
                  child: const Icon(Icons.person_outline, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        query['agent']['name'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        query['agent']['designation'],
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Last message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.message_outlined,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      query['lastMessage'],
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('View Details'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QueryTrackingScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.reply, size: 16),
                    label: const Text('Follow Up'),
                    onPressed: () {
                      // Handle follow up action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

