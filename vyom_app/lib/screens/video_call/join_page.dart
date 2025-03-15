// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:hmssdk_flutter/hmssdk_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';



// class JoinScreen extends StatelessWidget {
//   const JoinScreen({super.key});

//   Future<bool> getPermissions() async {
//     if (Platform.isIOS) return true;
//     await Permission.camera.request();
//     await Permission.microphone.request();
//     await Permission.bluetoothConnect.request();

//     while ((await Permission.camera.isDenied)) {
//       await Permission.camera.request();
//     }
//     while ((await Permission.microphone.isDenied)) {
//       await Permission.microphone.request();
//     }
//     while ((await Permission.bluetoothConnect.isDenied)) {
//       await Permission.bluetoothConnect.request();
//     }
//     return true;
//   }

// // UI to render join screen
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         color: Colors.black,
//         child: Center(
//           child: ElevatedButton(
//             style: ButtonStyle(
//               shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                 RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//               ),
//             ),
//             // Function to push to meeting page
//             onPressed: () async {
//               await getPermissions();
//               Navigator.push(
//                 context,
//                 CupertinoPageRoute(builder: (_) => const MeetingPage()),
//               );
//             },
//             child: const Padding(
//               padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//               child: Text(
//                 'Join',
//                 style: TextStyle(fontSize: 20),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class MeetingPage extends StatefulWidget {
//   const MeetingPage({super.key});

//   @override
//   State<MeetingPage> createState() => _MeetingPageState();
// }

// class _MeetingPageState extends State<MeetingPage>
//     implements HMSUpdateListener {
//   //SDK
//   late HMSSDK hmsSDK;

//   // Variables required for joining a room
//   String authToken =
//       "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2ZXJzaW9uIjoyLCJ0eXBlIjoiYXBwIiwiYXBwX2RhdGEiOm51bGwsImFjY2Vzc19rZXkiOiI2NzQwODRhNDQ5NDRmMDY3MzEzYTgyMjMiLCJyb2xlIjoiZ3Vlc3QiLCJyb29tX2lkIjoiNjdjZDNlYzUzNmQ0Y2ZjMTk4MWVmYWI2IiwidXNlcl9pZCI6IjU2NzUyMjI4LWM2YzktNGZlMC04MDk1LWFlYjRhZGQ3NWQyNSIsImV4cCI6MTc0MjExOTUxNiwianRpIjoiNGNlMjYyMTQtZmJjOC00MzhjLWI1MTgtNTdlOTBmNWYzMzliIiwiaWF0IjoxNzQyMDMzMTE2LCJpc3MiOiI2NzQwODRhNDQ5NDRmMDY3MzEzYTgyMjEiLCJuYmYiOjE3NDIwMzMxMTYsInN1YiI6ImFwaSJ9.ThWQFJtRmQRZSbd0HCpMNIUSG8O258MBKPfClT0JwKQ";
//   String userName = "test_user";

//   // Variables required for rendering video and peer info
//   HMSPeer? localPeer, remotePeer;
//   HMSVideoTrack? localPeerVideoTrack, remotePeerVideoTrack;

//   // Initialize variables and join room
//   @override
//   void initState() {
//     super.initState();
//     initHMSSDK();
//   }

//   void initHMSSDK() async {
//     hmsSDK = HMSSDK();
//     await hmsSDK.build(); // ensure to await while invoking the `build` method
//     hmsSDK.addUpdateListener(listener: this);
//     hmsSDK.join(config: HMSConfig(authToken: authToken, userName: userName));
//   }

//   // Clear all variables
//   @override
//   void dispose() {
//     remotePeer = null;
//     remotePeerVideoTrack = null;
//     localPeer = null;
//     localPeerVideoTrack = null;
//     super.dispose();
//   }

//   // Called when peer joined the room - get current state of room by using HMSRoom obj
//   @override
//   void onJoin({required HMSRoom room}) {
//     room.peers?.forEach((peer) {
//       if (peer.isLocal) {
//         localPeer = peer;
//         if (peer.videoTrack != null) {
//           localPeerVideoTrack = peer.videoTrack;
//         }
//         if (mounted) {
//           setState(() {});
//         }
//       }
//     });
//   }

