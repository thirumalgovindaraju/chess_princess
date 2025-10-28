// lib/styles/chess_board_styles.dart
import 'package:flutter/material.dart';

class ChessBoardStyles {
  // Wooden board colors - realistic wood texture simulation
  static const Color lightSquare = Color(0xFFE8D7B8);
  static const Color darkSquare = Color(0xFFAA7B4D);
  static const Color boardBorder = Color(0xFF654321);
  static const Color boardBackground = Color(0xFF3D2817);

  // Piece colors for 3D effect
  static const Color whitePieceMain = Color(0xFFFFFAF0);
  static const Color blackPieceMain = Color(0xFF2C2C2C);

  // Selected/highlighted square color
  static const Color selectedSquare = Color(0xFFFFEB3B);
  static const Color validMoveSquare = Color(0xFF81C784);

  // Board container decoration with realistic wood frame
  static BoxDecoration getBoardDecoration() {
    return BoxDecoration(
      color: boardBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: boardBorder,
        width: 8,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x40000000),
          blurRadius: 24,
          offset: Offset(0, 12),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: Color(0x20000000),
          blurRadius: 48,
          offset: Offset(0, 24),
          spreadRadius: -8,
        ),
      ],
    );
  }

  // Square decoration with wood grain gradient
  static BoxDecoration getSquareDecoration(bool isLight, {bool isSelected = false, bool isValidMove = false}) {
    Color baseColor;
    List<Color> gradientColors;

    if (isSelected) {
      baseColor = selectedSquare;
      gradientColors = [
        selectedSquare.withOpacity(0.7),
        selectedSquare,
        selectedSquare.withOpacity(0.8),
      ];
    } else if (isValidMove) {
      baseColor = validMoveSquare;
      gradientColors = [
        validMoveSquare.withOpacity(0.5),
        validMoveSquare.withOpacity(0.6),
        validMoveSquare.withOpacity(0.5),
      ];
    } else if (isLight) {
      baseColor = lightSquare;
      gradientColors = const [
        Color(0xFFF0E0C8),
        Color(0xFFE8D7B8),
        Color(0xFFE0CFA8),
      ];
    } else {
      baseColor = darkSquare;
      gradientColors = const [
        Color(0xFFB88B5E),
        Color(0xFFAA7B4D),
        Color(0xFF9C6B3D),
      ];
    }

    return BoxDecoration(
      color: baseColor,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 1,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  // 3D piece text style with realistic shadows
  static TextStyle getPieceStyle(bool isWhite, double size) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: isWhite ? whitePieceMain : blackPieceMain,
      height: 1.0,
      shadows: [
        // Main shadow for depth
        Shadow(
          color: isWhite
              ? const Color(0x60000000)
              : const Color(0x80000000),
          offset: const Offset(2, 3),
          blurRadius: 4,
        ),
        // Highlight for white pieces
        if (isWhite) ...[
          const Shadow(
            color: Color(0x40FFFFFF),
            offset: Offset(-1, -1),
            blurRadius: 2,
          ),
          const Shadow(
            color: Color(0x20FFFFFF),
            offset: Offset(-2, -2),
            blurRadius: 4,
          ),
        ],
        // Extra depth shadow
        Shadow(
          color: Colors.black.withOpacity(0.2),
          offset: const Offset(1, 2),
          blurRadius: 2,
        ),
      ],
    );
  }

  // Container decoration for piece (adds subtle glow)
  static BoxDecoration? getPieceContainerDecoration(bool isWhite) {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          isWhite
              ? const Color(0x10FFFFFF)
              : const Color(0x10000000),
          Colors.transparent,
        ],
      ),
    );
  }

  // Coordinate labels style (a-h, 1-8)
  static TextStyle getCoordinateStyle() {
    return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFF654321),
      height: 1.0,
    );
  }

  // Move indicator dot (for valid moves)
  static Widget getMoveIndicatorDot(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0x88555555),
        border: Border.all(
          color: const Color(0xFFDDDDDD),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }

  // Capture indicator ring (for valid capture moves)
  static Widget getCaptureIndicatorRing(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xCCFF5252),
          width: 4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40FF0000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

// Example implementation widget
class ChessBoardWidget extends StatelessWidget {
  final List<List<dynamic>> squares; // Your board squares
  final int? selectedRow;
  final int? selectedCol;
  final Function(int, int)? onSquareTap;

  const ChessBoardWidget({
    Key? key,
    required this.squares,
    this.selectedRow,
    this.selectedCol,
    this.onSquareTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = screenWidth > 600 ? 600.0 : screenWidth - 32;
    final squareSize = boardSize / 8;
    final pieceSize = squareSize * 0.7;

    return Container(
      decoration: ChessBoardStyles.getBoardDecoration(),
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: boardSize,
        height: boardSize,
        child: Column(
          children: List.generate(8, (row) {
            return Expanded(
              child: Row(
                children: List.generate(8, (col) {
                  final isLight = (row + col) % 2 == 0;
                  final isSelected = selectedRow == row && selectedCol == col;
                  final piece = squares[row][col];

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onSquareTap?.call(row, col),
                      child: Container(
                        decoration: ChessBoardStyles.getSquareDecoration(
                          isLight,
                          isSelected: isSelected,
                        ),
                        child: Center(
                          child: piece != null
                              ? Container(
                            decoration: ChessBoardStyles.getPieceContainerDecoration(
                              piece.isWhite ?? true,
                            ),
                            child: Text(
                              piece.symbol ?? '',
                              style: ChessBoardStyles.getPieceStyle(
                                piece.isWhite ?? true,
                                pieceSize,
                              ),
                            ),
                          )
                              : null,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}