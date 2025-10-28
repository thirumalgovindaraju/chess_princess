// lib/presentation/pages/puzzle/puzzle_game_screen.dart
import 'package:flutter/material.dart';
import '../../../models/chess_puzzle.dart';
import '../../../../models/chess_board.dart';
import '../../../../models/position.dart';
import '../../../../services/puzzle_service.dart';
import '../../../widgets/chess_board_widget.dart';
import '../../../widgets/puzzle_solved_dialog.dart';

class PuzzleGameScreen extends StatefulWidget {
  final PuzzleDifficulty? difficulty;

  const PuzzleGameScreen({
    Key? key,
    this.difficulty,
  }) : super(key: key);

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  List<ChessPuzzle> puzzles = [];
  int currentPuzzleIndex = 0;
  ChessPuzzle? currentPuzzle;
  late ChessBoard chessBoard;

  int movesMade = 0;
  bool puzzleCompleted = false;
  bool isLoading = true;
  DateTime? startTime;
  String? errorMessage;
  bool showHint = false;

  @override
  void initState() {
    super.initState();
    _loadPuzzles();
  }

  Future<void> _loadPuzzles() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      List<ChessPuzzle> loadedPuzzles;

      if (widget.difficulty != null) {
        loadedPuzzles = await PuzzleService.getPuzzlesByDifficulty(
          widget.difficulty!,
          limit: 50,
        );
      } else {
        loadedPuzzles = await PuzzleService.loadPuzzles(limit: 50);
      }

      if (loadedPuzzles.isEmpty) {
        setState(() {
          errorMessage = 'No puzzles found for this difficulty.';
          isLoading = false;
        });
        return;
      }

      setState(() {
        puzzles = loadedPuzzles;
        isLoading = false;
      });

