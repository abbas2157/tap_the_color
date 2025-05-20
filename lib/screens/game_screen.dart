// Updated game_screen.dart with smaller color boxes
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tap_the_color/models/game_settings.dart';
import 'package:tap_the_color/screens/game_over_screen.dart';
import 'package:tap_the_color/utils/color_utils.dart';

class GameScreen extends StatefulWidget {
  final GameSettings settings;
  final Function(int) onGameOver;
  final bool isDarkMode;

  const GameScreen({
    Key? key,
    required this.settings,
    required this.onGameOver,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late Timer _timer;
  late int _timeLeft;
  int _score = 0;
  late String _colorToTap;
  late Color _textColor;
  late List<Color> _colorOptions;
  late List<String> _colorNames;
  final Random _random = Random();
  
  // Animation controllers
  late AnimationController _clockController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Clock animation variables
  Color _clockColor = Colors.purple;
  final List<Color> _clockColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
  ];
  int _colorIndex = 0;
  bool _isCorrect = false;
  bool _isIncorrect = false;

  @override
  void initState() {
    super.initState();
    
    // Init animations
    _clockController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _initGame();
  }

  void _initGame() {
    _timeLeft = widget.settings.gameDuration;
    _score = 0;
    _isCorrect = false;
    _isIncorrect = false;
    
    // Get color names and limit to selected count
    _colorNames = ColorUtils.getColorNames(widget.settings.colorCount);
    
    // Get color values
    _colorOptions = ColorUtils.getColorValues(widget.settings.colorCount);
    
    // Set initial color to tap
    _setNewColorToTap();
    
    // Start the timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
          
          // Change clock color each second
          _colorIndex = (_colorIndex + 1) % _clockColors.length;
          _clockColor = _clockColors[_colorIndex];
          
          // Restart clock animation
          _clockController.reset();
          _clockController.forward();
        } else {
          _endGame();
        }
      });
    });
    
    // Start initial clock animation
    _clockController.forward();
  }

  void _setNewColorToTap() {
    // Select a random color name to tap
    _colorToTap = _colorNames[_random.nextInt(_colorNames.length)];
    
    // Select a random color for the text that is different from the meaning
    List<Color> availableTextColors = List.from(_colorOptions);
    availableTextColors.remove(ColorUtils.getColorByName(_colorToTap));
    _textColor = availableTextColors[_random.nextInt(availableTextColors.length)];
  }

  void _checkAnswer(String tapped) {
    if (tapped == _colorToTap) {
      setState(() {
        _score++;
        _isCorrect = true;
        _isIncorrect = false;
        // Animate the score counter
        _pulseController.reset();
        _pulseController.forward();
      });
      
      // Optional: Play correct sound
      // final player = AudioPlayer();
      // player.play(AssetSource('sounds/correct.mp3'));
      
      // Small delay before showing next color
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {
            _isCorrect = false;
            _setNewColorToTap();
          });
        }
      });
    } else {
      setState(() {
        _isIncorrect = true;
        _isCorrect = false;
      });
      
      // Optional: Play wrong sound
      // final player = AudioPlayer();
      // player.play(AssetSource('sounds/wrong.mp3'));
      
      // Small delay before resetting visual feedback
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _isIncorrect = false;
          });
        }
      });
    }
  }

  void _endGame() {
    _timer.cancel();
    widget.onGameOver(_score);
    
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GameOverScreen(
        score: _score,
        isDarkMode: widget.isDarkMode,
        onPlayAgain: () {
          Navigator.pop(context); // Close the modal
          _initGame(); // Restart the game
        },
        onGoHome: () {
          Navigator.pop(context); // Close the modal
          Navigator.pop(context); // Go back to home
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _clockController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final backgroundColor = widget.isDarkMode ? const Color(0xFF201429) : const Color(0xFF2D1B3D);
    final cardColor = widget.isDarkMode ? const Color(0xFF2D1B3D) : const Color(0xFF3D294F);
    
    // Set grid dimensions based on device size and color count
    int crossAxisCount;
    if (widget.settings.colorCount <= 4) {
      crossAxisCount = 2;
    } else if (widget.settings.colorCount <= 9) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }
    
    // Calculate optimal spacing and proportions
    double mainAxisSpacing = size.height < 600 ? 8.0 : 12.0;
    double crossAxisSpacing = size.width < 400 ? 8.0 : 12.0;
    
    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate optimal padding and sizes based on available space
                double headerHeight = constraints.maxHeight * 0.1;
                double colorTextHeight = constraints.maxHeight * 0.2;
                double gridHeight = constraints.maxHeight * 0.6;
                double footerHeight = constraints.maxHeight * 0.1;
                
                return Column(
                  children: [
                    // Timer and Score row - Compact
                    Container(
                      height: headerHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Timer with clock animation
                          AnimatedBuilder(
                            animation: _clockController,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Animated clock icon
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Clock face
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.15),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: _clockColor,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        
                                        // Second hand
                                        Transform.rotate(
                                          angle: 2 * pi * _clockController.value,
                                          child: Container(
                                            height: 12,
                                            width: 2,
                                            decoration: BoxDecoration(
                                              color: _clockColor,
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                            margin: const EdgeInsets.only(bottom: 12),
                                          ),
                                        ),
                                        
                                        // Center dot
                                        Container(
                                          width: 3,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color: _clockColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(width: 8),
                                    
                                    // Timer text
                                    Text(
                                      '$_timeLeft',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: _timeLeft <= 5 
                                          ? Colors.red 
                                          : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          ),
                          
                          // Score with pulse animation
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _isCorrect ? _pulseAnimation.value : 1.0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'SCORE',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white70,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      Text(
                                        '$_score',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: _isCorrect 
                                            ? Colors.greenAccent 
                                            : Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          ),
                        ],
                      ),
                    ),
                    
                    // Color text to tap - Compact
                    Container(
                      height: colorTextHeight,
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isIncorrect 
                              ? Colors.red.withOpacity(0.3) 
                              : _isCorrect 
                                ? Colors.green.withOpacity(0.3) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Tap the color:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _colorToTap,
                                style: TextStyle(
                                  // Smaller font size for smaller screens
                                  fontSize: size.height < 700 ? 32 : 38,
                                  fontWeight: FontWeight.bold,
                                  color: _textColor,
                                  letterSpacing: 1.0,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Color buttons grid - SMALLER BOXES with more compact layout
                    Container(
                      height: gridHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: mainAxisSpacing,
                            crossAxisSpacing: crossAxisSpacing,
                          ),
                          itemCount: _colorOptions.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => _checkAnswer(_colorNames[index]),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: _colorOptions[index],
                                  // Smaller radius for more compact appearance
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _colorOptions[index].withOpacity(0.4),
                                      blurRadius: 6, // Smaller blur
                                      offset: const Offset(0, 2), // Smaller offset
                                    ),
                                  ],
                                  border: Border.all(
                                    color: _colorToTap == _colorNames[index] && _isCorrect
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 2, // Thinner border
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    // Exit button - Compact
                    Container(
                      height: footerHeight,
                      child: Align(
                        alignment: Alignment.center,
                        child: TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: cardColor,
                                title: const Text(
                                  'Exit Game?',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: const Text(
                                  'Your progress will be lost.',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      'CANCEL',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog
                                      Navigator.pop(context); // Return to home
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF9C27B0),
                                    ),
                                    child: const Text(
                                      'EXIT',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            minimumSize: const Size(10, 10),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          icon: const Icon(
                            Icons.exit_to_app,
                            color: Colors.white70,
                            size: 16, // Smaller icon
                          ),
                          label: const Text(
                            'Exit',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14, // Smaller text
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}