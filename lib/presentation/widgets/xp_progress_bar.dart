// lib/presentation/widgets/xp_progress_bar.dart
import 'package:flutter/material.dart';
import '../../domain/services/xp_service.dart';

class XPService {
  static Future<int> getXP() async {
    // Example: Load XP from local storage or API
    return 350; // placeholder value
  }

  static int getLevelFromXP(int xp) {
    // Example XP curve
    return (xp / 100).floor() + 1;
  }

  static double getProgressToNextLevel(int xp) {
    int currentLevelXP = getXPForLevel(getLevelFromXP(xp));
    int nextLevelXP = getXPForLevel(getLevelFromXP(xp) + 1);
    return (xp - currentLevelXP) / (nextLevelXP - currentLevelXP);
  }

  static int getXPForLevel(int level) {
    // Define XP thresholds per level
    return (level - 1) * (level * 50); // simple curve
  }
}

class XPProgressBar extends StatefulWidget {
  const XPProgressBar({Key? key}) : super(key: key);

  @override
  State<XPProgressBar> createState() => _XPProgressBarState();
}

class _XPProgressBarState extends State<XPProgressBar>
    with SingleTickerProviderStateMixin {
  int _xp = 0;
  int _level = 1;
  double _progress = 0.0;
  int _xpForNextLevel = 100;
  int _currentLevelXP = 0;

  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _loadXP();
  }

  void _setupAnimation() {
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );
  }

  Future<void> _loadXP() async {
    final xp = await XPService.getXP();
    if (mounted) {
      setState(() {
        _xp = xp;
        _level = XPService.getLevelFromXP(xp);
        _progress = XPService.getProgressToNextLevel(xp);
        _xpForNextLevel = XPService.getXPForLevel(_level + 1);
        _currentLevelXP = XPService.getXPForLevel(_level);
      });
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final xpInLevel = _xp - _currentLevelXP;
    final xpNeededForLevel = _xpForNextLevel - _currentLevelXP;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade50,
            Colors.purple.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.deepPurple.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.shade400,
                          Colors.orange.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.stars,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level $_level',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.deepPurple.shade900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        _getLevelTitle(_level),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.deepPurple.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.deepPurple.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bolt,
                      color: Colors.amber.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_xp XP',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar - FIXED VERSION
          LayoutBuilder(
            builder: (context, constraints) {
              // Use LayoutBuilder to get actual available width
              final availableWidth = constraints.maxWidth;
              final progressWidth = (availableWidth * _progress).clamp(0.0, availableWidth);

              return Stack(
                children: [
                  // Background
                  Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                  ),

                  // Progress Fill with Shimmer
                  AnimatedBuilder(
                    animation: _shimmerAnimation,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            // Gradient Progress
                            Container(
                              height: 32,
                              width: progressWidth,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepPurple.shade400,
                                    Colors.purple.shade500,
                                    Colors.deepPurple.shade600,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),

                            // Shimmer Effect
                            if (_progress > 0.1)
                              Positioned(
                                left: (_shimmerAnimation.value * 100).clamp(-50.0, progressWidth),
                                child: Container(
                                  height: 32,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withValues(alpha: 0.0),
                                        Colors.white.withValues(alpha: 0.5),
                                        Colors.white.withValues(alpha: 0.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Progress Text
                  Container(
                    height: 32,
                    alignment: Alignment.center,
                    child: Text(
                      '$xpInLevel / $xpNeededForLevel XP',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _progress > 0.5 ? Colors.white : Colors.grey.shade700,
                        shadows: _progress > 0.5
                            ? [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 2,
                          ),
                        ]
                            : null,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          // Progress Percentage and Next Level Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 16,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(_progress * 100).toStringAsFixed(1)}% Complete',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '${xpNeededForLevel - xpInLevel} XP to Level ${_level + 1}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Milestones
          Row(
            children: [
              _buildMilestone(
                icon: Icons.emoji_events,
                label: 'Achievements',
                value: _getAchievementCount(_level).toString(),
                color: Colors.amber.shade600,
              ),
              const SizedBox(width: 12),
              _buildMilestone(
                icon: Icons.local_fire_department,
                label: 'Streak',
                value: '${_level * 2}d',
                color: Colors.orange.shade600,
              ),
              const SizedBox(width: 12),
              _buildMilestone(
                icon: Icons.workspace_premium,
                label: 'Rank',
                value: _getRank(_level),
                color: Colors.purple.shade600,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestone({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLevelTitle(int level) {
    if (level < 5) return 'Beginner';
    if (level < 10) return 'Novice';
    if (level < 15) return 'Intermediate';
    if (level < 20) return 'Advanced';
    if (level < 30) return 'Expert';
    if (level < 40) return 'Master';
    return 'Grandmaster';
  }

  String _getRank(int level) {
    if (level < 5) return 'Bronze';
    if (level < 10) return 'Silver';
    if (level < 20) return 'Gold';
    if (level < 30) return 'Platinum';
    if (level < 40) return 'Diamond';
    return 'Legend';
  }

  int _getAchievementCount(int level) {
    return (level / 5).floor() * 3 + 5;
  }
}