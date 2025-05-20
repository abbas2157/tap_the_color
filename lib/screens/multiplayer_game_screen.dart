// Updated multiplayer_game_screen.dart with smaller color boxes
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tap_the_color/models/game_settings.dart';
import 'package:tap_the_color/models/player.dart';
import 'package:tap_the_color/screens/multiplayer_result_screen.dart';
import 'package:tap_the_color/utils/color_utils.dart';

class MultiplayerGameScreen extends StatefulWidget {
  final GameSettings settings;
  final List<Player> players;
  final bool isDarkMode;
  final int totalRounds;

  const MultiplayerGameScreen({
    Key? key,
    required this.settings,
    required this.players,
    required this.isDarkMode,
    required this.totalRounds,
  }) : super(key: key);

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> with TickerProviderStateMixin {
  late Timer _timer;
  late int _timeLeft;
  int _currentRound = 1;
  int _currentPlayerIndex = 0;
  
  late String _colorToTap;
  late Color _textColor;
  late List<Color> _colorOptions;
  late List<String> _colorNames;
  final Random _random = Random();
  
  // Animation controllers
  late AnimationController _clockController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Game state
  bool _isCorrect = false;
  bool _isIncorrect = false;
  bool _isRoundOver = false;
  bool _isGameOver = false;
  
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
    
    _startRound();
  }

  void _startRound() {
    _timeLeft = widget.settings.gameDuration;
    _isCorrect = false;
    _isIncorrect = false;
    _isRoundOver = false;
    
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
          _endRound();
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
    if (_isRoundOver) return;
    
    if (tapped == _colorToTap) {
      setState(() {
        widget.players[_currentPlayerIndex].score++;
        _isCorrect = true;
        _isIncorrect = false;
        // Animate the score counter
        _pulseController.reset();
        _pulseController.forward();
      });
      
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

  void _endRound() {
    _timer.cancel();
    
    setState(() {
      _isRoundOver = true;
    });
    
    if (_currentRound < widget.totalRounds && _currentPlayerIndex < widget.players.length - 1) {
      // Next player's turn for this round
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _currentPlayerIndex++;
            _startRound();
          });
        }
      });
    } else if (_currentRound < widget.totalRounds) {
      // Next round, first player's turn
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _currentRound++;
            _currentPlayerIndex = 0;
            _startRound();
          });
        }
      });
    } else {
      // Game over
      setState(() {
        _isGameOver = true;
      });
      
      // Show results screen
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MultiplayerResultScreen(
              players: widget.players,
              isDarkMode: widget.isDarkMode,
            ),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _clockController.dispose();
    _pulseController.dispose();
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

  // Build round transition screen - compact version
  Widget _buildRoundTransition() {
    final nextPlayer = _currentPlayerIndex < widget.players.length - 1 
        ? widget.players[_currentPlayerIndex + 1] 
        : widget.players[0];
    
    final isNextRound = _currentPlayerIndex == widget.players.length - 1;
    final nextRound = _currentRound + 1;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isGameOver 
                ? 'GAME OVER!'
                : isNextRound
                    ? 'ROUND $_currentRound COMPLETE'
                    : '${widget.players[_currentPlayerIndex].name}\'s TURN COMPLETE',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          // Current scores - more compact
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT SCORES:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                ...widget.players.map((player) {
                  final index = widget.players.indexOf(player);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: _getPlayerColor(index),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            player.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${player.score}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getPlayerColor(index),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          if (!_isGameOver)
            Column(
              children: [
                Text(
                  isNextRound
                      ? 'GET READY FOR ROUND $nextRound'
                      : 'NEXT PLAYER:',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                if (!isNextRound) const SizedBox(height: 6),
                if (!isNextRound)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: _getPlayerColor(_currentPlayerIndex + 1),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        nextPlayer.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getPlayerColor(_currentPlayerIndex + 1),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final backgroundColor = widget.isDarkMode ? const Color(0xFF201429) : const Color(0xFF2D1B3D);
    final cardColor = widget.isDarkMode ? const Color(0xFF2D1B3D) : const Color(0xFF3D294F);
    
    final currentPlayer = widget.players[_currentPlayerIndex];
    
    // Set grid dimensions based on device size and color count
    int crossAxisCount;
    if (widget.settings.colorCount <= 4) {
      crossAxisCount = 2;
    } else if (widget.settings.colorCount <= 9) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }
    
    // Calculate optimal spacing based on screen size
    double mainAxisSpacing = size.height < 600 ? 8.0 : 12.0;
    double crossAxisSpacing = size.width < 400 ? 8.0 : 12.0;
    
    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 8.0), // Reduced padding
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate optimal padding and sizes based on available space
                double headerHeight = constraints.maxHeight * 0.12;
                double timerHeight = constraints.maxHeight * 0.08;
                double colorTextHeight = constraints.maxHeight * 0.18;
                double gridHeight = constraints.maxHeight * 0.55;
                double footerHeight = constraints.maxHeight * 0.07;
                
                return Column(
                  children: [
                    // Player info and round indicator - Compact
                    Container(
                      height: headerHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Current player - Smaller with truncation
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: _getPlayerColor(_currentPlayerIndex),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(maxWidth: size.width * 0.3),
                                      child: Text(
                                        currentPlayer.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Score: ${currentPlayer.score}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getPlayerColor(_currentPlayerIndex),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Round indicator - Smaller
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'ROUND',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  '$_currentRound / ${widget.totalRounds}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Timer - Compact
                    Container(
                      height: timerHeight,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _clockController,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Animated clock icon - Smaller
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Clock face
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: _clockColor,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      
                                      // Second hand
                                      Transform.rotate(
                                        angle: 2 * pi * _clockController.value,
                                        child: Container(
                                          height: 10,
                                          width: 1.5,
                                          decoration: BoxDecoration(
                                            color: _clockColor,
                                            borderRadius: BorderRadius.circular(1),
                                          ),
                                          margin: const EdgeInsets.only(bottom: 10),
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
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: _timeLeft <= 5 
                                        ? Colors.red 
                                        : Colors.white,
                                    ),
                                  ),
                                  const Text(
                                    ' seconds',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        ),
                      ),
                    ),
                    
                    // Round transition or Color text
                    Container(
                      height: colorTextHeight,
                      child: Center(
                        child: _isRoundOver && !_isGameOver
                          ? _buildRoundTransition()
                          : !_isRoundOver
                            ? AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _isIncorrect 
                                    ? Colors.red.withOpacity(0.3) 
                                    : _isCorrect 
                                      ? Colors.green.withOpacity(0.3) 
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
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
                                        // Smaller font size for better fit
                                        fontSize: size.height < 700 ? 30 : 36,
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
                              )
                            : Container(),
                      ),
                    ),
                    
                    // Color buttons grid - SMALLER BOXES with more compact layout
                    Visibility(
                      visible: !_isRoundOver,
                      maintainSize: false,
                      maintainState: true,
                      maintainAnimation: true,
                      child: Container(
                        height: gridHeight,
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
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _colorOptions[index].withOpacity(0.4),
                                      blurRadius: 4, // Smaller blur
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
                    Visibility(
                      visible: !_isRoundOver,
                      maintainSize: false,
                      maintainState: true,
                      maintainAnimation: true,
                      child: Container(
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
                                    'End Game?',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: const Text(
                                    'Current game progress will be lost.',
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
                                        Navigator.pop(context); // Return to previous screen
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
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