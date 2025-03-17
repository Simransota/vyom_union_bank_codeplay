import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//authentication sucessfully backend
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with TickerProviderStateMixin {
  bool _isVerifying = false;
  
  // Initialize controllers with default values to avoid LateInitializationError
  AnimationController? _pulseController;
  AnimationController? _successController;
  Animation<double>? _pulseAnimation;
  Animation<double>? _successScaleAnimation;
  Animation<double>? _successOpacityAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers in initState
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _successController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController!,
        curve: Curves.easeInOut,
      ),
    );
    
    _successScaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _successController!,
        curve: Curves.easeOutBack,
      ),
    );
    
    _successOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController!,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start pulsing animation after short delay to ensure everything is initialized
    Future.delayed(Duration.zero, () {
      if (mounted) {
        _pulseController?.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    _successController?.dispose();
    super.dispose();
  }

  void _startVerification() {
    // Only proceed if controllers are initialized
    if (_pulseController == null || _successController == null) return;
    
    // Trigger haptic feedback (like iOS)
    HapticFeedback.lightImpact();
    
    setState(() {
      _isVerifying = true;
    });
    
    // Stop pulsing during verification
    _pulseController?.stop();

    // Simulate verification process
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      
      // Show success animation
      _successController?.forward().then((_) {
        // After success animation completes, navigate
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const SuccessScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // iOS-style fade transition
                const begin = 0.0;
                const end = 1.0;
                const curve = Curves.easeOut;
                
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var opacityAnimation = animation.drive(tween);
                
                return FadeTransition(
                  opacity: opacityAnimation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if animations are initialized
    if (_pulseAnimation == null || _successScaleAnimation == null || _successOpacityAnimation == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Status bar area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
              
              ),
            ),
            SizedBox(height: 40),
            // Face ID icon with animations
            AnimatedBuilder(
              animation: _isVerifying ? _successController! : _pulseController!,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isVerifying 
                      ? _successController!.isCompleted 
                          ? _successScaleAnimation!.value 
                          : 1.0 
                      : _pulseAnimation!.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: _isVerifying 
                            ? _successController!.isCompleted 
                                ? Colors.green.withOpacity(_successOpacityAnimation!.value) 
                                : Colors.green 
                            : Colors.green,
                        width: 2,
                      ),
                    ),
                    child: _isVerifying
                        ? _successController!.isCompleted
                            ? FadeTransition(
                                opacity: _successOpacityAnimation!,
                                child: Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 60,
                                ),
                              )
                            : Center(
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(
                                    color: Colors.green,
                                    strokeWidth: 3,
                                  ),
                                ),
                              )
                        : CustomPaint(
                            painter: FaceIDPainter(),
                          ),
                  ),
                );
              },
            ),
            Spacer(),
            // Lock icon with fade animation
            AnimatedOpacity(
              opacity: _isVerifying && _successController!.isCompleted ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.lock,
                color: Colors.green,
                size: 40,
              ),
            ),
            SizedBox(height: 20),
            // WhatsApp Locked text with fade animation
            AnimatedOpacity(
              opacity: _isVerifying && _successController!.isCompleted ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                'FACE VERIFICATION',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Unlock button with scale animation on press
            AnimatedOpacity(
              opacity: _isVerifying && _successController!.isCompleted ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 200),
                tween: Tween<double>(begin: 1.0, end: _isVerifying ? 0.95 : 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: GestureDetector(
                      onTap: _isVerifying ? null : _startVerification,
                      child: Container(
                        width: 300,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            'Verify Face',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Spacer(),
            // Bottom indicator with subtle animation
            AnimatedOpacity(
              opacity: _isVerifying && _successController!.isCompleted ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 120,
                height: 5,
                margin: EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FaceIDPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Top left corner
    canvas.drawArc(
      Rect.fromLTWH(10, 10, 30, 30),
      3.14 * 1, // π radians (180 degrees)
      3.14 / 2, // π/2 radians (90 degrees)
      false,
      paint,
    );

    // Top right corner
    canvas.drawArc(
      Rect.fromLTWH(size.width - 40, 10, 30, 30),
      3.14 * 1.5, // 3π/2 radians (270 degrees)
      3.14 / 2, // π/2 radians (90 degrees)
      false,
      paint,
    );

    // Bottom left corner
    canvas.drawArc(
      Rect.fromLTWH(10, size.height - 40, 30, 30),
      3.14 / 2, // π/2 radians (90 degrees)
      3.14 / 2, // π/2 radians (90 degrees)
      false,
      paint,
    );

    // Bottom right corner
    canvas.drawArc(
      Rect.fromLTWH(size.width - 40, size.height - 40, 30, 30),
      0,
      3.14 / 2, // π/2 radians (90 degrees)
      false,
      paint,
    );

    // Draw smile
    canvas.drawArc(
      Rect.fromLTWH(size.width / 2 - 15, size.height / 2, 30, 30),
      0,
      3.14, // π radians (180 degrees)
      false,
      paint,
    );

    // Draw eyes
    canvas.drawCircle(
      Offset(size.width / 2 - 10, size.height / 2 - 5),
      3,
      paint..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(size.width / 2 + 10, size.height / 2 - 5),
      3,
      paint,
    );

    // Draw nose
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2 - 5),
      Offset(size.width / 2, size.height / 2 + 5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> with TickerProviderStateMixin {
  AnimationController? _scaleController;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Success animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Scale animation for success checkmark
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 30,
      ),
    ]).animate(_scaleController!);
    
    // Start animation after a small delay for more natural feel
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _scaleController?.forward();
      }
    });
  }

  @override
  void dispose() {
    _scaleController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if animations are initialized
    if (_scaleAnimation == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _scaleController!,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation!.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Center(
                  child: Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 60,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}