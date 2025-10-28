// lib/presentation/pages/training/opening_practice_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'package:chess_princess/widgets/chess_board_widget.dart';
import '../../../domain/services/xp_service.dart';
import '../../widgets/level_up_dialog.dart';
import 'dart:async';

enum PracticeMode { quickDrill, fullPractice, quizMode }

class OpeningPracticePage extends ConsumerStatefulWidget {
  final Map<String, dynamic> opening;
  final PracticeMode mode;

  const OpeningPracticePage({
    Key? key,
    required this.opening,
    required this.mode,
  }) : super(key: key);

  @override
  ConsumerState<OpeningPracticePage> createState() => _OpeningPracticePageState();
}

class _OpeningPracticePageState extends ConsumerState<OpeningPracticePage> {
  late chess_lib.Chess _chess;
  int currentPosition = 0;
  int correctMoves = 0;
  int totalMoves = 0;
  bool isCompleted = false;
  String? selectedSquare;
  List<String> userMoves = [];
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isPaused = false;

  // Practice positions for each opening
  late List<Map<String, dynamic>> positions;

  @override
  void initState() {
    super.initState();
    _initializePositions();
    _initializeChess();
    if (widget.mode == PracticeMode.quickDrill) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializePositions() {
    // Generate practice positions based on the opening
    final openingName = widget.opening['name'];

    switch (openingName) {
      case 'Ruy Lopez':
        positions = [
          {
            'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
            'correctMove': 'e2e4',
            'description': 'Start with 1. e4',
            'hint': 'King pawn opening',
          },
          {
            'fen': 'rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6 0 2',
            'correctMove': 'g1f3',
            'description': 'Develop the knight to f3',
            'hint': 'Attack the e5 pawn',
          },
          {
            'fen': 'rnbqkbnr/pppp1ppp/8/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2',
            'correctMove': 'b8c6',
            'description': 'Black defends with Nc6',
            'hint': 'Defend the e5 pawn',
          },
          {
            'fen': 'r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3',
            'correctMove': 'f1b5',
            'description': 'Play the Ruy Lopez with Bb5',
            'hint': 'Attack the knight on c6',
          },
          {
            'fen': 'r1bqkbnr/pppp1ppp/2n5/1B2p3/4P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 3 3',
            'correctMove': 'a7a6',
            'description': 'Challenge the bishop',
            'hint': 'Attack the bishop on b5',
          },
        ];
        break;

      case 'Sicilian Defense':
        positions = [
          {
            'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
            'correctMove': 'e2e4',
            'description': 'Start with 1. e4',
            'hint': 'King pawn opening',
          },
          {
            'fen': 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1',
            'correctMove': 'c7c5',
            'description': 'Sicilian Defense with c5',
            'hint': 'Attack the center from the side',
          },
          {
            'fen': 'rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq c6 0 2',
            'correctMove': 'g1f3',
            'description': 'Develop the knight',
            'hint': 'Prepare d4',
          },
          {
            'fen': 'rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2',
            'correctMove': 'd7d6',
            'description': 'Solid setup with d6',
            'hint': 'Prepare piece development',
          },
          {
            'fen': 'rnbqkbnr/pp2pppp/3p4/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 0 3',
            'correctMove': 'd2d4',
            'description': 'Break in the center',
            'hint': 'Attack the c5 pawn',
          },
        ];
        break;

      case 'French Defense':
        positions = [
          {
            'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
            'correctMove': 'e2e4',
            'description': 'Start with 1. e4',
            'hint': 'King pawn opening',
          },
          {
            'fen': 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1',
            'correctMove': 'e7e6',
            'description': 'French Defense with e6',
            'hint': 'Prepare d5',
          },
          {
            'fen': 'rnbqkbnr/pppp1ppp/4p3/8/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2',
            'correctMove': 'd2d4',
            'description': 'Establish pawn center',
            'hint': 'Control the center',
          },
          {
            'fen': 'rnbqkbnr/pppp1ppp/4p3/8/3PP3/8/PPP2PPP/RNBQKBNR b KQkq d3 0 2',
            'correctMove': 'd7d5',
            'description': 'Challenge the center',
            'hint': 'Attack e4',
          },
          {
            'fen': 'rnbqkbnr/ppp2ppp/4p3/3p4/3PP3/8/PPP2PPP/RNBQKBNR w KQkq d6 0 3',
            'correctMove': 'b1c3',
            'description': 'Develop and defend',
            'hint': 'Protect the e4 pawn',
          },
        ];
        break;

      default:
      // Generic positions for other openings
        positions = [
          {
            'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
            'correctMove': 'e2e4',
            'description': 'Start the opening',
            'hint': 'Most common first move',
          },
          {
            'fen': 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1',
            'correctMove': 'e7e5',
            'description': 'Respond symmetrically',
            'hint': 'Mirror white\'s move',
          },
          {
            'fen': 'rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6 0 2',
            'correctMove': 'g1f3',
            'description': 'Develop the knight',
            'hint': 'Attack the center',
          },
          {
            'fen': 'rnbqkbnr/pppp1ppp/8/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2',
            'correctMove': 'b8c6',
            'description': 'Defend the center',
            'hint': 'Develop and protect',
          },
          {
            'fen': 'r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3',
            'correctMove': 'f1c4',
            'description': 'Develop the bishop',
            'hint': 'Italian style development',
          },
        ];
    }

    // Limit positions based on mode
    if (widget.mode == PracticeMode.quickDrill) {
      positions = positions.take(5).toList();
    }
  }

  void _initializeChess() {
    _chess = chess_lib.Chess.fromFEN(positions[currentPosition]['fen']);
    userMoves = [];
    selectedSquare = null;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && mounted) {
        setState(() {
          _secondsElapsed++;
          if (widget.mode == PracticeMode.quickDrill && _secondsElapsed >= 300) {
            _completeSession();
          }
        });
      }
    });
  }

  void _onSquareTapped(String square) {
    if (isCompleted || _isPaused) return;

    setState(() {
      if (selectedSquare == null) {
        final piece = _chess.get(square);
        if (piece != null && piece.color == _chess.turn) {
          selectedSquare = square;
        }
      } else {
        final moveNotation = '$selectedSquare$square';
        final correctMove = positions[currentPosition]['correctMove'];

        final move = _chess.move({'from': selectedSquare, 'to': square});

        if (move != null) {
          totalMoves++;

          if (moveNotation == correctMove) {
            correctMoves++;
            _showFeedback(true, 'Correct! Excellent move! 🎉');

            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                _nextPosition();
              }
            });
          } else {
            _showFeedback(false, 'Not the best move. Try again!');
            _chess.undo();
          }
        }

        selectedSquare = null;
      }
    });
  }

  void _nextPosition() {
    if (currentPosition < positions.length - 1) {
      setState(() {
        currentPosition++;
        _initializeChess();
      });
    } else {
      _completeSession();
    }
  }

  void _completeSession() async {
    if (isCompleted) return;

    setState(() {
      isCompleted = true;
      _isPaused = true;
    });

    _timer?.cancel();

    // Calculate XP based on performance
    final accuracy = totalMoves > 0 ? (correctMoves / totalMoves * 100).round() : 0;
    int xpEarned = 0;

    if (widget.mode == PracticeMode.quickDrill) {
      xpEarned = 20 + (accuracy ~/ 10);
    } else if (widget.mode == PracticeMode.fullPractice) {
      xpEarned = 30 + (accuracy ~/ 5);
    } else {
      xpEarned = 25 + (accuracy ~/ 8);
    }

    final currentXP = await XPService.getXP();
    final oldLevel = XPService.getLevelFromXP(currentXP);

    await XPService.addXP(xpEarned);

    final newXP = await XPService.getXP();
    final newLevel = XPService.getLevelFromXP(newXP);

    if (mounted && newLevel > oldLevel) {
      await showDialog(
        context: context,
        builder: (_) => LevelUpDialog(level: newLevel),
      );
    }

    if (mounted) {
      _showCompletionDialog(accuracy, xpEarned);
    }
  }

  void _showFeedback(bool isCorrect, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: isCorrect ? Colors.green.shade600 : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: isCorrect ? 1000 : 2000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showCompletionDialog(int accuracy, int xpEarned) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.opening['color'].withValues(alpha: 0.8),
                      widget.opening['color'],
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _getCompletionTitle(accuracy),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You completed the ${_getModeTitle()} session!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildStatRow('Correct Moves', '$correctMoves / $totalMoves'),
                    const SizedBox(height: 8),
                    _buildStatRow('Accuracy', '$accuracy%'),
                    const SizedBox(height: 8),
                    _buildStatRow('Time', _formatTime(_secondsElapsed)),
                    const SizedBox(height: 8),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    _buildStatRow('XP Earned', '+$xpEarned', isHighlight: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.opening['color'],
                        side: BorderSide(color: widget.opening['color'], width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          currentPosition = 0;
                          correctMoves = 0;
                          totalMoves = 0;
                          isCompleted = false;
                          _isPaused = false;
                          _secondsElapsed = 0;
                          _initializeChess();
                          if (widget.mode == PracticeMode.quickDrill) {
                            _startTimer();
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.opening['color'],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildStatRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isHighlight ? widget.opening['color'] : Colors.black87,
          ),
        ),
      ],
    );
  }

  String _getCompletionTitle(int accuracy) {
    if (accuracy >= 90) return '🏆 Perfect!';
    if (accuracy >= 75) return '⭐ Excellent!';
    if (accuracy >= 60) return '👍 Good Job!';
    return '💪 Keep Practicing!';
  }

  String _getModeTitle() {
    switch (widget.mode) {
      case PracticeMode.quickDrill:
        return 'Quick Drill';
      case PracticeMode.fullPractice:
        return 'Full Practice';
      case PracticeMode.quizMode:
        return 'Quiz Mode';
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentPos = positions[currentPosition];
    final progress = (currentPosition + 1) / positions.length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(_getModeTitle()),
        backgroundColor: widget.opening['color'],
        foregroundColor: Colors.white,
        actions: [
          if (widget.mode == PracticeMode.quickDrill)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(_secondsElapsed),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(widget.opening['color']),
            minHeight: 6,
          ),

          // Header Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.opening['color'].withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            widget.opening['icon'],
                            color: widget.opening['color'],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.opening['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Position ${currentPosition + 1} of ${positions.length}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
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
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$correctMoves / $totalMoves',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.opening['color'].withValues(alpha: 0.1),
                        widget.opening['color'].withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.opening['color'].withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: widget.opening['color'],
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          currentPos['description'],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: widget.opening['color'],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Chess Board
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final boardSize = constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth - 32
                    : constraints.maxHeight - 32;

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: boardSize,
                      height: boardSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: widget.opening['color'].withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GestureDetector(
                          onTapUp: (details) {
                            final squareSize = boardSize / 8;
                            final localX = details.localPosition.dx;
                            final localY = details.localPosition.dy;

                            final col = (localX / squareSize).floor();
                            final row = (localY / squareSize).floor();

                            if (col >= 0 && col < 8 && row >= 0 && row < 8) {
                              final square = '${String.fromCharCode(97 + col)}${8 - row}';
                              _onSquareTapped(square);
                            }
                          },
                          child: ChessBoardWidget(
                            fen: _chess.fen,
                            isInteractive: false,
                            showCoordinates: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Row(
                              children: [
                                Icon(Icons.lightbulb, color: Colors.amber),
                                SizedBox(width: 8),
                                Text('Hint'),
                              ],
                            ),
                            content: Text(currentPos['hint']),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Got it!'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.lightbulb_outline, size: 18),
                      label: const Text(
                        'Hint',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amber.shade700,
                        side: BorderSide(color: Colors.amber.shade300, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Skip Position?'),
                            content: const Text(
                              'Skipping will mark this position as incorrect.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    totalMoves++;
                                  });
                                  _nextPosition();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                child: const Text('Skip'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.skip_next, size: 18),
                      label: const Text(
                        'Skip',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.opening['color'],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}