// screens/multiplayer_setup_screen.dart
import 'package:flutter/material.dart';
import '../models/game_settings.dart';
import '../models/player.dart';
import '../screens/multiplayer_game_screen.dart';

class MultiplayerSetupScreen extends StatefulWidget {
  final GameSettings settings;
  final bool isDarkMode;

  const MultiplayerSetupScreen({
    Key? key,
    required this.settings,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<MultiplayerSetupScreen> createState() => _MultiplayerSetupScreenState();
}

class _MultiplayerSetupScreenState extends State<MultiplayerSetupScreen> {
  final List<TextEditingController> _nameControllers = [
    TextEditingController(text: "Player 1"),
    TextEditingController(text: "Player 2"),
  ];
  
  int _playerCount = 2;
  int _roundsToPlay = 3;
  
  @override
  void initState() {
    super.initState();
    
    // Add a third controller for potential 3rd player
    _nameControllers.add(TextEditingController(text: "Player 3"));
  }
  
  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isDarkMode ? const Color(0xFF201429) : const Color(0xFF2D1B3D);
    final cardColor = widget.isDarkMode ? const Color(0xFF2D1B3D) : const Color(0xFF3D294F);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Multiplayer Setup',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: Container(
        color: backgroundColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Players Card
                Card(
                  color: cardColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.people_alt,
                                color: Colors.purple,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'PLAYERS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Player selection
                        Row(
                          children: [
                            const Text(
                              'Number of Players:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            ToggleButtons(
                              borderRadius: BorderRadius.circular(8),
                              selectedBorderColor: Colors.purple,
                              selectedColor: Colors.white,
                              fillColor: Colors.purple,
                              color: Colors.white70,
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 36,
                              ),
                              isSelected: [
                                _playerCount == 2,
                                _playerCount == 3,
                              ],
                              onPressed: (index) {
                                setState(() {
                                  _playerCount = index == 0 ? 2 : 3;
                                });
                              },
                              children: const [
                                Text('2'),
                                Text('3'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Player name inputs
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _playerCount,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return TextFormField(
                              controller: _nameControllers[index],
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.purple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                hintText: 'Enter name',
                                hintStyle: const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                              ),
                              onChanged: (value) {
                                // Update player name as they type
                                if (value.isEmpty) {
                                  _nameControllers[index].text = "Player ${index + 1}";
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Game Settings Card
                Card(
                  color: cardColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.settings,
                                color: Colors.purple,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'GAME SETTINGS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Number of rounds
                        Row(
                          children: [
                            const Text(
                              'Rounds to Play:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if (_roundsToPlay > 1) {
                                        setState(() {
                                          _roundsToPlay--;
                                        });
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.remove,
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    iconSize: 20,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      '$_roundsToPlay',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _roundsToPlay++;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    iconSize: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Game duration info
                        Row(
                          children: [
                            const Text(
                              'Round Duration:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.timer,
                                    color: Colors.purple,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${widget.settings.gameDuration} seconds',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Colors info
                        Row(
                          children: [
                            const Text(
                              'Number of Colors:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.palette,
                                    color: Colors.purple,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${widget.settings.colorCount} colors',
                                    style: const TextStyle(
                                      fontSize: 14,
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
                  ),
                ),
                
                const Spacer(),
                
                // Start Game Button
                ElevatedButton(
                  onPressed: () {
                    // Create player list
                    List<Player> players = List.generate(
                      _playerCount,
                      (index) => Player(name: _nameControllers[index].text),
                    );
                    
                    // Navigate to the multiplayer game screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MultiplayerGameScreen(
                          settings: widget.settings,
                          players: players,
                          isDarkMode: widget.isDarkMode,
                          totalRounds: _roundsToPlay,
                        ),
                      ),
                    );
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
                  child: const Text(
                    'START MULTIPLAYER GAME',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}