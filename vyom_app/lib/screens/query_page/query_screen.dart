import 'dart:io';
import 'dart:convert'; // For JSON decoding and base64 encoding
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:vyom/screens/query_page/query_success_screen.dart';
import 'package:vyom/screens/voice_asstance/voice_chat_bubble.dart' show VoiceChatBubble;
import 'package:image_picker/image_picker.dart'; // For picking video from gallery
import 'package:http/http.dart' as http; // For HTTP requests

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
      orElse: () => cameras.first,
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

  // Function to show the results dialog
  Future<void> _showResultsDialog(Map<String, dynamic> data) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Video Processing Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Classification: ${data["classification"]}'),
            Text('Antispoof Result: ${data["verification_results"]["antispoof_result"]}'),
            Text('Verification Result: ${data["verification_results"]["verification_result"]}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          )
        ],
      ),
    );
  }

  // Function to pick video from gallery, encode it in Base64, upload it, and display results
  Future<void> _uploadVideoFromGallery() async {
    final picker = ImagePicker();
    // Pick a video from the gallery
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile == null) {
      // User canceled picking a video
      return;
    }

    final videoFile = File(pickedFile.path);
    final bytes = await videoFile.readAsBytes();
    final videoBase64 = base64Encode(bytes);

    // Create the JSON body
    final Map<String, dynamic> jsonBody = {
      "video_base64": videoBase64,
    };

    final url = Uri.parse('https://risks-its-trace-butts.trycloudflare.com/process_video');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jsonBody),
      );

      if (response.statusCode == 200) {
        // Decode the response
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Show the dialog with results
        _showResultsDialog(jsonResponse);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload video. Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error uploading video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading video')),
      );
    }
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
                    'To submit a query, you need to record a video explaining your issue or feedback.',
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
                                        height: MediaQuery.of(context).size.height * 0.6,
                                        child: CameraPreview(_cameraController!),
                                      ),
                                    );
                                  } else {
                                    return Container(
                                      color: Color(0xFFEEFFAA),
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
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        _isRecording ? 'Stop Recording' : 'Start Recording',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Upload Video from Gallery Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _uploadVideoFromGallery,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        'Upload Video from Gallery',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                          backgroundColor: theme.colorScheme.primary,
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
            // Optionally, add VoiceChatBubble if required
            // VoiceChatBubble(
            //   onMessageReceived: (message) {
            //     print("Assistant: $message");
            //   },
            //   onUserMessage: (message) {
            //     print("User: $message");
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
