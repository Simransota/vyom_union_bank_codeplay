import 'package:flutter/material.dart';


class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isProcessing = false;
  String _transactionStatus = '';

  void _processTransaction() {
    // Validate input
    if (_amountController.text.isEmpty || _recipientController.text.isEmpty) {
      setState(() {
        _transactionStatus = 'Please fill in all required fields';
      });
      return;
    }

    // Simulate transaction processing
    setState(() {
      _isProcessing = true;
      _transactionStatus = '';
    });

    // Simulate API call with delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isProcessing = false;
        _transactionStatus = 'Transaction completed successfully!';
        
        // Clear the form
        _amountController.clear();
        _recipientController.clear();
        _descriptionController.clear();
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _recipientController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Transaction form
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _recipientController,
              decoration: const InputDecoration(
                labelText: 'Recipient',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isProcessing ? null : _processTransaction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('SEND PAYMENT', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            if (_transactionStatus.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _transactionStatus.contains('success')
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _transactionStatus,
                  style: TextStyle(
                    color: _transactionStatus.contains('success')
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 24),
            // Recent transactions section (dummy data)
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: const [
                  TransactionTile(
                    recipient: 'John Doe',
                    amount: '\$120.00',
                    date: 'Mar 16, 2025',
                    isDebit: true,
                  ),
                  TransactionTile(
                    recipient: 'Sarah Smith',
                    amount: '\$45.50',
                    date: 'Mar 14, 2025',
                    isDebit: true,
                  ),
                  TransactionTile(
                    recipient: 'Payroll',
                    amount: '\$2,450.00',
                    date: 'Mar 10, 2025',
                    isDebit: false,
                  ),
                  TransactionTile(
                    recipient: 'Electric Bill',
                    amount: '\$89.75',
                    date: 'Mar 5, 2025',
                    isDebit: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final String recipient;
  final String amount;
  final String date;
  final bool isDebit;

  const TransactionTile({
    Key? key,
    required this.recipient,
    required this.amount,
    required this.date,
    required this.isDebit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDebit ? Colors.red.shade100 : Colors.green.shade100,
          child: Icon(
            isDebit ? Icons.arrow_upward : Icons.arrow_downward,
            color: isDebit ? Colors.red : Colors.green,
          ),
        ),
        title: Text(recipient),
        subtitle: Text(date),
        trailing: Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDebit ? Colors.red.shade700 : Colors.green.shade700,
          ),
        ),
      ),
    );
  }
}