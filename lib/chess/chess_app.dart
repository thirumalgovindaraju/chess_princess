// lib/chess/chess_app.dart
import 'package:flutter/material.dart';
import '../models/chess_board.dart';
import '../models/position.dart';
import '../screens/chess_menu_screen.dart';
import '../screens/puzzle_screen.dart';
import '../models/chess_puzzle.dart';
import '../widgets/chess_board_widget.dart';

class ChessApp extends StatelessWidget {
  const ChessApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Game',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.indigo.shade700,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const ChessMenuScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/menu': (context) => const ChessMenuScreen(),
        '/puzzle': (context) => const PuzzleSelectionScreen(),
        '/game': (context) => const ChessGameScreen(),
      },
    );
  }
}

class PuzzleSelectionScreen extends StatelessWidget {
  const PuzzleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Puzzle Mode'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPuzzleModeCard(
              context,
              title: 'Tactical Puzzles',
              subtitle: 'Solve chess puzzles by difficulty',
              icon: Icons.psychology,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PuzzleScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildPuzzleModeCard(
              context,
              title: 'Easy Puzzles',
              subtitle: 'Beginner-friendly chess puzzles',
              icon: Icons.school,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PuzzleScreen(
                      selectedDifficulty: PuzzleDifficulty.easy,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildPuzzleModeCard(
              context,
              title: 'Medium Puzzles',
              subtitle: 'Intermediate chess puzzles',
              icon: Icons.trending_up,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PuzzleScreen(
                      selectedDifficulty: PuzzleDifficulty.medium,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildPuzzleModeCard(
              context,
              title: 'Hard Puzzles',
              subtitle: 'Advanced chess puzzles',
              icon: Icons.military_tech,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PuzzleScreen(
                      selectedDifficulty: PuzzleDifficulty.hard,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPuzzleModeCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.indigo),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}

class ChessGameScreen extends StatefulWidget {
  final bool isVsAI;
  final String? difficulty;

  const ChessGameScreen({
    Key? key,
    this.isVsAI = true,
    this.difficulty = 'Medium',
  }) : super(key: key);

  @override
  State<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends State<ChessGameScreen> {
  late ChessBoard chessBoard;
  bool isWhiteTurn = true;
  List<String> moveHistory = [];
  Duration whiteTime = const Duration(minutes: 10);
  Duration blackTime = const Duration(minutes: 10);
  bool gameStarted = false;

  @override
  void initState() {
    super.initState();
    chessBoard = ChessBoard.initial();
  }

  void _onMove(Position from, Position to) {
    setState(() {
      bool moveSuccess = chessBoard.makeMove(from, to);
      if (moveSuccess) {
        if (!gameStarted) {
          gameStarted = true;
        }
        isWhiteTurn = !isWhiteTurn;

        String fromSquare = _positionToSquare(from);
        String toSquare = _positionToSquare(to);
        moveHistory.add('$fromSquare-$toSquare');
      }
    });
  }

  String _positionToSquare(Position pos) {
    String file = String.fromCharCode('a'.codeUnitAt(0) + pos.col);
    String rank = (8 - pos.row).toString();
    return file + rank;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isVsAI ? 'vs AI (${widget.difficulty})' : 'vs Human'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                chessBoard = ChessBoard.initial();
                isWhiteTurn = true;
                moveHistory.clear();
                gameStarted = false;
                whiteTime = const Duration(minutes: 10);
                blackTime = const Duration(minutes: 10);
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: ChessBoardWidget(
                          board: chessBoard,
                          onMove: _onMove,
                          isInteractive: true,
                          showCoordinates: true,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildGameInfo(),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildGameInfo(),
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
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
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildGameInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Black'),
                      Text(
                        '${blackTime.inMinutes}:${(blackTime.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('White'),
                      Text(
                        '${whiteTime.inMinutes}:${(whiteTime.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isWhiteTurn ? Colors.white : Colors.grey.shade800,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${isWhiteTurn ? "White" : "Black"} to move',
              style: TextStyle(
                color: isWhiteTurn ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Move History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: moveHistory.isEmpty
                          ? const Center(
                        child: Text('No moves yet'),
                      )
                          : ListView.builder(
                        itemCount: moveHistory.length,
                        itemBuilder: (context, index) {
                          return Text(
                            '${index + 1}. ${moveHistory[index]}',
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
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
}