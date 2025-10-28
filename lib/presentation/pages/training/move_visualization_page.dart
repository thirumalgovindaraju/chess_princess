// lib/presentation/pages/training/move_visualization_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoveVisualizationPage extends ConsumerStatefulWidget {
  const MoveVisualizationPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MoveVisualizationPage> createState() => _MoveVisualizationPageState();
}

class _MoveVisualizationPageState extends ConsumerState<MoveVisualizationPage> {
  List<String> _moveSequence = [];
  int _currentMoveIndex = 0;
  bool _isShowingMoves = true;
  int _score = 0;
  int _difficulty = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _generateMoveSequence();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _generateMoveSequence() {
    final squares = <String>[];
    for (int rank = 1; rank <= 8; rank++) {
      for (int file = 0; file < 8; file++) {
        squares.add('${String.fromCharCode(97 + file)}$rank');
      }
    }

    _moveSequence = [];
    final random = DateTime.now().microsecondsSinceEpoch;
    for (int i = 0; i < _difficulty; i++) {
      _moveSequence.add(squares[(random + i * 13) % squares.length]);
    }

    setState(() {
      _currentMoveIndex = 0;
      _isShowingMoves = true;
    });

    _showMovesSequentially();
  }

  void _showMovesSequentially() async {
    for (int i = 0; i < _moveSequence.length; i++) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _currentMoveIndex = i);
      }
    }

    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isShowingMoves = false;
        _currentMoveIndex = 0;
      });
    }
  }

  void _onSquareTapped(String square) {
    if (_isShowingMoves) return;

    final expectedSquare = _moveSequence[_currentMoveIndex];
    final isCorrect = square == expectedSquare;

    if (isCorrect) {
      setState(() => _currentMoveIndex++);

      if (_currentMoveIndex >= _moveSequence.length) {
        setState(() => _score += 20);
        _showSuccessDialog();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wrong square! Try again.'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            const Text('Perfect!'),
          ],
        ),
        content: Text('You remembered all $_difficulty moves!\nScore: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_difficulty < 8) {
                setState(() => _difficulty++);
              }
              _generateMoveSequence();
            },
            child: const Text('Next Level'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Move Visualization'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.purple.shade600],
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('Score', '$_score', Icons.stars),
                    _buildStatColumn('Level', '$_difficulty', Icons.trending_up),
                    _buildStatColumn('Moves', '${_moveSequence.length}', Icons.route),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _isShowingMoves
                      ? 'Memorize the sequence...'
                      : 'Tap squares in order (${_currentMoveIndex + 1}/${_moveSequence.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: _buildChessBoard(),
                ),
              ),
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

        final isCurrentMove = _isShowingMoves &&
            _currentMoveIndex < _moveSequence.length &&
            square == _moveSequence[_currentMoveIndex];

        return GestureDetector(
          onTap: () => _onSquareTapped(square),
          child: Container(
            decoration: BoxDecoration(
              color: isCurrentMove
                  ? Colors.yellow.shade400
                  : isLight
                  ? Colors.grey.shade300
                  : Colors.grey.shade700,
            ),
            child: Center(
              child: isCurrentMove
                  ? Text(
                '${_currentMoveIndex + 1}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              )
                  : null,
            ),
          ),
        );
      },
    );
  }
}