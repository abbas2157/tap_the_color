// screens/settings_screen.dart (Updated for Multiplayer)
import 'package:flutter/material.dart';
import 'package:tap_the_color/models/game_settings.dart';
import 'package:tap_the_color/utils/color_utils.dart';

class SettingsScreen extends StatefulWidget {
  final GameSettings settings;
  final Function(bool) updateTheme;

  const SettingsScreen({
    Key? key,
    required this.settings,
    required this.updateTheme,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late int gameDuration;
  late int colorCount;
  late bool isDarkMode;
  late AnimationController _colorController;
  int _colorIndex = 0;
  final List<Color> _colorPreviewList = [];

  @override
  void initState() {
    super.initState();
    gameDuration = widget.settings.gameDuration;
    colorCount = widget.settings.colorCount;
    isDarkMode = widget.settings.isDarkMode;
    
    // Setup color cycle animation for preview
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _colorController.addListener(() {
      if (_colorController.isCompleted) {
        setState(() {
          _colorIndex = (_colorIndex + 1) % colorCount;
          _updateColorPreview();
        });
        _colorController.reset();
        _colorController.forward();
      }
    });
    
    // Initialize color preview
    _updateColorPreview();
    
    // Start color cycling animation
    _colorController.forward();
  }
  
  void _updateColorPreview() {
    _colorPreviewList.clear();
    _colorPreviewList.addAll(ColorUtils.getColorValues(colorCount));
  }

  Future<void> _saveSettings() async {
    widget.settings.gameDuration = gameDuration;
    widget.settings.colorCount = colorCount;
    widget.settings.isDarkMode = isDarkMode;
    
    // Update app theme
    widget.updateTheme(isDarkMode);
    
    // Save settings
    await widget.settings.saveSettings();
  }
  
  @override
  void dispose() {
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF201429) : const Color(0xFF2D1B3D);
    final cardColor = isDarkMode ? const Color(0xFF2D1B3D) : const Color(0xFF3D294F);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              await _saveSettings();
              if (mounted) {
                Navigator.pop(context, true);
              }
            },
            child: const Text(
              'SAVE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: backgroundColor,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Theme Toggle
            _buildSettingCard(
              title: 'Theme',
              subtitle: 'Toggle dark/light mode',
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isDarkMode = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isDarkMode 
                            ? const Color(0xFF9C27B0)
                            : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(30),
                          ),
                          border: Border.all(
                            color: !isDarkMode 
                              ? const Color(0xFF9C27B0)
                              : Colors.white24,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.light_mode,
                              size: 18,
                              color: !isDarkMode ? Colors.white : Colors.white54,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Light',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: !isDarkMode ? Colors.white : Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isDarkMode = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isDarkMode 
                            ? const Color(0xFF9C27B0)
                            : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(30),
                          ),
                          border: Border.all(
                            color: isDarkMode 
                              ? const Color(0xFF9C27B0)
                              : Colors.white24,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.dark_mode,
                              size: 18,
                              color: isDarkMode ? Colors.white : Colors.white54,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Dark',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              icon: Icons.palette,
              cardColor: cardColor,
            ),
            
            const SizedBox(height: 16),
            
            // Game Duration Setting
            _buildSettingCard(
              title: 'Game Duration',
              subtitle: 'Time to complete each round',
              icon: Icons.timer,
              cardColor: cardColor,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Color(0xFF9C27B0),
                          size: 28,
                        ),
                        onPressed: () {
                          if (gameDuration > 10) {
                            setState(() {
                              gameDuration -= 5;
                            });
                          }
                        },
                      ),
                      Column(
                        children: [
                          Text(
                            '$gameDuration',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9C27B0),
                            ),
                          ),
                          const Text(
                            'seconds',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: Color(0xFF9C27B0),
                          size: 28,
                        ),
                        onPressed: () {
                          if (gameDuration < 60) {
                            setState(() {
                              gameDuration += 5;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF9C27B0),
                      inactiveTrackColor: const Color(0xFF9C27B0).withOpacity(0.3),
                      thumbColor: const Color(0xFF9C27B0),
                      overlayColor: const Color(0xFF9C27B0).withOpacity(0.2),
                      valueIndicatorColor: const Color(0xFF9C27B0),
                      valueIndicatorTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      showValueIndicator: ShowValueIndicator.always,
                    ),
                    child: Slider(
                      min: 10,
                      max: 60,
                      divisions: 10,
                      value: gameDuration.toDouble(),
                      label: '$gameDuration seconds',
                      onChanged: (value) {
                        setState(() {
                          gameDuration = value.round();
                        });
                      },
                    ),
                  ),
                  
                  // Duration markers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '10s',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      const Text(
                        '30s',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      const Text(
                        '60s',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Color Count Setting
            _buildSettingCard(
              title: 'Number of Colors',
              subtitle: 'Adjust game difficulty',
              icon: Icons.color_lens,
              cardColor: cardColor,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Color(0xFF9C27B0),
                          size: 28,
                        ),
                        onPressed: () {
                          if (colorCount > 4) {
                            setState(() {
                              colorCount--;
                              _updateColorPreview();
                            });
                          }
                        },
                      ),
                      Column(
                        children: [
                          Text(
                            '$colorCount',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9C27B0),
                            ),
                          ),
                          const Text(
                            'colors',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: Color(0xFF9C27B0),
                          size: 28,
                        ),
                        onPressed: () {
                          if (colorCount < ColorUtils.colors.length) {
                            setState(() {
                              colorCount++;
                              _updateColorPreview();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Color preview with animation
                  AnimatedBuilder(
                    animation: _colorController,
                    builder: (context, child) {
                      return Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_colorPreviewList.length, (index) {
                                final isHighlighted = index == _colorIndex;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: isHighlighted ? 40 : 32,
                                  height: isHighlighted ? 40 : 32,
                                  decoration: BoxDecoration(
                                    color: _colorPreviewList[index],
                                    shape: BoxShape.circle,
                                    boxShadow: isHighlighted ? [
                                      BoxShadow(
                                        color: _colorPreviewList[index].withOpacity(0.8),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ] : null,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  Text(
                    'More colors = More challenge',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // About the game
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF9C27B0).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white70,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'ABOUT THE GAME',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the color matching the word meaning, not the text color. React quickly to score points before the timer runs out.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9C27B0).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: const Color(0xFF9C27B0).withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.pink,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'WIN PERCENTAGE IS ZERO',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
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
    );
  }
  
  // Helper method to build consistent setting cards
  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required Widget child,
    required IconData icon,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF9C27B0),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Content
          child,
        ],
      ),
    );
  }
}