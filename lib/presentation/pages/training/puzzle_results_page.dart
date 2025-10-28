// lib/presentation/pages/training/puzzle_results_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess_princess/domain/entities/puzzle.dart';
import 'package:chess_princess/presentation/pages/training/puzzles_provider.dart';
import 'package:chess_princess/domain/entities/drill.dart';
import 'package:chess_princess/presentation/pages/training/drill_attempt_provider.dart';

class PuzzleResultsPage extends ConsumerWidget {
  final Puzzle puzzle;
  final bool isCorrect;
  final int timeSeconds;

  const PuzzleResultsPage({
    required this.puzzle,
    required this.isCorrect,
    required this.timeSeconds,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle Results'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Result Icon with Animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCorrect ? Colors.green : Colors.red,
                    boxShadow: [
                      BoxShadow(
                        color: (isCorrect ? Colors.green : Colors.red)
                            .withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      isCorrect ? Icons.check_rounded : Icons.close_rounded,
                      color: Colors.white,
                      size: 70,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Result Title
              Text(
                isCorrect ? '🎉 Puzzle Solved!' : '❌ Puzzle Failed',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Encouragement Message
              Text(
                isCorrect
                    ? 'Great job! You found the solution!'
                    : 'Don\'t worry, keep practicing!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Stats Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    _StatRow(
                      icon: Icons.speed,
                      label: 'Time Taken',
                      value: _formatTime(timeSeconds),
                      color: Colors.blue,
                    ),
                    const Divider(height: 24),
                    _StatRow(
                      icon: Icons.signal_cellular_alt,
                      label: 'Difficulty',
                      value: '${puzzle.difficulty}',
                      color: _getDifficultyColor(puzzle.difficulty),
                    ),
                    const Divider(height: 24),
                    _StatRow(
                      icon: Icons.category,
                      label: 'Theme',
                      value: puzzle.theme.toUpperCase(),
                      color: Colors.orange,
                    ),
                    const Divider(height: 24),
                    _StatRow(
                      icon: Icons.star,
                      label: 'Rating',
                      value: '${puzzle.rating.toStringAsFixed(1)} ⭐',
                      color: Colors.amber,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Solution Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Solution',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: puzzle.solutionSan.map((move) {
                        return Chip(
                          label: Text(
                            move,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                            ),
                          ),
                          backgroundColor: Colors.blue[100],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Back to Training Hub'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to similar puzzles
                        ref.read(puzzlesProvider.notifier).filterByDifficulty(
                          puzzle.difficulty - 100,
                          puzzle.difficulty + 100,
                        );
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.replay),
                      label: const Text('Try Similar Puzzle'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  if (!isCorrect) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry This Puzzle'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }
    return '${seconds}s';
  }

  Color _getDifficultyColor(int difficulty) {
    if (difficulty < 1400) return Colors.green;
    if (difficulty < 1800) return Colors.blue;
    if (difficulty < 2200) return Colors.orange;
    return Colors.red;
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// lib/presentation/pages/training/drill_results_page.dart
class DrillResultsPage extends ConsumerWidget {
  final Drill drill;
  final int timeSeconds;
  final bool isSuccess;

  const DrillResultsPage({
    required this.drill,
    required this.timeSeconds,
    this.isSuccess = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(
      drillAttemptProvider.select((p) => p.getStats(drill.id)),
    );
    final successRate = ref.read(drillAttemptProvider.notifier).getSuccessRate(drill.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drill Complete'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 70,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Drill Name
              Text(
                drill.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Completed in ${_formatTime(timeSeconds)}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Performance Stats
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    _StatRow(
                      icon: Icons.fitness_center,
                      label: 'Total Attempts',
                      value: '${stats['attempts']}',
                      color: Colors.blue,
                    ),
                    const Divider(height: 24),
                    _StatRow(
                      icon: Icons.check_circle,
                      label: 'Successful',
                      value: '${stats['successes']}',
                      color: Colors.green,
                    ),
                    const Divider(height: 24),
                    _StatRow(
                      icon: Icons.trending_up,
                      label: 'Success Rate',
                      value: '${(successRate * 100).toStringAsFixed(1)}%',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Back to Training Hub'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.replay),
                      label: const Text('Try Again'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }
    return '${seconds}s';
  }
}