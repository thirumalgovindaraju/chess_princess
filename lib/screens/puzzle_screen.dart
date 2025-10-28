// lib/screens/puzzle_screen.dart
import 'package:flutter/material.dart';
import '../models/chess_board.dart';
import '../models/chess_puzzle.dart';
import '../services/puzzle_service.dart';
import '../widgets/chess_board_widget.dart';
import '../models/position.dart';
import '../widgets/puzzle_solved_dialog.dart';
class PuzzleScreen extends StatefulWidget {
  final String? selectedSet;
  final PuzzleDifficulty? selectedDifficulty;
  final ChessPuzzle? puzzle;
  final int? startTier;

  const PuzzleScreen({
    Key? key,
    this.selectedSet,
    this.puzzle,
    this.selectedDifficulty,
    this.startTier,
  }) : super(key: key);

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  late ChessBoard chessBoard;
  ChessPuzzle? currentPuzzle;
  List<ChessPuzzle> puzzles = [];
  int currentPuzzleIndex = 0;
  int movesMade = 0;
  bool puzzleCompleted = false;
  bool isLoading = true;
  DateTime? startTime;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    if (widget.puzzle != null) {
      setState(() {
        currentPuzzle = widget.puzzle;
        chessBoard = widget.puzzle!.createBoard();
        puzzles = [widget.puzzle!];
        isLoading = false;
        startTime = DateTime.now();
      });
    } else {
      _loadPuzzles();
    }
  }
