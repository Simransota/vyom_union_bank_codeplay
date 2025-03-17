import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:translator/translator.dart';
import 'package:vyom/onboardingscreen.dart';
import './screens/home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final translator = GoogleTranslator(); 
  final LocalAuthentication auth = LocalAuthentication();
  final supabase = Supabase.instance.client;
  bool isLoading = false;
  bool _isBiometricsAvailable = false;
  List<BiometricType> _availableBiometrics = [];
  String _authStatus = '';
  String _biometricSupportStatus = ''; 

  final _customerIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricSupport() async {
    bool isSupported = await auth.isDeviceSupported();
    
    if (isSupported) {
      try {
        bool canCheckBiometrics = await auth.canCheckBiometrics;
        if (canCheckBiometrics) {
          List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
          setState(() {
            _isBiometricsAvailable = true;
            _availableBiometrics = availableBiometrics;
            _biometricSupportStatus = 'Biometric authentication is available.\nAvailable biometrics: ${_getBiometricTypeIcon()}';
          });
        } else {
          setState(() {
            _biometricSupportStatus = 'Biometrics cannot be checked on this device.';
          });
        }
      } on PlatformException catch (e) {
        setState(() {
          _biometricSupportStatus = 'Error checking biometrics: ${e.message}';
        });
        print('Error checking biometrics: ${e.message}');
      }
    } else {
      setState(() {
        _biometricSupportStatus = 'This device does not support biometric authentication.';
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (!_isBiometricsAvailable) return;  // Check if biometrics are available

    try {
      setState(() {
        _authStatus = 'Authenticating...';
      });

      bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      setState(() {
        _authStatus = authenticated ? 'Success' : 'Failed';
      });

      if (authenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(translator: translator)),
        );
      }
    } on PlatformException catch (e) {
      setState(() {
        _authStatus = 'Error: ${e.message}';
      });
      print('Authentication error: ${e.message}');
    }
  }

  String _getBiometricTypeIcon() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else {
      return 'Biometrics';
    }
  }

  IconData _getBiometricIcon() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    } else {
      return Icons.security;
    }
  }

  Future<void> _login() async {
    final password = _passwordController.text.trim();
    final email = _emailController.text.trim();

    setState(() {
      isLoading = true;
    });
    try {
      await supabase.auth.signInWithPassword(password: password, email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Successfully login",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 21, color: Colors.white),
          ),
          backgroundColor: Colors.greenAccent,
        ));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen(translator: translator)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Login Failed")));
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
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  'assets/union_bank_logo.png',
                  height: 80,
                ),
                
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      labelText: "Email", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: "Password", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      side: const BorderSide(width: 2, color: Colors.blue)),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const Text(
                          "Login",
                          style:
                              TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
                
                // Removed duplicate login button
                
                if (_isBiometricsAvailable) ...[
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(_getBiometricIcon(), color: Colors.white),
                    label: Text(
                      'Login with ${_getBiometricTypeIcon()}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _authenticateWithBiometrics,
                  ),
                ],
                const SizedBox(height: 16),
                TextButton(
                  child: const Text('New User? Register Here'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AadhaarScannerScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  _biometricSupportStatus,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _biometricSupportStatus.contains('Error') 
                        ? Colors.red 
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_authStatus.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    _authStatus,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _authStatus == 'Success' 
                          ? Colors.green 
                          : _authStatus == 'Authenticating...' 
                              ? theme.colorScheme.primary 
                              : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}