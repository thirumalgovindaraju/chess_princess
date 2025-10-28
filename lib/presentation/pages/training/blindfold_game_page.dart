// lib/presentation/pages/training/blindfold_game_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'dart:async';
import 'dart:math';

// Import your custom widgets
import '../../../widgets/chess_board_3d_widget.dart';
import '../../../models/chess_board.dart';
import '../../../models/position.dart';

// Training Mode Enum
enum TrainingMode {
  practice,
  timed,
  memory,
  test
}

// Difficulty Level
enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  master
}

// Game Statistics Model
class GameStats {
  int correctMoves = 0;
  int incorrectMoves = 0;
  int hintsUsed = 0;
  int gamesCompleted = 0;
  Duration totalTime = Duration.zero;
  int longestStreak = 0;
  int currentStreak = 0;

  double get accuracy => correctMoves + incorrectMoves > 0
      ? (correctMoves / (correctMoves + incorrectMoves)) * 100
      : 0.0;
}

class BlindfoldGamePage extends ConsumerStatefulWidget {
  const BlindfoldGamePage({Key? key}) : super(key: key);

  @override
  ConsumerState<BlindfoldGamePage> createState() => _BlindfoldGamePageState();
}

class _BlindfoldGamePageState extends ConsumerState<BlindfoldGamePage> with TickerProviderStateMixin {
  late chess_lib.Chess _chess;
  late ChessBoard _customBoard; // Custom board for widget
  final List<String> _moveHistory = [];
  bool _boardVisible = false;
  final TextEditingController _moveController = TextEditingController();
  String? _errorMessage;
  String? _successMessage;

  // Training Features
  TrainingMode _currentMode = TrainingMode.practice;
  DifficultyLevel _difficulty = DifficultyLevel.beginner;
  GameStats _stats = GameStats();

  // Timer
  Timer? _gameTimer;
  Duration _elapsedTime = Duration.zero;
  int _timeLimit = 300; // 5 minutes default

  // Hints and Help
  List<String> _availableHints = [];
  bool _showLastMove = false;
  String _lastMoveHint = '';

