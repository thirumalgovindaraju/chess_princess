import 'package:flutter/material.dart';
import '../models/chess_board.dart';
import '../models/position.dart';

class ChessSquare extends StatelessWidget {
  final Position? position; // Optional for backward compatibility
  final ChessPiece? piece;
  final bool isLight;
  final bool isSelected;
  final bool isValidMove;
  final bool isLastMove;
  final double size;
  final VoidCallback? onTap;
  final double? squareSize; // Alternative size parameter

  const ChessSquare({
    Key? key,
    this.position,
    this.piece,
    this.isLight = true,
    this.isSelected = false,
    this.isValidMove = false,
    this.isLastMove = false,
    this.size = 60.0,
    this.onTap,
    this.squareSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double actualSize = squareSize ?? size;

    // Determine square color - use position if available, otherwise use isLight
    bool lightSquare = isLight;
    if (position != null) {
      lightSquare = (position!.row + position!.col) % 2 == 0;
    }

    Color squareColor;
    if (isSelected) {
      squareColor = Colors.yellow.shade300;
    } else if (isLastMove) {
      squareColor = Colors.amber.shade200;
    } else if (isValidMove) {
      squareColor = lightSquare
          ? Colors.lightGreen.shade200
          : Colors.lightGreen.shade400;
    } else {
      squareColor = lightSquare
          ? Colors.grey.shade200
          : Colors.brown.shade400;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: actualSize,
        height: actualSize,
        decoration: BoxDecoration(
          color: squareColor,
          border: isSelected
              ? Border.all(color: Colors.yellow.shade600, width: 3)
              : null,
        ),
        child: Stack(
          children: [
            // Valid move indicator
            if (isValidMove && piece == null)
              Center(
                child: Container(
                  width: actualSize * 0.3,
                  height: actualSize * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

            // Capture indicator (valid move with piece)
            if (isValidMove && piece != null)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.red.shade600,
                    width: 3,
                  ),
                ),
              ),

            // Piece
            if (piece != null)
              Center(
                child: Text(
                  piece!.symbol,
                  style: TextStyle(
                    fontSize: actualSize * 0.6,
                    color: piece!.color == PieceColor.white
                        ? Colors.white
                        : Colors.black,
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                        color: piece!.color == PieceColor.white
                            ? Colors.black
                            : Colors.white,
                      ),
                    ],
                  ),
                ),
              ),

            // Last move indicator
            if (isLastMove && !isSelected)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.orange.shade600,
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}