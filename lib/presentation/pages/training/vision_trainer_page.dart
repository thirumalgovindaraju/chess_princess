// lib/presentation/pages/training/vision_trainer_page.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'package:chess_princess/widgets/chess_board_widget.dart';
import 'package:chess_princess/presentation/pages/training/vision_trainer_provider.dart';
import 'package:chess_princess/domain/services/xp_service.dart';
import '../../widgets/level_up_dialog.dart';

class VisionTrainerPage extends ConsumerStatefulWidget {
  const VisionTrainerPage({Key? key}) : super(key: key);

  @override
  ConsumerState<VisionTrainerPage> createState() => _VisionTrainerPageState();
}

class _VisionTrainerPageState extends ConsumerState<VisionTrainerPage>
    with TickerProviderStateMixin {
  String _currentFen = '';
  String _userFen = '';
  bool _boardHidden = false;
  bool _showingAnswer = false;
  bool _isPlacingMode = false;
  Timer? _hideTimer;
  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  final Random _random = Random();

  // For piece placement
  String? _selectedPieceType;
  bool _isWhitePiece = true;

  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateNewPosition();
    });
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _countdownTimer?.cancel();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _generateNewPosition() {
    if (!mounted) return;

    final state = ref.read(visionTrainerProvider);
    final difficulty = state.currentDifficulty;

    final chess = chess_lib.Chess();
    final pieceCount = 4 + (difficulty * 2);
    final pieces = ['p', 'n', 'b', 'r', 'q'];

    chess.clear();

    // Helper function to generate random square
    String getRandomSquare() {
      final file = _random.nextInt(8);
      final rank = _random.nextInt(8);
      return '${String.fromCharCode(97 + file)}${rank + 1}';
    }

    // Add kings at random positions (ensure they're not adjacent)
    String? whiteKingSquare;
    String? blackKingSquare;

    int attempts = 0;
    while (attempts < 100) {
      whiteKingSquare = getRandomSquare();
      blackKingSquare = getRandomSquare();

      // Ensure kings are not on the same square and not adjacent
      if (whiteKingSquare != blackKingSquare && !_areSquaresAdjacent(whiteKingSquare, blackKingSquare)) {
        break;
      }
      attempts++;
    }

    // Place the kings
    chess.put(
      chess_lib.Piece(chess_lib.PieceType.KING, chess_lib.Color.WHITE),
      whiteKingSquare!,
    );
    chess.put(
      chess_lib.Piece(chess_lib.PieceType.KING, chess_lib.Color.BLACK),
      blackKingSquare!,
    );

    // Add random pieces
    int added = 2; // Already added 2 kings
    attempts = 0;
    while (added < pieceCount && attempts < 100) {
      final square = getRandomSquare();

      if (chess.get(square) == null) {
        final pieceType = pieces[_random.nextInt(pieces.length)];
        final isWhite = _random.nextBool();

        chess_lib.PieceType type;
        switch (pieceType) {
          case 'p':
          // Get rank from square (e.g., 'e4' -> rank is 4)
            final rank = int.parse(square[1]);
            if (rank == 1 || rank == 8) {
              attempts++;
              continue;
            }
            type = chess_lib.PieceType.PAWN;
            break;
          case 'n':
            type = chess_lib.PieceType.KNIGHT;
            break;
          case 'b':
            type = chess_lib.PieceType.BISHOP;
            break;
          case 'r':
            type = chess_lib.PieceType.ROOK;
            break;
          case 'q':
            type = chess_lib.PieceType.QUEEN;
            break;
          default:
            attempts++;
            continue;
        }

        chess.put(
          chess_lib.Piece(
            type,
            isWhite ? chess_lib.Color.WHITE : chess_lib.Color.BLACK,
          ),
          square,
        );
        added++;
      }
      attempts++;
    }

    setState(() {
      _currentFen = chess.fen;
      _userFen = '';
      _boardHidden = false;
      _showingAnswer = false;
      _isPlacingMode = false;
      _selectedPieceType = null;
    });

    _fadeController.forward(from: 0.0);
    _startMemorizationPhase();
  }
  bool _areSquaresAdjacent(String square1, String square2) {
    final file1 = square1.codeUnitAt(0) - 97; // 'a' = 0, 'b' = 1, etc.
    final rank1 = int.parse(square1[1]) - 1; // Convert to 0-indexed
    final file2 = square2.codeUnitAt(0) - 97;
    final rank2 = int.parse(square2[1]) - 1;

    final fileDiff = (file1 - file2).abs();
    final rankDiff = (rank1 - rank2).abs();

    // Kings are adjacent if they're within 1 square in any direction
    return fileDiff <= 1 && rankDiff <= 1;
  }

  void _startMemorizationPhase() {
    final state = ref.read(visionTrainerProvider);
    final memorizationSeconds = 30 - (state.currentDifficulty * 3);

    setState(() {
      _remainingSeconds = memorizationSeconds;
      _boardHidden = false;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        _hideBoard();
      }
    });
  }

  void _hideBoard() {
    setState(() {
      _boardHidden = true;
    });
    _countdownTimer?.cancel();
  }

  void _startPlacingMode() {
    // Use the same king positions from the current position
    final originalChess = chess_lib.Chess.fromFEN(_currentFen);

    final chess = chess_lib.Chess();
    chess.clear();

    // Find and place the kings from the original position
    for (var file = 0; file < 8; file++) {
      for (var rank = 0; rank < 8; rank++) {
        final square = '${String.fromCharCode(97 + file)}${rank + 1}';
        final piece = originalChess.get(square);

        if (piece != null && piece.type == chess_lib.PieceType.KING) {
          chess.put(piece, square);
        }
      }
    }

    setState(() {
      _userFen = chess.fen;
      _isPlacingMode = true;
      _boardHidden = false;
      _selectedPieceType = null;
    });
  }
