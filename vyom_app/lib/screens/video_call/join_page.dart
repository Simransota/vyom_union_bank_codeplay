// // import 'dart:math';
// // import 'package:flutter/material.dart';
// // import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// // import 'package:pin_code_fields/pin_code_fields.dart';
// // import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// // import '../../../constants/constants.dart';

// // class JoinScreen extends StatefulWidget {
// //   const JoinScreen({Key? key}) : super(key: key);

// //   @override
// //   _JoinScreenState createState() => _JoinScreenState();
// // }

// // class _JoinScreenState extends State<JoinScreen> {
// //   final TextEditingController _linkController = TextEditingController();
// //   String currentText = "";
// //   bool hasError = false;
// //   final formKey = GlobalKey<FormState>();

// //   void _startCall() {
// //     String link = currentText.trim();
// //     String? callID = _extractCallIDFromLink(link);
// //     if (callID != null && callID.isNotEmpty) {
// //       Navigator.push(
// //         context,
// //         MaterialPageRoute(builder: (context) => CallPage(callID: callID)),
// //       );
// //     } else {
// //       setState(() {
// //         hasError = true;
// //       });
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Please enter a valid link')),
// //       );
// //     }
// //   }

// //   String? _extractCallIDFromLink(String link) {
// //     // Extract the call ID from the link
// //     Uri? uri = Uri.tryParse(link);
// //     if (uri != null && uri.queryParameters.containsKey('callID')) {
// //       return uri.queryParameters['callID'];
// //     }
// //     return null;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Join Video Call'),
// //         backgroundColor: theme.colorScheme.surface,
// //         foregroundColor: theme.colorScheme.onSurface,
// //         elevation: 0,
// //       ),
// //       body: Container(
// //         color: const Color(0xFFF8F8F8),
// //         child: SafeArea(
// //           child: Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 24.0),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.center,
// //               children: [
// //                 const SizedBox(height: 30),
// //                 Container(
// //                   padding: const EdgeInsets.all(16),
// //                   decoration: BoxDecoration(
// //                     color: Colors.white,
// //                     borderRadius: BorderRadius.circular(20),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Colors.black.withOpacity(0.1),
// //                         blurRadius: 10,
// //                         spreadRadius: 1,
// //                       ),
// //                     ],
// //                   ),
// //                   child: Column(
// //                     children: [
// //                       const Icon(
// //                         Icons.video_call,
// //                         size: 60,
// //                         color: Color(0xFF233B99),
// //                       ),
// //                       const SizedBox(height: 20),
// //                       const Text(
// //                         "Enter Call Link",
// //                         style: TextStyle(
// //                           fontSize: 22,
// //                           fontWeight: FontWeight.bold,
// //                           color: Color(0xFF233B99),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 10),
// //                       const Text(
// //                         "Please enter the link to join the video call",
// //                         textAlign: TextAlign.center,
// //                         style: TextStyle(
// //                           fontSize: 14,
// //                           color: Colors.black54,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 30),
// //                       Form(
// //                         key: formKey,
// //                         child: Padding(
// //                           padding: const EdgeInsets.symmetric(horizontal: 10.0),
// //                           child: TextFormField(
// //                             controller: _linkController,
// //                             decoration: InputDecoration(
// //                               labelText: 'Call Link',
// //                               border: OutlineInputBorder(
// //                                 borderRadius: BorderRadius.circular(10),
// //                               ),
// //                             ),
// //                             onChanged: (value) {
// //                               setState(() {
// //                                 currentText = value;
// //                                 hasError = false;
// //                               });
// //                             },
// //                           ),
// //                         ),
// //                       ),
// //                       if (hasError)
// //                         Padding(
// //                           padding: const EdgeInsets.symmetric(vertical: 8.0),
// //                           child: Text(
// //                             "Please enter a valid link",
// //                             style: TextStyle(
// //                               color: Colors.red.shade300,
// //                               fontSize: 12,
// //                             ),
// //                           ),
// //                         ),
// //                       const SizedBox(height: 20),
// //                       ElevatedButton(
// //                         onPressed: _startCall,
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: const Color(0xFF233B99),
// //                           foregroundColor: Colors.white,
// //                           minimumSize: const Size(double.infinity, 50),
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(10),
// //                           ),
// //                           elevation: 2,
// //                         ),
// //                         child: const Text(
// //                           "Join Call",
// //                           style: TextStyle(fontSize: 16),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 20),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class CallPage extends StatelessWidget {
// //   final String callID;

// //   const CallPage({Key? key, required this.callID}) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     final userId = Random().nextInt(9999).toString();
// //     final theme = Theme.of(context);
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Join Video Call'),
// //         backgroundColor: theme.colorScheme.surface,
// //         foregroundColor: theme.colorScheme.onSurface,
// //         elevation: 0,
// //       ),
// //       body: ZegoUIKitPrebuiltCall(
// //         appID: AppInfo.appID, 
// //         appSign: AppInfo.appSign,
// //         userID: userId,
// //         userName: 'user_$userId',
// //         callID: callID,
// //         config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
// //       ),
// //     );
// //   }
// // }

