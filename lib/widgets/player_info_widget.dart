import 'package:flutter/material.dart';
import '../models/chess_board.dart';

class PlayerInfoWidget extends StatelessWidget {
  final String playerName;
  final int rating;
  final PieceColor color;
  final bool isCurrentTurn;
  final int? coins;

  const PlayerInfoWidget({
    Key? key,
    required this.playerName,
    required this.rating,
    required this.color,
    required this.isCurrentTurn,
    this.coins,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40, // Fixed compact height
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentTurn
            ? (color == PieceColor.white ? Colors.blue.shade50 : Colors.green.shade50)
            : Colors.grey.shade100,
        border: Border.all(
          color: isCurrentTurn
              ? (color == PieceColor.white ? Colors.blue : Colors.green)
              : Colors.grey.shade300,
          width: isCurrentTurn ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          // Player color indicator - smaller
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color == PieceColor.white ? Colors.white : Colors.black,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400, width: 1),
            ),
          ),
          const SizedBox(width: 6),

          // Player info - single line only
          Expanded(
            child: Row(
              children: [
                // Name
                Text(
                  playerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12, // Smaller font
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 6),

                // Rating
                Icon(Icons.star, size: 10, color: Colors.amber),
                const SizedBox(width: 2),
                Text(
                  '$rating',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Coins (if present) - inline
                if (coins != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.monetization_on, size: 10, color: Colors.amber.shade700),
                  const SizedBox(width: 2),
                  Text(
                    '$coins',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Turn indicator
          if (isCurrentTurn)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color == PieceColor.white ? Colors.blue : Colors.green,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}