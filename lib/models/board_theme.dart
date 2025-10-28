import 'package:flutter/material.dart';

class BoardTheme {
  final String name;
  final Color lightSquare;
  final Color darkSquare;
  final Color selectedSquare;
  final Color validMoveSquare;
  final Color lastMoveHighlight;
  final Color checkHighlight;

  const BoardTheme({
    required this.name,
    required this.lightSquare,
    required this.darkSquare,
    required this.selectedSquare,
    required this.validMoveSquare,
    required this.lastMoveHighlight,
    required this.checkHighlight,
  });

  static const classic = BoardTheme(
    name: 'Classic',
    lightSquare: Color(0xFFF0D9B5),
    darkSquare: Color(0xFFB58863),
    selectedSquare: Color(0xFFFEF3C7),
    validMoveSquare: Color(0xFF86EFAC),
    lastMoveHighlight: Color(0xFFBAE6FD),
    checkHighlight: Color(0xFFFCA5A5),
  );

  static const blue = BoardTheme(
    name: 'Blue Ocean',
    lightSquare: Color(0xFFDCEAF5),
    darkSquare: Color(0xFF7FA1C3),
    selectedSquare: Color(0xFFFFE4B5),
    validMoveSquare: Color(0xFF90EE90),
    lastMoveHighlight: Color(0xFFADD8E6),
    checkHighlight: Color(0xFFFF6B6B),
  );

  static const green = BoardTheme(
    name: 'Forest Green',
    lightSquare: Color(0xFFE8F5E9),
    darkSquare: Color(0xFF66BB6A),
    selectedSquare: Color(0xFFFFEB3B),
    validMoveSquare: Color(0xFFA5D6A7),
    lastMoveHighlight: Color(0xFFC5E1A5),
    checkHighlight: Color(0xFFEF5350),
  );

  static const purple = BoardTheme(
    name: 'Royal Purple',
    lightSquare: Color(0xFFF3E5F5),
    darkSquare: Color(0xFF9C27B0),
    selectedSquare: Color(0xFFFFD700),
    validMoveSquare: Color(0xFFBA68C8),
    lastMoveHighlight: Color(0xFFCE93D8),
    checkHighlight: Color(0xFFFF5252),
  );

  static const dark = BoardTheme(
    name: 'Dark Mode',
    lightSquare: Color(0xFF4A5568),
    darkSquare: Color(0xFF2D3748),
    selectedSquare: Color(0xFFEAB308),
    validMoveSquare: Color(0xFF10B981),
    lastMoveHighlight: Color(0xFF3B82F6),
    checkHighlight: Color(0xFFDC2626),
  );

  static const List<BoardTheme> allThemes = [
    classic,
    blue,
    green,
    purple,
    dark,
  ];
}