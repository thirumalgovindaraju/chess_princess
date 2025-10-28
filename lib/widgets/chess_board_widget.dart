// lib/widgets/chess_board_widget.dart
// Maximum board size with minimal coordinate borders
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/chess_board.dart';
import '../models/position.dart';
import '../utils/chess_piece_assets.dart';

class ChessBoardWidget extends StatefulWidget {
  final ChessBoard? board;
  final String? fen;
  final bool isInteractive;
  final bool showCoordinates;
  final Function(Position, Position)? onMove;
  final Function(Position)? onSquareTap;

  const ChessBoardWidget({
    super.key,
    this.board,
    this.fen,
    this.isInteractive = true,
    this.showCoordinates = true,
    this.onMove,
    this.onSquareTap,
  }) : assert(board != null || fen != null, 'Either board or fen must be provided');

  @override
  State<ChessBoardWidget> createState() => _ChessBoardWidgetState();
}

class _ChessBoardWidgetState extends State<ChessBoardWidget>
    with TickerProviderStateMixin {
  late ChessBoard _internalBoard;
  Position? _selectedSquare;
  Position? _hoveredSquare;
  List<Position> _legalMoves = [];
  Position? _lastMoveFrom;
  Position? _lastMoveTo;

  late AnimationController _pulseController;
  late AnimationController _selectionController;
  late AnimationController _hoverController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _selectionAnimation;
  late Animation<double> _hoverAnimation;

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
  void didUpdateWidget(ChessBoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fen != oldWidget.fen || widget.board != oldWidget.board) {
      _initializeBoard();
    }
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _selectionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _selectionController, curve: Curves.easeOutCubic),
    );

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _hoverAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _selectionController.dispose();
    _hoverController.dispose();
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
          // Minimal space for tiny coordinates
          const coordSpace = 10.0;
          final boardSize = maxSize - (widget.showCoordinates ? (coordSpace * 2) : 0);

          return _buildBoardWithCoordinates(boardSize, coordSpace);
        },
      ),
    );
  }

  Widget _buildBoardWithCoordinates(double boardSize, double coordSpace) {
    final squareSize = boardSize / 8.0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3E2515),
        borderRadius: BorderRadius.circular(1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top coordinates (A-H)
          if (widget.showCoordinates)
            SizedBox(
              height: coordSpace,
              child: Row(
                children: [
                  SizedBox(width: coordSpace),
                  ...List.generate(8, (col) {
                    return SizedBox(
                      width: squareSize,
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + col),
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD4A574),
                            height: 1.0,
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(width: coordSpace),
                ],
              ),
            ),

          // Board with side coordinates
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Left numbers
              if (widget.showCoordinates)
                SizedBox(
                  width: coordSpace,
                  height: boardSize,
                  child: Column(
                    children: List.generate(8, (row) {
                      return SizedBox(
                        height: squareSize,
                        child: Center(
                          child: Text(
                            '${8 - row}',
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD4A574),
                              height: 1.0,
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
                    color: const Color(0xFF2A1810),
                    width: 0.5,
                  ),
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
                  width: coordSpace,
                  height: boardSize,
                  child: Column(
                    children: List.generate(8, (row) {
                      return SizedBox(
                        height: squareSize,
                        child: Center(
                          child: Text(
                            '${8 - row}',
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD4A574),
                              height: 1.0,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),

          // Bottom coordinates (A-H)
          if (widget.showCoordinates)
            SizedBox(
              height: coordSpace,
              child: Row(
                children: [
                  SizedBox(width: coordSpace),
                  ...List.generate(8, (col) {
                    return SizedBox(
                      width: squareSize,
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + col),
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD4A574),
                            height: 1.0,
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(width: coordSpace),
                ],
              ),
            ),
        ],
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
      onEnter: (_) {
        setState(() => _hoveredSquare = position);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _hoveredSquare = null);
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTap: widget.isInteractive ? () => _onSquareTap(row, col) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: _getSquareGradient(isLight, isSelected, isHovered, isLastMove),
          ),
          child: Stack(
            children: [
              ..._buildWoodGrain(row: row, col: col, isLight: isLight),
              _buildGlossEffect(isLight: isLight),
              if (isLastMove) _buildLastMoveHighlight(),
              if (isValidMove && !isSelected)
                Center(child: _buildMoveIndicator(isCapture: piece != null)),
              if (piece != null)
                Center(
                  child: AnimatedScale(
                    scale: isSelected ? 1.12 : (isHovered ? 1.06 : 1.0),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: _buildPieceImage(piece),
                  ),
                ),
              if (isHovered && !isSelected && widget.isInteractive)
                _buildHoverEffect(),
              if (isSelected) _buildSelectionGlow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieceImage(ChessPiece piece) {
    const pieceSize = 70.0;
    final assetPath = ChessPieceAssets.getPieceAsset(piece);

    return RepaintBoundary(
      child: SizedBox(
        width: pieceSize,
        height: pieceSize,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: -3,
              child: Container(
                width: pieceSize * 0.6,
                height: pieceSize * 0.1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const RadialGradient(
                    colors: [
                      Color.fromRGBO(0, 0, 0, 0.5),
                      Color.fromRGBO(0, 0, 0, 0.3),
                      Color.fromRGBO(0, 0, 0, 0.1),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            Image.asset(
              assetPath,
              width: pieceSize,
              height: pieceSize,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                return Text(
                  ChessPieceAssets.getPieceUnicode(piece),
                  style: TextStyle(
                    fontSize: pieceSize * 0.65,
                    color: piece.isWhite ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(2, 3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                );
              },
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
        colors: [Color(0xFF90EE90), Color(0xFF7CCD7C), Color(0xFF6ABB6A)],
      );
    }
    if (isLastMove) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isLight
            ? [const Color(0xFFD4E6C8), const Color(0xFFC8DEB8), const Color(0xFFBCD6A8)]
            : [const Color(0xFF9B8B6F), const Color(0xFF8D7D61), const Color(0xFF7F6F53)],
      );
    }
    if (isLight) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF5EBDC),
          Color(0xFFF0E2CE),
          Color(0xFFEBD9C0),
        ],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF9B7653),
          Color(0xFF8B6847),
          Color(0xFF7B5A3B),
        ],
      );
    }
  }

  List<Widget> _buildWoodGrain({required int row, required int col, required bool isLight}) {
    final grainLines = <Widget>[];
    final seed = col * 8 + row;
    final random = math.Random(seed);

    for (int i = 0; i < 30; i++) {
      final yPos = (i * 3.5) + random.nextDouble() * 2.5;
      final opacity = isLight
          ? 0.10 + random.nextDouble() * 0.15
          : 0.18 + random.nextDouble() * 0.28;
      final height = 0.6 + random.nextDouble() * 1.4;

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
                    isLight ? 120 : 70,
                    isLight ? 80 : 45,
                    isLight ? 50 : 25,
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
              Color.fromRGBO(255, 255, 255, isLight ? 0.12 : 0.06),
              Color.fromRGBO(255, 255, 255, isLight ? 0.06 : 0.03),
              Colors.transparent,
            ],
            stops: const [0.0, 0.25, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildLastMoveHighlight() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF64B5F6), width: 2.5),
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
            width: isCapture ? 50 : 14,
            height: isCapture ? 50 : 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isCapture ? Border.all(color: const Color(0xFF66BB6A), width: 3.5) : null,
              color: !isCapture ? const Color(0xFF66BB6A).withOpacity(0.7) : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildHoverEffect() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF42A5F5).withOpacity(0.15 * _hoverAnimation.value),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectionGlow() {
    return Positioned.fill(
      child: FadeTransition(
        opacity: _selectionAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF90EE90).withOpacity(0.2),
          ),
        ),
      ),
    );
  }
}