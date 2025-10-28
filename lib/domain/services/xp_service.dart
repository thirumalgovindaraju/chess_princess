// lib/domain/services/xp_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class XPService {
  static const String _xpKey = 'user_xp';

  // Get current XP
  static Future<int> getXP() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_xpKey) ?? 0;
    } catch (e) {
      print('Error getting XP: $e');
      return 0;
    }
  }

  // Add XP
  static Future<void> addXP(int amount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentXP = await getXP();
      final newXP = currentXP + amount;
      await prefs.setInt(_xpKey, newXP);
    } catch (e) {
      print('Error adding XP: $e');
    }
  }

  // Set XP (for testing or resetting)
  static Future<void> setXP(int amount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_xpKey, amount);
    } catch (e) {
      print('Error setting XP: $e');
    }
  }

  // Calculate level from XP
  static int getLevelFromXP(int xp) {
    // Example XP curve: each level requires more XP
    // Level 1: 0-99 XP
    // Level 2: 100-299 XP
    // Level 3: 300-599 XP
    // etc.
    return (xp / 100).floor() + 1;
  }

  // Get progress to next level (0.0 to 1.0)
  static double getProgressToNextLevel(int xp) {
    int currentLevelXP = getXPForLevel(getLevelFromXP(xp));
    int nextLevelXP = getXPForLevel(getLevelFromXP(xp) + 1);

    if (nextLevelXP == currentLevelXP) return 1.0;

    return ((xp - currentLevelXP) / (nextLevelXP - currentLevelXP)).clamp(0.0, 1.0);
  }

  // Get XP required for a specific level
  static int getXPForLevel(int level) {
    // Define XP thresholds per level
    // This creates an exponential curve
    // Level 1 = 0 XP
    // Level 2 = 100 XP  
    // Level 3 = 300 XP
    // Level 4 = 600 XP
    // Level 5 = 1000 XP
    // etc.
    if (level <= 1) return 0;
    return (level - 1) * (level * 50);
  }

  // Get XP needed for next level
  static Future<int> getXPNeededForNextLevel() async {
    final currentXP = await getXP();
    final currentLevel = getLevelFromXP(currentXP);
    final nextLevelXP = getXPForLevel(currentLevel + 1);
    return nextLevelXP - currentXP;
  }

  // Get current level
  static Future<int> getCurrentLevel() async {
    final xp = await getXP();
    return getLevelFromXP(xp);
  }

  // Reset XP (for testing)
  static Future<void> resetXP() async {
    await setXP(0);
  }

  // Get level title
  static String getLevelTitle(int level) {
    if (level < 5) return 'Beginner';
    if (level < 10) return 'Novice';
    if (level < 15) return 'Intermediate';
    if (level < 20) return 'Advanced';
    if (level < 30) return 'Expert';
    if (level < 40) return 'Master';
    return 'Grandmaster';
  }

  // Get rank based on level
  static String getRank(int level) {
    if (level < 5) return 'Bronze';
    if (level < 10) return 'Silver';
    if (level < 20) return 'Gold';
    if (level < 30) return 'Platinum';
    if (level < 40) return 'Diamond';
    return 'Legend';
  }
}