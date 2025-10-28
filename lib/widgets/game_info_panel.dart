/*import 'package:flutter/material.dart';
import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/chess_move.dart';

class GameInfoPanel extends StatelessWidget {
  final ChessBoard chessBoard;
  final Duration? whiteTime;
  final Duration? blackTime;
  final bool showTimer;
  final VoidCallback? onResign;
  final VoidCallback? onOfferDraw;
  final VoidCallback? onUndo;

  const GameInfoPanel({
    Key? key,
    required this.chessBoard,
    this.whiteTime,
    this.blackTime,
    this.showTimer = false,
    this.onResign,
    this.onOfferDraw,
    this.onUndo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildGameStatus(),
          SizedBox(height: 12),
          if (showTimer) ...[
            _buildTimers(),
            SizedBox(height: 12),
          ],
          _buildMoveHistory(),
          SizedBox(height: 12),
          _buildCapturedPieces(),
          SizedBox(height: 12),
          _buildGameActions(),
        ],
      ),
    );
  }

  Widget _buildGameStatus() {
    String status;
    Color statusColor;

    if (chessBoard.isGameOver) {
      switch (chessBoard.gameResult) {
        case GameResult.whiteWins:
          status = "White wins!";
          statusColor = Colors.green;
          break;
        case GameResult.blackWins:
          status = "Black wins!";
          statusColor = Colors.green;
          break;
        case GameResult.stalemate:
          status = "Stalemate - Draw";
          statusColor = Colors.orange;
          break;
        case GameResult.draw:
          status = "Draw";
          statusColor = Colors.orange;
          break;
        default:
          status = "Game Over";
          statusColor = Colors.grey;
      }
    } else {
      bool inCheck = chessBoard.isInCheck(chessBoard.currentPlayer);
      String player = chessBoard.currentPlayer == PieceColor.white ? "White" : "Black";

      if (inCheck) {
        status = "$player in Check!";
        statusColor = Colors.red;
      } else {
        status = "$player to move";
        statusColor = Colors.blue;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(),
            color: statusColor,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: statusColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    if (chessBoard.isGameOver) {
      return chessBoard.gameResult == GameResult.stalemate ||
          chessBoard.gameResult == GameResult.draw
          ? Icons.handshake
          : Icons.emoji_events;
    } else if (chessBoard.isInCheck(chessBoard.currentPlayer)) {
      return Icons.warning;
    } else {
      return Icons.play_arrow;
    }
  }

  Widget _buildTimers() {
    return Row(
      children: [
        Expanded(
          child: _buildPlayerTimer("White", whiteTime, PieceColor.white),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildPlayerTimer("Black", blackTime, PieceColor.black),
        ),
      ],
    );
  }

  Widget _buildPlayerTimer(String player, Duration? time, PieceColor color) {
    bool isActive = chessBoard.currentPlayer == color && !chessBoard.isGameOver;

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive ? Colors.blue : Colors.grey.shade300,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            player,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.blue : Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            _formatTime(time),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: isActive ? Colors.blue : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration? time) {
    if (time == null) return "--:--";

    int minutes = time.inMinutes;
    int seconds = time.inSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  Widget _buildMoveHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Move History",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: chessBoard.moveHistory.isEmpty
              ? Center(
            child: Text(
              "No moves yet",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
              : ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: (chessBoard.moveHistory.length + 1) ~/ 2,
            itemBuilder: (context, index) {
              int moveNumber = index + 1;
              int whiteIndex = index * 2;
              int blackIndex = whiteIndex + 1;

              ChessMove? whiteMove = whiteIndex < chessBoard.moveHistory.length
                  ? chessBoard.moveHistory[whiteIndex]
                  : null;
              ChessMove? blackMove = blackIndex < chessBoard.moveHistory.length
                  ? chessBoard.moveHistory[blackIndex]
                  : null;

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        "$moveNumber.",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        whiteMove?.algebraicNotation ?? "",
                        style: TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        blackMove?.algebraicNotation ?? "",
                        style: TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCapturedPieces() {
    Map<PieceColor, List<ChessPiece>> capturedPieces = _getCapturedPieces();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Captured Pieces",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        _buildCapturedRow("White captured:", capturedPieces[PieceColor.black] ?? []),
        SizedBox(height: 4),
        _buildCapturedRow("Black captured:", capturedPieces[PieceColor.white] ?? []),
      ],
    );
  }

  Widget _buildCapturedRow(String label, List<ChessPiece> pieces) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: pieces.isEmpty
              ? Text(
            "None",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
              fontStyle: FontStyle.italic,
            ),
          )
              : Wrap(
            children: pieces.map((piece) => Text(
              piece.symbol,
              style: TextStyle(fontSize: 16),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Map<PieceColor, List<ChessPiece>> _getCapturedPieces() {
    Map<PieceColor, List<ChessPiece>> captured = {
      PieceColor.white: [],
      PieceColor.black: [],
    };

    for (ChessMove move in chessBoard.moveHistory) {
      if (move.capturedPiece != null) {
        captured[move.capturedPiece!.color]!.add(move.capturedPiece!);
      }
    }

    // Sort captured pieces by value (least valuable first)
    captured[PieceColor.white]!.sort((a, b) => a.value.compareTo(b.value));
    captured[PieceColor.black]!.sort((a, b) => a.value.compareTo(b.value));

    return captured;
  }

  Widget _buildGameActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Actions",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (onUndo != null && chessBoard.moveHistory.isNotEmpty)
              _buildActionButton(
                "Undo",
                Icons.undo,
                onUndo!,
                Colors.blue,
              ),
            if (onOfferDraw != null && !chessBoard.isGameOver)
              _buildActionButton(
                "Offer Draw",
                Icons.handshake,
                onOfferDraw!,
                Colors.orange,
              ),
            if (onResign != null && !chessBoard.isGameOver)
              _buildActionButton(
                "Resign",
                Icons.flag,
                onResign!,
                Colors.red,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed, Color color) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: TextStyle(fontSize: 12),
      ),
    );
  }
}

// Simplified info panel for mobile or compact layouts
class CompactGameInfoPanel extends StatelessWidget {
  final ChessBoard chessBoard;
  final Duration? whiteTime;
  final Duration? blackTime;

  const CompactGameInfoPanel({
    Key? key,
    required this.chessBoard,
    this.whiteTime,
    this.blackTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          _buildCurrentPlayer(),
          Spacer(),
          if (whiteTime != null && blackTime != null) ...[
            _buildCompactTimer("W", whiteTime!, PieceColor.white),
            SizedBox(width: 8),
            _buildCompactTimer("B", blackTime!, PieceColor.black),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentPlayer() {
    String player = chessBoard.currentPlayer == PieceColor.white
        ? "White"
        : "Black";
    bool inCheck = chessBoard.isInCheck(chessBoard.currentPlayer);

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: chessBoard.currentPlayer == PieceColor.white
                ? Colors.white
                : Colors.black,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade600),
          ),
        ),
        SizedBox(width: 8),
        Text(
          inCheck ? "$player (Check!)" : "$player to move",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: inCheck ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactTimer(String label, Duration time, PieceColor color) {
    bool isActive = chessBoard.currentPlayer == color;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
        border: isActive ? Border.all(color: Colors.blue) : null,
      ),
      child: Text(
        "$label ${_formatTime(time)}",
        style: TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.blue : Colors.grey.shade600,
        ),
      ),
    );
  }

  String _formatTime(Duration time) {
    int minutes = time.inMinutes;
    int seconds = time.inSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(
        2, '0')}";
  }
}
*/
import 'package:flutter/material.dart';
import '../models/chess_board.dart';
import '../models/chess_move.dart';


