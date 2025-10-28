// lib/presentation/pages/training/check_detection_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'dart:math';

class CheckDetectionPage extends ConsumerStatefulWidget {
  const CheckDetectionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CheckDetectionPage> createState() => _CheckDetectionPageState();
}

class _CheckDetectionPageState extends ConsumerState<CheckDetectionPage> {
  late chess_lib.Chess _chess;
  bool _hasCheck = false;
  int _score = 0;
  int _streak = 0;
  int _timeLimit = 10;
  int _remainingTime = 10;
  Timer? _countdownTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generatePosition();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _generatePosition() {
    _chess = chess_lib.Chess();

    // 50% chance of generating a position with check
    _hasCheck = _random.nextBool();

    if (_hasCheck) {
      _createCheckPosition();
    } else {
      _createNormalPosition();
    }

    setState(() {
      _remainingTime = _timeLimit;
    });

    _startCountdown();
  }

  void _createCheckPosition() {
    _chess.clear();

    // Add white king
    _chess.put(
      chess_lib.Piece(chess_lib.PieceType.KING, chess_lib.Color.WHITE),
      'e1',
    );

    // Add black king
    _chess.put(
      chess_lib.Piece(chess_lib.PieceType.KING, chess_lib.Color.BLACK),
      'e8',
    );

    // Add a piece that gives check
    final checkSquares = ['d2', 'f2', 'd1', 'f1'];
    final square = checkSquares[_random.nextInt(checkSquares.length)];

    _chess.put(
      chess_lib.Piece(chess_lib.PieceType.ROOK, chess_lib.Color.BLACK),
      square,
    );
  }

  void _createNormalPosition() {
    _chess.clear();

    // Add kings
    _chess.put(
      chess_lib.Piece(chess_lib.PieceType.KING, chess_lib.Color.WHITE),
      'e1',
    );
    _chess.put(
      chess_lib.Piece(chess_lib.PieceType.KING, chess_lib.Color.BLACK),
      'e8',
    );

    // Add some random pieces
    final pieces = [
      chess_lib.PieceType.PAWN,
      chess_lib.PieceType.KNIGHT,
      chess_lib.PieceType.BISHOP,
      chess_lib.PieceType.ROOK,
      chess_lib.PieceType.QUEEN,
    ];

    for (int i = 0; i < 4; i++) {
      final piece = pieces[_random.nextInt(pieces.length)];
      final color = _random.nextBool() ? chess_lib.Color.WHITE : chess_lib.Color.BLACK;

      // Find a random empty square
      String? square;
      for (int attempt = 0; attempt < 20; attempt++) {
        final file = _random.nextInt(8);
        final rank = _random.nextInt(8) + 1;
        square = '${String.fromCharCode(97 + file)}$rank';

        if (_chess.get(square) == null) {
          _chess.put(chess_lib.Piece(piece, color), square);

          // Make sure we didn't accidentally create a check
          if (_chess.in_check) {
            _chess.remove(square);
            continue;
          }
          break;
        }
      }
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          timer.cancel();
          _showTimeoutDialog();
        }
      });
    });
  }

  void _submitAnswer(bool userAnswer) {
    _countdownTimer?.cancel();

    final isCorrect = userAnswer == _hasCheck;

    setState(() {
      if (isCorrect) {
        _score += 15 + (_remainingTime * 2); // Bonus for speed
        _streak++;
      } else {
        _streak = 0;
      }
    });

    _showFeedbackDialog(isCorrect);
  }

  void _showFeedbackDialog(bool isCorrect) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        title: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              isCorrect ? 'Correct!' : 'Incorrect',
              style: TextStyle(
                color: isCorrect ? Colors.green.shade900 : Colors.red.shade900,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _hasCheck
                  ? 'There was a check in this position!'
                  : 'There was NO check in this position.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (isCorrect)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'Speed bonus: ${_remainingTime * 2} pts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _generatePosition();
            },
            child: Text(
              'Next Position',
              style: TextStyle(
                color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.orange.shade50,
        title: Row(
          children: [
            Icon(Icons.timer_off, color: Colors.orange.shade700, size: 32),
            const SizedBox(width: 12),
            Text(
              'Time\'s Up!',
              style: TextStyle(color: Colors.orange.shade900),
            ),
          ],
        ),
        content: Text(
          'The correct answer was: ${_hasCheck ? "CHECK" : "NO CHECK"}',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _streak = 0);
              _generatePosition();
            },
            child: Text(
              'Continue',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Detection'),
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade400, Colors.amber.shade600],
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('Score', '$_score', Icons.stars),
                    _buildStatColumn('Streak', '$_streak', Icons.local_fire_department),
                    _buildStatColumn('Time', '$_remainingTime', Icons.timer),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Is there a check in this position?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _buildChessBoard(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _submitAnswer(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.check_circle, size: 32),
                              SizedBox(height: 8),
                              Text(
                                'YES',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _submitAnswer(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.cancel, size: 32),
                              SizedBox(height: 8),
                              Text(
                                'NO',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
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
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
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
        final rank = 8 - (index ~/ 8);
        final file = index % 8;
        final square = '${String.fromCharCode(97 + file)}$rank';
        final isLight = (rank + file) % 2 == 0;
        final piece = _chess.get(square);

        return Container(
          decoration: BoxDecoration(
            color: isLight ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
          child: Center(
            child: piece != null
                ? Text(
              _getPieceSymbol(piece),
              style: const TextStyle(fontSize: 40),
            )
                : null,
          ),
        );
      },
    );
  }

  String _getPieceSymbol(chess_lib.Piece piece) {
    final symbols = {
      'p': piece.color == chess_lib.Color.WHITE ? '♙' : '♟',
      'n': piece.color == chess_lib.Color.WHITE ? '♘' : '♞',
      'b': piece.color == chess_lib.Color.WHITE ? '♗' : '♝',
      'r': piece.color == chess_lib.Color.WHITE ? '♖' : '♜',
      'q': piece.color == chess_lib.Color.WHITE ? '♕' : '♛',
      'k': piece.color == chess_lib.Color.WHITE ? '♔' : '♚',
    };
    return symbols[piece.type.name[0]] ?? '';
  }
}
