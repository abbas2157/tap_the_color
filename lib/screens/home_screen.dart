// screens/home_screen.dart (Updated for Multiplayer Support)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_the_color/models/game_settings.dart';
import 'package:tap_the_color/screens/game_screen.dart';
import 'package:tap_the_color/screens/multiplayer_setup_screen.dart';
import 'package:tap_the_color/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) updateTheme;
  final bool isDarkMode;

  const HomeScreen({
    Key? key, 
    required this.updateTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int highScore = 0;
  late GameSettings settings;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // Start pulsing animation
    _animationController.repeat(reverse: true);
  }

  Future<void> _loadData() async {
    // Load high score
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('highScore') ?? 0;
    
    // Load settings
    settings = await GameSettings.loadSettings();
    // Ensure the dark mode setting matches the app-level setting
    settings.isDarkMode = widget.isDarkMode;
    
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final backgroundColor = widget.isDarkMode ? const Color(0xFF201429) : const Color(0xFF2D1B3D);
    final cardColor = widget.isDarkMode ? const Color(0xFF2D1B3D) : const Color(0xFF3D294F);
    
    return Scaffold(
      body: isLoading 
        ? Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          )
        : Container(
            color: backgroundColor,
            child: Stack(
              children: [
                // Background decoration
                Positioned(
                  top: -size.width * 0.4,
                  right: -size.width * 0.4,
                  child: Container(
                    width: size.width * 0.8,
                    height: size.width * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.purple.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -size.width * 0.3,
                  left: -size.width * 0.3,
                  child: Container(
                    width: size.width * 0.6,
                    height: size.width * 0.6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.purple.withOpacity(0.1),
                    ),
                  ),
                ),
                
                // Main content
                SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Settings button
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: IconButton(
                              icon: const Icon(
                                Icons.settings,
                                color: Colors.white70,
                                size: 28,
                              ),
                              onPressed: () async {
                                final result = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SettingsScreen(
                                      settings: settings,
                                      updateTheme: widget.updateTheme,
                                    ),
                                  ),
                                );
                                
                                if (result == true) {
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                        ),
                        
                        // Logo
                        Expanded(
                          child: Center(
                            child: Container(
                              width: size.width * 0.85,
                              height: size.width * 0.85,
                              margin: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Top decorative element
                                  Container(
                                    width: 60,
                                    height: 30,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: CustomPaint(
                                      painter: DecorativePainter(
                                        color: const Color(0xFF9C27B0),
                                      ),
                                    ),
                                  ),
                                  
                                  // Title
                                  const Text(
                                    "Tap the Color",
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  
                                  // Subtitle
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10.0),
                                    child: Text(
                                      "WIN PERCENTAGE IS ZERO",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                        letterSpacing: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  
                                  // Bottom decorative element
                                  Container(
                                    width: 60,
                                    height: 30,
                                    margin: const EdgeInsets.only(top: 16),
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
                          ),
                        ),
                        
                        // Game Mode Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              // Single Player Button
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _scaleAnimation.value,
                                    child: Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation, secondaryAnimation) => GameScreen(
                                                settings: settings,
                                                isDarkMode: widget.isDarkMode,
                                                onGameOver: (score) async {
                                                  if (score > highScore) {
                                                    highScore = score;
                                                    final prefs = await SharedPreferences.getInstance();
                                                    await prefs.setInt('highScore', highScore);
                                                    setState(() {});
                                                  }
                                                },
                                              ),
                                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                const begin = Offset(1.0, 0.0);
                                                const end = Offset.zero;
                                                const curve = Curves.easeInOut;
                                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                                var offsetAnimation = animation.drive(tween);
                                                return SlideTransition(position: offsetAnimation, child: child);
                                              },
                                              transitionDuration: const Duration(milliseconds: 400),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          'SINGLE PLAYER',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF9C27B0),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          elevation: 8,
                                          shadowColor: const Color(0xFF9C27B0).withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              
                              // Multiplayer Button
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 16),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MultiplayerSetupScreen(
                                          settings: settings,
                                          isDarkMode: widget.isDarkMode,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.people_alt,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'MULTIPLAYER',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 8,
                                    shadowColor: Colors.blue.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // High Score
                        Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'SINGLE PLAYER HIGH SCORE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.emoji_events,
                                    color: Color(0xFFFFD700), // Gold color
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$highScore',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFD700), // Gold color
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
              ],
            ),
          ),
    );
  }
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