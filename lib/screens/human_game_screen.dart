import 'package:flutter/material.dart';
import 'dart:async';
import '../models/chess_board.dart';
import '../widgets/chess_board_widget.dart';
import '../widgets/game_info_panel.dart';
import '../models/position.dart';

class HumanGameScreen extends StatefulWidget {
  const HumanGameScreen({super.key});

  @override
  State<HumanGameScreen> createState() => _HumanGameScreenState();
}

class _HumanGameScreenState extends State<HumanGameScreen> {
  late ChessBoard chessBoard;
  List<ChessPiece> whiteCapturedPieces = [];
  List<ChessPiece> blackCapturedPieces = [];

  // Timer variables
  Duration whiteTime = const Duration(minutes: 10);
  Duration blackTime = const Duration(minutes: 10);
  Timer? _timer;

  // Player stats
  int whitePlayerRating = 1200;
  int blackPlayerRating = 1180;

  // Draw offer tracking
  PieceColor? drawOfferedBy;

  // Position repetition tracking for threefold repetition
  Map<String, int> positionHistory = {};

  // Fifty-move rule counter
  int halfMoveClock = 0;

  @override
  void initState() {
    super.initState();
    chessBoard = ChessBoard.initial();
    _initializeCapturedPiecesListener();
    _startTimer();
    _recordPosition();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!chessBoard.isGameOver) {
        setState(() {
          if (chessBoard.currentPlayer == PieceColor.white) {
            if (whiteTime.inSeconds > 0) {
              whiteTime = whiteTime - const Duration(seconds: 1);
              if (whiteTime.inSeconds == 0) {
                _onTimeUp(PieceColor.white);
              }
            }
          } else {
            if (blackTime.inSeconds > 0) {
              blackTime = blackTime - const Duration(seconds: 1);
              if (blackTime.inSeconds == 0) {
                _onTimeUp(PieceColor.black);
              }
            }
          }
        });
      }
    });
  }

  void _initializeCapturedPiecesListener() {
    chessBoard.addCaptureListener((ChessPiece capturedPiece) {
      setState(() {
        if (capturedPiece.color == PieceColor.white) {
          whiteCapturedPieces.add(capturedPiece);
        } else {
          blackCapturedPieces.add(capturedPiece);
        }
      });
    });
  }

  void _recordPosition() {
    String fen = chessBoard.toFEN();
    positionHistory[fen] = (positionHistory[fen] ?? 0) + 1;
  }

  bool _isThreefoldRepetition() {
    String currentFen = chessBoard.toFEN();
    return (positionHistory[currentFen] ?? 0) >= 3;
  }

  bool _isFiftyMoveRule() {
    return halfMoveClock >= 100;
  }

  bool _isInsufficientMaterial() {
    List<ChessPiece> pieces = chessBoard.getAllPieces();
    pieces.removeWhere((p) => p.type == PieceType.king);

    if (pieces.isEmpty) return true;

    if (pieces.length == 1) {
      return pieces[0].type == PieceType.bishop || pieces[0].type == PieceType.knight;
    }

    if (pieces.length == 2) {
      if (pieces.every((p) => p.type == PieceType.bishop)) {
        bool firstBishopOnLight = (pieces[0].position.row + pieces[0].position.col) % 2 == 0;
        bool secondBishopOnLight = (pieces[1].position.row + pieces[1].position.col) % 2 == 0;
        return firstBishopOnLight == secondBishopOnLight;
      }
    }

    return false;
  }

  void _onMove(Position from, Position to) async {
    if (chessBoard.isGameOver) {
      return;
    }

    if (drawOfferedBy != null) {
      setState(() {
        drawOfferedBy = null;
      });
    }

    final piece = chessBoard.getPieceAt(from);
    if (piece == null) return;

    if (!chessBoard.isMoveLegal(from, to)) {
      _showMoveValidationMessage(from, to);
      return;
    }

    bool isCapture = chessBoard.getPieceAt(to) != null;
    bool isPawnMove = piece.type == PieceType.pawn;

    if (piece.type == PieceType.pawn) {
      if ((piece.color == PieceColor.white && to.row == 0) ||
          (piece.color == PieceColor.black && to.row == 7)) {
        final promotionPiece = await _showPromotionDialog(piece.color);
        if (promotionPiece == null) return;

        setState(() {
          bool moveSuccess = chessBoard.makeMove(from, to, promotionPiece: promotionPiece);
          if (!moveSuccess) {
            moveSuccess = chessBoard.makeMove(from, to);
            if (moveSuccess) {
              _manuallyPromotePawn(to, piece.color, promotionPiece);
            }
          }

          if (moveSuccess) {
            _handlePostMove(isCapture, isPawnMove);
          }
        });
        return;
      }
    }

    setState(() {
      bool moveSuccess = chessBoard.makeMove(from, to);
      if (moveSuccess) {
        _handlePostMove(isCapture, isPawnMove);
      }
    });
  }

  void _handlePostMove(bool isCapture, bool isPawnMove) {
    if (isCapture || isPawnMove) {
      halfMoveClock = 0;
    } else {
      halfMoveClock++;
    }

    _recordPosition();

    if (_isThreefoldRepetition()) {
      _showAutomaticDrawDialog('Threefold Repetition');
    } else if (_isFiftyMoveRule()) {
      _showAutomaticDrawDialog('Fifty-Move Rule');
    } else if (_isInsufficientMaterial()) {
      _showAutomaticDrawDialog('Insufficient Material');
    } else if (chessBoard.isStalemate()) {
      _showAutomaticDrawDialog('Stalemate');
    } else if (chessBoard.isCheckmate()) {
      setState(() {
        chessBoard.isGameOver = true;
        chessBoard.winner = chessBoard.currentPlayer == PieceColor.white
            ? PieceColor.black
            : PieceColor.white;
      });
    }
  }

  void _showMoveValidationMessage(Position from, Position to) {
    String message = _getMoveValidationMessage(from, to);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  String _getMoveValidationMessage(Position from, Position to) {
    final piece = chessBoard.getPieceAt(from);
    if (piece == null) return 'No piece selected';

    if (piece.color != chessBoard.currentPlayer) {
      return 'It\'s ${chessBoard.currentPlayer == PieceColor.white ? "White" : "Black"}\'s turn!';
    }

    if (chessBoard.wouldLeaveKingInCheck(from, to)) {
      return 'This move would leave your king in check!';
    }

    final destPiece = chessBoard.getPieceAt(to);
    if (destPiece != null && destPiece.color == piece.color) {
      return 'Cannot capture your own piece!';
    }

    switch (piece.type) {
      case PieceType.pawn:
        return 'Pawns can only move forward (or capture diagonally)';
      case PieceType.knight:
        return 'Knights move in an L-shape (2 squares + 1 square)';
      case PieceType.bishop:
        return 'Bishops can only move diagonally';
      case PieceType.rook:
        return 'Rooks can only move horizontally or vertically';
      case PieceType.queen:
        return 'Queens move diagonally, horizontally, or vertically';
      case PieceType.king:
        if (chessBoard.isPositionUnderAttack(to, piece.color)) {
          return 'Cannot move king into check!';
        }
        return 'Kings can only move one square (except castling)';
    }
  }

  void _manuallyPromotePawn(Position pos, PieceColor color, PieceType promoteTo) {
    final promotedPiece = ChessPiece(
      promoteTo,
      color,
      position: pos,
    );

    try {
      chessBoard.setPieceAt(pos, promotedPiece);
    } catch (e) {
      print('Warning: ChessBoard does not support manual piece placement');
    }
  }

  Future<PieceType?> _showPromotionDialog(PieceColor color) async {
    return showDialog<PieceType>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Promote Pawn'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Choose a piece to promote to:'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPromotionPieceWithContext(dialogContext, PieceType.queen, color, '♕', '♛'),
                  _buildPromotionPieceWithContext(dialogContext, PieceType.rook, color, '♖', '♜'),
                  _buildPromotionPieceWithContext(dialogContext, PieceType.bishop, color, '♗', '♝'),
                  _buildPromotionPieceWithContext(dialogContext, PieceType.knight, color, '♘', '♞'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPromotionPieceWithContext(
      BuildContext dialogContext,
      PieceType type,
      PieceColor color,
      String whiteSymbol,
      String blackSymbol,
      ) {
    return InkWell(
      onTap: () {
        Navigator.of(dialogContext).pop(type);
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Center(
          child: Text(
            color == PieceColor.white ? whiteSymbol : blackSymbol,
            style: const TextStyle(fontSize: 40),
          ),
        ),
      ),
    );
  }

  void _onTimeUp(PieceColor loser) {
    _timer?.cancel();
    setState(() {
      chessBoard.isGameOver = true;
      chessBoard.winner = loser == PieceColor.white ? PieceColor.black : PieceColor.white;
    });

    _showTimeUpDialog(loser);
  }

  void _showTimeUpDialog(PieceColor loser) {
    String winnerName = loser == PieceColor.white ? "Black" : "White";
    String loserName = loser == PieceColor.white ? "White" : "Black";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Time\'s Up!'),
          content: Text(
              '$loserName\'s time has expired.\n'
                  '$winnerName wins by timeout!'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _onNewGame();
              },
              child: const Text('New Game'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Main Menu'),
            ),
          ],
        );
      },
    );
  }

  void _showAutomaticDrawDialog(String reason) {
    _timer?.cancel();
    setState(() {
      chessBoard.isGameOver = true;
      chessBoard.winner = null;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Drawn'),
          content: Text('The game is a draw by $reason.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _onNewGame();
              },
              child: const Text('New Game'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Main Menu'),
            ),
          ],
        );
      },
    );
  }

  void _onNewGame() {
    setState(() {
      chessBoard.reset();
      whiteCapturedPieces.clear();
      blackCapturedPieces.clear();
      positionHistory.clear();
      halfMoveClock = 0;
      drawOfferedBy = null;

      whiteTime = const Duration(minutes: 10);
      blackTime = const Duration(minutes: 10);
      _startTimer();
      _recordPosition();
    });
  }

  void _onOfferDraw() {
    setState(() {
      drawOfferedBy = chessBoard.currentPlayer;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String offeringPlayer = chessBoard.currentPlayer == PieceColor.white ? "White" : "Black";
        String receivingPlayer = chessBoard.currentPlayer == PieceColor.white ? "Black" : "White";

        return AlertDialog(
          title: const Text('Draw Offer'),
          content: Text('$offeringPlayer offers a draw.\n$receivingPlayer, do you accept?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  drawOfferedBy = null;
                });
              },
              child: const Text('Decline'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _acceptDraw();
              },
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  void _acceptDraw() {
    _timer?.cancel();
    setState(() {
      chessBoard.isGameOver = true;
      chessBoard.winner = null;
      drawOfferedBy = null;
    });
  }

  void _onResign() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String currentPlayerName = chessBoard.currentPlayer == PieceColor.white ? "White" : "Black";

        return AlertDialog(
          title: const Text('Resign Game'),
          content: Text('$currentPlayerName, are you sure you want to resign?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _timer?.cancel();
                setState(() {
                  chessBoard.isGameOver = true;
                  chessBoard.winner = chessBoard.currentPlayer == PieceColor.white
                      ? PieceColor.black
                      : PieceColor.white;
                });
              },
              child: const Text('Resign'),
            ),
          ],
        );
      },
    );
  }

  void _onUndo() {
    if (chessBoard.moveHistory.isNotEmpty) {
      setState(() {
        chessBoard.undoLastMove();
        _updateCapturedPieces();

        String currentFen = chessBoard.toFEN();
        if (positionHistory[currentFen] != null && positionHistory[currentFen]! > 0) {
          positionHistory[currentFen] = positionHistory[currentFen]! - 1;
        }

        if (halfMoveClock > 0) halfMoveClock--;
      });
    }
  }

  void _updateCapturedPieces() {
    whiteCapturedPieces.clear();
    blackCapturedPieces.clear();

    for (ChessPiece piece in chessBoard.capturedPieces) {
      if (piece.color == PieceColor.white) {
        whiteCapturedPieces.add(piece);
      } else {
        blackCapturedPieces.add(piece);
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.handshake),
                title: const Text('Offer Draw'),
                onTap: () {
                  Navigator.pop(context);
                  _onOfferDraw();
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('Resign'),
                onTap: () {
                  Navigator.pop(context);
                  _onResign();
                },
              ),
              ListTile(
                leading: const Icon(Icons.undo),
                title: const Text('Undo Move'),
                onTap: () {
                  Navigator.pop(context);
                  _onUndo();
                },
                enabled: chessBoard.moveHistory.isNotEmpty,
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Captured Pieces'),
                onTap: () {
                  Navigator.pop(context);
                  _showCapturedPiecesDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.analytics_outlined),
                title: const Text('Game Stats'),
                onTap: () {
                  Navigator.pop(context);
                  _showGameStatsDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCapturedPiecesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Captured Pieces'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'White: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.brown.shade800,
                    ),
                  ),
                  Expanded(
                    child: whiteCapturedPieces.isEmpty
                        ? Text('None', style: TextStyle(color: Colors.brown.shade400))
                        : Wrap(
                      spacing: 4,
                      children: whiteCapturedPieces
                          .map((piece) => _buildCapturedPieceIcon(piece))
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Black: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.brown.shade800,
                    ),
                  ),
                  Expanded(
                    child: blackCapturedPieces.isEmpty
                        ? Text('None', style: TextStyle(color: Colors.brown.shade400))
                        : Wrap(
                      spacing: 4,
                      children: blackCapturedPieces
                          .map((piece) => _buildCapturedPieceIcon(piece))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showGameStatsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Statistics'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('Total Moves', '${chessBoard.moveHistory.length}'),
              _buildStatRow('Fifty-Move Clock', '$halfMoveClock/100'),
              _buildStatRow('Position Repetitions', '${positionHistory[chessBoard.toFEN()] ?? 0}'),
              _buildStatRow('White Time', _formatDuration(whiteTime)),
              _buildStatRow('Black Time', _formatDuration(blackTime)),
              if (_isThreefoldRepetition())
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    '⚠️ Threefold repetition reached',
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ),
              if (_isFiftyMoveRule())
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    '⚠️ Fifty-move rule reached',
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isInCheck = chessBoard.isKingInCheck(chessBoard.currentPlayer);

    return Scaffold(
      backgroundColor: Colors.brown.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Human vs Human'),
            if (isInCheck) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text('CHECK!', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptions,
            tooltip: 'More Options',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onNewGame,
            tooltip: 'New Game',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Help',
          ),
        ],
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWideScreen = constraints.maxWidth > 800;

              if (isWideScreen) {
                // Wide screen layout (desktop/tablet landscape)
                return Row(
                  children: [
                    // Left sidebar - Game info
                    SizedBox(
                      width: 260,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            _buildPlayerInfoWithTimer(
                              playerName: 'Black Player',
                              rating: blackPlayerRating,
                              color: PieceColor.black,
                              time: blackTime,
                              isCurrentTurn: chessBoard.currentPlayer == PieceColor.black,
                              isInCheck: isInCheck && chessBoard.currentPlayer == PieceColor.black,
                            ),
                            const SizedBox(height: 12),
                            _buildGameStatus(),
                            const SizedBox(height: 12),
                            _buildCapturedPieces(),
                            const SizedBox(height: 12),
                            _buildDrawOfferButton(),
                          ],
                        ),
                      ),
                    ),

                    // Center - Chessboard
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: ChessBoardWidget(
                              board: chessBoard,
                              onMove: _onMove,
                              isInteractive: true,
                              showCoordinates: true,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Right sidebar - Move history & controls
                    SizedBox(
                      width: 260,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            _buildPlayerInfoWithTimer(
                              playerName: 'White Player',
                              rating: whitePlayerRating,
                              color: PieceColor.white,
                              time: whiteTime,
                              isCurrentTurn: chessBoard.currentPlayer == PieceColor.white,
                              isInCheck: isInCheck && chessBoard.currentPlayer == PieceColor.white,
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: GameInfoPanel(
                                chessBoard: chessBoard,
                                onResign: _onResign,
                                onUndo: _onUndo,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Mobile/narrow screen layout - 90% board, 10% details
                return Column(
                  children: [
                    // Compact info bar at top (5% of space)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      color: Colors.brown.shade100,
                      child: Row(
                        children: [
                          // Black player info - compact
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.brown.shade400),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Black',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: chessBoard.currentPlayer == PieceColor.black ? FontWeight.bold : FontWeight.normal,
                                    color: Colors.brown.shade900,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                if (isInCheck && chessBoard.currentPlayer == PieceColor.black)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: const Text(
                                      'CHECK',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Timer
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: blackTime.inSeconds < 20 ? Colors.red.shade50 : Colors.brown.shade200,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: blackTime.inSeconds < 20 ? Colors.red : Colors.brown.shade400,
                              ),
                            ),
                            child: Text(
                              _formatDuration(blackTime),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                color: blackTime.inSeconds < 20 ? Colors.red : Colors.brown.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Chessboard - 90% of available space
                    Expanded(
                      flex: 90,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: ChessBoardWidget(
                              board: chessBoard,
                              onMove: _onMove,
                              isInteractive: true,
                              showCoordinates: true,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Compact info bar at bottom (5% of space)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      color: Colors.brown.shade100,
                      child: Row(
                        children: [
                          // White player info - compact
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.brown.shade400),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'White',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: chessBoard.currentPlayer == PieceColor.white ? FontWeight.bold : FontWeight.normal,
                                    color: Colors.brown.shade900,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                if (isInCheck && chessBoard.currentPlayer == PieceColor.white)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: const Text(
                                      'CHECK',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Timer
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: whiteTime.inSeconds < 20 ? Colors.red.shade50 : Colors.brown.shade200,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: whiteTime.inSeconds < 20 ? Colors.red : Colors.brown.shade400,
                              ),
                            ),
                            child: Text(
                              _formatDuration(whiteTime),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                color: whiteTime.inSeconds < 20 ? Colors.red : Colors.brown.shade900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Compact game info
                          Text(
                            'Moves: ${chessBoard.moveHistory.length}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.brown.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          ),

          // Game over overlay
          if (chessBoard.isGameOver)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getGameResultIcon(),
                          size: 64,
                          color: _getGameResultColor(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getGameResultText(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _onNewGame,
                              icon: const Icon(Icons.refresh),
                              label: const Text('New Game'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                            const SizedBox(width: 16),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Main Menu'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Draw offer indicator
          if (drawOfferedBy != null && !chessBoard.isGameOver)
            Positioned(
              top: 16,
              right: 16,
              child: Card(
                color: Colors.orange.shade50,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.handshake, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Draw offered by ${drawOfferedBy == PieceColor.white ? "White" : "Black"}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.brown.shade300),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Game Status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.brown.shade900,
                ),
              ),
              if (_isThreefoldRepetition() && positionHistory[chessBoard.toFEN()] == 3)
                Chip(
                  label: const Text('3x Repetition', style: TextStyle(fontSize: 10)),
                  backgroundColor: Colors.orange.shade100,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Moves: ${chessBoard.moveHistory.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.brown.shade700,
                ),
              ),
              Text(
                '50-move: $halfMoveClock/100',
                style: TextStyle(
                  fontSize: 12,
                  color: halfMoveClock > 80 ? Colors.red : Colors.brown.shade700,
                  fontWeight: halfMoveClock > 80 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawOfferButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: chessBoard.isGameOver ? null : _onOfferDraw,
        icon: const Icon(Icons.handshake, size: 20),
        label: const Text('Offer Draw'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown.shade200,
          foregroundColor: Colors.brown.shade900,
        ),
      ),
    );
  }

  Widget _buildPlayerInfoWithTimer({
    required String playerName,
    required int rating,
    required PieceColor color,
    required Duration time,
    required bool isCurrentTurn,
    required bool isInCheck,
  }) {
    bool isLowTime = time.inSeconds < 60;
    bool isCriticalTime = time.inSeconds < 20;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isInCheck ? Colors.red.shade50 : Colors.brown.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isInCheck
              ? Colors.red
              : isCurrentTurn
              ? Colors.brown.shade700
              : Colors.brown.shade300,
          width: isInCheck || isCurrentTurn ? 2 : 1,
        ),
        boxShadow: isCurrentTurn || isInCheck
            ? [
          BoxShadow(
            color: (isInCheck ? Colors.red : Colors.brown.shade700).withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 1,
          )
        ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color == PieceColor.white ? Colors.white : Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.brown.shade400),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  playerName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.brown.shade900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isInCheck)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'CHECK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.star, size: 12, color: Colors.brown.shade600),
                  const SizedBox(width: 3),
                  Text(
                    rating.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.brown.shade600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCriticalTime
                          ? Colors.red.shade50
                          : isLowTime
                          ? Colors.orange.shade50
                          : Colors.brown.shade100,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isCriticalTime
                            ? Colors.red
                            : isLowTime
                            ? Colors.orange
                            : Colors.brown.shade300,
                      ),
                    ),
                    child: Text(
                      _formatDuration(time),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: isCriticalTime
                            ? Colors.red
                            : isLowTime
                            ? Colors.orange.shade900
                            : Colors.brown.shade900,
                      ),
                    ),
                  ),
                  if (isCurrentTurn && !chessBoard.isGameOver) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.brown.shade700,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getGameResultIcon() {
    if (chessBoard.winner == null) {
      return Icons.handshake;
    }
    return Icons.emoji_events;
  }

  Color _getGameResultColor() {
    if (chessBoard.winner == null) {
      return Colors.grey;
    }
    return Colors.amber;
  }

  String _getGameResultText() {
    if (chessBoard.winner == null) {
      return 'Draw!';
    } else if (chessBoard.winner == PieceColor.white) {
      return '🎉 White Wins!';
    } else {
      return '🎉 Black Wins!';
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Human vs Human Mode'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'How to Play:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text('• White moves first'),
                const Text('• Players take turns moving pieces'),
                const Text('• Tap a piece to select it'),
                const Text('• Tap a highlighted square to move'),
                const Text('• Each player has 10 minutes on the clock'),
                const SizedBox(height: 16),
                const Text(
                  'Chess Rules Implemented:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text('• Standard piece movements'),
                const Text('• Castling (kingside and queenside)'),
                const Text('• En passant capture'),
                const Text('• Pawn promotion'),
                const Text('• Check and checkmate detection'),
                const Text('• Stalemate detection'),
                const Text('• Threefold repetition (automatic draw)'),
                const Text('• Fifty-move rule (automatic draw)'),
                const Text('• Insufficient material (automatic draw)'),
                const SizedBox(height: 16),
                const Text(
                  'Game Controls:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text('• More menu (⋮) - Access all game options'),
                const Text('• Offer Draw - Propose a draw'),
                const Text('• Resign - Forfeit the game'),
                const Text('• Undo Move - Take back moves'),
                const Text('• View captured pieces and stats'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tips:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text('• Control the center of the board', style: TextStyle(fontSize: 12)),
                      Text('• Develop your pieces early', style: TextStyle(fontSize: 12)),
                      Text('• Protect your king', style: TextStyle(fontSize: 12)),
                      Text('• Look for tactics and combinations', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it!'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCapturedPieces() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.brown.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.brown.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Captured Pieces',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.brown.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'White: ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.brown.shade800,
                ),
              ),
              Expanded(
                child: whiteCapturedPieces.isEmpty
                    ? Text('None', style: TextStyle(color: Colors.brown.shade400))
                    : Wrap(
                  spacing: 4,
                  children: whiteCapturedPieces
                      .map((piece) => _buildCapturedPieceIcon(piece))
                      .toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Black: ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.brown.shade800,
                ),
              ),
              Expanded(
                child: blackCapturedPieces.isEmpty
                    ? Text('None', style: TextStyle(color: Colors.brown.shade400))
                    : Wrap(
                  spacing: 4,
                  children: blackCapturedPieces
                      .map((piece) => _buildCapturedPieceIcon(piece))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCapturedPieceIcon(ChessPiece piece) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: piece.color == PieceColor.white ? Colors.white : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Center(
        child: Text(
          _getPieceSymbol(piece),
          style: TextStyle(
            fontSize: 16,
            color: piece.color == PieceColor.white ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  String _getPieceSymbol(ChessPiece piece) {
    switch (piece.type) {
      case PieceType.king:
        return '♔';
      case PieceType.queen:
        return '♕';
      case PieceType.rook:
        return '♖';
      case PieceType.bishop:
        return '♗';
      case PieceType.knight:
        return '♘';
      case PieceType.pawn:
        return '♙';
    }
  }
}