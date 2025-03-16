import 'package:flutter/material.dart';
import 'package:vyom/screens/voice_asstance/voice_chat_bubble.dart';
import '../../widgets/financial_card.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  String _selectedService = 'Loan Discussion';
  String _selectedBranch = 'Main Branch';
  bool _isVirtual = false;
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '10:00 AM';

  final List<String> _services = [
    'Loan Discussion',
    'Investment Guidance',
    'Issue Resolution',
    'Account Services',
  ];

  final List<String> _branches = [
    'Main Branch',
    'Downtown Branch',
    'West Side Branch',
    'North Branch',
  ];

  final List<String> _timeSlots = [
    '10:00 AM',
    '11:00 AM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Schedule Appointment'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: Stack(
        children:[
           SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Selection
              FinancialCard(
                title: 'Select Service',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _services.map((service) {
                        final isSelected = _selectedService == service;
                        return ChoiceChip(
                          label: Text(service),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedService = service);
                            }
                          },
                          selectedColor: theme.colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onBackground,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
        
              // Branch Selection
              FinancialCard(
                title: 'Select Branch',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedBranch,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: _branches.map((branch) {
                        return DropdownMenuItem(
                          value: branch,
                          child: Text(branch),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedBranch = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                  ],
                ),
              ),
              const SizedBox(height: 16),
        
              // Meeting Type
              FinancialCard(
                title: 'Meeting Type',
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMeetingTypeOption(
                        theme,
                        icon: Icons.people_outline,
                        title: 'In-Person',
                        isSelected: !_isVirtual,
                        onTap: () => setState(() => _isVirtual = false),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMeetingTypeOption(
                        theme,
                        icon: Icons.video_camera_front_outlined,
                        title: 'Virtual',
                        isSelected: _isVirtual,
                        onTap: () => setState(() => _isVirtual = true),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
        
              // Date & Time Selection
              FinancialCard(
                title: 'Select Date & Time',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calendar
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CalendarDatePicker(
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                        onDateChanged: (date) {
                          setState(() => _selectedDate = date);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Available Time Slots',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _timeSlots.map((time) {
                        final isSelected = _selectedTime == time;
                        return ChoiceChip(
                          label: Text(time),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedTime = time);
                            }
                          },
                          selectedColor: theme.colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onBackground,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
        
              // Book Appointment Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle appointment booking
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Book Appointment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
    );
  }

  Widget _buildMeetingTypeOption(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.secondary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

