import 'package:flutter/material.dart';
import '../models/chess_puzzle.dart';
import 'puzzle_screen.dart';

class PuzzleSelectionScreen extends StatelessWidget {
  const PuzzleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solve Puzzles'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.indigo.shade100],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // All Puzzles - Full width
                _buildPuzzleCard(
                  context,
                  title: 'All Puzzles',
                  subtitle: 'Mixed difficulty tactical puzzles',
                  icon: Icons.apps,
                  color: Colors.purple,
                  onTap: () => _navigateToPuzzles(context, null, null),
                ),

                const SizedBox(height: 20),

                // Difficulty grid
                Row(
                  children: [
                    Expanded(
                      child: _buildPuzzleCard(
                        context,
                        title: 'Easy Puzzles',
                        subtitle: 'Beginner level',
                        icon: Icons.school,
                        color: Colors.green,
                        isCompact: true,
                        onTap: () => _navigateToPuzzles(
                          context,
                          PuzzleDifficulty.easy,
                          null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPuzzleCard(
                        context,
                        title: 'Medium Puzzles',
                        subtitle: 'Intermediate level',
                        icon: Icons.trending_up,
                        color: Colors.orange,
                        isCompact: true,
                        onTap: () => _navigateToPuzzles(
                          context,
                          PuzzleDifficulty.medium,
                          null,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildPuzzleCard(
                        context,
                        title: 'Hard Puzzles',
                        subtitle: 'Advanced level',
                        icon: Icons.whatshot,
                        color: Colors.red,
                        isCompact: true,
                        onTap: () => _navigateToPuzzles(
                          context,
                          PuzzleDifficulty.hard,
                          null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPuzzleCard(
                        context,
                        title: 'Expert Puzzles',
                        subtitle: 'Master level',
                        icon: Icons.emoji_events,
                        color: Colors.deepPurple,
                        isCompact: true,
                        onTap: () => _navigateToPuzzles(
                          context,
                          PuzzleDifficulty.expert,
                          null,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Info card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 40,
                        color: Colors.indigo.shade700,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Improve Your Chess Skills',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Play games to practice your skills, or solve puzzles to learn tactical patterns.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPuzzleCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
        bool isCompact = false,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isCompact ? 16 : 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isCompact ? 36 : 48,
                color: Colors.white,
              ),
              SizedBox(height: isCompact ? 8 : 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isCompact ? 16 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isCompact ? 4 : 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isCompact ? 12 : 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPuzzles(
      BuildContext context,
      PuzzleDifficulty? difficulty,
      int? tier,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PuzzleScreen(
          selectedDifficulty: difficulty,
          startTier: tier,
        ),
      ),
    );
  }
}