/*
  void _onSquareTapped(String square) {
    if (!_isPlacingMode || _selectedPieceType == null) return;

    final chess = chess_lib.Chess.fromFEN(_userFen);

    // Remove piece if clicking on existing piece
    if (chess.get(square) != null) {
      chess.remove(square);
    } else {
      // Add selected piece
      chess_lib.PieceType type;
      switch (_selectedPieceType!) {
        case 'p':
          type = chess_lib.PieceType.PAWN;
          break;
        case 'n':
          type = chess_lib.PieceType.KNIGHT;
          break;
        case 'b':
          type = chess_lib.PieceType.BISHOP;
          break;
        case 'r':
          type = chess_lib.PieceType.ROOK;
          break;
        case 'q':
          type = chess_lib.PieceType.QUEEN;
          break;
        default:
          return;
      }

      chess.put(
        chess_lib.Piece(
          type,
          _isWhitePiece ? chess_lib.Color.WHITE : chess_lib.Color.BLACK,
        ),
        square,
      );
    }

    setState(() {
      _userFen = chess.fen;
    });
  }
*/

  void _onSquareTapped(String square) {
    if (!_isPlacingMode) return;

    final chess = chess_lib.Chess.fromFEN(_userFen);
    final existingPiece = chess.get(square);

    // If no piece is selected, do nothing
    if (_selectedPieceType == null && existingPiece == null) {
      // Show a hint to select a piece first
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a piece type first'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Don't allow removing or placing pieces on king squares
    if (existingPiece != null && existingPiece.type == chess_lib.PieceType.KING) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cannot remove or replace kings'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // If clicking on an existing piece (that's not a king)
    if (existingPiece != null) {
      // If a piece type is selected, replace the piece
      if (_selectedPieceType != null) {
        chess.remove(square);

        chess_lib.PieceType type;
        switch (_selectedPieceType!) {
          case 'p':
          // Prevent placing pawns on first or last rank
            final rank = int.parse(square[1]);
            if (rank == 1 || rank == 8) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cannot place pawns on first or last rank'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            type = chess_lib.PieceType.PAWN;
            break;
          case 'n':
            type = chess_lib.PieceType.KNIGHT;
            break;
          case 'b':
            type = chess_lib.PieceType.BISHOP;
            break;
          case 'r':
            type = chess_lib.PieceType.ROOK;
            break;
          case 'q':
            type = chess_lib.PieceType.QUEEN;
            break;
          default:
            return;
        }

        chess.put(
          chess_lib.Piece(
            type,
            _isWhitePiece ? chess_lib.Color.WHITE : chess_lib.Color.BLACK,
          ),
          square,
        );
      } else {
        // If no piece selected, just remove the existing piece
        chess.remove(square);
      }
    } else {
      // Empty square - place the selected piece
      if (_selectedPieceType == null) return;

      chess_lib.PieceType type;
      switch (_selectedPieceType!) {
        case 'p':
        // Prevent placing pawns on first or last rank
          final rank = int.parse(square[1]);
          if (rank == 1 || rank == 8) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Cannot place pawns on first or last rank'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          type = chess_lib.PieceType.PAWN;
          break;
        case 'n':
          type = chess_lib.PieceType.KNIGHT;
          break;
        case 'b':
          type = chess_lib.PieceType.BISHOP;
          break;
        case 'r':
          type = chess_lib.PieceType.ROOK;
          break;
        case 'q':
          type = chess_lib.PieceType.QUEEN;
          break;
        default:
          return;
      }

      chess.put(
        chess_lib.Piece(
          type,
          _isWhitePiece ? chess_lib.Color.WHITE : chess_lib.Color.BLACK,
        ),
        square,
      );
    }

    setState(() {
      _userFen = chess.fen;
    });
  }

  int _comparePositions() {
    final originalChess = chess_lib.Chess.fromFEN(_currentFen);
    final userChess = chess_lib.Chess.fromFEN(_userFen);

    int correctPieces = 0;
    int totalPieces = 0;

    // Count pieces in original position (excluding kings)
    for (var file = 0; file < 8; file++) {
      for (var rank = 0; rank < 8; rank++) {
        final square = '${String.fromCharCode(97 + file)}${rank + 1}';
        final originalPiece = originalChess.get(square);

        if (originalPiece != null && originalPiece.type != chess_lib.PieceType.KING) {
          totalPieces++;
          final userPiece = userChess.get(square);

          if (userPiece != null &&
              userPiece.type == originalPiece.type &&
              userPiece.color == originalPiece.color) {
            correctPieces++;
          }
        }
      }
    }

    return totalPieces > 0 ? ((correctPieces / totalPieces) * 100).round() : 0;
  }

  Future<void> _checkAnswer() async {
    if (!mounted) return;

    final accuracy = _comparePositions();
    final isCorrect = accuracy >= 80; // 80% or more is considered correct

    ref.read(visionTrainerProvider.notifier).recordAttempt(isCorrect: isCorrect);

    final currentXP = await XPService.getXP();
    final oldLevel = XPService.getLevelFromXP(currentXP);

    if (isCorrect) {
      ref.read(visionTrainerProvider.notifier).updateScore(10);
      await XPService.addXP(20);
    } else {
      await XPService.addXP(5);
    }

    final newXP = await XPService.getXP();
    final newLevel = XPService.getLevelFromXP(newXP);

    if (mounted && newLevel > oldLevel) {
      await showDialog(
        context: context,
        builder: (_) => LevelUpDialog(level: newLevel),
      );
    }

    if (mounted) {
      _showResultDialog(isCorrect, accuracy);
    }
  }

  Future<void> _onAnswerSubmit(bool isCorrect) async {
    if (!mounted) return;

    ref.read(visionTrainerProvider.notifier).recordAttempt(isCorrect: isCorrect);

    final currentXP = await XPService.getXP();
    final oldLevel = XPService.getLevelFromXP(currentXP);

    if (isCorrect) {
      ref.read(visionTrainerProvider.notifier).updateScore(10);
      await XPService.addXP(20);
    } else {
      await XPService.addXP(5);
    }

    final newXP = await XPService.getXP();
    final newLevel = XPService.getLevelFromXP(newXP);

    if (mounted && newLevel > oldLevel) {
      await showDialog(
        context: context,
        builder: (_) => LevelUpDialog(level: newLevel),
      );
    }

    if (mounted) {
      _showResultDialog(isCorrect, 100);
    }
  }

  void _showResultDialog(bool isCorrect, int accuracy) {
    final state = ref.read(visionTrainerProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isCorrect
                      ? [Colors.green.shade50, Colors.green.shade100]
                      : [Colors.orange.shade50, Colors.orange.shade100],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isCorrect
                            ? [Colors.green.shade400, Colors.green.shade600]
                            : [Colors.orange.shade400, Colors.orange.shade600],
                      ),
                    ),
                    child: Icon(
                      isCorrect ? Icons.check_circle : Icons.lightbulb_outline,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    isCorrect ? '🎉 Excellent!' : '💡 Keep Practicing!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green.shade800 : Colors.orange.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    _isPlacingMode ? 'Accuracy: $accuracy%' : (isCorrect ? 'Great memory!' : 'Every attempt helps!'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactStatCard(
                          'Score',
                          state.score.toString(),
                          Icons.stars,
                          Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCompactStatCard(
                          'Accuracy',
                          '${(ref.read(visionTrainerProvider.notifier).getAccuracy() * 100).toStringAsFixed(0)}%',
                          Icons.trending_up,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _generateNewPosition();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCorrect ? Colors.green.shade600 : Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Next Challenge',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
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
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trainerState = ref.watch(visionTrainerProvider);
    final accuracy = trainerState.getAccuracy();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Vision Trainer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(visionTrainerProvider.notifier).reset();
              _generateNewPosition();
            },
            tooltip: 'Reset Progress',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showHowToPlayDialog(),
            tooltip: 'How to Play',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.deepPurple,
                    Colors.deepPurple.shade300,
                  ],
                ),
              ),
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTopStatCard(
                            icon: Icons.stars,
                            label: 'Score',
                            value: trainerState.score.toString(),
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTopStatCard(
                            icon: Icons.percent_rounded,
                            label: 'Accuracy',
                            value: '${(accuracy * 100).toStringAsFixed(0)}%',
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTopStatCard(
                            icon: Icons.trending_up,
                            label: 'Level',
                            value: trainerState.currentDifficulty.toString(),
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (!_boardHidden && !_isPlacingMode) _buildInstructionsCard(),
                  if (!_boardHidden && !_isPlacingMode) const SizedBox(height: 20),

                  if (!_boardHidden && _remainingSeconds > 0 && !_isPlacingMode)
                    _buildCountdownTimer(),
                  if (!_boardHidden && _remainingSeconds > 0 && !_isPlacingMode)
                    const SizedBox(height: 12),

                  // Skip button during countdown
                  if (!_boardHidden && _remainingSeconds > 0 && !_isPlacingMode)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _countdownTimer?.cancel();
                          _hideBoard();
                        },
                        icon: const Icon(Icons.skip_next, size: 24),
                        label: const Text(
                          'Skip Timer',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          side: BorderSide(color: Colors.deepPurple.shade300, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                  if (!_boardHidden && _remainingSeconds > 0 && !_isPlacingMode)
                    const SizedBox(height: 20),

                  _buildChessBoard(),

                  const SizedBox(height: 24),

                  if (_isPlacingMode) _buildPiecePicker(),
                  if (_isPlacingMode) const SizedBox(height: 16),

                  if (_boardHidden && !_showingAnswer && !_isPlacingMode)
                    _buildActionButtons(),

                  if (_isPlacingMode) _buildPlacingModeButtons(),

                  if (_showingAnswer && !_isPlacingMode) _buildContinueButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.shade300, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.psychology, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text('How to Play', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 16),
            _buildInstructionStep('1', 'Memorize the position', Icons.visibility),
            const SizedBox(height: 8),
            _buildInstructionStep('2', 'Board hides after countdown', Icons.timer),
            const SizedBox(height: 8),
            _buildInstructionStep('3', 'Reconstruct or recall', Icons.psychology_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: Colors.blue.shade700, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 15, color: Colors.grey.shade800)),
        ),
      ],
    );
  }

  Widget _buildCountdownTimer() {
    final isUrgent = _remainingSeconds <= 5;
    return ScaleTransition(
      scale: isUrgent ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isUrgent
                ? [Colors.red.shade400, Colors.red.shade600]
                : [Colors.green.shade400, Colors.green.shade600],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isUrgent ? Icons.warning_amber_rounded : Icons.timer_outlined, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text('$_remainingSeconds', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(width: 8),
            const Text('seconds', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildChessBoard() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: 4,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _boardHidden && !_showingAnswer && !_isPlacingMode
                  ? _buildHiddenBoard()
                  : _buildVisibleBoard(),
            ),
          ),
        ),
      ),
    );
  }
