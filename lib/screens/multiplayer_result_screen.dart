// screens/multiplayer_result_screen.dart
import 'dart:math';

import 'package:flutter/material.dart';
import '../models/player.dart';

class MultiplayerResultScreen extends StatefulWidget {
  final List<Player> players;
  final bool isDarkMode;

  const MultiplayerResultScreen({
    Key? key,
    required this.players,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<MultiplayerResultScreen> createState() => _MultiplayerResultScreenState();
}

class _MultiplayerResultScreenState extends State<MultiplayerResultScreen> with SingleTickerProviderStateMixin {
  late List<Player> _sortedPlayers;
  late Player _winner;
  bool _isTie = false;
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
    
    // Sort players by score (descending)
    _sortedPlayers = List.from(widget.players)
      ..sort((a, b) => b.score.compareTo(a.score));
      
    // Determine winner or if there's a tie
    _winner = _sortedPlayers.first;
    _isTie = _sortedPlayers.length > 1 && _sortedPlayers[0].score == _sortedPlayers[1].score;
    
    // Initialize confetti animation
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    // Create confetti particles
    if (!_isTie) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _createConfetti(40);
        _confettiController.repeat();
      });
    }
  }
  
  void _createConfetti(int count) {
    final size = MediaQuery.of(context).size;
    
    for (int i = 0; i < count; i++) {
      _particles.add(
        Particle(
          position: Offset(
            _random.nextDouble() * size.width,
            -50 - _random.nextDouble() * 100,
          ),
          velocity: Offset(
            (_random.nextDouble() * 2 - 1) * 3,
            2 + _random.nextDouble() * 4,
          ),
          color: _confettiColors[_random.nextInt(_confettiColors.length)],
          size: 5 + _random.nextDouble() * 10,
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

  // Helper method to get color for player based on index
  Color _getPlayerColor(int index) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
    ];
    return colors[index % colors.length];
  }

  // Helper method to get trophy icon based on position
  Widget _getTrophyIcon(int position) {
    if (position == 0 && !_isTie) {
      // Gold trophy
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.emoji_events,
          color: Colors.amber,
          size: 24,
        ),
      );
    } else if (position == 1 && !_isTie) {
      // Silver trophy
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade300.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.emoji_events,
          color: Colors.grey.shade300,
          size: 22,
        ),
      );
    } else if (position == 2 && !_isTie) {
      // Bronze trophy
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.brown.shade300.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.emoji_events,
          color: Colors.brown.shade300,
          size: 20,
        ),
      );
    } else {
      // No trophy
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person,
          color: Colors.purple,
          size: 20,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final backgroundColor = widget.isDarkMode ? const Color(0xFF201429) : const Color(0xFF2D1B3D);
    final cardColor = widget.isDarkMode ? const Color(0xFF2D1B3D) : const Color(0xFF3D294F);
    
    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: SafeArea(
          child: Stack(
            children: [
              // Confetti animation
              if (!_isTie)
                AnimatedBuilder(
                  animation: _confettiController,
                  builder: (context, child) {
                    // Update particle positions
                    for (var particle in _particles) {
                      particle.position += particle.velocity;
                      particle.rotation += 0.05;
                      
                      // Reset particles that go off screen
                      if (particle.position.dy > size.height) {
                        particle.position = Offset(
                          _random.nextDouble() * size.width,
                          -50,
                        );
                      }
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header with title
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          // Decorative top element
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
                          
                          Text(
                            _isTie ? 'IT\'S A TIE!' : 'GAME RESULTS',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          
                          // Decorative bottom element
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
                    ),
                    
                    // Winner section
                    if (!_isTie)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'WINNER',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.amber,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Winner icon with glow
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.amber.withOpacity(0.1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getPlayerColor(widget.players.indexOf(_winner)).withOpacity(0.2),
                                  ),
                                  child: Icon(
                                    Icons.emoji_events,
                                    color: Colors.amber,
                                    size: 36,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _winner.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Score: ${_winner.score}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Player rankings
                    Expanded(
                      child: Card(
                        color: cardColor,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.leaderboard,
                                      color: Colors.purple,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'FINAL RANKINGS',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Player list
                              Expanded(
                                child: ListView.separated(
                                  itemCount: _sortedPlayers.length,
                                  separatorBuilder: (context, index) => const Divider(
                                    color: Colors.white24,
                                    height: 32,
                                  ),
                                  itemBuilder: (context, index) {
                                    final player = _sortedPlayers[index];
                                    final originalIndex = widget.players.indexOf(player);
                                    final playerColor = _getPlayerColor(originalIndex);
                                    
                                    return Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withOpacity(0.1),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${index + 1}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: index == 0 
                                                  ? Colors.amber 
                                                  : index == 1 
                                                    ? Colors.grey.shade300 
                                                    : index == 2 
                                                      ? Colors.brown.shade300 
                                                      : Colors.white70,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        _getTrophyIcon(index),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              player.name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Score: ${player.score}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: playerColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Action buttons
                    Row(
                      children: [
                        // Play Again button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Go back to multiplayer setup screen
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: Colors.purple.withOpacity(0.4),
                            ),
                            icon: const Icon(
                              Icons.replay,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: const Text(
                              'PLAY AGAIN',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Home button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Go back to home screen
                              Navigator.popUntil(context, (route) => route.isFirst);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade800,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            icon: const Icon(
                              Icons.home,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: const Text(
                              'HOME',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: Colors.white,
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
        ),
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