//   // Called when there's a peer update - use to update local & remote peer variables
//   @override
//   void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
//     switch (update) {
//       case HMSPeerUpdate.peerJoined:
//         if (!peer.isLocal) {
//           if (mounted) {
//             setState(() {
//               remotePeer = peer;
//             });
//           }
//         }
//         break;
//       case HMSPeerUpdate.peerLeft:
//         if (!peer.isLocal) {
//           if (mounted) {
//             setState(() {
//               remotePeer = null;
//             });
//           }
//         }
//         break;
//       case HMSPeerUpdate.networkQualityUpdated:
//         return;
//       default:
//         if (mounted) {
//           setState(() {
//             localPeer = null;
//           });
//         }
//     }
//   }

//   // Called when there's a track update - use to update local & remote track variables
//   @override
//   void onTrackUpdate(
//       {required HMSTrack track,
//       required HMSTrackUpdate trackUpdate,
//       required HMSPeer peer}) {
//     if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
//       switch (trackUpdate) {
//         case HMSTrackUpdate.trackRemoved:
//           if (mounted) {
//             setState(() {
//               peer.isLocal
//                   ? localPeerVideoTrack = null
//                   : remotePeerVideoTrack = null;
//             });
//           }
//           return;
//         default:
//           if (mounted) {
//             setState(() {
//               peer.isLocal
//                   ? localPeerVideoTrack = track as HMSVideoTrack
//                   : remotePeerVideoTrack = track as HMSVideoTrack;
//             });
//           }
//       }
//     }
//   }

//   // More callbacks - no need to implement for quickstart
//   @override
//   void onAudioDeviceChanged(
//       {HMSAudioDevice? currentAudioDevice,
//       List<HMSAudioDevice>? availableAudioDevice}) {}

//   @override
//   void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}

//   @override
//   void onChangeTrackStateRequest(
//       {required HMSTrackChangeRequest hmsTrackChangeRequest}) {}

//   @override
//   void onHMSError({required HMSException error}) {}

//   @override
//   void onMessage({required HMSMessage message}) {}

//   @override
//   void onReconnected() {}

//   @override
//   void onReconnecting() {}

//   @override
//   void onRemovedFromRoom(
//       {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {}

//   @override
//   void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

//   @override
//   void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}

//   @override
//   void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}

//   // Widget to render a single video tile
//   Widget peerTile(Key key, HMSVideoTrack? videoTrack, HMSPeer? peer) {
//     return Container(
//       key: key,
//       child: (videoTrack != null && !(videoTrack.isMute))
//           // Actual widget to render video
//           ? HMSVideoView(
//               track: videoTrack,
//             )
//           : Center(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.blue.withAlpha(4),
//                   shape: BoxShape.circle,
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Colors.blue,
//                       blurRadius: 20.0,
//                       spreadRadius: 5.0,
//                     ),
//                   ],
//                 ),
//                 child: Text(
//                   peer?.name.substring(0, 1) ?? "D",
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ),
//     );
//   }

