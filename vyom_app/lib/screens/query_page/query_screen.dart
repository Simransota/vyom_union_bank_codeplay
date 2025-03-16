import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:vyom/screens/query_page/query_success_screen.dart';
import 'package:vyom/screens/voice_asstance/voice_chat_bubble.dart' show VoiceChatBubble;

class VideoQueryScreen extends StatefulWidget {
  @override
  _VideoQueryScreenState createState() => _VideoQueryScreenState();
}

class _VideoQueryScreenState extends State<VideoQueryScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  VideoPlayerController? _videoPlayerController;
  bool _isRecording = false;
  String? _videoPath;
  

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
  final cameras = await availableCameras();
  if (cameras.isEmpty) {
    print('No cameras available');
    return;
  }

  // Find the front camera
  final frontCamera = cameras.firstWhere(
    (camera) => camera.lensDirection == CameraLensDirection.front,
    orElse: () => cameras.first, // Default to first camera if no front camera is found
  );

  _cameraController = CameraController(frontCamera, ResolutionPreset.high);

  try {
    _initializeControllerFuture = _cameraController!.initialize();
    await _initializeControllerFuture;
    if (mounted) setState(() {});
  } catch (e) {
    print('Error initializing camera: $e');
  }
}


  Future<void> _startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_cameraController == null || !_cameraController!.value.isRecordingVideo) return;

    try {
      final videoFile = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _videoPath = videoFile.path;
      });
      _initializeVideoPlayer(videoFile.path);
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  void _initializeVideoPlayer(String path) {
    _videoPlayerController?.dispose();
    _videoPlayerController = VideoPlayerController.file(File(path))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _videoPlayerController!.play();
        }
      });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _submitQuery() {
    if (_videoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please record a video before submitting')),
      );
      return;
    }

    

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoQuerySuccessScreen(
          queryType: 'loan inquiry',
          referenceId: "LC789012",
        ),
      ),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Submit Video Query',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Record Your Query',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'To submit a query, you need to record a video explaining your issue or feedback. ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.6,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _videoPlayerController != null && _videoPlayerController!.value.isInitialized
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: AspectRatio(
                                    aspectRatio: _videoPlayerController!.value.aspectRatio,
                                    child: VideoPlayer(_videoPlayerController!),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _videoPlayerController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (_videoPlayerController!.value.isPlaying) {
                                        _videoPlayerController!.pause();
                                      } else {
                                        _videoPlayerController!.play();
                                      }
                                    });
                                  },
                                ),
                              ],
                            )
                          : Center(
                              child: FutureBuilder<void>(
                                future: _initializeControllerFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done &&
                                      _cameraController != null &&
                                      _cameraController!.value.isInitialized) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6, // Increase height
                      child: CameraPreview(_cameraController!),
                    ),
                                    );
                                  } else {
                                    return Container(
                                      color: Color(0xFFEEFFAA), // Light green color as shown in the image
                                    );
                                  }
                                },
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isRecording ? _stopRecording : _startRecording,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary, // Deep blue color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        _isRecording ? 'Stop Recording' : 'Start Recording',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _submitQuery,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary, // Deep blue color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          'Submit Query',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,  
                          ),
                        ),
                      ),
                    ],
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
      ),
    );
  }
}