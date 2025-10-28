import 'position.dart';
import 'chess_board.dart';

class ChessMove {
  final Position from;
  final Position to;
  final ChessPiece piece;
  final ChessPiece? capturedPiece;
  final bool isCapture;
  final bool isCheck;
  final bool isCheckmate;
  final bool isCastling;
  final bool isEnPassant;
  final bool isPromotion;
  final PieceType? promotionPiece;
  final DateTime timestamp;

  ChessMove({
    required this.from,
    required this.to,
    required this.piece,
    this.capturedPiece,
    this.isCapture = false,
    this.isCheck = false,
    this.isCheckmate = false,
    this.isCastling = false,
    this.isEnPassant = false,
    this.isPromotion = false,
    this.promotionPiece,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Factory constructor for a simple move
  factory ChessMove.simple(Position from, Position to, ChessPiece piece) {
    return ChessMove(
      from: from,
      to: to,
      piece: piece,
    );
  }

  // Factory constructor for a capture move
  factory ChessMove.capture(Position from, Position to, ChessPiece piece, ChessPiece capturedPiece) {
    return ChessMove(
      from: from,
      to: to,
      piece: piece,
      capturedPiece: capturedPiece,
      isCapture: true,
    );
  }

  // Convert position to chess notation (e.g., a1, h8)
  String _positionToNotation(Position pos) {
    String file = String.fromCharCode('a'.codeUnitAt(0) + pos.col);
    String rank = (8 - pos.row).toString();
    return file + rank;
  }

  // Convert piece type to notation
  String _pieceToNotation(PieceType type) {
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
        return '';
    }
  }

  // Get algebraic notation for the move
  String get algebraicNotation {
    StringBuffer notation = StringBuffer();

    // Add piece symbol (except for pawns)
    if (piece.type != PieceType.pawn) {
      notation.write(_pieceToNotation(piece.type));
    }

    // Add capture symbol
    if (isCapture) {
      if (piece.type == PieceType.pawn) {
        // For pawn captures, include the file letter
        notation.write(_positionToNotation(from)[0]);
      }
      notation.write('x');
    }

    // Add destination square
    notation.write(_positionToNotation(to));

    // Add promotion
    if (isPromotion && promotionPiece != null) {
      notation.write('=');
      notation.write(_pieceToNotation(promotionPiece!));
    }

    // Add check/checkmate
    if (isCheckmate) {
      notation.write('#');
    } else if (isCheck) {
      notation.write('+');
    }

    return notation.toString();
  }

  // Get long algebraic notation (includes both from and to squares)
  String get longAlgebraicNotation {
    StringBuffer notation = StringBuffer();

    // Add piece symbol
    notation.write(_pieceToNotation(piece.type));

    // Add from square
    notation.write(_positionToNotation(from));

    // Add capture symbol or move symbol
    notation.write(isCapture ? 'x' : '-');

    // Add destination square
    notation.write(_positionToNotation(to));

    // Add promotion
    if (isPromotion && promotionPiece != null) {
      notation.write('=');
      notation.write(_pieceToNotation(promotionPiece!));
    }

    // Add check/checkmate
    if (isCheckmate) {
      notation.write('#');
    } else if (isCheck) {
      notation.write('+');
    }

    return notation.toString();
  }

  // Get a human-readable description of the move
  String get description {
    StringBuffer desc = StringBuffer();

    // Piece name
    String pieceName = _getPieceName(piece.type);
    desc.write(pieceName);

    if (isCapture && capturedPiece != null) {
      String capturedPieceName = _getPieceName(capturedPiece!.type);
      desc.write(' captures $capturedPieceName');
    } else {
      desc.write(' moves');
    }

    desc.write(' to ${_positionToNotation(to)}');

    if (isCheck) {
      desc.write(' (Check)');
    }

    if (isCheckmate) {
      desc.write(' (Checkmate)');
    }

    if (isPromotion) {
      desc.write(' (Promotion)');
    }

    return desc.toString();
  }

  String _getPieceName(PieceType type) {
    switch (type) {
      case PieceType.king:
        return 'King';
      case PieceType.queen:
        return 'Queen';
      case PieceType.rook:
        return 'Rook';
      case PieceType.bishop:
        return 'Bishop';
      case PieceType.knight:
        return 'Knight';
      case PieceType.pawn:
        return 'Pawn';
    }
  }

  // Copy the move with additional properties
  ChessMove copyWith({
    Position? from,
    Position? to,
    ChessPiece? piece,
    ChessPiece? capturedPiece,
    bool? isCapture,
    bool? isCheck,
    bool? isCheckmate,
    bool? isCastling,
    bool? isEnPassant,
    bool? isPromotion,
    PieceType? promotionPiece,
  }) {
    return ChessMove(
      from: from ?? this.from,
      to: to ?? this.to,
      piece: piece ?? this.piece,
      capturedPiece: capturedPiece ?? this.capturedPiece,
      isCapture: isCapture ?? this.isCapture,
      isCheck: isCheck ?? this.isCheck,
      isCheckmate: isCheckmate ?? this.isCheckmate,
      isCastling: isCastling ?? this.isCastling,
      isEnPassant: isEnPassant ?? this.isEnPassant,
      isPromotion: isPromotion ?? this.isPromotion,
      promotionPiece: promotionPiece ?? this.promotionPiece,
      timestamp: timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChessMove &&
        other.from == from &&
        other.to == to &&
        other.piece == piece &&
        other.capturedPiece == capturedPiece;
  }

  @override
  int get hashCode {
    return from.hashCode ^
    to.hashCode ^
    piece.hashCode ^
    capturedPiece.hashCode;
  }

  @override
  String toString() {
    return 'ChessMove($algebraicNotation)';
  }

  // Convert to JSON-like map for serialization
  Map<String, dynamic> toMap() {
    return {
      'from': {'row': from.row, 'col': from.col},
      'to': {'row': to.row, 'col': to.col},
      'piece': {'type': piece.type.index, 'color': piece.color.index},
      'capturedPiece': capturedPiece != null
          ? {'type': capturedPiece!.type.index, 'color': capturedPiece!.color.index}
          : null,
      'isCapture': isCapture,
      'isCheck': isCheck,
      'isCheckmate': isCheckmate,
      'isCastling': isCastling,
      'isEnPassant': isEnPassant,
      'isPromotion': isPromotion,
      'promotionPiece': promotionPiece?.index,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'algebraicNotation': algebraicNotation,
      'description': description,
    };
  }

  // Create from JSON-like map
  factory ChessMove.fromMap(Map<String, dynamic> map) {
    final fromPos = Position(row: map['from']['row'], col: map['from']['col']);
    final toPos = Position(row: map['to']['row'], col: map['to']['col']);

    return ChessMove(
      from: fromPos,
      to: toPos,
      piece: ChessPiece(
        PieceType.values[map['piece']['type']],
        PieceColor.values[map['piece']['color']],
        position: fromPos, // Add position parameter
      ),
      capturedPiece: map['capturedPiece'] != null
          ? ChessPiece(
        PieceType.values[map['capturedPiece']['type']],
        PieceColor.values[map['capturedPiece']['color']],
        position: toPos, // Add position parameter for captured piece
      )
          : null,
      isCapture: map['isCapture'] ?? false,
      isCheck: map['isCheck'] ?? false,
      isCheckmate: map['isCheckmate'] ?? false,
      isCastling: map['isCastling'] ?? false,
      isEnPassant: map['isEnPassant'] ?? false,
      isPromotion: map['isPromotion'] ?? false,
      promotionPiece: map['promotionPiece'] != null
          ? PieceType.values[map['promotionPiece']]
          : null,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}