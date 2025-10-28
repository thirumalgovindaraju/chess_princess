// lib/utils/chess_piece_assets.dart
import 'package:chess_princess/models/chess_board.dart';

class ChessPieceAssets {
  // Base path for chess piece images
  static const String _basePath = 'assets/images/pieces';

  /// Get the asset path for a chess piece
  static String getPieceAsset(ChessPiece piece) {
    final color = piece.color == PieceColor.white ? 'w' : 'b';
    final pieceType = _getPieceTypeCode(piece.type);
    return '$_basePath/$color$pieceType.png';
  }

  /// Convert piece type to single character code
  static String _getPieceTypeCode(PieceType type) {
    switch (type) {
      case PieceType.king:
        return 'K';
      case PieceType.queen:
        return 'Q';
      case PieceType.rook:
        return 'R';
      case PieceType.bishop:
        return 'B';
      case PieceType.knight:
        return 'N';
      case PieceType.pawn:
        return 'P';
    }
  }

  /// Get all piece assets for preloading
  static List<String> getAllPieceAssets() {
    return [
      // White pieces
      '$_basePath/wK.png',
      '$_basePath/wQ.png',
      '$_basePath/wR.png',
      '$_basePath/wB.png',
      '$_basePath/wN.png',
      '$_basePath/wP.png',
      // Black pieces
      '$_basePath/bK.png',
      '$_basePath/bQ.png',
      '$_basePath/bR.png',
      '$_basePath/bB.png',
      '$_basePath/bN.png',
      '$_basePath/bP.png',
    ];
  }

  /// Verify asset exists (for debugging)
  static String getAssetPath(PieceColor color, PieceType type) {
    final colorCode = color == PieceColor.white ? 'w' : 'b';
    final typeCode = _getPieceTypeCode(type);
    return '$_basePath/$colorCode$typeCode.png';
  }

  /// Get piece Unicode character (fallback for text rendering)
  static String getPieceUnicode(ChessPiece piece) {
    if (piece.color == PieceColor.white) {
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
    } else {
      switch (piece.type) {
        case PieceType.king:
          return '♚';
        case PieceType.queen:
          return '♛';
        case PieceType.rook:
          return '♜';
        case PieceType.bishop:
          return '♝';
        case PieceType.knight:
          return '♞';
        case PieceType.pawn:
          return '♟';
      }
    }
  }
}

// Example usage in ChessBoardWidget or any widget that displays pieces:
/*
import 'package:flutter/material.dart';
import 'chess_piece_assets.dart';
import '../models/chess_board.dart';

Widget buildPieceWidget(ChessPiece piece) {
  return Image.asset(
    ChessPieceAssets.getPieceAsset(piece),
    width: 40,
    height: 40,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) {
      // Fallback to Unicode character if image fails to load
      return Text(
        ChessPieceAssets.getPieceUnicode(piece),
        style: const TextStyle(fontSize: 32),
      );
    },
  );
}
*/