// lib/widgets/chess_timer.dart
import 'package:flutter/material.dart';
import 'dart:async';

class ChessTimer extends StatefulWidget {
  final Duration initialTime;
  final bool isActive;
  final VoidCallback? onTimeExpired;
  final String playerName;
  final bool isPlayerTurn;

  const ChessTimer({
    Key? key,
    required this.initialTime,
    required this.isActive,
    this.onTimeExpired,
    required this.playerName,
    required this.isPlayerTurn,
  }) : super(key: key);

  @override
  State<ChessTimer> createState() => _ChessTimerState();
}

class _ChessTimerState extends State<ChessTimer> {
  late Duration remainingTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.initialTime;
    if (widget.isActive && widget.isPlayerTurn) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(ChessTimer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive != oldWidget.isActive ||
        widget.isPlayerTurn != oldWidget.isPlayerTurn) {
      if (widget.isActive && widget.isPlayerTurn) {
        _startTimer();
      } else {
        _stopTimer();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime.inSeconds > 0) {
          remainingTime = remainingTime - const Duration(seconds: 1);
        } else {
          _stopTimer();
          widget.onTimeExpired?.call();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    String minutes = duration.inMinutes.toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    bool isLowTime = remainingTime.inSeconds < 60;
    bool isVeryLowTime = remainingTime.inSeconds < 10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isPlayerTurn
            ? (isVeryLowTime ? Colors.red.shade100 : Colors.blue.shade100)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isPlayerTurn
              ? (isVeryLowTime ? Colors.red : Colors.blue)
              : Colors.grey,
          width: widget.isPlayerTurn ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.playerName,
            style: TextStyle(
              fontWeight: widget.isPlayerTurn ? FontWeight.bold : FontWeight.normal,
              color: widget.isPlayerTurn ? Colors.black : Colors.grey.shade600,
            ),
          ),
          Text(
            _formatTime(remainingTime),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isVeryLowTime
                  ? Colors.red
                  : (isLowTime ? Colors.orange : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

// Simplified chess game timer manager
class ChessGameTimer extends StatefulWidget {
  final Duration whiteTime;
  final Duration blackTime;
  final bool gameActive;
  final bool isWhiteTurn;
  final VoidCallback? onWhiteTimeExpired;
  final VoidCallback? onBlackTimeExpired;

  const ChessGameTimer({
    Key? key,
    required this.whiteTime,
    required this.blackTime,
    required this.gameActive,
    required this.isWhiteTurn,
    this.onWhiteTimeExpired,
    this.onBlackTimeExpired,
  }) : super(key: key);

  @override
  State<ChessGameTimer> createState() => _ChessGameTimerState();
}

class _ChessGameTimerState extends State<ChessGameTimer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChessTimer(
          initialTime: widget.blackTime,
          isActive: widget.gameActive,
          playerName: 'Black',
          isPlayerTurn: !widget.isWhiteTurn,
          onTimeExpired: widget.onBlackTimeExpired,
        ),
        const SizedBox(height: 12),
        ChessTimer(
          initialTime: widget.whiteTime,
          isActive: widget.gameActive,
          playerName: 'White',
          isPlayerTurn: widget.isWhiteTurn,
          onTimeExpired: widget.onWhiteTimeExpired,
        ),
      ],
    );
  }
}