/*
  Widget _buildVisibleBoard() {
    final fenToShow = _isPlacingMode ? _userFen : _currentFen;

    if (_isPlacingMode) {
      return GestureDetector(
        onTapDown: (details) {
          final RenderBox? box = context.findRenderObject() as RenderBox?;
          if (box == null) return;

          // Get the widget's size
          final size = box.size;

          // Account for the ChessBoardWidget's border (8px on each side based on your widget)
          const borderWidth = 8.0;
          final boardSize = size.width - (borderWidth * 2);
          final squareSize = boardSize / 8;

          // Adjust for border offset
          final localX = details.localPosition.dx - borderWidth;
          final localY = details.localPosition.dy - borderWidth;

          // Calculate which square was tapped
          final col = (localX / squareSize).floor();
          final row = (localY / squareSize).floor();

          print('Tap at: ($localX, $localY) -> Square: col=$col, row=$row');

          if (col >= 0 && col < 8 && row >= 0 && row < 8) {
            final square = '${String.fromCharCode(97 + col)}${8 - row}';
            print('Tapped square: $square');
            _onSquareTapped(square);
          }
        },
        child: ChessBoardWidget(
          fen: fenToShow,
          isInteractive: false,
          showCoordinates: true,
        ),
      );
    }

    return ChessBoardWidget(
      fen: fenToShow,
      isInteractive: false,
      showCoordinates: true,
    );
  }
*/

  Widget _buildVisibleBoard() {
    final fenToShow = _isPlacingMode ? _userFen : _currentFen;

    if (_isPlacingMode) {
      // Use a GlobalKey to get the correct render box
      final boardKey = GlobalKey();

      return GestureDetector(
        key: boardKey,
        onTapUp: (details) {
          final RenderBox? box = boardKey.currentContext?.findRenderObject() as RenderBox?;
          if (box == null) return;

          // Get tap position relative to the board widget
          final localPosition = box.globalToLocal(details.globalPosition);

          // Get the widget's size
          final size = box.size;

          // Account for the ChessBoardWidget's border (8px on each side)
          const borderWidth = 8.0;
          final boardSize = size.width - (borderWidth * 2);
          final squareSize = boardSize / 8;

          // Adjust for border offset
          final localX = localPosition.dx - borderWidth;
          final localY = localPosition.dy - borderWidth;

          // Calculate which square was tapped
          final col = (localX / squareSize).floor();
          final row = (localY / squareSize).floor();

          // Validate the square is within bounds
          if (col >= 0 && col < 8 && row >= 0 && row < 8) {
            final square = '${String.fromCharCode(97 + col)}${8 - row}';
            _onSquareTapped(square);
          }
        },
        child: ChessBoardWidget(
          fen: fenToShow,
          isInteractive: false,
          showCoordinates: true,
        ),
      );
    }

    return ChessBoardWidget(
      fen: fenToShow,
      isInteractive: false,
      showCoordinates: true,
    );
  }


  Widget _buildHiddenBoard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade800, Colors.grey.shade900],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility_off_rounded, size: 80, color: Colors.grey.shade600),
            const SizedBox(height: 24),
            Text('Position Hidden', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
            const SizedBox(height: 12),
            Text('Can you remember it?', style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
/*
  Widget _buildPiecePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Color: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('White'),
                selected: _isWhitePiece,
                onSelected: (selected) {
                  setState(() => _isWhitePiece = true);
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Black'),
                selected: !_isWhitePiece,
                onSelected: (selected) {
                  setState(() => _isWhitePiece = false);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Select Piece:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPieceButton('♟', 'p'),
              _buildPieceButton('♞', 'n'),
              _buildPieceButton('♝', 'b'),
              _buildPieceButton('♜', 'r'),
              _buildPieceButton('♛', 'q'),
            ],
          ),
        ],
      ),
    );
  }
*/

  Widget _buildPiecePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Color: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('White'),
                selected: _isWhitePiece,
                onSelected: (selected) {
                  setState(() => _isWhitePiece = true);
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Black'),
                selected: !_isWhitePiece,
                onSelected: (selected) {
                  setState(() => _isWhitePiece = false);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Select Piece:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPieceButton('♟', 'p'),
              _buildPieceButton('♞', 'n'),
              _buildPieceButton('♝', 'b'),
              _buildPieceButton('♜', 'r'),
              _buildPieceButton('♛', 'q'),
            ],
          ),
          const SizedBox(height: 12),
          // Add a helper text
          Text(
            _selectedPieceType == null
                ? 'Tap a piece to select, then tap the board to place'
                : 'Tap the board to place ${_getPieceName(_selectedPieceType!)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

// Helper method to get piece name
  String _getPieceName(String pieceType) {
    switch (pieceType) {
      case 'p': return 'Pawn';
      case 'n': return 'Knight';
      case 'b': return 'Bishop';
      case 'r': return 'Rook';
      case 'q': return 'Queen';
      default: return 'piece';
    }
  }

  Widget _buildPieceButton(String symbol, String pieceType) {
    final isSelected = _selectedPieceType == pieceType;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPieceType = pieceType;
        });
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            symbol,
            style: TextStyle(
              fontSize: 32,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlacingModeButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _checkAnswer,
                  icon: const Icon(Icons.check_circle, size: 24),
                  label: const Text(
                    'Check Answer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showingAnswer = true;
                      _isPlacingMode = false;
                    });
                  },
                  icon: const Icon(Icons.visibility, size: 24),
                  label: const Text(
                    'Show Answer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: BorderSide(color: Colors.deepPurple.shade300, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              final chess = chess_lib.Chess();
              chess.clear();
              chess.put(
                chess_lib.Piece(chess_lib.PieceType.KING, chess_lib.Color.WHITE),
                'e1',
              );
              chess.put(
                chess_lib.Piece(chess_lib.PieceType.KING, chess_lib.Color.BLACK),
                'e8',
              );
              setState(() {
                _userFen = chess.fen;
              });
            },
            icon: const Icon(Icons.refresh, size: 24),
            label: const Text(
              'Clear Board',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: BorderSide(color: Colors.orange.shade300, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () => _onAnswerSubmit(true),
            icon: const Icon(Icons.check_circle, size: 28),
            label: const Text(
              'I Remember It!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: Colors.green.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: _startPlacingMode,
            icon: const Icon(Icons.dashboard_customize, size: 28),
            label: const Text(
              'Place Pieces',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: Colors.blue.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () => _onAnswerSubmit(false),
            icon: const Icon(Icons.highlight_off, size: 28),
            label: const Text(
              'I Forgot',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: Colors.orange.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _showingAnswer = true;
                _boardHidden = false;
              });
            },
            icon: const Icon(Icons.visibility, size: 28),
            label: const Text(
              'Show Answer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.deepPurple,
              side: BorderSide(color: Colors.deepPurple.shade300, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () => _onAnswerSubmit(false),
        icon: const Icon(Icons.arrow_forward, size: 28),
        label: const Text(
          'Continue',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: Colors.deepPurple.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  void _showHowToPlayDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.deepPurple.shade50, Colors.purple.shade50],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade400, Colors.purple.shade600],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              const Text('How to Play', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildDialogTip('👀', 'Study the chess position carefully'),
              _buildDialogTip('⏱️', 'Board hides after countdown'),
              _buildDialogTip('🧠', 'Choose: Remember, Place Pieces, or Give Up'),
              _buildDialogTip('🎯', 'Place Pieces mode: Reconstruct position'),
              _buildDialogTip('⭐', 'Earn points for correct answers'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Got It!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTip(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade800, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}