//   // Widget to render grid of peer tiles and a end button
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       // Used to call "leave room" upon clicking back button [in android]
//       onWillPop: () async {
//         hmsSDK.leave();
//         Navigator.pop(context);
//         return true;
//       },
//       child: SafeArea(
//         child: Scaffold(
//           backgroundColor: Colors.black,
//           body: Stack(
//             children: [
//               // Grid of peer tiles
//               Container(
//                 height: MediaQuery.of(context).size.height,
//                 child: GridView(
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       mainAxisExtent: (remotePeerVideoTrack == null)
//                           ? MediaQuery.of(context).size.height
//                           : MediaQuery.of(context).size.height / 2,
//                       crossAxisCount: 1),
//                   children: [
//                     if (remotePeerVideoTrack != null && remotePeer != null)
//                       peerTile(
//                           Key(remotePeerVideoTrack?.trackId ?? "" "mainVideo"),
//                           remotePeerVideoTrack,
//                           remotePeer),
//                     peerTile(
//                         Key(localPeerVideoTrack?.trackId ?? "" "mainVideo"),
//                         localPeerVideoTrack,
//                         localPeer)
//                   ],
//                 ),
//               ),
//               // End button to leave the room
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: RawMaterialButton(
//                   onPressed: () {
//                     hmsSDK.leave();
//                     Navigator.pop(context);
//                   },
//                   elevation: 2.0,
//                   fillColor: Colors.red,
//                   padding: const EdgeInsets.all(15.0),
//                   shape: const CircleBorder(),
//                   child: const Icon(
//                     Icons.call_end,
//                     size: 25.0,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
  
//   @override
//   void onPeerListUpdate({required List<HMSPeer> addedPeers, required List<HMSPeer> removedPeers}) {
//     // TODO: implement onPeerListUpdate
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:hms_room_kit/hms_room_kit.dart';



// class JoinScreen extends StatelessWidget {
//   const JoinScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(),
//       themeMode: ThemeMode.dark,
//       darkTheme: ThemeData(
//           bottomSheetTheme: BottomSheetThemeData(
//               backgroundColor: themeBottomSheetColor, elevation: 5),
//           brightness: Brightness.dark,
//           primaryColor: const Color.fromARGB(255, 13, 107, 184),
//           scaffoldBackgroundColor: Colors.black),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   TextEditingController meetingLinkController = TextEditingController();
//   TextEditingController nameController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     return SafeArea(
//       child: Scaffold(
//         body: Center(
//           child: HMSPrebuilt(
//             roomCode: "qoz-efqi-zog",
//             options: HMSPrebuiltOptions(userName: "John Appleseed"),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';


class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roomIdController = TextEditingController();
  bool isCameraOn = true;
  bool isMicOn = true;
  
  Future<bool> getPermissions() async {
    if (Platform.isIOS) return true;
    
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.bluetoothConnect.request();

    while ((await Permission.camera.isDenied)) {
      await Permission.camera.request();
    }
    while ((await Permission.microphone.isDenied)) {
      await Permission.microphone.request();
    }
    while ((await Permission.bluetoothConnect.isDenied)) {
      await Permission.bluetoothConnect.request();
    }
    return true;
  }

  @override
  void dispose() {
    nameController.dispose();
    roomIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Meeting'),
        
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Your Name',
                labelStyle: const TextStyle(color: Colors.black),
                prefixIcon: const Icon(Icons.person, color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: roomIdController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Room ID (optional)',
                labelStyle: const TextStyle(color: Colors.black),
                prefixIcon: const Icon(Icons.meeting_room, color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     Column(
            //       children: [
            //         CircleAvatar(
            //           radius: 25,
            //           backgroundColor: isCameraOn ? Colors.green : Colors.red,
            //           child: IconButton(
            //             icon: Icon(
            //               isCameraOn ? Icons.videocam : Icons.videocam_off,
            //               color: Colors.white,
            //             ),
            //             onPressed: () {
            //               setState(() {
            //                 isCameraOn = !isCameraOn;
            //               });
            //             },
            //           ),
            //         ),
            //         const SizedBox(height: 8),
            //         Text(
            //           isCameraOn ? 'Camera On' : 'Camera Off',
            //           style: const TextStyle(color: Colors.white70),
            //         ),
            //       ],
            //     ),
            //     Column(
            //       children: [
            //         CircleAvatar(
            //           radius: 25,
            //           backgroundColor: isMicOn ? Colors.green : Colors.red,
            //           child: IconButton(
            //             icon: Icon(
            //               isMicOn ? Icons.mic : Icons.mic_off,
            //               color: Colors.white,
            //             ),
            //             onPressed: () {
            //               setState(() {
            //                 isMicOn = !isMicOn;
            //               });
            //             },
            //           ),
            //         ),
            //         const SizedBox(height: 8),
            //         Text(
            //           isMicOn ? 'Mic On' : 'Mic Off',
            //           style: const TextStyle(color: Colors.white70),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter your name')),
                  );
                  return;
                }
                
                await getPermissions();
                
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => MeetingPage(
                      userName: nameController.text,
                      roomId: roomIdController.text.isEmpty ? null : roomIdController.text,
                      isCameraOn: isCameraOn,
                      isMicOn: isMicOn,
                    ),
                  ),
                );
              },
              child: const Text(
                'Join Meeting',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MeetingPage extends StatefulWidget {
  final String userName;
  final String? roomId;
  final bool isCameraOn;
  final bool isMicOn;

  const MeetingPage({
    super.key,
    required this.userName,
    this.roomId,
    required this.isCameraOn,
    required this.isMicOn,
  });

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> implements HMSUpdateListener {
  // SDK
  late HMSSDK hmsSDK;

  // Room and authentication
  late String authToken;
  
  // Peer state
  List<HMSPeer> peers = [];
  HMSPeer? localPeer;
  
  // Track state
  Map<String, HMSVideoTrack> videoTracks = {};
  Map<String, HMSAudioTrack> audioTracks = {};
  
  // UI control state
  bool isMicMuted = false;
  bool isCameraMuted = false;
  bool isScreenSharing = false;
  bool showControls = true;
  bool isRoomInfoVisible = false;
  String roomId = "Meeting Room";
  List<HMSSpeaker> speakers = [];
  int participantCount = 0;
  
  // Initialize SDK and join room
  @override
  void initState() {
    super.initState();
    
    // Set initial mute states based on parameters
    isMicMuted = !widget.isMicOn;
    isCameraMuted = !widget.isCameraOn;
    
    // Initialize the room ID
    if (widget.roomId != null) {
      roomId = widget.roomId!;
    }
    
    // Get token and initialize SDK
    _getAuthToken().then((_) {
      initHMSSDK();
    });
    
    // Auto-hide controls after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          showControls = false;
        });
      }
    });
  }

  // Simulate getting an auth token (in a real app, this would come from your server)
  Future<void> _getAuthToken() async {
    // In a real app, get this token from your server
    authToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2ZXJzaW9uIjoyLCJ0eXBlIjoiYXBwIiwiYXBwX2RhdGEiOm51bGwsImFjY2Vzc19rZXkiOiI2NzQwODRhNDQ5NDRmMDY3MzEzYTgyMjMiLCJyb2xlIjoiZ3Vlc3QiLCJyb29tX2lkIjoiNjdjZDNlYzUzNmQ0Y2ZjMTk4MWVmYWI2IiwidXNlcl9pZCI6IjU2NzUyMjI4LWM2YzktNGZlMC04MDk1LWFlYjRhZGQ3NWQyNSIsImV4cCI6MTc0MjExOTUxNiwianRpIjoiNGNlMjYyMTQtZmJjOC00MzhjLWI1MTgtNTdlOTBmNWYzMzliIiwiaWF0IjoxNzQyMDMzMTE2LCJpc3MiOiI2NzQwODRhNDQ5NDRmMDY3MzEzYTgyMjEiLCJuYmYiOjE3NDIwMzMxMTYsInN1YiI6ImFwaSJ9.ThWQFJtRmQRZSbd0HCpMNIUSG8O258MBKPfClT0JwKQ";
  }

  void initHMSSDK() async {
    hmsSDK = HMSSDK();
    await hmsSDK.build(); // Await the build method
    hmsSDK.addUpdateListener(listener: this);
    
    // Join with initial audio/video state
    HMSConfig config = HMSConfig(
      authToken: authToken,
      userName: widget.userName,
    );
    
    await hmsSDK.join(config: config);
    
    // Apply initial audio/video state
    if (isMicMuted) {
      await toggleMic();
    }
    
    if (isCameraMuted) {
      await toggleCamera();
    }
  }

  // Toggles microphone mute state
  Future<void> toggleMic() async {
    if (localPeer == null) return;
    
    try {
      await hmsSDK.toggleMicMuteState();
      setState(() {
        isMicMuted = !isMicMuted;
      });
    } catch (e) {
      debugPrint("Error toggling mic: $e");
    }
  }

  // Toggles camera mute state
  Future<void> toggleCamera() async {
    if (localPeer == null) return;
    
    try {
      await hmsSDK.toggleCameraMuteState();
      setState(() {
        isCameraMuted = !isCameraMuted;
      });
    } catch (e) {
      debugPrint("Error toggling camera: $e");
    }
  }

  // Toggles screen sharing
  Future<void> toggleScreenShare() async {
    try {
      if (!isScreenSharing) {
        await hmsSDK.startScreenShare();
      } else {
        hmsSDK.stopScreenShare();
      }
      setState(() {
        isScreenSharing = !isScreenSharing;
      });
    } catch (e) {
      debugPrint("Error toggling screen share: $e");
    }
  }

  // Switch camera between front and back
  Future<void> switchCamera() async {
    try {
      await hmsSDK.switchCamera();
    } catch (e) {
      debugPrint("Error switching camera: $e");
    }
  }

  // Leave the meeting
  void leaveMeeting() async {
    try {
      await hmsSDK.leave();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint("Error leaving room: $e");
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  // Clean up resources
@override
void dispose() {
  hmsSDK.removeUpdateListener(listener: this);
  hmsSDK.leave();
  super.dispose();
}

// HMS SDK Listener Methods
@override
void onJoin({required HMSRoom room}) {
  // Update room info
  setState(() {
    roomId = room.name ?? "Meeting Room";
    participantCount = room.peerCount ?? 0;
    
    // Set local peer
    room.peers?.forEach((peer) {
      if (peer.isLocal) {
        localPeer = peer;
        peers.add(peer);
        
        // Add video track if available
        if (peer.videoTrack != null) {
          videoTracks[peer.peerId] = peer.videoTrack!;
        }
        
        // Add audio track if available
        if (peer.audioTrack != null) {
          audioTracks[peer.peerId] = peer.audioTrack!;
        }
      } else {
        // Add remote peers
        peers.add(peer);
        
        // Add video track if available
        if (peer.videoTrack != null) {
          videoTracks[peer.peerId] = peer.videoTrack!;
        }
        
        // Add audio track if available
        if (peer.audioTrack != null) {
          audioTracks[peer.peerId] = peer.audioTrack!;
        }
      }
    });
  });
}

@override
void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
  switch (update) {
    case HMSPeerUpdate.peerJoined:
      setState(() {
        peers.add(peer);
        participantCount = peers.length;
      });
      break;
      
    case HMSPeerUpdate.peerLeft:
      setState(() {
        peers.removeWhere((element) => element.peerId == peer.peerId);
        videoTracks.remove(peer.peerId);
        audioTracks.remove(peer.peerId);
        participantCount = peers.length;
      });
      break;
      
    case HMSPeerUpdate.networkQualityUpdated:
      // Handle network quality updates if needed
      break;
      
    case HMSPeerUpdate.roleUpdated:
      // Handle role updates if needed
      break;
      
    default:
      // Handle other updates
      break;
  }
}

@override
void onTrackUpdate({
  required HMSTrack track,
  required HMSTrackUpdate trackUpdate,
  required HMSPeer peer
}) {
  if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
    switch (trackUpdate) {
      case HMSTrackUpdate.trackAdded:
        setState(() {
          videoTracks[peer.peerId] = track as HMSVideoTrack;
        });
        break;
        
      case HMSTrackUpdate.trackRemoved:
        setState(() {
          videoTracks.remove(peer.peerId);
        });
        break;
        
      case HMSTrackUpdate.trackMuted:
        setState(() {
          if (peer.isLocal) {
            isCameraMuted = true;
          }
        });
        break;
        
      case HMSTrackUpdate.trackUnMuted:
        setState(() {
          if (peer.isLocal) {
            isCameraMuted = false;
          }
        });
        break;
        
      default:
        break;
    }
  } else if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
    switch (trackUpdate) {
      case HMSTrackUpdate.trackAdded:
        setState(() {
          audioTracks[peer.peerId] = track as HMSAudioTrack;
        });
        break;
        
      case HMSTrackUpdate.trackRemoved:
        setState(() {
          audioTracks.remove(peer.peerId);
        });
        break;
        
      case HMSTrackUpdate.trackMuted:
        setState(() {
          if (peer.isLocal) {
            isMicMuted = true;
          }
        });
        break;
        
      case HMSTrackUpdate.trackUnMuted:
        setState(() {
          if (peer.isLocal) {
            isMicMuted = false;
          }
        });
        break;
        
      default:
        break;
    }
  }
}

