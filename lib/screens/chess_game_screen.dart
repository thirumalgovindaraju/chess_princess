// lib/screens/chess_game_screen.dart
import 'package:flutter/material.dart';
import '../models/chess_board.dart';
import '../models/position.dart';
import '../services/chess_coach.dart';
import '../services/chess_ai.dart';
import '../models/coach_suggestion.dart';
import 'coach_screen.dart';

class ChessGameScreen extends StatefulWidget {
  const ChessGameScreen({Key? key}) : super(key: key);

  @override
  State<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends State<ChessGameScreen> {
  late ChessBoard currentBoard;
  late List<String> moveHistory;

  // AI Coach variables
  final ChessCoach _coach = ChessCoach();
  final ChessAI _ai = ChessAI(); // Add separate AI instance
  CoachSuggestion? _lastMoveSuggestion;
  bool _coachEnabled = true;
  ChessBoard? _previousBoard;

  // Game variables
  Position? selectedPosition;
  List<Position> validMoves = [];

  @override
  void initState() {
    super.initState();
    currentBoard = ChessBoard.initial();
    moveHistory = [];
    _previousBoard = currentBoard.copy();
  }

  Future<void> _analyzeLastMove() async {
    if (!_coachEnabled || moveHistory.isEmpty || _previousBoard == null) return;

    try {
      final lastMove = moveHistory.last;
      final suggestion = _coach.analyzeMoveQuality(
        _previousBoard!,
        currentBoard,
        lastMove,
      );

      if (suggestion != null && mounted) {
        setState(() {
          _lastMoveSuggestion = suggestion;
        });
        _showMoveFeedback(suggestion);
      }
    } catch (e) {
      debugPrint('Error analyzing move: $e');
    }
  }

  void _showMoveFeedback(CoachSuggestion suggestion) {
    if (suggestion.type == SuggestionType.warning ||
        suggestion.type == SuggestionType.mistake) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                suggestion.type == SuggestionType.mistake
                    ? Icons.error
                    : Icons.warning_amber,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(suggestion.title)),
            ],
          ),
          backgroundColor: suggestion.type == SuggestionType.mistake
              ? Colors.red
              : Colors.orange,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () => _openCoachScreen(),
          ),
        ),
      );
    } else if (suggestion.type == SuggestionType.praise) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.star, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(suggestion.title)),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openCoachScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoachScreen(
          currentBoard: currentBoard,
          moveHistory: moveHistory,
          onMoveApplied: (move) {
            _applySuggestedMove(move);
          },
        ),
      ),
    );
  }

  void _applySuggestedMove(String move) {
    if (move.length < 4) return;

    try {
      final fromCol = move[0].codeUnitAt(0) - 'a'.codeUnitAt(0);
      final fromRow = 8 - int.parse(move[1]);
      final toCol = move[2].codeUnitAt(0) - 'a'.codeUnitAt(0);
      final toRow = 8 - int.parse(move[3]);

      final from = Position(row : fromRow, col:  fromCol);
      final to = Position(row : toRow, col: toCol);

      _makeMove(from, to);
    } catch (e) {
      debugPrint('Error applying suggested move: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to apply suggested move'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _makeMove(Position from, Position to) {
    _previousBoard = currentBoard.copy();

    setState(() {
      currentBoard.movePiece(from, to);
      final moveNotation = _positionToNotation(from) + _positionToNotation(to);
      moveHistory.add(moveNotation);
      selectedPosition = null;
      validMoves = [];
    });

    _analyzeLastMove();
  }

  void _handleSquareTap(Position position) {
    final piece = currentBoard.squares[position.row][position.col];

    if (selectedPosition == null) {
      if (piece != null && piece.isWhite == currentBoard.isWhiteTurn) {
        setState(() {
          selectedPosition = position;
          validMoves = _getValidMovesForPosition(position);
        });
      }
    } else {
      if (validMoves.contains(position)) {
        _makeMove(selectedPosition!, position);
      } else if (piece != null && piece.isWhite == currentBoard.isWhiteTurn) {
        setState(() {
          selectedPosition = position;
          validMoves = _getValidMovesForPosition(position);
        });
      } else {
        setState(() {
          selectedPosition = null;
          validMoves = [];
        });
      }
    }
  }

  List<Position> _getValidMovesForPosition(Position position) {
    // Use the AI instance instead of _coach.ai
    return _ai.getLegalMovesForPiece(currentBoard, position);
  }

  String _positionToNotation(Position pos) {
    const files = 'abcdefgh';
    return '${files[pos.col]}${8 - pos.row}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Game'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: moveHistory.isNotEmpty ? _undoLastMove : null,
            tooltip: 'Undo Move',
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.school),
                if (_lastMoveSuggestion != null &&
                    _lastMoveSuggestion!.priority.index <=
                        SuggestionPriority.high.index)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: _lastMoveSuggestion!.priority ==
                            SuggestionPriority.critical
                            ? Colors.red
                            : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _openCoachScreen,
            tooltip: 'AI Coach',
          ),
          IconButton(
            icon: Icon(
              _coachEnabled ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _coachEnabled = !_coachEnabled;
                if (!_coachEnabled) {
                  _lastMoveSuggestion = null;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _coachEnabled ? 'AI Coach enabled' : 'AI Coach disabled',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            tooltip: _coachEnabled ? 'Disable Coach' : 'Enable Coach',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showGameMenu,
            tooltip: 'Menu',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_lastMoveSuggestion != null &&
              _lastMoveSuggestion!.priority == SuggestionPriority.critical)
            _buildSuggestionBanner(),
          _buildGameInfoBar(),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: _buildChessBoard(),
              ),
            ),
          ),
          _buildMoveHistory(),
        ],
      ),
      floatingActionButton: _coachEnabled
          ? FloatingActionButton.extended(
        onPressed: _openCoachScreen,
        icon: const Icon(Icons.lightbulb),
        label: const Text('Get Advice'),
        backgroundColor: Colors.deepPurple,
      )
          : null,
    );
  }

  Widget _buildSuggestionBanner() {
    final suggestion = _lastMoveSuggestion!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: suggestion.priority == SuggestionPriority.critical
            ? Colors.red.withOpacity(0.9)
            : Colors.orange.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            suggestion.type == SuggestionType.mistake
                ? Icons.error
                : Icons.warning_amber,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  suggestion.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _openCoachScreen,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: const Text('View'),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
            onPressed: () {
              setState(() {
                _lastMoveSuggestion = null;
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfoBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                currentBoard.isWhiteTurn ? Icons.circle_outlined : Icons.circle,
                color: currentBoard.isWhiteTurn ? Colors.white : Colors.black,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${currentBoard.isWhiteTurn ? "White" : "Black"} to move',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            'Move ${(moveHistory.length / 2).ceil()}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChessBoard() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      itemCount: 64,
      itemBuilder: (context, index) {
        final row = index ~/ 8;
        final col = index % 8;
        final position = Position(row: row, col: col);
        final piece = currentBoard.squares[row][col];

        final isLight = (row + col) % 2 == 0;
        final isSelected = selectedPosition == position;
        final isValidMove = validMoves.contains(position);

        Color squareColor;
        if (isSelected) {
          squareColor = Colors.yellow[300]!;
        } else if (isValidMove) {
          squareColor = isLight ? Colors.green[200]! : Colors.green[400]!;
        } else {
          squareColor = isLight ? Colors.grey[300]! : Colors.brown[300]!;
        }

        return GestureDetector(
          onTap: () => _handleSquareTap(position),
          child: Container(
            decoration: BoxDecoration(
              color: squareColor,
              border: Border.all(
                color: Colors.black12,
                width: 0.5,
              ),
            ),
            child: Stack(
              children: [
                if (col == 0)
                  Positioned(
                    left: 2,
                    top: 2,
                    child: Text(
                      '${8 - row}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isLight ? Colors.black54 : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (row == 7)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Text(
                      String.fromCharCode('a'.codeUnitAt(0) + col),
                      style: TextStyle(
                        fontSize: 10,
                        color: isLight ? Colors.black54 : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (piece != null)
                  Center(
                    child: Text(
                      piece.symbol,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                if (isValidMove && piece == null)
                  Center(
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                if (isValidMove && piece != null)
                  Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoveHistory() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Move History',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                if (moveHistory.isNotEmpty)
                  TextButton.icon(
                    onPressed: _clearHistory,
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: moveHistory.isEmpty
                ? Center(
              child: Text(
                'No moves yet',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            )
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: (moveHistory.length / 2).ceil(),
              itemBuilder: (context, index) {
                final moveNumber = index + 1;
                final whiteMove = moveHistory[index * 2];
                final blackMove = index * 2 + 1 < moveHistory.length
                    ? moveHistory[index * 2 + 1]
                    : null;

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$moveNumber.',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        whiteMove,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (blackMove != null)
                        Text(
                          blackMove,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _undoLastMove() {
    if (moveHistory.isEmpty) return;

    setState(() {
      moveHistory.removeLast();
      _lastMoveSuggestion = null;
      currentBoard = ChessBoard.initial();
      _replayMoves();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Move undone'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _replayMoves() {
    for (final move in moveHistory) {
      final fromCol = move[0].codeUnitAt(0) - 'a'.codeUnitAt(0);
      final fromRow = 8 - int.parse(move[1]);
      final toCol = move[2].codeUnitAt(0) - 'a'.codeUnitAt(0);
      final toRow = 8 - int.parse(move[3]);

      currentBoard.movePiece(
        Position(row : fromRow, col : fromCol),
        Position(row : toRow, col : toCol),
      );
    }
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear the move history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                moveHistory.clear();
                _lastMoveSuggestion = null;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showGameMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('New Game'),
              onTap: () {
                Navigator.pop(context);
                _newGame();
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Open Coach'),
              onTap: () {
                Navigator.pop(context);
                _openCoachScreen();
              },
            ),
            ListTile(
              leading: Icon(
                _coachEnabled ? Icons.visibility_off : Icons.visibility,
              ),
              title: Text(
                _coachEnabled ? 'Disable Coach' : 'Enable Coach',
              ),
              onTap: () {
                setState(() {
                  _coachEnabled = !_coachEnabled;
                  if (!_coachEnabled) {
                    _lastMoveSuggestion = null;
                  }
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('How to Play'),
              onTap: () {
                Navigator.pop(context);
                _showHelpDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _newGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Game'),
        content: const Text('Start a new game? Current game will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                currentBoard = ChessBoard.initial();
                moveHistory.clear();
                selectedPosition = null;
                validMoves = [];
                _lastMoveSuggestion = null;
                _previousBoard = currentBoard.copy();
              });
              Navigator.pop(context);
            },
            child: const Text('New Game'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Play'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Game Controls:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Tap a piece to select it'),
              Text('• Tap a highlighted square to move'),
              Text('• Tap another piece to switch selection'),
              Text('• Use the undo button to take back moves'),
              SizedBox(height: 16),
              Text(
                'AI Coach:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Get real-time feedback on your moves'),
              Text('• View tactical opportunities'),
              Text('• See suggested best moves'),
              Text('• Learn from positional analysis'),
              SizedBox(height: 16),
              Text(
                'Toggle the coach on/off using the eye icon in the toolbar.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: null,
            child: Text('Got it'),
          ),
        ],
      ),
    ).then((_) {
      Navigator.of(context).pop();
    });
  }
}