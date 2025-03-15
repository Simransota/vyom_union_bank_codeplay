import 'package:flutter/material.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: theme.colorScheme.onBackground),
                onPressed: () {},
              ),
              Text(
                'February 2025',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: theme.colorScheme.onBackground),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CalendarDayHeader('Su', theme),
              _CalendarDayHeader('Mo', theme),
              _CalendarDayHeader('Tu', theme),
              _CalendarDayHeader('We', theme),
              _CalendarDayHeader('Th', theme),
              _CalendarDayHeader('Fr', theme),
              _CalendarDayHeader('Sa', theme),
            ],
          ),
          const SizedBox(height: 8),
          _buildCalendarWeek(['26', '27', '28', '29', '30', '31', '1'], theme, true),
          _buildCalendarWeek(['2', '3', '4', '5', '6', '7', '8'], theme),
          _buildCalendarWeek(['9', '10', '11', '12', '13', '14', '15'], theme),
          _buildCalendarWeek(['16', '17', '18', '19', '20', '21', '22'], theme),
          _buildCalendarWeek(['23', '24', '25', '26', '27', '28', '1'], theme, false, 2),
        ],
      ),
    );
  }

  Widget _buildCalendarWeek(List<String> days, ThemeData theme, [bool isFirstWeek = false, int highlightIndex = -1]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final isHighlighted = index == highlightIndex;
          final isCurrentMonth = !(isFirstWeek && index < 5) && !(index == 6 && day == '1');
          
          return _CalendarDay(
            day: day,
            isCurrentMonth: isCurrentMonth,
            isHighlighted: isHighlighted,
            theme: theme,
          );
        }).toList(),
      ),
    );
  }
}

class _CalendarDayHeader extends StatelessWidget {
  final String text;
  final ThemeData theme;
  
  const _CalendarDayHeader(this.text, this.theme);
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: theme.colorScheme.onBackground.withOpacity(0.6),
          fontSize: 14,
        ),
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final String day;
  final bool isCurrentMonth;
  final bool isHighlighted;
  final ThemeData theme;
  
  const _CalendarDay({
    required this.day,
    required this.theme,
    this.isCurrentMonth = true,
    this.isHighlighted = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isHighlighted ? theme.colorScheme.primary.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        day,
        style: TextStyle(
          color: isCurrentMonth 
              ? theme.colorScheme.onBackground 
              : theme.colorScheme.onBackground.withOpacity(0.3),
          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

