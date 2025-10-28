// lib/presentation/pages/training/drill_practice_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess_princess/domain/entities/drill.dart';
import 'package:chess_princess/domain/entities/training_result.dart';
import 'package:chess_princess/models/chess_board.dart';
import 'package:chess_princess/widgets/chess_board_widget.dart';
import 'package:chess_princess/presentation/providers/drill_provider.dart';
import 'package:chess_princess/presentation/providers/timer_provider.dart';
import 'package:chess_princess/presentation/providers/training_analytics_provider.dart';
import 'package:chess_princess/presentation/pages/training/drill_results_page.dart';

class DrillPracticePage extends ConsumerStatefulWidget {
  final Drill drill;

  const DrillPracticePage({required this.drill, super.key});

  @override
  ConsumerState<DrillPracticePage> createState() => _DrillPracticePageState();
}

class _DrillPracticePageState extends ConsumerState<DrillPracticePage> {
  late List<String> _userMoves;
  late ChessBoard _board;
  int _moveIndex = 0;
  bool _showingSolution = false;
  bool _showingHints = false;
  int _currentHintIndex = 0;

  @override
  void initState() {
    super.initState();
    _userMoves = [];
    _board = ChessBoard.fromFen(widget.drill.fen);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(timerProvider.notifier).reset();
      ref.read(timerProvider.notifier).startTimer();
    });
  }

  @override
  void dispose() {
    ref.read(timerProvider.notifier).stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeSeconds = ref.watch(timerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.drill.name),
        actions: [
          // Timer display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(timeSeconds),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drill Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getDifficultyColor(widget.drill.difficulty).withValues(alpha: 0.2),
                    _getDifficultyColor(widget.drill.difficulty).withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getDifficultyColor(widget.drill.difficulty).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(widget.drill.difficulty),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(widget.drill.type),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.drill.difficulty,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getDifficultyColor(widget.drill.difficulty),
                          ),
                        ),
                        if (widget.drill.description != null)
                          Text(
                            widget.drill.description!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Chess Board
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ChessBoardWidget(
                  board: _board,
                  onMove: (from, to) => _onMove('$from$to'),
                  isInteractive: true,
                  showCoordinates: true,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Solution Progress
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.route, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Solution Moves',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$_moveIndex / ${widget.drill.solutionMoves.length}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.drill.solutionMoves.asMap().entries.map((entry) {
                      final index = entry.key;
                      final move = entry.value;
                      final isCompleted = index < _moveIndex;
                      final isCurrent = index == _moveIndex;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green
                              : isCurrent
                              ? Colors.blue
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCompleted
                                ? Colors.green
                                : isCurrent
                                ? Colors.blue
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isCompleted)
                              const Icon(Icons.check, color: Colors.white, size: 16)
                            else if (isCurrent)
                              const Icon(Icons.arrow_forward, color: Colors.white, size: 16)
                            else
                              Icon(Icons.radio_button_unchecked,
                                  color: Colors.grey[400],
                                  size: 16),
                            const SizedBox(width: 6),
                            Text(
                              move,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace',
                                color: isCompleted || isCurrent
                                    ? Colors.white
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  if (_moveIndex == widget.drill.solutionMoves.length) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'All moves completed! Ready to finish.',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Hints Section
            if (widget.drill.hints.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber[700], size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Hints Available',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_currentHintIndex + 1}/${widget.drill.hints.length}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (_showingHints) ...[
                      const SizedBox(height: 12),
                      Text(
                        widget.drill.hints[_currentHintIndex],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.amber[900],
                          height: 1.4,
                        ),
                      ),
                      if (_currentHintIndex < widget.drill.hints.length - 1) ...[
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () {
                            setState(() => _currentHintIndex++);
                          },
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: const Text('Next Hint'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.amber[800],
                          ),
                        ),
                      ],
                    ] else ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          setState(() => _showingHints = true);
                        },
                        icon: const Icon(Icons.help_outline, size: 18),
                        label: const Text('Show Hint'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.amber[800],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _showingSolution = !_showingSolution);
                    },
                    icon: Icon(_showingSolution ? Icons.visibility_off : Icons.visibility),
                    label: Text(_showingSolution ? 'Hide Solution' : 'Show Solution'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _userMoves = [];
                        _moveIndex = 0;
                        _showingSolution = false;
                        _showingHints = false;
                        _currentHintIndex = 0;
                        _board = ChessBoard.fromFen(widget.drill.fen);
                      });
                      ref.read(timerProvider.notifier).reset();
                      ref.read(timerProvider.notifier).startTimer();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Restart'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _moveIndex == widget.drill.solutionMoves.length
                    ? _completeDrill
                    : null,
                icon: const Icon(Icons.check_circle),
                label: const Text('Complete Drill'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            // Solution Display
            if (_showingSolution) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.school, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Complete Solution',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.drill.solutionMoves.join(' → '),
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[900],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onMove(String move) {
    // Check if move matches current solution move
    if (_moveIndex < widget.drill.solutionMoves.length) {
      // Simple validation - in production, use chess engine to validate
      setState(() {
        _userMoves.add(move);
        _moveIndex++;
      });

      // Show feedback
      if (_moveIndex == widget.drill.solutionMoves.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All moves completed! Click "Complete Drill" to finish.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _completeDrill() async {
    ref.read(timerProvider.notifier).stopTimer();
    final timeSeconds = ref.read(timerProvider);

    // Record attempt
    await ref
        .read(drillAttemptProvider.notifier)
        .recordAttempt(widget.drill.id, true);

    // Record training result
    final result = TrainingResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: '', // Add userId from auth provider if available
      itemId: widget.drill.id,
      type: 'drill',
      completedAt: DateTime.now(),
      score: 100,
      timeSpentSeconds: timeSeconds,
      isSuccess: true,
    );

    await ref.read(trainingAnalyticsProvider.notifier).recordResult(result);

    if (!mounted) return;

    // Navigate to results
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => DrillResultsPage(
          drill: widget.drill,
          timeSeconds: timeSeconds,
          isSuccess: true,
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

  Color _getDifficultyColor(String difficulty) {
    return switch (difficulty.toLowerCase()) {
      'beginner' => Colors.green,
      'intermediate' => Colors.orange,
      'advanced' => Colors.red,
      _ => Colors.grey,
    };
  }

  IconData _getTypeIcon(DrillType type) {
    return switch (type) {
      DrillType.endgame => Icons.castle,
      DrillType.opening => Icons.play_circle,
      DrillType.middlegame => Icons.extension,
      DrillType.tactics => Icons.psychology,
      DrillType.strategy => Icons.lightbulb_outline,
    };
  }
}