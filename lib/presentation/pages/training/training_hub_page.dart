// lib/presentation/pages/training/training_hub_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ADD THIS
import 'package:chess_princess/domain/entities/drill.dart';
import '../../widgets/xp_progress_bar.dart';
import '../../../core/utils/page_transitions.dart';
import 'tactics_trainer_page.dart';
import 'vision_trainer_page.dart';
import 'endgame_drills_page.dart';
import 'opening_drills_page.dart';
import 'blindfold_game_page.dart';

// CHANGE: Extend ConsumerWidget instead of StatelessWidget
class TrainingHubPage extends ConsumerWidget {
  const TrainingHubPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) { // ADD WidgetRef parameter
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Hub'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.fitness_center, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Text(
                        'Choose Your Training',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a training tool to improve your chess skills',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const XPProgressBar(), // XP progress bar
            const SizedBox(height: 24),

            // Training Tools Grid
            const Text(
              'Training Tools',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildTrainingCard(
              context,
              title: 'Tactics Trainer',
              description: 'Solve puzzles to sharpen your tactical vision',
              icon: Icons.flash_on,
              color: Colors.orange,
              difficulty: 'All Levels',
              estimatedTime: '15-30 min',
              onTap: () {
                Navigator.push(
                  context,
                  SlidePageRoute(page: const TacticsTrainerPage()),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildTrainingCard(
              context,
              title: 'Vision Trainer',
              description: 'Train your board visualization and memory',
              icon: Icons.visibility,
              color: Colors.purple,
              difficulty: 'Intermediate',
              estimatedTime: '10-20 min',
              onTap: () {
                Navigator.push(
                  context,
                  SlidePageRoute(page: const VisionTrainerPage()),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildTrainingCard(
              context,
              title: 'Endgame Drills',
              description: 'Master essential endgame techniques and patterns',
              icon: Icons.castle,
              color: Colors.green,
              difficulty: 'Beginner - Advanced',
              estimatedTime: '20-40 min',
              onTap: () {
                Navigator.push(
                  context,
                  SlidePageRoute(page: const EndgameDrillsPage()),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildTrainingCard(
              context,
              title: 'Blindfold Game',
              description: 'Play chess without seeing the board to train visualization',
              icon: Icons.visibility_off,
              color: Colors.red,
              difficulty: 'Advanced',
              estimatedTime: '20-45 min',
              onTap: () {
                Navigator.push(
                  context,
                  SlidePageRoute(page: const BlindfoldGamePage()),
                );
              },
            ),
            _buildTrainingCard(
              context,
              title: 'Opening Drills',
              description: 'Learn and practice popular chess openings',
              icon: Icons.play_circle,
              color: Colors.blue,
              difficulty: 'All Levels',
              estimatedTime: '15-30 min',
              onTap: () {
                Navigator.push(
                  context,
                  SlidePageRoute(page: const OpeningDrillsPage()),
                );
              },
            ),
            const SizedBox(height: 32),

            // Quick Stats Section
            const Text(
              'Your Training Stats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.psychology,
                    label: 'Puzzles Solved',
                    value: '156',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.fitness_center,
                    label: 'Drills Done',
                    value: '24',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.visibility,
                    label: 'Vision Score',
                    value: '85%',
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.trending_up,
                    label: 'Avg Rating',
                    value: '1650',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTrainingCard(
      BuildContext context, {
        required String title,
        required String description,
        required IconData icon,
        required Color color,
        required String difficulty,
        required String estimatedTime,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.signal_cellular_alt,
                            size: 14,
                            color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          difficulty,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.timer,
                            size: 14,
                            color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          estimatedTime,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}