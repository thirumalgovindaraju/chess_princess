// lib/presentation/widgets/puzzle_viewer.dart
import 'package:flutter/material.dart';
import 'package:chess_princess/domain/entities/puzzle.dart';
import 'package:chess_princess/widgets/chess_board_widget.dart';
import 'package:chess_princess/models/chess_board.dart';
import 'package:chess_princess/models/position.dart';

class PuzzleViewer extends StatefulWidget {
  final Puzzle puzzle;
  final void Function(String)? onMove;
  final bool showHint;

  const PuzzleViewer({
    required this.puzzle,
    this.onMove,
    this.showHint = false,
    super.key,
  });

  @override
  State<PuzzleViewer> createState() => _PuzzleViewerState();
}

class _PuzzleViewerState extends State<PuzzleViewer> {
  late ChessBoard chessBoard;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  @override
  void didUpdateWidget(PuzzleViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.puzzle.fen != widget.puzzle.fen) {
      _initializeBoard();
    }
  }

  void _initializeBoard() {
    try {
      chessBoard = ChessBoard.fromFen(widget.puzzle.fen);
    } catch (e) {
      print('Error loading FEN: $e');
      chessBoard = ChessBoard.initial();
    }
  }

  String _positionToString(Position pos) {
    String file = String.fromCharCode('a'.codeUnitAt(0) + pos.col);
    String rank = (8 - pos.row).toString();
    return '$file$rank';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Puzzle info card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Difficulty: ${widget.puzzle.difficulty}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.puzzle.theme.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Chess Board Widget
        ChessBoardWidget(
          board: chessBoard,
          onMove: (from, to) {
            // Convert Position objects to chess notation and combine
            String fromSquare = _positionToString(from);
            String toSquare = _positionToString(to);
            widget.onMove?.call('$fromSquare$toSquare');
          },
          isInteractive: true,
          showCoordinates: true,
        ),

        const SizedBox(height: 16),

        // Hint section
        if (widget.showHint && widget.puzzle.hint != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber[800]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.puzzle.hint!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.amber[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}