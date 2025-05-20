// lib/screens/splash_screen.dart (Updated)
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tap_the_color/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final List<Color> _clockColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
  ];
  
  Color _currentClockColor = Colors.purple;
  int _currentSeconds = 0;
  int _colorIndex = 0;
  bool _showLogo = false;
  bool _isDarkMode = false; // Default to light mode
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    // Create scale animation
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    // Start animation
    _controller.forward();
    
    // Start the clock with color change
    _startClock();
    
    // Show logo after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showLogo = true;
      });
    });
    
    // Navigate to home screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
            updateTheme: _updateTheme, // Pass the theme update function
            isDarkMode: _isDarkMode,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.0;
            const end = 1.0;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var fadeAnimation = animation.drive(tween);
            return FadeTransition(opacity: fadeAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }
  
  // Function to update theme state
  void _updateTheme(bool isDarkMode) {
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }
  
  void _startClock() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentSeconds = (_currentSeconds + 1) % 60;
          _colorIndex = (_colorIndex + 1) % _clockColors.length;
          _currentClockColor = _clockColors[_colorIndex];
        });
      } else {
        timer.cancel();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final backgroundColor = _isDarkMode ? const Color(0xFF201429) : const Color(0xFF2D1B3D);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Clock Icon
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Clock face
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _currentClockColor,
                              width: 4,
                            ),
                          ),
                        ),
                        
                        // Hour hand
                        Transform.rotate(
                          angle: 2 * pi * (_currentSeconds / 60) * 0.08333,  // 1/12th rotation per second
                          child: Container(
                            height: 40,
                            width: 4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            margin: const EdgeInsets.only(bottom: 40),
                          ),
                        ),
                        
                        // Minute hand
                        Transform.rotate(
                          angle: 2 * pi * (_currentSeconds / 60),
                          child: Container(
                            height: 50,
                            width: 3,
                            decoration: BoxDecoration(
                              color: _currentClockColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            margin: const EdgeInsets.only(bottom: 50),
                          ),
                        ),
                        
                        // Center dot
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _currentClockColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              // Game Logo with animation
              AnimatedOpacity(
                opacity: _showLogo ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                child: Container(
                  margin: const EdgeInsets.only(top: 40),
                  padding: const EdgeInsets.all(16),
                  width: size.width * 0.8,
                  child: Column(
                    children: [
                      // Decorative top element
                      Container(
                        width: 40,
                        height: 20,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: CustomPaint(
                          painter: DecorativeDiamondPainter(
                            color: const Color(0xFF9C27B0),
                          ),
                        ),
                      ),
                      
                      // Title and subtitle
                      const Text(
                        "Tap the Color",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "WIN PERCENTAGE IS ZERO",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      // Decorative bottom element
                      Container(
                        width: 40,
                        height: 20,
                        margin: const EdgeInsets.only(top: 10),
                        child: CustomPaint(
                          painter: DecorativeDiamondPainter(
                            color: const Color(0xFF9C27B0),
                            isFlipped: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for decorative elements
class DecorativeDiamondPainter extends CustomPainter {
  final Color color;
  final bool isFlipped;
  
  DecorativeDiamondPainter({
    required this.color,
    this.isFlipped = false,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    if (!isFlipped) {
      // Top decorative element (diamond with swirls)
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width * 0.6, size.height * 0.4);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width * 0.4, size.height * 0.4);
      path.close();
      
      // Left swirl
      path.moveTo(size.width * 0.2, size.height * 0.5);
      path.quadraticBezierTo(0, size.height * 0.2, size.width * 0.35, size.height * 0.5);
      
      // Right swirl
      path.moveTo(size.width * 0.8, size.height * 0.5);
      path.quadraticBezierTo(size.width, size.height * 0.2, size.width * 0.65, size.height * 0.5);
    } else {
      // Bottom decorative element (flipped version)
      path.moveTo(size.width / 2, size.height);
      path.lineTo(size.width * 0.6, size.height * 0.6);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width * 0.4, size.height * 0.6);
      path.close();
      
      // Left swirl
      path.moveTo(size.width * 0.2, size.height * 0.5);
      path.quadraticBezierTo(0, size.height * 0.8, size.width * 0.35, size.height * 0.5);
      
      // Right swirl
      path.moveTo(size.width * 0.8, size.height * 0.5);
      path.quadraticBezierTo(size.width, size.height * 0.8, size.width * 0.65, size.height * 0.5);
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}