/*
  Future<void> _loadPuzzles() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (widget.selectedDifficulty != null) {
        puzzles = await PuzzleService.getPuzzlesByDifficulty(
          widget.selectedDifficulty!,
          limit: 100000,
        );
      } else if (widget.selectedSet != null) {
        puzzles = await PuzzleService.getPuzzlesByTheme(
          theme: widget.selectedSet!,
          limit: 100000,
        );
      } else {
        puzzles = await PuzzleService.loadPuzzles(limit: 100000);
      }

      if (puzzles.isNotEmpty) {
        int startIndex = widget.startTier != null ? (widget.startTier! - 1) * 20 : 0;
        if (startIndex >= puzzles.length) startIndex = 0;
        _loadPuzzle(startIndex);
      } else {
        setState(() {
          errorMessage = 'No puzzles found for this difficulty.';
        });
      }
    } catch (e, stackTrace) {
      print('Error loading puzzles: $e\n$stackTrace');
      setState(() {
        errorMessage = 'Failed to load puzzles: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
*/

  // FIXED: Now accepts Position objects instead of strings
  void _onMove(Position from, Position to) {
    if (puzzleCompleted || currentPuzzle == null) return;

    // Convert positions to chess notation for validation
    String fromSquare = _positionToString(from);
    String toSquare = _positionToString(to);

    if (movesMade < currentPuzzle!.solution.length) {
      String expectedMove = currentPuzzle!.solution[movesMade];

      if (!_checkMoveCorrectness(fromSquare, toSquare, expectedMove)) {
        _showWrongMoveDialog(expectedMove);
        return;
      }
    }

    setState(() {
      bool moveSuccess = chessBoard.makeMove(from, to);

      if (moveSuccess) {
        movesMade++;

        if (movesMade >= currentPuzzle!.solution.length) {
          _completePuzzle();
        }
      }
    });
  }

  // NEW: Convert Position to chess notation (e.g., "e2")
  String _positionToString(Position pos) {
    String file = String.fromCharCode('a'.codeUnitAt(0) + pos.col);
    String rank = (8 - pos.row).toString();
    return '$file$rank';
  }

  Position _stringToPosition(String square) {
    // Convert "e2" format to Position(row, col)
    int col = square.codeUnitAt(0) - 'a'.codeUnitAt(0);
    int row = 8 - int.parse(square[1]);
    return Position(row: row, col: col);
  }

  bool _checkMoveCorrectness(String from, String to, String expectedMove) {
    String toSquare = to;
    String cleanExpected = expectedMove.replaceAll(RegExp(r'[+#]'), '');
    String expectedDestination = '';

    if (cleanExpected.contains('=')) {
      expectedDestination = cleanExpected.split('=')[0];
      if (expectedDestination.length >= 2) {
        expectedDestination = expectedDestination.substring(expectedDestination.length - 2);
      }
    } else if (cleanExpected.length >= 2) {
      expectedDestination = cleanExpected.substring(cleanExpected.length - 2);
    }

    return expectedDestination.toLowerCase() == toSquare.toLowerCase();
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

  void _skipPuzzle() {
    if (currentPuzzle == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.skip_next, color: Colors.orange),
              SizedBox(width: 8),
              Text('Skip Puzzle?'),
            ],
          ),
          content: const Text(
            'Are you sure you want to skip this puzzle? You can come back to it later.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                PuzzleService.skipPuzzle(currentPuzzle!.id);
                _nextPuzzle();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Skip'),
            ),
          ],
        );
      },
    );
  }

  void _showWrongMoveDialog(String expectedMove) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.close, color: Colors.red.shade700),
              const SizedBox(width: 8),
              const Text('Wrong Move!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'That\'s not the correct solution.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'Expected: $expectedMove',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _getHint();
              },
              child: const Text('Get Hint'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _skipPuzzle();
              },
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetPuzzle();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _showCompletionDialog() {
    if (currentPuzzle == null || startTime == null) return;

    final timeInSeconds = DateTime.now().difference(startTime!).inSeconds;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PuzzleSolvedDialog(
          puzzleId: currentPuzzle!.name,
          moves: movesMade,
          timeInSeconds: timeInSeconds,
          onTryAgain: () {
            Navigator.of(context).pop();
            _resetPuzzle();
          },
          onNextPuzzle: () {
            Navigator.of(context).pop();
            _nextPuzzle();
          },
        );
      },
    );
  }

  void _nextPuzzle() {
    if (currentPuzzleIndex < puzzles.length - 1) {
      _loadPuzzle(currentPuzzleIndex + 1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You\'ve completed all puzzles!')),
      );
    }
  }

  void _previousPuzzle() {
    if (currentPuzzleIndex > 0) {
      _loadPuzzle(currentPuzzleIndex - 1);
    }
  }

  void _resetPuzzle() {
    if (currentPuzzle != null) {
      _loadPuzzle(currentPuzzleIndex);
    }
  }

  Future<void> _loadPuzzles() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (widget.selectedDifficulty != null) {
        puzzles = await PuzzleService.getPuzzlesByDifficulty(
          widget.selectedDifficulty!,
          limit: 100000,
        );
      } else if (widget.selectedSet != null) {
        puzzles = await PuzzleService.getPuzzlesByTheme(
          theme: widget.selectedSet!,
          limit: 100000,
        );
      } else {
        puzzles = await PuzzleService.loadPuzzles(limit: 100000);
      }

      if (puzzles.isNotEmpty) {
        int startIndex = widget.startTier != null ? (widget.startTier! - 1) * 20 : 0;
        if (startIndex >= puzzles.length) startIndex = 0;
        _loadPuzzle(startIndex);
      } else {
        setState(() {
          errorMessage = 'No puzzles found for this difficulty.';
        });
      }
    } catch (e, stackTrace) {
      print('Error loading puzzles: $e\n$stackTrace');
      setState(() {
        errorMessage = 'Failed to load puzzles: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

// Updated _loadPuzzle with proper debugging
  void _loadPuzzle(int index) {
    if (index >= 0 && index < puzzles.length) {
      setState(() {
        currentPuzzleIndex = index;
        currentPuzzle = puzzles[index];

        try {
          print('═══════════════════════════════════════');
          print('Loading puzzle: ${currentPuzzle!.id}');
          print('FEN input: ${currentPuzzle!.fenPosition}');

          // Create a completely new board instance
          chessBoard = currentPuzzle!.createBoard();

          print('Board created successfully!');
          //print('Board FEN output: ${chessBoard.toFen()}');
          print('Piece count on board:');

          int whiteCount = 0;
          int blackCount = 0;
          for (int row = 0; row < 8; row++) {
            for (int col = 0; col < 8; col++) {
              final piece = chessBoard.getPieceAt(Position(row: row, col: col));
              if (piece != null) {
                if (piece.isWhite) {
                  whiteCount++;
                } else {
                  blackCount++;
                }
              }
            }
          }
          print('White pieces: $whiteCount, Black pieces: $blackCount');
          print('═══════════════════════════════════════');

        } catch (e, stackTrace) {
          print('ERROR creating board: $e');
          print('Stack trace: $stackTrace');
          errorMessage = 'Failed to create board: $e';
          chessBoard = ChessBoard.initial();
        }

        movesMade = 0;
        puzzleCompleted = false;
        startTime = DateTime.now();
      });
    }
  }

  void _getHint() {
    if (currentPuzzle == null) return;

    String hint = PuzzleService.getHint(currentPuzzle!, movesMade);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber),
              SizedBox(width: 8),
              Text('Hint'),
            ],
          ),
          content: Text(hint),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it!'),
            ),
          ],
        );
      },
    );
  }

  int _getCurrentTier() {
    return (currentPuzzleIndex ~/ 20) + 1;
  }

  int _getLevelInTier() {
    return (currentPuzzleIndex % 20) + 1;
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chess Puzzles'),
          backgroundColor: Colors.indigo.shade700,
          foregroundColor: Colors.white,
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
          title: const Text('Chess Puzzles'),
          backgroundColor: Colors.indigo.shade700,
          foregroundColor: Colors.white,
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
      appBar: AppBar(
        title: Text('Tier ${_getCurrentTier()} - Level ${_getLevelInTier()} (${currentPuzzleIndex + 1}/${puzzles.length})'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb),
            onPressed: _getHint,
            tooltip: 'Get Hint',
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: _skipPuzzle,
            tooltip: 'Skip Puzzle',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetPuzzle,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWideScreen = constraints.maxWidth > 800;

            if (isWideScreen) {
              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxHeight * 0.9,
                          maxHeight: constraints.maxHeight * 0.9,
                        ),
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            // FIXED: Pass board object instead of fen string
                            child: ChessBoardWidget(
                              key: ValueKey('puzzle_${currentPuzzle?.id ?? currentPuzzleIndex}'),
                              board: chessBoard,
                              onMove: _onMove,
                              isInteractive: true,
                              showCoordinates: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildPuzzleInfo(),
                    ),
                  ),
                ],
              );
            } else {
              double infoHeight = 200;
              double controlsHeight = 70;
              double boardHeight = constraints.maxHeight - infoHeight - controlsHeight;
              double boardSize = constraints.maxWidth < boardHeight
                  ? constraints.maxWidth * 0.95
                  : boardHeight * 0.95;

              return Column(
                children: [
                  SizedBox(
                    height: infoHeight,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildPuzzleInfo(),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: boardSize,
                        height: boardSize,
                        // FIXED: Pass board object instead of fen string
                        child: ChessBoardWidget(
                          key: ValueKey('puzzle_${currentPuzzle?.id ?? currentPuzzleIndex}'),
                          board: chessBoard,
                          onMove: _onMove,
                          isInteractive: true,
                          showCoordinates: true,
                        ),
                      ),
                    ),
                  ),
                  _buildBottomControls(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildPuzzleInfo() {
    if (currentPuzzle == null) return Container();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Tier ${_getCurrentTier()}',
                    style: TextStyle(
                      color: Colors.indigo.shade900,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    currentPuzzle!.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(currentPuzzle!.difficulty),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentPuzzle!.difficultyName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (currentPuzzle!.description != null)
              Text(currentPuzzle!.description!),
            if (currentPuzzle!.description != null)
              const SizedBox(height: 8),
            if (currentPuzzle!.theme.isNotEmpty) ...[
              Text(
                'Theme: ${currentPuzzle!.theme}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ],
            if (currentPuzzle!.movesToMate > 0) ...[
              Text(
                'Mate in ${currentPuzzle!.movesToMate}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Moves: $movesMade'),
                const SizedBox(width: 16),
                if (startTime != null)
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, snapshot) {
                      int seconds = DateTime.now().difference(startTime!).inSeconds;
                      return Text('Time: ${seconds}s');
                    },
                  ),
              ],
            ),
            if (puzzleCompleted) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Completed!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: currentPuzzleIndex > 0 ? _previousPuzzle : null,
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Prev', style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _skipPuzzle,
              icon: const Icon(Icons.skip_next, size: 16),
              label: const Text('Skip', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade100,
                foregroundColor: Colors.orange.shade900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _resetPuzzle,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reset', style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: currentPuzzleIndex < puzzles.length - 1 ? _nextPuzzle : null,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Next', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}