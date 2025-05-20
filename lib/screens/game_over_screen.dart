// lib/screens/game_over_screen.dart (Updated)
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameOverScreen extends StatefulWidget {
  final int score;
  final VoidCallback onPlayAgain;
  final VoidCallback onGoHome;
  final bool isDarkMode; // Added isDarkMode parameter

  const GameOverScreen({
    Key? key,
    required this.score,
    required this.onPlayAgain,
    required this.onGoHome,
    required this.isDarkMode, // Made isDarkMode required
  }) : super(key: key);

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> with SingleTickerProviderStateMixin {
  int highScore = 0;
  bool isLoading = true;
  bool isNewHighScore = false;
  late AnimationController _confettiController;
  final List<Particle> _particles = [];
  final Random _random = Random();
  
  final List<Color> _confettiColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    
    // Initialize confetti animation
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    _confettiController.addListener(() {
      if (_confettiController.value == 0) {
        // Clear particles at the end
        _particles.clear();
      }
    });
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('highScore') ?? 0;
    
    // Check if we have a new high score
    isNewHighScore = widget.score >= highScore;
    
    // Update high score if needed
    if (isNewHighScore) {
      highScore = widget.score;
      await prefs.setInt('highScore', highScore);
      
      // Create initial confetti particles
      _createConfetti(40);
      // Start the animation
      _confettiController.repeat();
    }
    
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  void _createConfetti(int count) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    for (int i = 0; i < count; i++) {
      _particles.add(
        Particle(
          position: Offset(
            _random.nextDouble() * screenWidth,
            -20 - _random.nextDouble() * 100, // Start above screen
          ),
          velocity: Offset(
            (_random.nextDouble() * 2 - 1) * 2,
            _random.nextDouble() * 3 + 2,
          ),
          color: _confettiColors[_random.nextInt(_confettiColors.length)],
          size: _random.nextDouble() * 8 + 5,
          rotation: _random.nextDouble() * 2 * pi,
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final backgroundColor = widget.isDarkMode ? const Color(0xFF2D1B3D) : const Color(0xFF3D294F);
    
    return Container(
      height: size.height * 0.7,
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF201429) : const Color(0xFF2D1B3D),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
              children: [
                // Confetti animation
                if (isNewHighScore)
                  AnimatedBuilder(
                    animation: _confettiController,
                    builder: (context, child) {
                      // Update particle positions
                      for (var particle in _particles) {
                        particle.position += particle.velocity;
                        particle.rotation += 0.05;
                      }
                      
                      return CustomPaint(
                        painter: ConfettiPainter(
                          particles: _particles,
                        ),
                        size: Size(size.width, size.height),
                      );
                    },
                  ),
                
                // Main content
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Game Over Title with decorative elements
                      Stack(
                        children: [
                          // Background glow
                          Positioned.fill(
                            child: Center(
                              child: Container(
                                width: 180,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF9C27B0).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                          
                          Column(
                            children: [
                              // Top decorative element
                              Container(
                                width: 40,
                                height: 20,
                                margin: const EdgeInsets.only(bottom: 8),
                                child: CustomPaint(
                                  painter: DecorativePainter(
                                    color: const Color(0xFF9C27B0),
                                  ),
                                ),
                              ),
                              
                              const Text(
                                'GAME OVER!',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              
                              // Bottom decorative element
                              Container(
                                width: 40,
                                height: 20,
                                margin: const EdgeInsets.only(top: 8),
                                child: CustomPaint(
                                  painter: DecorativePainter(
                                    color: const Color(0xFF9C27B0),
                                    isFlipped: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Score card with shine effect
                      Stack(
                        children: [
                          // Score card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Final Score
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.emoji_events,
                                        color: Colors.amber,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'FINAL SCORE',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white70,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              '${widget.score}',
                                              style: const TextStyle(
                                                fontSize: 36,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            if (isNewHighScore)
                                              Container(
                                                margin: const EdgeInsets.only(left: 10),
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.amber,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: const Row(
                                                  children: [
                                                    Icon(
                                                      Icons.workspace_premium,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'NEW BEST!',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                
                                // Divider
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 16),
                                  height: 1,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                
                                // High Score
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.military_tech,
                                        color: Color(0xFFFFD700),
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'HIGH SCORE',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white70,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '$highScore',
                                          style: const TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFFD700),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Shine effect for new high score
                          if (isNewHighScore)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: ShineEffect(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: 20,
                              ),
                            ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Buttons
                      Row(
                        children: [
                          // Play Again button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: widget.onPlayAgain,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF9C27B0),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                                shadowColor: const Color(0xFF9C27B0).withOpacity(0.5),
                              ),
                              icon: const Icon(
                                Icons.replay,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'PLAY AGAIN',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Home button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: widget.onGoHome,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade800,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(
                                Icons.home,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'HOME',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// Particle class for confetti
class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double rotation;
  
  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.rotation,
  });
}

// Confetti painter
class ConfettiPainter extends CustomPainter {
  final List<Particle> particles;
  
  ConfettiPainter({required this.particles});
  
  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;
      
      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.rotation);
      
      // Draw a rectangular confetti
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.5,
        ),
        paint,
      );
      
      canvas.restore();
    }
  }
  
  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}

// Shine effect for high score
class ShineEffect extends StatefulWidget {
  final Color color;
  final double borderRadius;

  const ShineEffect({
    Key? key,
    required this.color,
    required this.borderRadius,
  }) : super(key: key);

  @override
  State<ShineEffect> createState() => _ShineEffectState();
}

class _ShineEffectState extends State<ShineEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    // Repeat the animation
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: CustomPaint(
              painter: ShinePainter(
                position: _animation.value,
                color: widget.color,
              ),
              child: Container(),
            ),
          ),
        );
      },
    );
  }
}

// Shine effect painter
class ShinePainter extends CustomPainter {
  final double position;
  final Color color;
  
  ShinePainter({
    required this.position,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          color,
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    
    // Map position from [-1, 1] to the diagonal of the container
    final double diagonalLength = sqrt(size.width * size.width + size.height * size.height);
    final double mappedPosition = (position + 1) / 2 * (diagonalLength + 100) - 50;
    
    // Draw shine with rotation
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(pi / 4); // 45 degrees rotation
    canvas.translate(-size.width / 2, -size.height / 2);
    
    canvas.drawRect(
      Rect.fromLTWH(
        mappedPosition - 50,
        -50,
        100,
        size.height + 100,
      ),
      paint,
    );
    
    canvas.restore();
  }
  
  @override
  bool shouldRepaint(covariant ShinePainter oldDelegate) => true;
}

// Custom painter for decorative elements
class DecorativePainter extends CustomPainter {
  final Color color;
  final bool isFlipped;
  
  DecorativePainter({
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
      path.moveTo(0, size.height * 0.5);
      path.quadraticBezierTo(size.width * 0.25, size.height * 0.2, size.width * 0.35, size.height * 0.5);
      
      // Right swirl
      path.moveTo(size.width, size.height * 0.5);
      path.quadraticBezierTo(size.width * 0.75, size.height * 0.2, size.width * 0.65, size.height * 0.5);
    } else {
      // Bottom decorative element (flipped version)
      path.moveTo(size.width / 2, size.height);
      path.lineTo(size.width * 0.6, size.height * 0.6);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width * 0.4, size.height * 0.6);
      path.close();
      
      // Left swirl
      path.moveTo(0, size.height * 0.5);
      path.quadraticBezierTo(size.width * 0.25, size.height * 0.8, size.width * 0.35, size.height * 0.5);
      
      // Right swirl
      path.moveTo(size.width, size.height * 0.5);
      path.quadraticBezierTo(size.width * 0.75, size.height * 0.8, size.width * 0.65, size.height * 0.5);
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}