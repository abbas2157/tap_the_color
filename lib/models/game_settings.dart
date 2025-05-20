// models/game_settings.dart
import 'package:shared_preferences/shared_preferences.dart';

class GameSettings {
  int gameDuration;
  int colorCount;
  bool isDarkMode;

  GameSettings({
    this.gameDuration = 30,
    this.colorCount = 6,
    this.isDarkMode = false,
  });

  // Load settings from SharedPreferences
  static Future<GameSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return GameSettings(
      gameDuration: prefs.getInt('gameDuration') ?? 30,
      colorCount: prefs.getInt('colorCount') ?? 6,
      isDarkMode: prefs.getBool('isDarkMode') ?? false,
    );
  }

  // Save settings to SharedPreferences
  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gameDuration', gameDuration);
    await prefs.setInt('colorCount', colorCount);
    await prefs.setBool('isDarkMode', isDarkMode);
  }
}