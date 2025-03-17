import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:vyom/onboardingscreen.dart';
class CameraUploadScreen extends StatefulWidget {
  const CameraUploadScreen({Key? key}) : super(key: key);

  @override
  State<CameraUploadScreen> createState() => _CameraUploadScreenState();
}

class _CameraUploadScreenState extends State<CameraUploadScreen> {
  CameraController? _cameraController;
  List<CameraDescription> cameras = [];
  bool _isRearCameraSelected = true;
  bool _isFlashOn = false;
  File? _capturedImage;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        return;
      }

      _cameraController = CameraController(
        cameras[_isRearCameraSelected ? 0 : 1],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }

      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (cameras.length < 2) return;
    
    setState(() {
      _isRearCameraSelected = !_isRearCameraSelected;
      _isCameraInitialized = false;
    });

    await _cameraController?.dispose();

    _cameraController = CameraController(
      cameras[_isRearCameraSelected ? 0 : 1],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Error switching camera: $e');
    }
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = File(photo.path);
      });
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  

void _uploadManually() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    String filePath = result.files.single.path!;
    print('📂 Selected file: $filePath');
  } else {
    print('❌ No file selected');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview or Captured Image
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: _isCameraInitialized
                ? _capturedImage != null
                    ? Image.file(
                        _capturedImage!,
                        fit: BoxFit.cover,
                      )
                    : CameraPreview(_cameraController!)
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),

          // Flash Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                ),
                onPressed: _toggleFlash,
              ),
            ),
          ),

          // Camera Switch Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            right: 80,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                onPressed: _switchCamera,
              ),
            ),
          ),

          // Selected Area Highlight
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFFF8F7D),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // Bottom Actions
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Upload Manually Button
                  ElevatedButton.icon(
                    onPressed: _uploadManually,
                    icon: const Icon(Icons.file_upload, color: Colors.white),
                    label: const Text(
                      'Upload manually',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4019FA),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  
                  // Take Photo Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Color(0xFF4019FA), size: 30),
                      onPressed: _takePhoto,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Captured image actions (only show when image is captured)
          if (_capturedImage != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Use this image?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Retake Button
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _capturedImage = null;
                            });
                          },
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text(
                            'Retake',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Use Photo Button
                        ElevatedButton.icon(
                          onPressed: () {
                            // Navigator.pop(context, _capturedImage);
                                          Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const PanScannerScreen()),
);
                            
                          },
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text(
                            'Use Photo',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}