@override
void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {
  setState(() {
    speakers = updateSpeakers;
  });
}

@override
void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {
  switch (update) {
    case HMSRoomUpdate.roomMuted:
    case HMSRoomUpdate.roomUnmuted:
      // Handle room mute/unmute
      break;
      
    case HMSRoomUpdate.browserRecordingStateUpdated:
    case HMSRoomUpdate.serverRecordingStateUpdated:
    case HMSRoomUpdate.rtmpStreamingStateUpdated:
    case HMSRoomUpdate.hlsStreamingStateUpdated:
      // Handle recording state updates
      break;
      
    default:
      break;
  }
}

@override
void onHMSError({required HMSException error}) {
  debugPrint("Error: ${error.message}");
  // Show error to user if needed
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Error: ${error.message}")),
  );
}

// Required but not used for basic implementation
@override
void onMessage({required HMSMessage message}) {}

@override
void onReconnected() {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Reconnected to the room")),
  );
}

@override
void onReconnecting() {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Reconnecting...")),
  );
}

@override
void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

@override
void onChangeTrackStateRequest({required HMSTrackChangeRequest hmsTrackChangeRequest}) {
  // Handle track change requests (e.g., when someone asks you to unmute)
  if (hmsTrackChangeRequest.track.kind == HMSTrackKind.kHMSTrackKindAudio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${hmsTrackChangeRequest.requestBy?.name} has requested you to unmute your microphone"),
        action: SnackBarAction(
          label: "Unmute",
          onPressed: () {
            toggleMic();
          },
        ),
      ),
    );
  } else if (hmsTrackChangeRequest.track.kind == HMSTrackKind.kHMSTrackKindVideo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${hmsTrackChangeRequest.requestBy?.name} has requested you to turn on your camera"),
        action: SnackBarAction(
          label: "Turn On",
          onPressed: () {
            toggleCamera();
          },
        ),
      ),
    );
  }
}