  // Memory Training
  bool _isMemoryPhase = false;
  int _memoryTimeLeft = 30;
  Timer? _memoryTimer;

  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  // Educational Content
  final List<Map<String, String>> _tips = [
    {
      'title': 'Visualize the Board',
      'content': 'Start by clearly imagining the 8x8 board. Picture the light and dark squares alternating.'
    },
    {
      'title': 'Track Piece Positions',
      'content': 'Keep a mental map of where all major pieces are. Start with just tracking your pieces, then add opponent pieces.'
    },
    {
      'title': 'Use Coordinates',
      'content': 'Always think in algebraic notation (e.g., e4, Nf3). This helps create a mental coordinate system.'
    },
    {
      'title': 'Replay Recent Moves',
      'content': 'Periodically replay the last 3-5 moves in your mind to maintain accuracy of the position.'
    },
    {
      'title': 'Practice Daily',
      'content': 'Even 10 minutes of daily blindfold training significantly improves visualization skills.'
    },
    {
      'title': 'Start Simple',
      'content': 'Begin with endgame positions (few pieces) before attempting full games.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _chess = chess_lib.Chess();
    _customBoard = ChessBoard.initial();
    _initializeAnimations();
    _startGameTimer();
    _updateAvailableHints();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_chess.game_over && mounted) {
        setState(() {
          _elapsedTime += const Duration(seconds: 1);
          if (_currentMode == TrainingMode.timed &&
              _elapsedTime.inSeconds >= _timeLimit) {
            _endGame(timeout: true);
          }
        });
      }
    });
  }

  void _toggleBoardVisibility() {
    setState(() => _boardVisible = !_boardVisible);
    if (_boardVisible) {
      _stats.hintsUsed++;
    }
  }

  void _syncBoards() {
    // Sync chess_lib.Chess to custom ChessBoard
    final fen = _chess.fen;
    _customBoard = ChessBoard.fromFen(fen);
  }

  void _makeMove() {
    final move = _moveController.text.trim();
    if (move.isEmpty) return;

    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final success = _chess.move(move);
      if (success) {
        _syncBoards(); // Sync boards after move
        setState(() {
          _moveHistory.add(move);
          _moveController.clear();
          _stats.correctMoves++;
          _stats.currentStreak++;
          if (_stats.currentStreak > _stats.longestStreak) {
            _stats.longestStreak = _stats.currentStreak;
          }
          _successMessage = 'Great move! ✓';
          _lastMoveHint = 'Last move: $move';
          _updateAvailableHints();
        });

        // Auto-hide success message
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _successMessage = null);
        });

        // Make computer move
        if (_difficulty != DifficultyLevel.beginner ||
            _currentMode != TrainingMode.practice) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _makeComputerMove();
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid move: $move';
          _stats.incorrectMoves++;
          _stats.currentStreak = 0;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _stats.incorrectMoves++;
        _stats.currentStreak = 0;
      });
    }
  }

  void _makeComputerMove() {
    if (_chess.game_over) return;

    final moves = _chess.moves();
    if (moves.isEmpty) return;

    String selectedMove;

    // AI difficulty based on level
    switch (_difficulty) {
      case DifficultyLevel.beginner:
        selectedMove = moves[Random().nextInt(moves.length)].toString();
        break;
      case DifficultyLevel.intermediate:
        selectedMove = _getIntermediateMove(moves);
        break;
      case DifficultyLevel.advanced:
        selectedMove = _getAdvancedMove(moves);
        break;
      case DifficultyLevel.master:
        selectedMove = _getMasterMove(moves);
        break;
    }

    _chess.move(selectedMove);
    _syncBoards(); // Sync boards after computer move
    setState(() {
      _moveHistory.add(selectedMove);
      _lastMoveHint = 'Opponent played: $selectedMove';
      _updateAvailableHints();
    });
  }

  String _getIntermediateMove(List<dynamic> moves) {
    final moveStrings = moves.map((m) => m.toString()).toList();
    final captures = moveStrings.where((m) => m.contains('x')).toList();
    final checks = moveStrings.where((m) => m.contains('+')).toList();

    if (checks.isNotEmpty && Random().nextBool()) {
      return checks[Random().nextInt(checks.length)];
    }
    if (captures.isNotEmpty && Random().nextBool()) {
      return captures[Random().nextInt(captures.length)];
    }
    return moveStrings[Random().nextInt(moveStrings.length)];
  }

  String _getAdvancedMove(List<dynamic> moves) {
    final moveStrings = moves.map((m) => m.toString()).toList();
    final checks = moveStrings.where((m) => m.contains('+')).toList();
    if (checks.isNotEmpty) {
      return checks[Random().nextInt(checks.length)];
    }

    final captures = moveStrings.where((m) => m.contains('x')).toList();
    if (captures.isNotEmpty && Random().nextDouble() > 0.3) {
      return captures[Random().nextInt(captures.length)];
    }

    return moveStrings[Random().nextInt(moveStrings.length)];
  }

  String _getMasterMove(List<dynamic> moves) {
    final moveStrings = moves.map((m) => m.toString()).toList();
    final checks = moveStrings.where((m) => m.contains('+')).toList();
    if (checks.isNotEmpty) {
      return checks.first;
    }

    final captures = moveStrings.where((m) => m.contains('x')).toList();
    if (captures.isNotEmpty) {
      return captures.first;
    }

    return moveStrings[Random().nextInt(min(3, moveStrings.length))];
  }

  void _updateAvailableHints() {
    _availableHints.clear();

    _availableHints.add(
        _chess.turn == chess_lib.Color.WHITE ? 'White to move' : 'Black to move'
    );

    if (_chess.in_check) {
      _availableHints.add('You are in check!');
    }

    final legalMoves = _chess.moves();
    _availableHints.add('${legalMoves.length} legal moves available');

    final fen = _chess.fen;
    final position = fen.split(' ')[0];
    final whitePieces = position.replaceAll(RegExp(r'[^PNBRQK]'), '').length;
    final blackPieces = position.replaceAll(RegExp(r'[^pnbrqk]'), '').length;
    _availableHints.add('Pieces: White $whitePieces, Black $blackPieces');
  }

  void _showHint(int index) {
    if (index < _availableHints.length) {
      _stats.hintsUsed++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_availableHints[index]),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.blue.shade700,
        ),
      );
    }
  }

  void _showPossibleMoves() {
    final moves = _chess.moves();
    final movesPreview = moves.take(5).join(', ');
    _stats.hintsUsed++;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Available Moves (first 5)'),
        content: Text(movesPreview + (moves.length > 5 ? '...' : '')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _chess.reset();
      _customBoard = ChessBoard.initial();
      _moveHistory.clear();
      _errorMessage = null;
      _successMessage = null;
      _moveController.clear();
      _elapsedTime = Duration.zero;
      _lastMoveHint = '';
      _updateAvailableHints();
    });
    _startGameTimer();
  }

  void _endGame({bool timeout = false}) {
    _gameTimer?.cancel();
    _stats.gamesCompleted++;
    _stats.totalTime += _elapsedTime;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(timeout ? '⏰ Time\'s Up!' : '🎉 Game Complete!'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('Moves Played', '${_moveHistory.length}'),
              _buildStatRow('Correct Moves', '${_stats.correctMoves}'),
              _buildStatRow('Incorrect Moves', '${_stats.incorrectMoves}'),
              _buildStatRow('Accuracy', '${_stats.accuracy.toStringAsFixed(1)}%'),
              _buildStatRow('Hints Used', '${_stats.hintsUsed}'),
              _buildStatRow('Time', _formatDuration(_elapsedTime)),
              _buildStatRow('Longest Streak', '${_stats.longestStreak}'),
              const SizedBox(height: 16),
              _buildPerformanceMessage(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('New Game'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPerformanceMessage() {
    final accuracy = _stats.accuracy;
    String message;
    Color color;

    if (accuracy >= 90) {
      message = '🏆 Outstanding! You\'re a blindfold master!';
      color = Colors.green;
    } else if (accuracy >= 75) {
      message = '⭐ Excellent work! Keep practicing!';
      color = Colors.blue;
    } else if (accuracy >= 60) {
      message = '👍 Good effort! You\'re improving!';
      color = Colors.orange;
    } else {
      message = '💪 Keep training! Practice makes perfect!';
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        message,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _startMemoryTraining() {
    setState(() {
      _isMemoryPhase = true;
      _memoryTimeLeft = 30;
      _boardVisible = true;
    });

    _memoryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _memoryTimeLeft--;
        if (_memoryTimeLeft <= 0) {
          _memoryTimer?.cancel();
          _boardVisible = false;
          _isMemoryPhase = false;
        }
      });
    });
  }

  void _showTutorial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎓 Blindfold Chess Tutorial'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How to Train:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ..._tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ${tip['title']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip['content']!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blindfold Chess Trainer'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.school),
            onPressed: _showTutorial,
            tooltip: 'Tutorial',
          ),
          PopupMenuButton<TrainingMode>(
            icon: const Icon(Icons.fitness_center),
            tooltip: 'Training Mode',
            onSelected: (mode) {
              setState(() => _currentMode = mode);
              _resetGame();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TrainingMode.practice,
                child: Text('Practice Mode'),
              ),
              const PopupMenuItem(
                value: TrainingMode.timed,
                child: Text('Timed Challenge'),
              ),
              const PopupMenuItem(
                value: TrainingMode.memory,
                child: Text('Memory Training'),
              ),
              const PopupMenuItem(
                value: TrainingMode.test,
                child: Text('Test Mode'),
              ),
            ],
          ),
          PopupMenuButton<DifficultyLevel>(
            icon: const Icon(Icons.tune),
            tooltip: 'Difficulty',
            onSelected: (level) {
              setState(() => _difficulty = level);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: DifficultyLevel.beginner,
                child: Text('Beginner'),
              ),
              const PopupMenuItem(
                value: DifficultyLevel.intermediate,
                child: Text('Intermediate'),
              ),
              const PopupMenuItem(
                value: DifficultyLevel.advanced,
                child: Text('Advanced'),
              ),
              const PopupMenuItem(
                value: DifficultyLevel.master,
                child: Text('Master'),
              ),
            ],
          ),
          IconButton(
            icon: Icon(_boardVisible ? Icons.visibility_off : Icons.visibility),
            onPressed: _toggleBoardVisibility,
            tooltip: 'Toggle Board',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
            tooltip: 'New Game',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Bar
          _buildStatusBar(),

          // Main Content Area
          if (_boardVisible)
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
                  margin: const EdgeInsets.all(16),
                  child: ChessBoard3DWidget(
                    board: _customBoard,
                    isInteractive: false, // Read-only for blindfold training
                    showCoordinates: true,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.grey.shade900, Colors.grey.shade800],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeTransition(
                        opacity: _pulseController,
                        child: Icon(
                          Icons.visibility_off,
                          size: 80,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Visualize the position',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Move ${_moveHistory.length ~/ 2 + 1}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (_lastMoveHint.isNotEmpty && _showLastMove)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _lastMoveHint,
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          // Control Panel
          _buildControlPanel(),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatusChip(
            icon: Icons.timer,
            label: _formatDuration(_elapsedTime),
            color: Colors.blue,
          ),
          _buildStatusChip(
            icon: Icons.check_circle,
            label: '${_stats.correctMoves}',
            color: Colors.green,
          ),
          _buildStatusChip(
            icon: Icons.cancel,
            label: '${_stats.incorrectMoves}',
            color: Colors.red,
          ),
          _buildStatusChip(
            icon: Icons.lightbulb,
            label: '${_stats.hintsUsed}',
            color: Colors.orange,
          ),
          _buildStatusChip(
            icon: Icons.local_fire_department,
            label: '${_stats.currentStreak}',
            color: Colors.deepOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Move History',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _chess.in_checkmate
                      ? Colors.red.shade100
                      : _chess.in_check
                      ? Colors.orange.shade100
                      : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _chess.in_checkmate
                      ? 'Checkmate!'
                      : _chess.in_check
                      ? 'Check!'
                      : _chess.turn == chess_lib.Color.WHITE
                      ? 'White to move'
                      : 'Black to move',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _chess.in_checkmate || _chess.in_check
                        ? Colors.red.shade900
                        : Colors.green.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 80,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              child: Text(
                _moveHistory.isEmpty
                    ? 'No moves yet'
                    : _formatMoveHistory(_moveHistory),
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ),

          // Hints Section
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildHintButton('Turn', () => _showHint(0)),
                _buildHintButton('Legal Moves', () => _showHint(2)),
                _buildHintButton('Pieces', () => _showHint(3)),
                _buildHintButton('Show Moves', _showPossibleMoves),
                _buildHintButton(
                  _showLastMove ? 'Hide Last' : 'Show Last',
                      () => setState(() => _showLastMove = !_showLastMove),
                ),
              ],
            ),
          ),

          if (_successMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: TextStyle(color: Colors.green.shade700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _moveController,
                  enabled: !_chess.game_over,
                  decoration: InputDecoration(
                    labelText: 'Enter move (e.g., e4, Nf3, O-O)',
                    hintText: 'Type your move',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.edit),
                  ),
                  onSubmitted: (_) => _makeMove(),
                  textCapitalization: TextCapitalization.none,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _chess.game_over ? null : _makeMove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Icon(Icons.send, size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHintButton(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.lightbulb_outline, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade50,
          foregroundColor: Colors.blue.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }

  String _formatMoveHistory(List<String> moves) {
    if (moves.isEmpty) return 'No moves yet';

    final buffer = StringBuffer();
    for (int i = 0; i < moves.length; i += 2) {
      final moveNumber = (i ~/ 2) + 1;
      final whiteMove = moves[i];
      final blackMove = i + 1 < moves.length ? moves[i + 1] : '';

      buffer.write('$moveNumber. $whiteMove');
      if (blackMove.isNotEmpty) {
        buffer.write(' $blackMove');
      }
      if (i + 2 < moves.length) {
        buffer.write('  ');
      }
    }

    return buffer.toString();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _memoryTimer?.cancel();
    _pulseController.dispose();
    _fadeController.dispose();
    _moveController.dispose();
    super.dispose();
  }
}