// import 'dart:io';

// import 'package:vyom/screens/video_call/hms_sdk_interactor.dart';
// import 'package:vyom/screens/video_call/preview/preview_screen.dart';
// import 'package:vyom/screens/video_call/preview/preview_store.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hmssdk_flutter/hmssdk_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';




// class JoinScreen extends StatefulWidget {
//   const JoinScreen({Key? key}) : super(key: key);

//   @override
//   _JoinScreenState createState() => _JoinScreenState();
// }

// Future<bool> getPermissions() async {
//   if (Platform.isIOS) return true;
//   await Permission.camera.request();
//   await Permission.microphone.request();
//   await Permission.bluetoothConnect.request();

//   while ((await Permission.camera.isDenied)) {
//     await Permission.camera.request();
//   }
//   while ((await Permission.microphone.isDenied)) {
//     await Permission.microphone.request();
//   }
//   while ((await Permission.bluetoothConnect.isDenied)) {
//     await Permission.bluetoothConnect.request();
//   }
//   return true;
// }

// class _JoinScreenState extends State<JoinScreen> {
//   TextEditingController nameTextController = TextEditingController(text: "");
//   TextEditingController roomCodeController =
//       TextEditingController(text: "zhr-seow-tuj");
    
//   @override
//   Widget build(BuildContext context) {
//      final theme = Theme.of(context);
//     return SafeArea(
//       child: Scaffold(
//         body: Center(
//             child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               "100ms Riverpod Example",
//               style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             SizedBox(
//               width: 300.0,
//               child: TextField(
//                 controller: roomCodeController,
//                 autofocus: true,
//                 keyboardType: TextInputType.url,
//                 decoration: InputDecoration(
//                     hintText: 'Enter Room URL',
//                     suffixIcon: IconButton(
//                       onPressed: roomCodeController.clear,
//                       icon: const Icon(Icons.clear),
//                     ),
//                     border: const OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(16)))),
//               ),
//             ),
//             const SizedBox(
//               height: 30.0,
//             ),
//             SizedBox(
//               width: 300.0,
//               child: TextField(
//                 controller: nameTextController,
//                 autofocus: true,
//                 keyboardType: TextInputType.url,
//                 decoration: InputDecoration(
//                     hintText: 'Enter Name',
//                     suffixIcon: IconButton(
//                       onPressed: nameTextController.clear,
//                       icon: const Icon(Icons.clear),
//                     ),
//                     border: const OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(16)))),
//               ),
//             ),
//             const SizedBox(
//               height: 30.0,
//             ),
//             SizedBox(
//               width: 300.0,
//               child: ElevatedButton(
//                 style: ButtonStyle(
//                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                         RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16.0),
//                 ))),
//                 onPressed: () async {
//                   if (roomCodeController.text.isNotEmpty &&
//                       nameTextController.text.isNotEmpty) {
//                     bool res = await getPermissions();
//                     if (res) {
//                       var hmssdk = HMSSDK();
//                       await hmssdk.build();
//                       var hmssdkInteractor = HMSSDKInteractor(hmsSDK: hmssdk);
//                       var previewStore =
//                           PreviewStore(hmssdkInteractor: hmssdkInteractor);

//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => PreviewScreen(
//                                   name: nameTextController.text,
//                                   roomLink: roomCodeController.text,
//                                   previewStore: previewStore,
//                                 )),
//                       );
//                     }
//                   }
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.all(4.0),
//                   decoration: const BoxDecoration(
//                       borderRadius: BorderRadius.all(Radius.circular(16))),
//                   child: Text('Join Meeting',
//                       style: TextStyle(fontSize: 20, color: theme.colorScheme.primary)),
//                 ),
//               ),
//             )
//           ],
//         )),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({Key? key}) : super(key: key);

  @override
  _JoinScreenState createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  InAppWebViewController? webViewController;
  bool isLoading = true; // Show loader until page loads

  @override
  Widget build(BuildContext context) {
    String iframeHtml = """
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { margin: 0; }
          iframe {
            width: 100%;
            height: 100vh;
            border: none;
          }
        </style>
      </head>
      <body>
        <iframe 
          title="100ms-app"
          allow="camera *;microphone *;display-capture *"
          src="https://simran-videoconf-1239.app.100ms.live/meeting/jte-lwyv-lgi"
        ></iframe>
      </body>
      </html>
    """;

    return Scaffold(
      appBar: AppBar(title: const Text('Join Meeting')),
      body: Stack(
        children: [
          InAppWebView(
            initialData: InAppWebViewInitialData(data: iframeHtml),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false, // Auto-play media
              ),
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStop: (_, __) {
              setState(() {
                isLoading = false;
              });
            },
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