@override
void onRemovedFromRoom({required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("You have been removed from the room by ${hmsPeerRemovedFromPeer.kickedBy?.name}")),
  );
  Navigator.of(context).pop();
}

@override
void onAudioDeviceChanged({HMSAudioDevice? currentAudioDevice, List<HMSAudioDevice>? availableAudioDevice}) {
  // Handle audio device changes
}

@override
void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {
  // Handle session store
}

@override
void onPeerListUpdate({required List<HMSPeer> addedPeers, required List<HMSPeer> removedPeers}) {
  setState(() {
    // Add new peers
    for (final peer in addedPeers) {
      if (!peers.any((element) => element.peerId == peer.peerId)) {
        peers.add(peer);
      }
    }
    
    // Remove peers that left
    for (final peer in removedPeers) {
      peers.removeWhere((element) => element.peerId == peer.peerId);
      videoTracks.remove(peer.peerId);
      audioTracks.remove(peer.peerId);
    }
    
    participantCount = peers.length;
  });
}

// UI for the meeting page
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: GestureDetector(
      onTap: () {
        setState(() {
          showControls = !showControls;
        });
        
        if (showControls) {
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              setState(() {
                showControls = false;
              });
            }
          });
        }
      },
      child: Stack(
        children: [
          // Video grid
          Container(
            color: Colors.black,
            child: peers.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _buildVideoGrid(),
          ),
          
          // Room info at the top
          AnimatedOpacity(
            opacity: showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          roomId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.people, size: 16, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                participantCount.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          isRoomInfoVisible = !isRoomInfoVisible;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Controls at the bottom
          AnimatedOpacity(
            opacity: showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: isMicMuted ? Colors.red : Colors.green,
                        child: IconButton(
                          icon: Icon(
                            isMicMuted ? Icons.mic_off : Icons.mic,
                            color: Colors.white,
                          ),
                          onPressed: toggleMic,
                        ),
                      ),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: isCameraMuted ? Colors.red : Colors.green,
                        child: IconButton(
                          icon: Icon(
                            isCameraMuted ? Icons.videocam_off : Icons.videocam,
                            color: Colors.white,
                          ),
                          onPressed: toggleCamera,
                        ),
                      ),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blue,
                        child: IconButton(
                          icon: const Icon(
                            Icons.switch_camera,
                            color: Colors.white,
                          ),
                          onPressed: switchCamera,
                        ),
                      ),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: isScreenSharing ? Colors.amber : Colors.blue,
                        child: IconButton(
                          icon: Icon(
                            isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
                            color: Colors.white,
                          ),
                          onPressed: toggleScreenShare,
                        ),
                      ),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                          ),
                          onPressed: leaveMeeting,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Room info dialog
          if (isRoomInfoVisible)
            GestureDetector(
              onTap: () {
                setState(() {
                  isRoomInfoVisible = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A2742),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Meeting Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _infoRow("Room ID", roomId),
                        _infoRow("Participants", participantCount.toString()),
                        _infoRow("Your Name", widget.userName),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              isRoomInfoVisible = false;
                            });
                          },
                          child: const Text("Close"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

// Helper method to build info rows
Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

// Build the video grid based on the number of peers
Widget _buildVideoGrid() {
  if (peers.isEmpty) {
    return const Center(child: CircularProgressIndicator());
  }
  
  // Different layouts based on peer count
  if (peers.length == 1) {
    return _buildVideoTile(peers[0]);
  } else if (peers.length == 2) {
    return Column(
      children: [
        Expanded(child: _buildVideoTile(peers[0])),
        Expanded(child: _buildVideoTile(peers[1])),
      ],
    );
  } else {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: peers.length <= 4 ? 2 : 3,
        childAspectRatio: 1,
      ),
      itemCount: peers.length,
      itemBuilder: (context, index) {
        return _buildVideoTile(peers[index]);
      },
    );
  }
}

