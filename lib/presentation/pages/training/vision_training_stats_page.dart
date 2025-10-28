// lib/presentation/pages/training/vision_training_stats_page.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'vision_training_provider.dart';
import 'vision_training_hub.dart';

class VisionTrainingStatsPage extends ConsumerWidget {
  const VisionTrainingStatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(visionTrainingStatsProvider);
    final notifier = ref.read(visionTrainingStatsProvider.notifier);
    final overallStats = notifier.getOverallStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Statistics'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Statistics'),
                  content: const Text('Are you sure you want to reset all statistics?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        notifier.reset();
                        Navigator.pop(context);
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverallStatsCard(overallStats),
            const SizedBox(height: 24),
            const Text(
              'Mode Statistics',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildModeStatCard(
              'positionMemory',
              stats.modeStats['positionMemory']!,
              'Position Memory',
              Icons.memory,
              Colors.blue,
            ),
            _buildModeStatCard(
              'coordinateTraining',
              stats.modeStats['coordinateTraining']!,
              'Coordinate Training',
              Icons.grid_on,
              Colors.green,
            ),
            _buildModeStatCard(
              'patternRecognition',
              stats.modeStats['patternRecognition']!,
              'Pattern Recognition',
              Icons.analytics,
              Colors.orange,
            ),
            _buildModeStatCard(
              'moveVisualization',
              stats.modeStats['moveVisualization']!,
              'Move Visualization',
              Icons.play_arrow,
              Colors.purple,
            ),
            _buildModeStatCard(
              'blindfoldGame',
              stats.modeStats['blindfoldGame']!,
              'Blindfold Game',
              Icons.visibility_off,
              Colors.red,
            ),
            _buildModeStatCard(
              'knightTour',
              stats.modeStats['knightTour']!,
              'Knight Tour',
              Icons.local_fire_department,
              Colors.indigo,
            ),
            _buildModeStatCard(
              'checkDetection',
              stats.modeStats['checkDetection']!,
              'Check Detection',
              Icons.warning,
              Colors.amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatsCard(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purple.shade700],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Overall Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Level',
                '${stats['level']}',
                Icons.emoji_events,
              ),
              _buildStatItem(
                'XP',
                '${stats['totalXP']}',
                Icons.star,
              ),
              _buildStatItem(
                'Accuracy',
                '${(stats['overallAccuracy'] * 100).toStringAsFixed(0)}%',
                Icons.trending_up,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (stats['totalXP'] % 100) / 100,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '${stats['totalXP'] % 100}/100 XP to next level',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildModeStatCard(
      String modeKey,
      ModeStats stats,
      String modeName,
      IconData icon,
      Color color,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      modeName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (stats.lastPlayed != null)
                      Text(
                        'Last played: ${_formatDate(stats.lastPlayed!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Played', '${stats.played}', color),
              _buildMiniStat('Correct', '${stats.correct}', color),
              _buildMiniStat(
                'Accuracy',
                '${(stats.accuracy * 100).toStringAsFixed(0)}%',
                color,
              ),
              _buildMiniStat('Best', '${stats.bestScore}', color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
