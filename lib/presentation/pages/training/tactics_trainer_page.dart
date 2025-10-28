// lib/presentation/pages/training/tactics_trainer_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'package:chess_princess/widgets/chess_board_widget.dart';
import '../../../domain/services/xp_service.dart';
import '../../widgets/level_up_dialog.dart';

class TacticsTrainerPage extends ConsumerStatefulWidget {
  const TacticsTrainerPage({super.key});

  @override
  ConsumerState<TacticsTrainerPage> createState() => _TacticsTrainerPageState();
}

class _TacticsTrainerPageState extends ConsumerState<TacticsTrainerPage> {
  int currentPuzzleIndex = 0;
  int solvedCount = 0;
  int totalAttempts = 0;
  bool showSolution = false;
  String? selectedDifficulty;

  // Chess state
  late chess_lib.Chess _chess;
  List<String> _userMoves = [];
  String? _selectedSquare;

  @override
  void initState() {
    super.initState();
    _initializePuzzle();
  }

  void _initializePuzzle() {
    final currentPuzzle = puzzles[currentPuzzleIndex % puzzles.length];
    _chess = chess_lib.Chess.fromFEN(currentPuzzle['fen']);
    _userMoves = [];
    _selectedSquare = null;
    showSolution = false;
  }

  // Sample puzzle data structure
  final List<Map<String, dynamic>> puzzles = [
    {
      'id': '1',
      'fen': 'r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3',
      'moves': ['f3b5', 'a7a6', 'b5a4'],
      'solution': ['Bb5', 'a6', 'Ba4'],
      'theme': 'Pin',
      'difficulty': 'Easy',
      'rating': 1200,
    },
    {
      'id': '2',
      'fen': 'r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/3P1N2/PPP2PPP/RNBQK2R w KQkq - 4 5',
      'moves': ['c4f7', 'e8f7', 'f3g5'],
      'solution': ['Bxf7+', 'Kxf7', 'Ng5+'],
      'theme': 'Fork',
      'difficulty': 'Medium',
      'rating': 1500,
    },
    {
      'id': '3',
      'fen': 'r1bqkb1r/pppp1ppp/2n2n2/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4',
      'moves': ['f3g5', 'd7d5', 'e4d5', 'c6a5'],
      'solution': ['Ng5', 'd5', 'exd5', 'Na5'],
      'theme': 'Trap',
      'difficulty': 'Hard',
      'rating': 1800,
    },
  ];

