// lib/presentation/pages/puzzle/puzzle_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/puzzle.dart';
import '../../../models/chess_puzzle.dart';
import '../../../services/puzzle_service.dart';
import '../../../widgets/puzzle_viewer.dart';
import 'puzzle_game_screen.dart';

class PuzzlePage extends ConsumerStatefulWidget {
  const PuzzlePage({Key? key}) : super(key: key);

  @override
  ConsumerState<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends ConsumerState<PuzzlePage> {
  Map<String, int> _categoryStats = {};
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoadingStats = true);
    try {
      final stats = await PuzzleService.getStatistics();
      setState(() {
        _categoryStats = {
          'Easy': stats['easy'] ?? 0,
          'Medium': stats['medium'] ?? 0,
          'Hard': stats['hard'] ?? 0,
          'Expert': stats['expert'] ?? 0,
        };
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() => _isLoadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Puzzle Challenge',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout
          final isWideScreen = constraints.maxWidth > 800;
          final crossAxisCount = isWideScreen ? 4 : 2;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isWideScreen ? 24 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Solve Puzzles'),
                const SizedBox(height: 16),

                // All Puzzles Card - Full width
                _buildPuzzleModeCard(
                  context,
                  title: 'All Puzzles',
                  subtitle: 'Mixed difficulty tactical puzzles',
                  icon: Icons.psychology,
                  color: Colors.purple,
                  count: _categoryStats.values.fold(0, (a, b) => a + b),
                  onTap: () => _navigateToPuzzles(context, null),
                  isFullWidth: true,
                ),
                const SizedBox(height: 12),

                // Difficulty Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: isWideScreen ? 1.2 : 1.0,
                  children: [
                    _buildPuzzleModeCard(
                      context,
                      title: 'Easy Puzzles',
                      subtitle: 'Beginner level',
                      icon: Icons.school,
                      color: Colors.green,
                      count: _categoryStats['Easy'] ?? 0,
                      onTap: () => _navigateToPuzzles(context, PuzzleDifficulty.easy),
                    ),
                    _buildPuzzleModeCard(
                      context,
                      title: 'Medium Puzzles',
                      subtitle: 'Intermediate level',
                      icon: Icons.trending_up,
                      color: Colors.orange,
                      count: _categoryStats['Medium'] ?? 0,
                      onTap: () => _navigateToPuzzles(context, PuzzleDifficulty.medium),
                    ),
                    _buildPuzzleModeCard(
                      context,
                      title: 'Hard Puzzles',
                      subtitle: 'Advanced level',
                      icon: Icons.whatshot,
                      color: Colors.red,
                      count: _categoryStats['Hard'] ?? 0,
                      onTap: () => _navigateToPuzzles(context, PuzzleDifficulty.hard),
                    ),
                    _buildPuzzleModeCard(
                      context,
                      title: 'Expert Puzzles',
                      subtitle: 'Master level',
                      icon: Icons.military_tech,
                      color: Colors.deepPurple,
                      count: _categoryStats['Expert'] ?? 0,
                      onTap: () => _navigateToPuzzles(context, PuzzleDifficulty.expert),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Statistics Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.bar_chart_rounded,
                            color: const Color(0xFFE91E63),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Your Progress',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      FutureBuilder<int>(
                        future: PuzzleService.getCompletedCount(),
                        builder: (context, snapshot) {
                          final solved = snapshot.data ?? 0;
                          return Column(
                            children: [
                              _buildStatRow('Puzzles Solved', '$solved', Icons.check_circle_outline),
                              const SizedBox(height: 12),
                              _buildStatRow('Success Rate', '${solved > 0 ? "75" : "0"}%', Icons.trending_up),
                              const SizedBox(height: 12),
                              _buildStatRow('Current Streak', '0 days', Icons.local_fire_department),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Tips Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pro Tip',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Look for forcing moves: checks, captures, and threats!',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF5C6BC0),
      ),
    );
  }

  Widget _buildPuzzleModeCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
        int count = 0,
        bool isFullWidth = false,
      }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color,
                color.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: isFullWidth ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  if (count > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFE91E63),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  void _navigateToPuzzles(BuildContext context, PuzzleDifficulty? difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PuzzleGameScreen(
          difficulty: difficulty,
        ),
      ),
    );
  }
}