      _loadPuzzle(0);
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load puzzles: $e';
        isLoading = false;
      });
    }
  }

  void _loadPuzzle(int index) {
    if (index < 0 || index >= puzzles.length) return;

    setState(() {
      currentPuzzleIndex = index;
      currentPuzzle = puzzles[index];
      chessBoard = currentPuzzle!.createBoard();
      movesMade = 0;
      puzzleCompleted = false;
      startTime = DateTime.now();
      showHint = false;
    });
  }

  void _onMove(Position from, Position to) {
    if (puzzleCompleted || currentPuzzle == null) return;

    String fromSquare = _positionToString(from);
    String toSquare = _positionToString(to);

    // Check if move is correct
    if (movesMade < currentPuzzle!.solution.length) {
      String expectedMove = currentPuzzle!.solution[movesMade];

      if (!_checkMoveCorrectness(fromSquare, toSquare, expectedMove)) {
        _showWrongMoveDialog();
        return;
      }
    }

    // Execute move
    setState(() {
      bool moveSuccess = chessBoard.makeMove(from, to);
      if (moveSuccess) {
        movesMade++;

        // Check if puzzle is completed
        if (movesMade >= currentPuzzle!.solution.length) {
          _completePuzzle();
        }
      }
    });
  }

  String _positionToString(Position pos) {
    String file = String.fromCharCode('a'.codeUnitAt(0) + pos.col);
    String rank = (8 - pos.row).toString();
    return '$file$rank';
  }

  bool _checkMoveCorrectness(String from, String to, String expectedMove) {
    String cleanExpected = expectedMove.replaceAll(RegExp(r'[+#x=QRBN]'), '');
    return cleanExpected.toLowerCase().endsWith(to.toLowerCase());
  }

  void _completePuzzle() {
    if (currentPuzzle == null || startTime == null) return;

    setState(() {
      puzzleCompleted = true;
    });

    Duration timeSpent = DateTime.now().difference(startTime!);
    PuzzleService.completePuzzle(currentPuzzle!.id, timeSpent, const []);

    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    if (currentPuzzle == null || startTime == null) return;

    final timeInSeconds = DateTime.now().difference(startTime!).inSeconds;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PuzzleSolvedDialog(
        puzzleId: currentPuzzle!.name,
        moves: movesMade,
        timeInSeconds: timeInSeconds,
        onTryAgain: () {
          Navigator.pop(context);
          _resetPuzzle();
        },
        onNextPuzzle: () {
          Navigator.pop(context);
          _nextPuzzle();
        },
      ),
    );
  }

  void _showWrongMoveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.close, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('Wrong Move!'),
          ],
        ),
        content: const Text(
          'That\'s not the correct solution. Try again!',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => showHint = true);
            },
            child: const Text('Show Hint'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetPuzzle();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade700,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _nextPuzzle() {
    if (currentPuzzleIndex < puzzles.length - 1) {
      _loadPuzzle(currentPuzzleIndex + 1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 You\'ve completed all puzzles!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _previousPuzzle() {
    if (currentPuzzleIndex > 0) {
      _loadPuzzle(currentPuzzleIndex - 1);
    }
  }

  void _resetPuzzle() {
    _loadPuzzle(currentPuzzleIndex);
  }

  void _skipPuzzle() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.skip_next, color: Colors.orange),
            SizedBox(width: 8),
            Text('Skip Puzzle?'),
          ],
        ),
        content: const Text('Move to the next puzzle?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (currentPuzzle != null) {
                PuzzleService.skipPuzzle(currentPuzzle!.id);
              }
              _nextPuzzle();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading Puzzles...'),
          backgroundColor: const Color(0xFFE91E63),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading puzzles...'),
            ],
          ),
        ),
      );
    }

    if (errorMessage != null || puzzles.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: const Color(0xFFE91E63),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(errorMessage ?? 'No puzzles available'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPuzzles,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Puzzle ${currentPuzzleIndex + 1}/${puzzles.length}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb),
            onPressed: () => setState(() => showHint = !showHint),
            tooltip: 'Toggle Hint',
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: _skipPuzzle,
            tooltip: 'Skip',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetPuzzle,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 800;

          if (isWideScreen) {
            // Desktop Layout
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: _buildChessBoard(constraints.maxHeight * 0.85),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: _buildPuzzleInfo(),
                ),
              ],
            );
          } else {
            // Mobile Layout
            return Column(
              children: [
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: _buildPuzzleInfo(),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: _buildChessBoard(
                      constraints.maxWidth < constraints.maxHeight * 0.6
                          ? constraints.maxWidth * 0.95
                          : constraints.maxHeight * 0.5,
                    ),
                  ),
                ),
                _buildBottomControls(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildChessBoard(double size) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(8),
      child: ChessBoardWidget(
        key: ValueKey('puzzle_${currentPuzzle?.id ?? currentPuzzleIndex}'),
        board: chessBoard,
        onMove: _onMove,
        isInteractive: !puzzleCompleted,
        showCoordinates: true,
      ),
    );
  }

  Widget _buildPuzzleInfo() {
    if (currentPuzzle == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(currentPuzzle!.difficulty),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      currentPuzzle!.difficultyName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      currentPuzzle!.theme.toUpperCase(),
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                currentPuzzle!.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),

              // Description
              if (currentPuzzle!.description != null)
                Text(
                  currentPuzzle!.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              const SizedBox(height: 16),

              // Stats
              Row(
                children: [
                  _buildStatChip(
                    icon: Icons.touch_app,
                    label: 'Moves',
                    value: '$movesMade/${currentPuzzle!.solution.length}',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  if (startTime != null)
                    StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        final seconds = DateTime.now().difference(startTime!).inSeconds;
                        return _buildStatChip(
                          icon: Icons.timer,
                          label: 'Time',
                          value: '${seconds}s',
                          color: Colors.green,
                        );
                      },
                    ),
                ],
              ),

              // Hint
              if (showHint && currentPuzzle!.hints.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber.shade800),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          currentPuzzle!.hints.first,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Completed Badge
              if (puzzleCompleted) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text(
                        'Completed!',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: currentPuzzleIndex > 0 ? _previousPuzzle : null,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.grey.shade800,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _resetPuzzle,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reset'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: currentPuzzleIndex < puzzles.length - 1 ? _nextPuzzle : null,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.grey.shade800,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(PuzzleDifficulty difficulty) {
    switch (difficulty) {
      case PuzzleDifficulty.easy:
        return Colors.green;
      case PuzzleDifficulty.medium:
        return Colors.orange;
      case PuzzleDifficulty.hard:
        return Colors.red;
      case PuzzleDifficulty.expert:
        return Colors.purple;
    }
  }
}