  void _onSquareTapped(String square) {
    if (showSolution) return;

    setState(() {
      if (_selectedSquare == null) {
        final piece = _chess.get(square);
        if (piece != null && piece.color == _chess.turn) {
          _selectedSquare = square;
        }
      } else {
        final move = _chess.move({'from': _selectedSquare, 'to': square});

        if (move != null) {
          _userMoves.add('$_selectedSquare$square');
          _selectedSquare = null;
        } else {
          final piece = _chess.get(square);
          if (piece != null && piece.color == _chess.turn) {
            _selectedSquare = square;
          } else {
            _selectedSquare = null;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPuzzle = puzzles[currentPuzzleIndex % puzzles.length];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tactics Trainer'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _initializePuzzle();
              });
            },
            tooltip: 'Reset Puzzle',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showHelp,
            tooltip: 'Help',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Header - Compact
          _buildStatsHeader(),

          // Puzzle Info Card - Compact
          _buildPuzzleInfo(currentPuzzle),

          // Chess Board - Takes remaining space
          Expanded(
            child: _buildChessBoard(currentPuzzle),
          ),

          // Control Buttons - Compact
          _buildControlButtons(currentPuzzle),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    final accuracy = totalAttempts > 0
        ? (solvedCount / totalAttempts * 100).toStringAsFixed(0)
        : '0';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade400,
            Colors.orange.shade600,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.emoji_events,
            label: 'Solved',
            value: '$solvedCount',
            color: Colors.white,
            bgColor: Colors.green.shade600,
          ),
          _buildStatItem(
            icon: Icons.format_list_numbered,
            label: 'Total',
            value: '$totalAttempts',
            color: Colors.white,
            bgColor: Colors.blue.shade600,
          ),
          _buildStatItem(
            icon: Icons.show_chart,
            label: 'Accuracy',
            value: '$accuracy%',
            color: Colors.white,
            bgColor: Colors.purple.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: color.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzleInfo(Map<String, dynamic> puzzle) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.orange.shade50],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.orange.shade600],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.extension, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Puzzle #${currentPuzzleIndex + 1}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              _buildDifficultyBadge(puzzle['difficulty']),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb_outline, size: 10, color: Colors.blue.shade700),
                    const SizedBox(width: 2),
                    Text(
                      puzzle['theme'],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 10, color: Colors.amber.shade700),
                    const SizedBox(width: 2),
                    Text(
                      '${puzzle['rating']}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade100, Colors.orange.shade50],
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.orange.shade300,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 12, color: Colors.orange.shade700),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Find the best move for ${_chess.turn == chess_lib.Color.WHITE ? "White" : "Black"}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        color = Colors.green;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'hard':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildChessBoard(Map<String, dynamic> puzzle) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available space
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;

        // Use the smaller dimension to ensure square board fits
        final boardSize = (availableWidth < availableHeight
            ? availableWidth
            : availableHeight) - 32; // padding

        return SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Chess Board
                  Container(
                    width: boardSize,
                    height: boardSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.2),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: GestureDetector(
                        onTapUp: (details) {
                          final RenderBox? box = context.findRenderObject() as RenderBox?;
                          if (box == null) return;

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

                  // Solution Display
                  if (showSolution)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade50,
                            Colors.green.shade100,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.green.shade400,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lightbulb,
                                color: Colors.green.shade700,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Solution',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              puzzle['solution'].join(' → '),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade900,
                                letterSpacing: 0.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButtons(Map<String, dynamic> puzzle) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_userMoves.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade100, Colors.blue.shade50],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade300, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app, size: 12, color: Colors.blue.shade700),
                    const SizedBox(width: 4),
                    Text(
                      '${_userMoves.length} move${_userMoves.length > 1 ? 's' : ''} made',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: _buildCompactButton(
                    onPressed: () {
                      setState(() {
                        showSolution = !showSolution;
                      });
                    },
                    icon: showSolution ? Icons.visibility_off : Icons.visibility,
                    label: showSolution ? 'Hide' : 'Hint',
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.orange.shade700,
                    borderColor: Colors.orange.shade400,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildCompactButton(
                    onPressed: _checkSolution,
                    icon: Icons.check_circle,
                    label: 'Check',
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _buildCompactButton(
                    onPressed: _skipPuzzle,
                    icon: Icons.skip_next,
                    label: 'Skip',
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.grey.shade700,
                    borderColor: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildCompactButton(
                    onPressed: _nextPuzzle,
                    icon: Icons.arrow_forward,
                    label: 'Next',
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
    Color? borderColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foregroundColor, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkSolution() async {
    setState(() {
      totalAttempts++;
    });

    final currentPuzzle = puzzles[currentPuzzleIndex % puzzles.length];
    final expectedMoves = currentPuzzle['moves'] as List<String>;

    bool isCorrect = _userMoves.length >= expectedMoves.length;
    if (isCorrect) {
      for (int i = 0; i < expectedMoves.length && i < _userMoves.length; i++) {
        if (_userMoves[i] != expectedMoves[i]) {
          isCorrect = false;
          break;
        }
      }
    } else {
      isCorrect = false;
    }

    if (isCorrect) {
      setState(() => solvedCount++);

      final currentXP = await XPService.getXP();
      final oldLevel = XPService.getLevelFromXP(currentXP);

      await XPService.addXP(15);

      final newXP = await XPService.getXP();
      final newLevel = XPService.getLevelFromXP(newXP);

      if (mounted && newLevel > oldLevel) {
        await showDialog(
          context: context,
          builder: (_) => LevelUpDialog(level: newLevel),
        );
      }

      if (mounted) {
        _showSuccessDialog();
      }
    } else {
      if (mounted) {
        _showErrorFeedback();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '🎉 Excellent!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You solved the puzzle!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade100, Colors.amber.shade200],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars, color: Colors.amber, size: 18),
                    SizedBox(width: 4),
                    Text(
                      '+15 XP',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _nextPuzzle();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Next Puzzle',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Not quite right!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Try again or use the hint',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _skipPuzzle() {
    setState(() {
      totalAttempts++;
      currentPuzzleIndex++;
      _initializePuzzle();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.skip_next, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Puzzle skipped',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade700,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _nextPuzzle() {
    setState(() {
      currentPuzzleIndex++;
      _initializePuzzle();
    });
  }

  void _showFeedback(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 12))),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.help_outline, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('How to Play', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Tactics Trainer helps you improve your chess tactics skills',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildHelpStep('1️⃣', 'Study the position carefully'),
              _buildHelpStep('2️⃣', 'Tap a piece to select it'),
              _buildHelpStep('3️⃣', 'Tap destination to move'),
              _buildHelpStep('4️⃣', 'Click "Check" to verify'),
              _buildHelpStep('💡', 'Use "Hint" if you need help'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tips_and_updates, color: Colors.blue.shade700, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Pro Tips',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildTip('Look for checks, captures, and threats'),
                    _buildTip('Consider all forcing moves'),
                    _buildTip('Calculate variations carefully'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Got it!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpStep(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}