class GameInfoPanel extends StatelessWidget {
  final ChessBoard chessBoard;
  final VoidCallback? onResign;
  final VoidCallback? onUndo;

  const GameInfoPanel({
    Key? key,
    required this.chessBoard,
    this.onResign,
    this.onUndo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGameStatus(),
            const SizedBox(height: 16),
            _buildActionButtons(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildMoveHistory(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Turn:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: chessBoard.currentPlayer == PieceColor.white
                      ? Colors.white
                      : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Text(
                  chessBoard.currentPlayer == PieceColor.white
                      ? 'White'
                      : 'Black',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: chessBoard.currentPlayer == PieceColor.white
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (chessBoard.isGameOver) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: chessBoard.winner != null
                    ? Colors.amber.shade100
                    : Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: chessBoard.winner != null
                      ? Colors.amber.shade300
                      : Colors.blue.shade300,
                ),
              ),
              child: Text(
                _getGameEndMessage(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: chessBoard.winner != null
                      ? Colors.amber.shade800
                      : Colors.blue.shade800,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Move: ${(chessBoard.moveHistory.length ~/ 2) + 1}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                'Total: ${chessBoard.moveHistory.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGameEndMessage() {
    if (!chessBoard.isGameOver) return '';

    if (chessBoard.winner == null) {
      return 'Game Draw!';
    } else {
      return '${chessBoard.winner == PieceColor.white
          ? 'White'
          : 'Black'} Wins!';
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onUndo != null && chessBoard.moveHistory.isNotEmpty &&
                !chessBoard.isGameOver
                ? onUndo
                : null,
            icon: const Icon(Icons.undo, size: 18),
            label: const Text('Undo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onResign != null && !chessBoard.isGameOver
                ? onResign
                : null,
            icon: const Icon(Icons.flag, size: 18),
            label: const Text('Resign'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoveHistoryRow(int moveNumber) {
    int whiteIndex = moveNumber * 2;
    int blackIndex = moveNumber * 2 + 1;

    String? whiteMove = whiteIndex < chessBoard.moveHistory.length
        ? chessBoard.moveHistory[whiteIndex]
        : null;
    String? blackMove = blackIndex < chessBoard.moveHistory.length
        ? chessBoard.moveHistory[blackIndex]
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: moveNumber % 2 == 0 ? Colors.grey.shade50 : Colors.white,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '${moveNumber + 1}.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: whiteMove != null
                ? _buildMoveCell(whiteMove, PieceColor.white)
                : const SizedBox(),
          ),
          Expanded(
            child: blackMove != null
                ? _buildMoveCell(blackMove, PieceColor.black)
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveCell(String move, PieceColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color == PieceColor.white ? Colors.white : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Text(
        move,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade800,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildMoveHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Move History',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: chessBoard.moveHistory.isEmpty
                ? Center(
              child: Text(
                'No moves yet',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
                : ListView.builder(
              itemCount: (chessBoard.moveHistory.length + 1) ~/ 2,
              itemBuilder: (context, index) {
                return _buildMoveHistoryRow(index);
              },
            ),
          ),
        ),
      ],
    );
  }
}