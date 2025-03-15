import 'package:flutter/material.dart';

class QueryFilterSheet extends StatefulWidget {
  final String currentSortBy;
  final String currentFilterBy;
  final Function(String) onSortChanged;
  final Function(String) onFilterChanged;

  const QueryFilterSheet({
    Key? key,
    required this.currentSortBy,
    required this.currentFilterBy,
    required this.onSortChanged,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<QueryFilterSheet> createState() => _QueryFilterSheetState();
}

class _QueryFilterSheetState extends State<QueryFilterSheet> {
  late String _sortBy;
  late String _filterBy;

  @override
  void initState() {
    super.initState();
    _sortBy = widget.currentSortBy;
    _filterBy = widget.currentFilterBy;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter & Sort',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Sort Options
          Text(
            'Sort By',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              _buildSortOption(theme, 'Newest'),
              _buildSortOption(theme, 'Oldest'),
              _buildSortOption(theme, 'Status'),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Filter Options
          Text(
            'Filter By',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterOption(theme, 'All Queries'),
              _buildFilterOption(theme, 'Open Queries'),
              _buildFilterOption(theme, 'Closed Queries'),
              _buildFilterOption(theme, 'Loan'),
              _buildFilterOption(theme, 'Credit Card'),
              _buildFilterOption(theme, 'Account'),
              _buildFilterOption(theme, 'Security'),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onSortChanged(_sortBy);
                widget.onFilterChanged(_filterBy);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Reset Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _sortBy = 'Newest';
                  _filterBy = 'All Queries';
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Reset Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(ThemeData theme, String option) {
    final isSelected = _sortBy == option;
    
    return ChoiceChip(
      label: Text(option),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _sortBy = option;
          });
        }
      },
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.secondary.withOpacity(0.3),
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onBackground,
      ),
    );
  }

  Widget _buildFilterOption(ThemeData theme, String option) {
    final isSelected = _filterBy == option;
    
    return ChoiceChip(
      label: Text(option),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filterBy = option;
          });
        }
      },
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.secondary.withOpacity(0.3),
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onBackground,
      ),
    );
  }
}

