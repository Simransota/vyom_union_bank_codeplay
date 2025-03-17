// import 'package:flutter/material.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:vyom/signup_screen.dart';
// import 'login_screen.dart';

// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({Key? key}) : super(key: key);

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final controller = PageController();
//   bool isLastPage = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             PageView(
//               controller: controller,
//               onPageChanged: (index) {
//                 setState(() => isLastPage = index == 2);
//               },
//               children: [
//                 OnboardingPage(
//                   title: 'Welcome to Union Bank',
//                   description: 'Your trusted partner in banking for generations',
//                   image: 'assets/union_bank_logo.png',
//                 ),
//                 OnboardingPage(
//                   title: 'Secure Banking',
//                   description: 'Bank securely anytime, anywhere with our advanced security features',
//                   image: 'assets/onboarding1.png',
//                 ),
//                 OnboardingPage(
//                   title: 'Easy Transactions',
//                   description: 'Transfer money, pay bills, and manage your finances with ease',
//                   image: 'assets/onboarding2.png',
//                 ),
//               ],
//             ),
//             Positioned(
//               top: 16,
//               right: 16,
//               child: TextButton(
//                 child: const Text('Skip'),
//                 onPressed: () => Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const LoginScreen()),
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 32,
//               left: 0,
//               right: 0,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SmoothPageIndicator(
//                       controller: controller,
//                       count: 3,
//                       effect: WormEffect(
//                         spacing: 16,
//                         dotColor: Colors.grey.shade300,
//                         activeDotColor: const Color(0xFF233B99),
//                       ),
//                     ),
//                     FloatingActionButton(
//                       backgroundColor: const Color(0xFF233B99),
//                         child: const Icon(Icons.arrow_forward, color: Colors.white),
//                       onPressed: () {
//                         if (isLastPage) {
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(builder: (context) => const SignupScreen()),
//                           );
//                         } else {
//                           controller.nextPage(
//                             duration: const Duration(milliseconds: 500),
//                             curve: Curves.easeInOut,
//                           );
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class OnboardingPage extends StatelessWidget {
//   final String title;
//   final String description;
//   final String image;

//   const OnboardingPage({
//     Key? key,
//     required this.title,
//     required this.description,
//     required this.image,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Image.asset(
//             image,
//             height: 250,
//           ),
//           const SizedBox(height: 32),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF233B99),
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             description,
//             style: const TextStyle(
//               fontSize: 16,
//               color: Colors.grey,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:vyom/main.dart';
import 'package:vyom/screens/camera_upload_page.dart';
import 'package:vyom/screens/camera_upload_pancard.dart';
import 'package:vyom/signup_screen.dart';



class AadhaarScannerScreen extends StatefulWidget {


  const AadhaarScannerScreen({Key? key}) : super(key: key);

  @override
  State<AadhaarScannerScreen> createState() => _AadhaarScannerScreenState();
}

class _AadhaarScannerScreenState extends State<AadhaarScannerScreen> {
   @override
  void initState() {
    super.initState();
     showGlobalChatBubble = false; 
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Handle back navigation
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aadhaar Card Scanner',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Using this scanner, we will scan your Aadhaar Card. The scanner helps verify the authenticity of this document.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Note: Position your Aadhaar Card within the scanner frame.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/qr_scanner_frame.png', // You'll need to create this asset
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    // If you don't have the asset, use Icon instead:
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.document_scanner,
                      size: 150,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to PAN Card scanner after successful Aadhaar scan
                Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const CameraUploadScreen()),
);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4019FA),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                
              ),
              child: const Text(
                'SCAN NOW',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PanScannerScreen extends StatefulWidget {
 

  const PanScannerScreen({Key? key}) : super(key: key);

  @override
  State<PanScannerScreen> createState() => _PanScannerScreenState();
}

class _PanScannerScreenState extends State<PanScannerScreen> {
   @override
  void initState() {
    super.initState();
     showGlobalChatBubble = false; 
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PAN Card Scanner',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Using this scanner, you can scan your PAN Card. The scanner helps verify the authenticity of this document.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Note: Position your PAN Card within the scanner frame.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/qr_scanner_frame.png', // You'll need to create this asset
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    // If you don't have the asset, use Icon instead:
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.qr_code_scanner,
                      size: 150,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to Registration screen after successful PAN scan
                Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const CameraUploadPanScreen()),
);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4019FA),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: const Text(
                'SCAN NOW',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}