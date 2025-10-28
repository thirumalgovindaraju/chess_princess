// lib/presentation/pages/training/endgame_drills_page.dart

import 'package:flutter/material.dart';
import 'package:chess_princess/widgets/chess_board_widget.dart';
import 'package:chess_princess/models/position.dart';
import 'package:chess/chess.dart' as chess_lib;

class EndgameDrillsPage extends StatelessWidget {
  const EndgameDrillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final drills = [
      // BASIC CHECKMATES (1-10)
      {'title': 'Queen + King vs King #1', 'description': 'Basic queen checkmate technique', 'fen': '8/8/8/8/4k3/8/8/Q3K3 w - - 0 1', 'difficulty': 'Beginner', 'icon': Icons.workspace_premium, 'color': const Color(0xFF9C27B0)},
      {'title': 'Rook + King vs King #1', 'description': 'Execute the classic rook checkmate', 'fen': '8/8/8/8/8/4k3/8/R3K3 w - - 0 1', 'difficulty': 'Beginner', 'icon': Icons.castle, 'color': const Color(0xFF2196F3)},
      {'title': 'Two Rooks vs King #1', 'description': 'Perfect the ladder mate', 'fen': '8/8/8/8/4k3/8/R7/R3K3 w - - 0 1', 'difficulty': 'Beginner', 'icon': Icons.view_column, 'color': const Color(0xFFFF9800)},
      {'title': 'Queen + King vs King #2', 'description': 'Queen mate from center position', 'fen': '8/8/8/3k4/8/8/4Q3/4K3 w - - 0 1', 'difficulty': 'Beginner', 'icon': Icons.workspace_premium, 'color': const Color(0xFF9C27B0)},
      {'title': 'Rook + King vs King #2', 'description': 'Rook mate with edge technique', 'fen': '8/8/8/8/8/8/4k3/R3K3 w - - 0 1', 'difficulty': 'Beginner', 'icon': Icons.castle, 'color': const Color(0xFF2196F3)},
      {'title': 'Two Rooks vs King #2', 'description': 'Back rank checkmate pattern', 'fen': '4k3/8/8/8/8/8/R7/R3K3 w - - 0 1', 'difficulty': 'Beginner', 'icon': Icons.view_column, 'color': const Color(0xFFFF9800)},
      {'title': 'Queen + King vs King #3', 'description': 'Force king to corner efficiently', 'fen': '8/8/4k3/8/8/8/Q7/4K3 w - - 0 1', 'difficulty': 'Easy', 'icon': Icons.workspace_premium, 'color': const Color(0xFF9C27B0)},
      {'title': 'Rook + King vs King #3', 'description': 'Building the mating net', 'fen': '8/8/3k4/8/8/8/8/R3K3 w - - 0 1', 'difficulty': 'Easy', 'icon': Icons.castle, 'color': const Color(0xFF2196F3)},
      {'title': 'Two Bishops + King vs King', 'description': 'Elegant two bishops mate', 'fen': '8/8/8/4k3/8/3BKB2/8/8 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.auto_awesome, 'color': const Color(0xFFF44336)},
      {'title': 'Bishop + Knight + King vs King', 'description': 'The most challenging basic mate', 'fen': '8/8/8/8/4k3/8/3BN3/4K3 w - - 0 1', 'difficulty': 'Expert', 'icon': Icons.psychology, 'color': const Color(0xFF6A1B9A)},

      // PAWN ENDGAMES (11-30)
      {'title': 'King + Pawn vs King #1', 'description': 'Central pawn promotion technique', 'fen': '8/8/8/4k3/8/4K3/4P3/8 w - - 0 1', 'difficulty': 'Beginner', 'icon': Icons.star_outline, 'color': const Color(0xFF4CAF50)},
      {'title': 'King + Pawn vs King #2', 'description': 'Opposition and key squares', 'fen': '8/8/8/3k4/8/3K4/3P4/8 w - - 0 1', 'difficulty': 'Beginner', 'icon': Icons.star_outline, 'color': const Color(0xFF4CAF50)},
      {'title': 'King + Pawn vs King #3', 'description': 'Rook pawn special case', 'fen': '8/8/8/5k2/8/5K2/5P2/8 w - - 0 1', 'difficulty': 'Easy', 'icon': Icons.star_outline, 'color': const Color(0xFF4CAF50)},
      {'title': 'Opposition Training #1', 'description': 'Master the opposition concept', 'fen': '8/8/8/4k3/8/8/4K3/8 w - - 0 1', 'difficulty': 'Beginner', 'icon': Icons.compare_arrows, 'color': const Color(0xFF26C6DA)},
      {'title': 'Opposition Training #2', 'description': 'Distant opposition technique', 'fen': '8/8/8/8/4k3/8/8/4K3 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.compare_arrows, 'color': const Color(0xFF26C6DA)},
      {'title': 'Square of the Pawn #1', 'description': 'Can the king catch the pawn?', 'fen': '8/5k2/8/4P3/8/8/8/5K2 w - - 0 1', 'difficulty': 'Easy', 'icon': Icons.crop_square, 'color': const Color(0xFFAB47BC)},
      {'title': 'Square of the Pawn #2', 'description': 'Calculate the critical square', 'fen': '8/2k5/8/3P4/8/8/8/5K2 w - - 0 1', 'difficulty': 'Easy', 'icon': Icons.crop_square, 'color': const Color(0xFFAB47BC)},
      {'title': 'Passed Pawn Race #1', 'description': 'Who promotes first wins', 'fen': '8/5k2/8/4P3/8/5K2/5p2/8 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.flag, 'color': const Color(0xFF00897B)},
      {'title': 'Passed Pawn Race #2', 'description': 'Calculate the pawn race', 'fen': '8/4k3/8/3P4/8/3K4/6p1/8 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.flag, 'color': const Color(0xFF00897B)},
      {'title': 'Outside Passed Pawn', 'description': 'Use outside pawn advantage', 'fen': '8/1p3k2/8/P7/6K1/8/8/8 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.trending_up, 'color': const Color(0xFF43A047)},
      {'title': 'Protected Passed Pawn', 'description': 'Advance the protected pawn', 'fen': '8/5k2/8/3PP3/8/5K2/8/8 w - - 0 1', 'difficulty': 'Easy', 'icon': Icons.security, 'color': const Color(0xFF66BB6A)},
      {'title': 'Breakthrough Combination #1', 'description': 'Sacrifice to create passed pawn', 'fen': '8/5k2/5p2/4pPp1/4P1P1/5K2/8/8 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.bolt, 'color': const Color(0xFFFFB300)},
      {'title': 'Breakthrough Combination #2', 'description': 'Pawn break to victory', 'fen': '8/4k3/4p3/3pPp2/3P1P2/4K3/8/8 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.bolt, 'color': const Color(0xFFFFB300)},
      {'title': 'Zugzwang Position #1', 'description': 'Whoever moves loses', 'fen': '8/8/8/3k4/3p4/3K4/3P4/8 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.block, 'color': const Color(0xFFE53935)},
      {'title': 'Zugzwang Position #2', 'description': 'Force opponent into zugzwang', 'fen': '8/8/4k3/4p3/4K3/4P3/8/8 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.block, 'color': const Color(0xFFE53935)},
      {'title': 'Triangulation #1', 'description': 'Lose a tempo with triangulation', 'fen': '8/8/8/4k3/8/4K3/4P3/8 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.change_history, 'color': const Color(0xFF5C6BC0)},
      {'title': 'Triangulation #2', 'description': 'Advanced triangulation technique', 'fen': '8/8/3k4/3p4/3K4/3P4/8/8 w - - 0 1', 'difficulty': 'Expert', 'icon': Icons.change_history, 'color': const Color(0xFF5C6BC0)},
      {'title': 'Connected Passed Pawns', 'description': 'Power of connected pawns', 'fen': '8/5k2/8/3PP3/8/5K2/8/8 w - - 0 1', 'difficulty': 'Easy', 'icon': Icons.link, 'color': const Color(0xFF29B6F6)},
      {'title': 'Doubled Pawns Defense', 'description': 'Defend with doubled pawns', 'fen': '8/5k2/5p2/5P2/5P2/5K2/8/8 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.vertical_align_center, 'color': const Color(0xFF8D6E63)},
      {'title': 'Isolated Pawn Endgame', 'description': 'Exploit isolated pawn weakness', 'fen': '8/5k2/8/3p4/8/3P4/5K2/8 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.panorama_fish_eye, 'color': const Color(0xFFFF7043)},

      // ROOK ENDGAMES (31-50)
      {'title': 'Rook vs Pawn #1', 'description': 'Stop the passed pawn', 'fen': '8/8/8/8/8/1k6/1p6/1KR5 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.shield, 'color': const Color(0xFF42A5F5)},
      {'title': 'Rook vs Pawn #2', 'description': 'Cutting off the king', 'fen': '8/8/8/8/1k6/1p6/8/1KR5 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.shield, 'color': const Color(0xFF42A5F5)},
      {'title': 'Lucena Position', 'description': 'Classic winning technique', 'fen': '1K6/1P1k4/8/8/8/8/5r2/5R2 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.emoji_events, 'color': const Color(0xFFFFD54F)},
      {'title': 'Philidor Position', 'description': 'Defensive drawing technique', 'fen': '5k2/8/5K2/5P2/8/8/5r2/5R2 b - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.shield_outlined, 'color': const Color(0xFF78909C)},
      {'title': 'Back Rank Defense', 'description': 'Defend from the back rank', 'fen': '5k2/5P2/5K2/8/8/8/8/5r2 b - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.layers, 'color': const Color(0xFF9575CD)},
      {'title': 'Rook + Pawn vs Rook #1', 'description': 'Convert the extra pawn', 'fen': '8/5k2/5p2/5K2/5P2/8/8/4r1R1 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.add_circle, 'color': const Color(0xFF4CAF50)},
      {'title': 'Rook + Pawn vs Rook #2', 'description': 'Rook pawn difficulty', 'fen': '8/6k1/6p1/6K1/6P1/8/8/5r1R w - - 0 1', 'difficulty': 'Expert', 'icon': Icons.add_circle, 'color': const Color(0xFF4CAF50)},
      {'title': 'Active Rook Principle', 'description': 'Keep your rook active', 'fen': '8/5k2/8/3pK3/3P4/8/R7/4r3 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.directions_run, 'color': const Color(0xFFFF6F00)},
      {'title': 'Seventh Rank Dominance', 'description': 'Rook on the 7th rank power', 'fen': '6k1/R4ppp/8/8/8/8/5PPP/6K1 w - - 0 1', 'difficulty': 'Easy', 'icon': Icons.grade, 'color': const Color(0xFFFDD835)},
      {'title': 'Rook Behind Passed Pawn', 'description': 'Optimal rook placement', 'fen': '8/5k2/8/4P3/8/5K2/8/4R3 w - - 0 1', 'difficulty': 'Easy', 'icon': Icons.arrow_upward, 'color': const Color(0xFF7CB342)},
      {'title': 'Rook Cut-off Technique', 'description': 'Cut off opposing king', 'fen': '8/5k2/8/3K4/3P4/8/8/4r3 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.content_cut, 'color': const Color(0xFFEC407A)},
      {'title': 'Building a Bridge', 'description': 'Bridge building technique', 'fen': '8/8/8/5K2/5P2/5k2/8/5R2 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.architecture, 'color': const Color(0xFF8E24AA)},
      {'title': 'Skewer Tactics', 'description': 'Use skewer to win material', 'fen': '8/8/8/3k4/8/3K4/8/1r4R1 w - - 0 1', 'difficulty': 'Easy', 'icon': Icons.texture, 'color': const Color(0xFFD32F2F)},
      {'title': 'Rook Endgame Fortress', 'description': 'Create an impregnable fortress', 'fen': '8/5k2/5p2/5K2/5P2/8/8/5r1R w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.domain, 'color': const Color(0xFF616161)},
      {'title': 'Rook vs Two Pawns #1', 'description': 'Can rook stop both pawns?', 'fen': '8/8/8/8/2k5/2pp4/8/2KR4 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.looks_two, 'color': const Color(0xFF00897B)},
      {'title': 'Rook vs Two Pawns #2', 'description': 'Connected pawns advantage', 'fen': '8/8/8/1k6/1pp5/8/8/1KR5 w - - 0 1', 'difficulty': 'Expert', 'icon': Icons.looks_two, 'color': const Color(0xFF00897B)},
      {'title': 'Vancura Position', 'description': 'Drawing technique vs rook pawn', 'fen': '8/8/8/8/Pk6/8/8/1K4r1 b - - 0 1', 'difficulty': 'Expert', 'icon': Icons.save, 'color': const Color(0xFF546E7A)},
      {'title': 'Shouldering Technique', 'description': 'Push away opponent king', 'fen': '8/8/8/3k4/8/3K4/3P4/3R4 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.push_pin, 'color': const Color(0xFF1976D2)},
      {'title': 'Rook Pawn Special Case', 'description': 'Rook pawn drawing chances', 'fen': '8/6k1/6p1/6K1/6P1/8/8/7r w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.file_copy, 'color': const Color(0xFF757575)},
      {'title': 'Short-Side Defense', 'description': 'Defend from short side', 'fen': '5k2/5p2/5K2/5P2/8/8/8/2r3R1 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.swap_horiz, 'color': const Color(0xFFFF5722)},

      // QUEEN ENDGAMES (51-60)
      {'title': 'Queen vs Pawn #1', 'description': 'Win against advanced pawn', 'fen': '8/8/8/8/8/1k6/1p6/1KQ5 w - - 0 1', 'difficulty': 'Easy', 'icon': Icons.workspace_premium, 'color': const Color(0xFFE91E63)},
      {'title': 'Queen vs Pawn #2', 'description': 'Stopping bishop/rook pawn', 'fen': '8/8/8/8/6k1/6p1/6K1/6Q1 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.workspace_premium, 'color': const Color(0xFFE91E63)},
      {'title': 'Queen + Pawn vs Queen #1', 'description': 'Try to promote the pawn', 'fen': '8/5k2/8/4QK2/4P3/8/8/4q3 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.favorite, 'color': const Color(0xFFF06292)},
      {'title': 'Queen + Pawn vs Queen #2', 'description': 'Defend against promotion', 'fen': '8/4k3/8/3QK3/3P4/8/8/3q4 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.favorite, 'color': const Color(0xFFF06292)},
      {'title': 'Perpetual Check Defense', 'description': 'Save draw with checks', 'fen': '7k/5Q2/6K1/8/8/8/8/7q b - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.loop, 'color': const Color(0xFF26A69A)},
      {'title': 'Queen Stalemate Tricks #1', 'description': 'Avoid stalemate traps', 'fen': '7Q/8/7k/8/8/7K/8/8 w - - 0 1', 'difficulty': 'Easy', 'icon': Icons.warning, 'color': const Color(0xFFFF9800)},
      {'title': 'Queen Stalemate Tricks #2', 'description': 'Stalemate awareness', 'fen': '8/8/8/8/8/7k/7q/7K w - - 0 1', 'difficulty': 'Easy', 'icon': Icons.warning, 'color': const Color(0xFFFF9800)},
      {'title': 'Queen vs Rook #1', 'description': 'Win queen vs rook endgame', 'fen': '8/8/8/4k3/8/4K3/8/3Q3r w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.balance, 'color': const Color(0xFF9C27B0)},
      {'title': 'Queen vs Rook #2', 'description': 'Avoid fortress positions', 'fen': '8/8/8/8/4k3/8/4K2r/4Q3 w - - 0 1', 'difficulty': 'Expert', 'icon': Icons.balance, 'color': const Color(0xFF9C27B0)},
      {'title': 'Queen vs Two Minor Pieces', 'description': 'Queen vs bishop and knight', 'fen': '8/8/8/4k3/8/2BN4/4K3/4Q3 w - - 0 1', 'difficulty': 'Expert', 'icon': Icons.group_work, 'color': const Color(0xFF673AB7)},

      // MINOR PIECE ENDGAMES (61-75)
      {'title': 'Bishop vs Knight #1', 'description': 'Bishop vs knight advantage', 'fen': '8/8/8/4k3/8/2B5/4K3/4n3 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.compare, 'color': const Color(0xFF3F51B5)},
      {'title': 'Bishop vs Knight #2', 'description': 'Open position bishop strength', 'fen': '8/8/3k4/8/3B4/3K4/8/6n1 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.compare, 'color': const Color(0xFF3F51B5)},
      {'title': 'Same-Color Bishops', 'description': 'Same bishop color endgame', 'fen': '8/5k2/8/3B4/8/3b4/5K2/8 w - - 0 1', 'difficulty': 'Easy', 'icon': Icons.brightness_1, 'color': const Color(0xFF8BC34A)},
      {'title': 'Opposite-Color Bishops', 'description': 'Drawing tendencies explained', 'fen': '8/5k2/8/3B4/8/3b4/5K2/8 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.brightness_4, 'color': const Color(0xFFCDDC39)},
      {'title': 'Good vs Bad Bishop', 'description': 'Pawns on bishop color matter', 'fen': '8/4kp2/5p2/4pB2/4P3/4P3/4K3/3b4 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.thumb_up, 'color': const Color(0xFF4CAF50)},
      {'title': 'Bishop + Pawn vs Bishop', 'description': 'Can you promote?', 'fen': '8/5k2/8/3BpK2/8/8/8/3b4 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.add_box, 'color': const Color(0xFF00BCD4)},
      {'title': 'Knight + Pawn vs Knight', 'description': 'Knight endgame complexity', 'fen': '8/5k2/8/3NpK2/8/8/8/3n4 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.casino, 'color': const Color(0xFF009688)},
      {'title': 'Bishop vs Pawns #1', 'description': 'Stop multiple pawns', 'fen': '8/8/8/8/2k5/2pp4/2B5/2K5 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.grain, 'color': const Color(0xFF795548)},
      {'title': 'Bishop vs Pawns #2', 'description': 'Bishop blockade technique', 'fen': '8/8/1k6/1pp5/1B6/1K6/8/8 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.grain, 'color': const Color(0xFF795548)},
      {'title': 'Knight vs Pawns #1', 'description': 'Knight stops passed pawns', 'fen': '8/8/8/8/2k5/2pp4/2N5/2K5 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.sports_esports, 'color': const Color(0xFF00838F)},
      {'title': 'Knight vs Pawns #2', 'description': 'Knight maneuvering skills', 'fen': '8/8/1k6/1pp5/1N6/1K6/8/8 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.sports_esports, 'color': const Color(0xFF00838F)},
      {'title': 'Wrong Bishop Draw', 'description': 'Wrong color bishop saves draw', 'fen': '8/8/8/8/8/1k6/1p6/1KB5 w - - 0 1', 'difficulty': 'Easy', 'icon': Icons.error_outline, 'color': const Color(0xFFFF5252)},
      {'title': 'Bishops of Same Color', 'description': 'Attacking with same bishops', 'fen': '8/5k2/5p2/4pB2/4P3/4P3/4K3/3b4 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.group, 'color': const Color(0xFF7E57C2)},
      {'title': 'Knight Outpost', 'description': 'Dominating knight position', 'fen': '8/5k2/8/3N4/8/8/5K2/8 w - - 0 1', 'difficulty': 'Easy', 'icon': Icons.stars, 'color': const Color(0xFF26C6DA)},
      {'title': 'Bishop Pair Advantage', 'description': 'Two bishops vs bishop + knight', 'fen': '8/5k2/8/3BB3/8/8/3Nb3/5K2 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.auto_awesome_mosaic, 'color': const Color(0xFFAB47BC)},

      // COMPLEX ENDGAMES (76-90)
      {'title': 'Rook + Bishop vs Rook', 'description': 'Convert extra piece to win', 'fen': '8/5k2/8/8/8/3RBK2/8/5r2 w - - 0 1', 'difficulty': 'Expert', 'icon': Icons.add_circle_outline, 'color': const Color(0xFF5C6BC0)},
      {'title': 'Rook + Knight vs Rook', 'description': 'Winning with rook + knight', 'fen': '8/5k2/8/8/8/3RNK2/8/5r2 w - - 0 1', 'difficulty': 'Expert', 'icon': Icons.control_point, 'color': const Color(0xFF7E57C2)},
      {'title': 'Queen vs Rook + Bishop', 'description': 'Queen against rook + bishop', 'fen': '8/5k2/8/8/8/3Q4/8/3rb1K1 w - - 0 1', 'difficulty': 'Expert', 'icon': Icons.unfold_more, 'color': const Color(0xFF8E24AA)},
      {'title': 'Queen vs Rook + Knight', 'description': 'Complex queen endgame', 'fen': '8/5k2/8/8/8/3Q4/8/3rn1K1 w - - 0 1', 'difficulty': 'Expert', 'icon': Icons.unfold_less, 'color': const Color(0xFF9C27B0)},
      {'title': 'Two Knights vs Pawn', 'description': 'Can two knights win?', 'fen': '8/8/8/8/8/1k6/1p6/1KNN4 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.looks_two, 'color': const Color(0xFF00897B)},
      {'title': 'Rook + Pawn vs Bishop + Pawn', 'description': 'Material balance endgame', 'fen': '8/5k1p/8/5KP1/8/8/3B4/3R4 w - - 0 1', 'difficulty': 'Expert', 'icon': Icons.scale, 'color': const Color(0xFF43A047)},
      {'title': 'Two Bishops vs Knight', 'description': 'Bishop pair dominance', 'fen': '8/5k2/8/8/8/3BB3/3N4/5K2 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.compare_arrows, 'color': const Color(0xFF3949AB)},
      {'title': 'Rook + Two Pawns vs Rook + Pawn', 'description': 'Extra pawn advantage', 'fen': '8/5kp1/6p1/8/6P1/5PKP/8/3r2R1 w - - 0 1', 'difficulty': 'Expert', 'icon': Icons.exposure_plus_1, 'color': const Color(0xFF1E88E5)},
      {'title': 'Bishop + Two Pawns vs Bishop', 'description': 'Two pawns vs bishop', 'fen': '8/5k2/5p2/4pB2/4P3/4P3/4K3/3b4 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.add_box, 'color': const Color(0xFF00ACC1)},
      {'title': 'Knight + Two Pawns vs Knight', 'description': 'Knight pawn endgame', 'fen': '8/5k2/5p2/4pN2/4P3/4P3/4K3/3n4 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.exposure_plus_2, 'color': const Color(0xFF00897B)},
      {'title': 'Fortress Drawing Technique', 'description': 'Build impregnable fortress', 'fen': '8/8/8/8/5k2/5pB1/5P2/5K2 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.security, 'color': const Color(0xFF546E7A)},
      {'title': 'Piece Sacrifice for Pawn', 'description': 'Sacrifice piece to promote', 'fen': '8/5k1P/8/5K2/8/8/3b4/3R4 w - - 0 1', 'difficulty': 'Advanced', 'icon': Icons.compare_arrows, 'color': const Color(0xFFD32F2F)},
      {'title': 'Desperado Piece', 'description': 'Trade doomed piece favorably', 'fen': '8/5k2/5p2/4pP2/4P3/4K3/3b4/3B4 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.flash_on, 'color': const Color(0xFFF57C00)},
      {'title': 'Mate with Bishop + Knight #2', 'description': 'Advanced B+N technique', 'fen': '8/8/8/8/8/2k5/2BN4/2K5 w - - 0 1', 'difficulty': 'Expert', 'icon': Icons.military_tech, 'color': const Color(0xFF6A1B9A)},
      {'title': 'Mate with Bishop + Knight #3', 'description': 'Corner mating pattern', 'fen': '7k/8/6BN/8/8/8/8/6K1 w - - 0 1', 'difficulty': 'Expert', 'icon': Icons.military_tech, 'color': const Color(0xFF6A1B9A)},

      // TACTICAL ENDGAMES (91-100)
      {'title': 'Endgame Skewer #1', 'description': 'Win material with skewer', 'fen': '8/8/8/3k4/8/3K4/8/1r4R1 w - - 0 1', 'difficulty': 'Easy', 'icon': Icons.arrow_forward, 'color': const Color(0xFFEF5350)},
      {'title': 'Endgame Pin #1', 'description': 'Use pin to win material', 'fen': '8/8/8/3k4/3r4/3K4/3R4/8 w - - 0 1', 'difficulty': 'Easy', 'icon': Icons.push_pin, 'color': const Color(0xFFEC407A)},
      {'title': 'Endgame Fork #1', 'description': 'Knight fork in endgame', 'fen': '8/8/8/3k4/8/3K1r2/8/5N2 w - - 0 1', 'difficulty': 'Easy', 'icon': Icons.call_split, 'color': const Color(0xFFAB47BC)},
      {'title': 'Deflection Tactic', 'description': 'Deflect defending piece', 'fen': '8/8/8/3k4/3p4/3K4/3R4/5r2 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.trending_down, 'color': const Color(0xFF7E57C2)},
      {'title': 'Decoy Sacrifice', 'description': 'Lure piece to bad square', 'fen': '8/8/8/3k4/3p4/3K4/3R4/5r2 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.gps_fixed, 'color': const Color(0xFF5C6BC0)},
      {'title': 'Clearance Tactic', 'description': 'Clear square for promotion', 'fen': '8/5k1P/8/5K2/8/8/3r4/3R4 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.clear_all, 'color': const Color(0xFF42A5F5)},
      {'title': 'Intermediate Check', 'description': 'In-between check tactic', 'fen': '8/5k2/8/4K3/4P3/8/8/4r1R1 w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.check_circle, 'color': const Color(0xFF29B6F6)},
      {'title': 'Zugzwang Masterclass', 'description': 'Complex zugzwang position', 'fen': '8/8/8/3pk3/3pP3/3P4/3K4/8 w - - 0 1', 'difficulty': 'Expert', 'icon': Icons.block, 'color': const Color(0xFFE53935)},
      {'title': 'Stalemate Trap #1', 'description': 'Avoid giving stalemate', 'fen': '7k/5Q2/6K1/8/8/8/8/8 w - - 0 1', 'difficulty': 'Easy', 'icon': Icons.dangerous, 'color': const Color(0xFFFF6F00)},
      {'title': 'Stalemate Trap #2', 'description': 'Complex stalemate defense', 'fen': '8/8/8/8/8/7k/7q/7K w - - 0 1', 'difficulty': 'Intermediate', 'icon': Icons.dangerous, 'color': const Color(0xFFFF6F00)},
    ];
    /*final drills = [
      {
        'title': 'King and Pawn vs King',
        'description': 'Master pawn promotion with perfect king support',
        'fen': '8/8/8/4k3/8/4K3/4P3/8 w - - 0 1',
        'difficulty': 'Beginner',
        'icon': Icons.star_outline,
        'color': const Color(0xFF4CAF50),
      },
      {
        'title': 'Rook and King vs King',
        'description': 'Execute the classic rook checkmate pattern',
        'fen': '8/8/8/8/8/4k3/8/R3K3 w - - 0 1',
        'difficulty': 'Beginner',
        'icon': Icons.castle,
        'color': const Color(0xFF2196F3),
      },
      {
        'title': 'Queen and King vs King',
        'description': 'Deliver efficient queen checkmate techniques',
        'fen': '8/8/8/8/4k3/8/8/Q3K3 w - - 0 1',
        'difficulty': 'Easy',
        'icon': Icons.workspace_premium,
        'color': const Color(0xFF9C27B0),
      },
      {
        'title': 'Two Rooks vs King',
        'description': 'Perfect the powerful ladder mate strategy',
        'fen': '8/8/8/8/4k3/8/R7/R3K3 w - - 0 1',
        'difficulty': 'Intermediate',
        'icon': Icons.view_column,
        'color': const Color(0xFFFF9800),
      },
      {
        'title': 'King and Two Bishops vs King',
        'description': 'Master the elegant two bishops checkmate',
        'fen': '8/8/8/4k3/8/3BKB2/8/8 w - - 0 1',
        'difficulty': 'Advanced',
        'icon': Icons.auto_awesome,
        'color': const Color(0xFFF44336),
      },
    ];*/

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Endgame Drills',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1B4D3E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1B4D3E).withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: drills.length,
          itemBuilder: (context, index) {
            final drill = drills[index];
            return _buildDrillCard(context, drill, index);
          },
        ),
      ),
    );
  }

  Widget _buildDrillCard(BuildContext context, Map<String, dynamic> drill, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (drill['color'] as Color).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: (drill['color'] as Color).withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EndgameDrillDetailPage(
                  title: drill['title']!,
                  fen: drill['fen']!,
                  description: drill['description']!,
                  difficulty: drill['difficulty']!,
                  color: drill['color'] as Color,
                  icon: drill['icon'] as IconData,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        drill['color'] as Color,
                        (drill['color'] as Color).withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (drill['color'] as Color).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    drill['icon'] as IconData,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              drill['title']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (drill['color'] as Color).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (drill['color'] as Color).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              drill['difficulty']!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: drill['color'] as Color,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        drill['description']!,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: drill['color'] as Color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EndgameDrillDetailPage extends StatefulWidget {
  final String title;
  final String fen;
  final String description;
  final String difficulty;
  final Color color;
  final IconData icon;

  const EndgameDrillDetailPage({
    super.key,
    required this.title,
    required this.fen,
    required this.description,
    required this.difficulty,
    required this.color,
    required this.icon,
  });

  @override
  State<EndgameDrillDetailPage> createState() => _EndgameDrillDetailPageState();
}

class _EndgameDrillDetailPageState extends State<EndgameDrillDetailPage>
    with SingleTickerProviderStateMixin {
  bool _isPracticing = false;
  late chess_lib.Chess _chess;
  String _currentFen = '';
  String _statusMessage = '';
  int _moveCount = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentFen = widget.fen;
    _chess = chess_lib.Chess.fromFEN(widget.fen);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startPractice() {
    setState(() {
      _isPracticing = true;
      _currentFen = widget.fen;
      _chess = chess_lib.Chess.fromFEN(widget.fen);
      _moveCount = 0;
      _statusMessage = '♟️ Your turn! Play as White and find the winning moves.';
    });
    _animationController.forward();
  }

  void _resetPractice() {
    setState(() {
      _currentFen = widget.fen;
      _chess = chess_lib.Chess.fromFEN(widget.fen);
      _moveCount = 0;
      _statusMessage = '♟️ Position reset. Good luck!';
    });
  }

  void _exitPractice() {
    _animationController.reverse().then((_) {
      setState(() {
        _isPracticing = false;
        _currentFen = widget.fen;
        _statusMessage = '';
      });
    });
  }

  void _handleMove(Position from, Position to) {
    // Convert Position objects to chess notation (e.g., 'e2', 'e4')
    final fromStr = '${String.fromCharCode(97 + from.col)}${8 - from.row}';
    final toStr = '${String.fromCharCode(97 + to.col)}${8 - to.row}';

    final move = _chess.move({'from': fromStr, 'to': toStr});

    if (move != null) {
      setState(() {
        _currentFen = _chess.fen;
        _moveCount++;

        if (_chess.in_checkmate) {
          _statusMessage = '🎉 Brilliant! Checkmate in $_moveCount moves!';
          _showSuccessDialog();
        } else if (_chess.in_check) {
          _statusMessage = '⚔️ Check! Keep up the pressure...';
          _makeComputerMove();
        } else if (_chess.in_stalemate) {
          _statusMessage = '🤔 Stalemate! Remember to give the king space.';
        } else if (_chess.in_draw) {
          _statusMessage = '⏱️ Draw! Try to checkmate faster.';
        } else {
          _statusMessage = '✓ Nice move! Black is thinking...';
          _makeComputerMove();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.white),
              SizedBox(width: 12),
              Text('Illegal move! Try again.'),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _makeComputerMove() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      final moves = _chess.moves();
      if (moves.isNotEmpty) {
        final randomMove = moves[0];
        _chess.move(randomMove);

        setState(() {
          _currentFen = _chess.fen;

          if (_chess.in_checkmate) {
            _statusMessage = '😞 Black checkmated you! Study the position and try again.';
          } else if (_chess.in_check) {
            _statusMessage = '⚠️ Black checks you! Defend or counter-attack.';
          } else if (_chess.game_over) {
            _statusMessage = '🏁 Game over!';
          } else {
            _statusMessage = '♟️ Your turn! Find the best move.';
          }
        });
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: widget.color, size: 32),
            const SizedBox(width: 12),
            const Text('Victory!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Congratulations! You delivered checkmate in $_moveCount moves.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_outlined),
                  const SizedBox(width: 8),
                  Text(
                    '$_moveCount moves',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetPractice();
            },
            child: const Text('Try Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exitPractice();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: widget.color,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: _isPracticing
            ? [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _resetPractice,
            tooltip: 'Reset Position',
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: _exitPractice,
            tooltip: 'Exit Practice',
          ),
        ]
            : null,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.color.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isPracticing) _buildObjectiveCard(),
              if (_isPracticing && _statusMessage.isNotEmpty) _buildStatusCard(),
              _buildChessBoard(),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObjectiveCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.color, widget.color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Objective',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.difficulty,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.description,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    IconData statusIcon;
    Color statusColor;

    if (_statusMessage.contains('🎉')) {
      statusIcon = Icons.emoji_events;
      statusColor = Colors.green;
    } else if (_statusMessage.contains('😞')) {
      statusIcon = Icons.warning_rounded;
      statusColor = Colors.red;
    } else if (_statusMessage.contains('⚔️') || _statusMessage.contains('⚠️')) {
      statusIcon = Icons.warning_amber_rounded;
      statusColor = Colors.orange;
    } else {
      statusIcon = Icons.lightbulb_outline;
      statusColor = widget.color;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              statusColor.withValues(alpha: 0.15),
              statusColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _statusMessage,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChessBoard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxWidth > 400 ? 400.0 : constraints.maxWidth;
          return Center(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ChessBoardWidget(
                  fen: _currentFen,
                  isInteractive: _isPracticing,
                  onMove: _isPracticing ? _handleMove : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isPracticing) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.trending_up, 'Moves', '$_moveCount'),
                  Container(width: 1, height: 40, color: Colors.grey[300]),
                  _buildStatItem(
                    Icons.circle,
                    'Turn',
                    _chess.turn == chess_lib.Color.WHITE ? 'White' : 'Black',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (!_isPracticing) ...[
            const Text(
              'How to Practice',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTip(Icons.visibility, 'Study the position and identify key squares'),
            _buildTip(Icons.psychology, 'Calculate the winning sequence of moves'),
            _buildTip(Icons.repeat, 'Practice until you can execute it perfectly'),
            const SizedBox(height: 24),
          ],

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isPracticing ? _resetPractice : _startPractice,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: widget.color.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_isPracticing ? Icons.refresh_rounded : Icons.play_arrow_rounded, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    _isPracticing ? 'Reset Position' : 'Start Practice',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: widget.color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: widget.color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}