// Build individual video tiles
Widget _buildVideoTile(HMSPeer peer) {
  final bool hasVideo = videoTracks.containsKey(peer.peerId) && 
                        !(videoTracks[peer.peerId]?.isMute ?? true);
  
  return Container(
    margin: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: Colors.black87,
      border: Border.all(
        color: peer.isLocal ? Colors.blue : Colors.grey,
        width: 1,
      ),
    ),
    child: Stack(
      children: [
        // Video or avatar placeholder
        Center(
          child: hasVideo
              ? HMSVideoView(
                  track: videoTracks[peer.peerId]!,
                  scaleType: ScaleType.SCALE_ASPECT_FILL,
                )
              : CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue.withOpacity(0.3),
                  child: Text(
                    peer.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
        
        // Name and audio indicator
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            color: Colors.black54,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${peer.name}${peer.isLocal ? ' (You)' : ''}",
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  audioTracks.containsKey(peer.peerId) && 
                  !(audioTracks[peer.peerId]?.isMute ?? true)
                      ? Icons.mic
                      : Icons.mic_off,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        
        // Speaking indicator
        if (speakers.any((speaker) => speaker.peer.peerId == peer.peerId))
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              color: Colors.green,
            ),
          ),
      ],
    ),
  );
}
}

extension on HMSPeerRemovedFromPeer {
  get kickedBy => null;
}