// lib/screens/chess_menu_screen.dart
/*
import 'package:flutter/material.dart';
import 'chess_game_screen.dart';
import 'ai_game_screen.dart';
import 'puzzle_screen.dart';

class ChessMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.brown.shade800,
              Colors.brown.shade600,
              Colors.brown.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_esports,
                        size: 80,
                        color: Colors.white,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Chess Master',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Strategic Mind Games',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MenuButton(
                        title: 'Play vs Human',
                        subtitle: 'Two players on same device',
                        icon: Icons.people,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChessGameScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      _MenuButton(
                        title: 'Play vs AI',
                        subtitle: 'Challenge the computer',
                        icon: Icons.computer,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AIGameScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      _MenuButton(
                        title: 'Chess Puzzles',
                        subtitle: 'Improve your tactics',
                        icon: Icons.extension, // Using extension icon instead of puzzle
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PuzzleScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      _MenuButton(
                        title: 'Settings',
                        subtitle: 'Customize your experience',
                        icon: Icons.settings,
                        onPressed: () {
                          _showSettingsDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  '© 2024 Chess Master App',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.volume_up),
                title: Text('Sound Effects'),
                trailing: Switch(
                  value: true, // You can add actual state management here
                  onChanged: (value) {
                    // Handle sound toggle
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.brightness_6),
                title: Text('Dark Theme'),
                trailing: Switch(
                  value: false, // You can add actual state management here
                  onChanged: (value) {
                    // Handle theme toggle
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.vibration),
                title: Text('Vibration'),
                trailing: Switch(
                  value: true, // You can add actual state management here
                  onChanged: (value) {
                    // Handle vibration toggle
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onPressed;

  const _MenuButton({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.9),
          foregroundColor: Colors.brown.shade800,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.brown.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 30,
                color: Colors.brown.shade800,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.brown.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.brown.shade600,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}*/

// lib/screens/chess_menu_screen.dart
import 'package:flutter/material.dart';
import 'puzzle_screen.dart';
import '../models/chess_puzzle.dart';
import '../widgets/chess_board_widget.dart';
import 'ai_game_screen.dart';          // Add this line
import 'human_game_screen.dart';      // Add this line

class ChessMenuScreen extends StatelessWidget {
  const ChessMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Game'),
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

                const Text(
                  'Choose Your Game Mode',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),

                const SizedBox(height: 40),

                // Regular Chess Game Section
                _buildSectionTitle('Play Chess'),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildGameModeCard(
                        context,
                        title: 'vs AI Easy',
                        subtitle: 'Play against computer (Easy)',
                        icon: Icons.smart_toy,
                        color: Colors.green,
                        onTap: () => _navigateToGame(context, difficulty: 'Easy'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGameModeCard(
                        context,
                        title: 'vs AI Medium',
                        subtitle: 'Play against computer (Medium)',
                        icon: Icons.android,
                        color: Colors.orange,
                        onTap: () => _navigateToGame(context, difficulty: 'Medium'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildGameModeCard(
                        context,
                        title: 'vs AI Hard',
                        subtitle: 'Play against computer (Hard)',
                        icon: Icons.psychology,
                        color: Colors.red,
                        onTap: () => _navigateToGame(context, difficulty: 'Hard'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGameModeCard(
                        context,
                        title: 'vs Human',
                        subtitle: 'Play against another player',
                        icon: Icons.people,
                        color: Colors.blue,
                        onTap: () => _navigateToGame(context, vsAI: false),
                      ),
                    ),
                  ],
                ),

                /*// const SizedBox(height: 40),
                //
                // // Chess Puzzles Section
                // _buildSectionTitle('Solve Puzzles'),
                //
                // const SizedBox(height: 16),
                //
                // _buildPuzzleModeCard(
                //   context,
                //   title: 'All Puzzles',
                //   subtitle: 'Mixed difficulty tactical puzzles',
                //   icon: Icons.psychology,
                //   color: Colors.purple,
                //   onTap: () => _navigateToPuzzles(context),
                // ),
                //
                // const SizedBox(height: 12),
                //
                // Row(
                //   children: [
                //     Expanded(
                //       child: _buildPuzzleModeCard(
                //         context,
                //         title: 'Easy Puzzles',
                //         subtitle: 'Beginner level',
                //         icon: Icons.school,
                //         color: Colors.green,
                //         onTap: () => _navigateToPuzzles(context, PuzzleDifficulty.easy),
                //       ),
                //     ),
                //     const SizedBox(width: 12),
                //     Expanded(
                //       child: _buildPuzzleModeCard(
                //         context,
                //         title: 'Medium Puzzles',
                //         subtitle: 'Intermediate level',
                //         icon: Icons.trending_up,
                //         color: Colors.orange,
                //         onTap: () => _navigateToPuzzles(context, PuzzleDifficulty.medium),
                //       ),
                //     ),
                //   ],
                // ),
                //
                // const SizedBox(height: 12),
                //
                // Row(
                //   children: [
                //     Expanded(
                //       child: _buildPuzzleModeCard(
                //         context,
                //         title: 'Hard Puzzles',
                //         subtitle: 'Advanced level',
                //         icon: Icons.whatshot,
                //         color: Colors.red,
                //         onTap: () => _navigateToPuzzles(context, PuzzleDifficulty.hard),
                //       ),
                //     ),
                //     const SizedBox(width: 12),
                //     Expanded(
                //       child: _buildPuzzleModeCard(
                //         context,
                //         title: 'Expert Puzzles',
                //         subtitle: 'Master level',
                //         icon: Icons.military_tech,
                //         color: Colors.deepPurple,
                //         onTap: () => _navigateToPuzzles(context, PuzzleDifficulty.expert),
                //       ),
                //     ),
                //   ],
                // ),

*/                const SizedBox(height: 40),

                // Quick Stats or Info Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 32,
                          color: Colors.indigo,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Improve Your Chess Skills',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }

  Widget _buildGameModeCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required MaterialColor color,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.shade400, color.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPuzzleModeCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required MaterialColor color,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [color.shade300, color.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: Colors.white,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
/*
  void _navigateToGame(BuildContext context, {bool vsAI = true, String? difficulty}) {
    // For now, show a message since the regular game screen needs to be implemented
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(vsAI ? 'Starting game vs AI ($difficulty)' : 'Starting game vs Human'),
        backgroundColor: Colors.indigo,
      ),
    );

    // TODO: Navigate to proper game screen when implemented
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ChessGameScreen(
    //       isVsAI: vsAI,
    //       difficulty: difficulty,
    //     ),
    //   ),
    // );
  }
*/
  // Replace the existing _navigateToGame method in chess_menu_screen.dart with this:

  void _navigateToGame(BuildContext context, {bool vsAI = true, String? difficulty}) {
    if (vsAI) {
      // Navigate to AI game screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AIGameScreen(),
        ),
      );
    } else {
      // Navigate to Human vs Human game screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HumanGameScreen(),
        ),
      );
    }
  }
  void _navigateToPuzzles(BuildContext context, [PuzzleDifficulty? difficulty]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PuzzleScreen(
          selectedDifficulty: difficulty,
        ),
      ),
    );
  }
}