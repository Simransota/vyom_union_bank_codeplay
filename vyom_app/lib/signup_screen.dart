import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final accountNumberController = TextEditingController();
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final panCardController = TextEditingController();
  final aadhaarCardController = TextEditingController();
  final addressController = TextEditingController();
  DateTime? selectedDate;
  bool isLoading = false;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    nameController.dispose();
    accountNumberController.dispose();
   
    emailController.dispose();
    passwordController.dispose();
    panCardController.dispose();
    aadhaarCardController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // Function to select date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Format date for display
  String get formattedDate {
    return selectedDate == null
        ? "Select Date of Birth"
        : DateFormat('dd-MM-yyyy').format(selectedDate!);
  }

  /// Function for signup using Supabase
  Future<void> _signup() async {
    final name = nameController.text.trim();
    final accountNumber = accountNumberController.text.trim();
   
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final panCard = panCardController.text.trim();
    final aadhaarCard = aadhaarCardController.text.trim();
    final address = addressController.text.trim();

    // Validate form inputs
    if (name.isEmpty || accountNumber.isEmpty || 
        email.isEmpty || password.isEmpty || panCard.isEmpty ||
        aadhaarCard.isEmpty || address.isEmpty || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Please fill all the details",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userCreate = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'account_number': accountNumber,
         
          'pan_card': panCard,
          'aadhaar_card': aadhaarCard,
          'date_of_birth': selectedDate?.toIso8601String(),
          'address': address,
        },
      );
      
      if (mounted) {
        if (userCreate.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "Check your email to confirm your registration!",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
          ));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Registration failed: $e"),
          backgroundColor: Colors.red,
        ));
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Registration',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: accountNumberController,
              decoration: InputDecoration(
                labelText: 'Account Number',
                prefixIcon: const Icon(Icons.account_balance),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
           
            // PAN Card field
            TextFormField(
              controller: panCardController,
              decoration: InputDecoration(
                labelText: 'PAN Card Number',
                prefixIcon: const Icon(Icons.credit_card),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            // Aadhaar Card field
            TextFormField(
              controller: aadhaarCardController,
              decoration: InputDecoration(
                labelText: 'Aadhaar Card Number',
                prefixIcon: const Icon(Icons.credit_card),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Date of Birth field
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 16,
                    color: selectedDate == null ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Address field
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                prefixIcon: const Icon(Icons.home),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Create Password',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF233B99),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isLoading ? null : _signup,
              child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : const Text(
                  'REGISTER',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                "Already have an account? Login",
                style: TextStyle(fontSize: 14, color: Color(0xFF233B99)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}