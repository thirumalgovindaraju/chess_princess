// ==========================================
// FILE: lib/widgets/chess_board_3d_widget.dart
// ==========================================
// 3D Perspective Chess Board with realistic wooden frame
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/chess_board.dart';
import '../models/position.dart';
import '../utils/chess_piece_assets.dart';

class ChessBoard3DWidget extends StatefulWidget {
  final ChessBoard? board;
  final String? fen;
  final bool isInteractive;
  final bool showCoordinates;
  final Function(Position, Position)? onMove;
  final Function(Position)? onSquareTap;

  const ChessBoard3DWidget({
    super.key,
    this.board,
    this.fen,
    this.isInteractive = true,
    this.showCoordinates = true,
    this.onMove,
    this.onSquareTap,
  }) : assert(board != null || fen != null, 'Either board or fen must be provided');

  @override
  State<ChessBoard3DWidget> createState() => _ChessBoard3DWidgetState();
}

class _ChessBoard3DWidgetState extends State<ChessBoard3DWidget>
    with TickerProviderStateMixin {
  late ChessBoard _internalBoard;
  Position? _selectedSquare;
  Position? _hoveredSquare;
  List<Position> _legalMoves = [];
  Position? _lastMoveFrom;
  Position? _lastMoveTo;

  late AnimationController _pulseController;
  late AnimationController _selectionController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _selectionAnimation;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
    _initAnimations();
  }

  void _initializeBoard() {
    if (widget.board != null) {
      _internalBoard = widget.board!;
    } else if (widget.fen != null) {
      _internalBoard = ChessBoard.fromFen(widget.fen!);
    } else {
      _internalBoard = ChessBoard.initial();
    }
  }

  @override
  void didUpdateWidget(ChessBoard3DWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fen != oldWidget.fen || widget.board != oldWidget.board) {
      _initializeBoard();
    }
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _selectionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _selectionController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _selectionController.dispose();
    super.dispose();
  }

  void _onSquareTap(int row, int col) {
    if (!widget.isInteractive) return;

    final position = Position(row: row, col: col);
    final piece = _internalBoard.getPieceAt(position);

    if (_selectedSquare == null) {
      if (piece != null && piece.isWhite == _internalBoard.isWhiteTurn) {
        setState(() {
          _selectedSquare = position;
          _legalMoves = _getLegalMoves(position);
        });
        _selectionController.forward();
        widget.onSquareTap?.call(position);
      }
    } else {
      if (_selectedSquare == position) {
        setState(() {
          _selectedSquare = null;
          _legalMoves = [];
        });
        _selectionController.reverse();
      } else if (_legalMoves.contains(position)) {
        setState(() {
          _lastMoveFrom = _selectedSquare;
          _lastMoveTo = position;
        });
        widget.onMove?.call(_selectedSquare!, position);
        setState(() {
          _selectedSquare = null;
          _legalMoves = [];
        });
        _selectionController.reverse();
      } else if (piece != null && piece.isWhite == _internalBoard.isWhiteTurn) {
        setState(() {
          _selectedSquare = position;
          _legalMoves = _getLegalMoves(position);
        });
        widget.onSquareTap?.call(position);
      }
    }
  }

  List<Position> _getLegalMoves(Position from) {
    final piece = _internalBoard.getPieceAt(from);
    if (piece == null) return [];

    List<Position> moves = [];

    switch (piece.type) {
      case PieceType.pawn:
        moves = _getPawnMoves(from, piece);
        break;
      case PieceType.knight:
        moves = _getKnightMoves(from, piece);
        break;
      case PieceType.bishop:
        moves = _getBishopMoves(from, piece);
        break;
      case PieceType.rook:
        moves = _getRookMoves(from, piece);
        break;
      case PieceType.queen:
        moves = _getQueenMoves(from, piece);
        break;
      case PieceType.king:
        moves = _getKingMoves(from, piece);
        break;
    }

    return moves;
  }

  List<Position> _getPawnMoves(Position from, ChessPiece piece) {
    List<Position> moves = [];
    final direction = piece.isWhite ? -1 : 1;
    final startRow = piece.isWhite ? 6 : 1;

    final forward = Position(row: from.row + direction, col: from.col);
    if (_internalBoard.isValidPosition(forward) && _internalBoard.getPieceAt(forward) == null) {
      moves.add(forward);

      if (from.row == startRow) {
        final doubleForward = Position(row: from.row + (2 * direction), col: from.col);
        if (_internalBoard.getPieceAt(doubleForward) == null) {
          moves.add(doubleForward);
        }
      }
    }

    for (int colOffset in [-1, 1]) {
      final capture = Position(row: from.row + direction, col: from.col + colOffset);
      if (_internalBoard.isValidPosition(capture)) {
        final targetPiece = _internalBoard.getPieceAt(capture);
        if (targetPiece != null && targetPiece.isWhite != piece.isWhite) {
          moves.add(capture);
        }
      }
    }

    return moves;
  }

  List<Position> _getKnightMoves(Position from, ChessPiece piece) {
    List<Position> moves = [];
    final knightMoves = [
      [-2, -1], [-2, 1], [-1, -2], [-1, 2],
      [1, -2], [1, 2], [2, -1], [2, 1]
    ];

    for (var move in knightMoves) {
      final to = Position(row: from.row + move[0], col: from.col + move[1]);
      if (_internalBoard.isValidPosition(to)) {
        final targetPiece = _internalBoard.getPieceAt(to);
        if (targetPiece == null || targetPiece.isWhite != piece.isWhite) {
          moves.add(to);
        }
      }
    }

    return moves;
  }

  List<Position> _getBishopMoves(Position from, ChessPiece piece) {
    List<Position> moves = [];
    final directions = [[-1, -1], [-1, 1], [1, -1], [1, 1]];

    for (var dir in directions) {
      for (int i = 1; i < 8; i++) {
        final to = Position(row: from.row + (dir[0] * i), col: from.col + (dir[1] * i));
        if (!_internalBoard.isValidPosition(to)) break;

        final targetPiece = _internalBoard.getPieceAt(to);
        if (targetPiece == null) {
          moves.add(to);
        } else {
          if (targetPiece.isWhite != piece.isWhite) {
            moves.add(to);
          }
          break;
        }
      }
    }

    return moves;
  }

  List<Position> _getRookMoves(Position from, ChessPiece piece) {
    List<Position> moves = [];
    final directions = [[-1, 0], [1, 0], [0, -1], [0, 1]];

    for (var dir in directions) {
      for (int i = 1; i < 8; i++) {
        final to = Position(row: from.row + (dir[0] * i), col: from.col + (dir[1] * i));
        if (!_internalBoard.isValidPosition(to)) break;

        final targetPiece = _internalBoard.getPieceAt(to);
        if (targetPiece == null) {
          moves.add(to);
        } else {
          if (targetPiece.isWhite != piece.isWhite) {
            moves.add(to);
          }
          break;
        }
      }
    }

    return moves;
  }

  List<Position> _getQueenMoves(Position from, ChessPiece piece) {
    List<Position> moves = [];
    moves.addAll(_getBishopMoves(from, piece));
    moves.addAll(_getRookMoves(from, piece));
    return moves;
  }

  List<Position> _getKingMoves(Position from, ChessPiece piece) {
    List<Position> moves = [];
    final kingMoves = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1], [0, 1],
      [1, -1], [1, 0], [1, 1]
    ];

    for (var move in kingMoves) {
      final to = Position(row: from.row + move[0], col: from.col + move[1]);
      if (_internalBoard.isValidPosition(to)) {
        final targetPiece = _internalBoard.getPieceAt(to);
        if (targetPiece == null || targetPiece.isWhite != piece.isWhite) {
          moves.add(to);
        }
      }
    }

    return moves;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxSize = math.min(constraints.maxWidth, constraints.maxHeight);
          return _build3DBoard(maxSize * 0.9);
        },
      ),
    );
  }

  Widget _build3DBoard(double size) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspective
          ..rotateX(-0.3) // Tilt the board
          ..rotateZ(0.0),
        alignment: Alignment.center,
        child: _buildBoardWithFrame(size),
      ),
    );
  }

  Widget _buildBoardWithFrame(double size) {
    final boardSize = size * 0.85;
    final frameWidth = size * 0.075;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD4A574),
            Color(0xFFC89564),
            Color(0xFFB88554),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Color(0xFF8B6F47),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top coordinates
            if (widget.showCoordinates)
              SizedBox(
                height: frameWidth * 0.8,
                width: boardSize,
                child: Row(
                  children: List.generate(8, (col) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + col),
                          style: TextStyle(
                            fontSize: frameWidth * 0.4,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF654321),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            // Board with side numbers
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left numbers
                if (widget.showCoordinates)
                  SizedBox(
                    width: frameWidth * 0.8,
                    height: boardSize,
                    child: Column(
                      children: List.generate(8, (row) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              '${8 - row}',
                              style: TextStyle(
                                fontSize: frameWidth * 0.4,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF654321),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                // Chess board
                Container(
                  width: boardSize,
                  height: boardSize,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFF654321),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: List.generate(8, (row) {
                      return Expanded(
                        child: Row(
                          children: List.generate(8, (col) {
                            return Expanded(
                              child: _buildSquare(row, col),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                ),
                // Right numbers
                if (widget.showCoordinates)
                  SizedBox(
                    width: frameWidth * 0.8,
                    height: boardSize,
                    child: Column(
                      children: List.generate(8, (row) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              '${8 - row}',
                              style: TextStyle(
                                fontSize: frameWidth * 0.4,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF654321),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
            // Bottom coordinates
            if (widget.showCoordinates)
              SizedBox(
                height: frameWidth * 0.8,
                width: boardSize,
                child: Row(
                  children: List.generate(8, (col) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + col),
                          style: TextStyle(
                            fontSize: frameWidth * 0.4,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF654321),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquare(int row, int col) {
    final position = Position(row: row, col: col);
    final piece = _internalBoard.getPieceAt(position);
    final isLight = (row + col) % 2 == 0;
    final isSelected = _selectedSquare == position;
    final isValidMove = _legalMoves.contains(position);
    final isHovered = _hoveredSquare == position;
    final isLastMove = _lastMoveFrom == position || _lastMoveTo == position;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredSquare = position),
      onExit: (_) => setState(() => _hoveredSquare = null),
      child: GestureDetector(
        onTap: widget.isInteractive ? () => _onSquareTap(row, col) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: _getSquareGradient(isLight, isSelected, isHovered, isLastMove),
          ),
          child: Stack(
            children: [
              ..._buildWoodGrain(row: row, col: col, isLight: isLight),
              _buildGlossEffect(isLight: isLight),
              if (isValidMove && !isSelected)
                Center(child: _buildMoveIndicator(isCapture: piece != null)),
              if (piece != null)
                Center(
                  child: AnimatedScale(
                    scale: isSelected ? 1.1 : (isHovered ? 1.05 : 1.0),
                    duration: const Duration(milliseconds: 200),
                    child: _build3DPiece(piece),
                  ),
                ),
              if (isSelected) _buildSelectionHighlight(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DPiece(ChessPiece piece) {
    const pieceSize = 80.0;
    final assetPath = ChessPieceAssets.getPieceAsset(piece);

    return RepaintBoundary(
      child: SizedBox(
        width: pieceSize,
        height: pieceSize,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Strong circular shadow
            Positioned(
              bottom: -8,
              child: Container(
                width: pieceSize * 0.8,
                height: pieceSize * 0.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: RadialGradient(
                    colors: [
                      Color.fromRGBO(0, 0, 0, 0.7),
                      Color.fromRGBO(0, 0, 0, 0.5),
                      Color.fromRGBO(0, 0, 0, 0.3),
                      Color.fromRGBO(0, 0, 0, 0.15),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
                ),
              ),
            ),
            // Piece with 3D lift
            Transform.translate(
              offset: const Offset(0, -4),
              child: Image.asset(
                assetPath,
                width: pieceSize,
                height: pieceSize,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: pieceSize * 0.85,
                    height: pieceSize * 0.85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: piece.isWhite
                            ? [Color(0xFFFFFAF0), Color(0xFFF5F5DC), Color(0xFFE8E8D8)]
                            : [Color(0xFF3C3C3C), Color(0xFF2C2C2C), Color(0xFF1C1C1C)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 10,
                          offset: Offset(3, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        ChessPieceAssets.getPieceUnicode(piece),
                        style: TextStyle(
                          fontSize: pieceSize * 0.6,
                          color: piece.isWhite ? Color(0xFF2C2C2C) : Color(0xFFF5F5DC),
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: Offset(2, 3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getSquareGradient(bool isLight, bool isSelected, bool isHovered, bool isLastMove) {
    if (isSelected) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF8BC34A), Color(0xFF7CB342), Color(0xFF689F38)],
      );
    }
    if (isLastMove) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isLight
            ? [Color(0xFFD4E6C8), Color(0xFFC8DEB8), Color(0xFFBCD6A8)]
            : [Color(0xFF9B8B6F), Color(0xFF8D7D61), Color(0xFF7F6F53)],
      );
    }
    if (isLight) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF5E6D3),
          Color(0xFFF0DCBE),
          Color(0xFFEBD2A9),
        ],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF8B6F47),
          Color(0xFF7A5F37),
          Color(0xFF694F27),
        ],
      );
    }
  }

  List<Widget> _buildWoodGrain({required int row, required int col, required bool isLight}) {
    final grainLines = <Widget>[];
    final seed = col * 8 + row;
    final random = math.Random(seed);

    for (int i = 0; i < 40; i++) {
      final yPos = (i * 2.5) + random.nextDouble() * 2.0;
      final opacity = isLight
          ? 0.15 + random.nextDouble() * 0.25
          : 0.25 + random.nextDouble() * 0.40;
      final height = 0.9 + random.nextDouble() * 2.0;

      grainLines.add(
        Positioned(
          left: 0,
          right: 0,
          top: yPos,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Color.fromRGBO(
                    isLight ? 100 : 50,
                    isLight ? 60 : 30,
                    isLight ? 30 : 15,
                    opacity,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      );
    }

    return grainLines;
  }

  Widget _buildGlossEffect({required bool isLight}) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(255, 255, 255, isLight ? 0.15 : 0.08),
              Color.fromRGBO(255, 255, 255, isLight ? 0.08 : 0.04),
              Colors.transparent,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildMoveIndicator({required bool isCapture}) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: isCapture ? 65 : 18,
            height: isCapture ? 65 : 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isCapture
                  ? Border.all(
                color: const Color(0xFF4CAF50),
                width: 5.0,
              )
                  : null,
              color: !isCapture ? const Color(0xFF4CAF50).withOpacity(0.8) : null,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectionHighlight() {
    return Positioned.fill(
      child: FadeTransition(
        opacity: _selectionAnimation,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF8BC34A),
              width: 3,
            ),
            color: const Color(0xFF8BC34A).withOpacity(0.2),
          ),
        ),
      ),
    );
  }
}