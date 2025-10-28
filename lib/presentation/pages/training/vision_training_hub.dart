// lib/presentation/pages/training/vision_training_hub.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess_princess/presentation/pages/training/move_visualization_page.dart';
import 'package:chess_princess/presentation/pages/training/blindfold_game_page.dart';
import 'package:chess_princess/presentation/pages/training/vision_trainer_page.dart';
import 'package:chess_princess/presentation/pages/training/check_detection_page.dart';
enum VisionTrainingMode {
  positionMemory,
  coordinateTraining,
  patternRecognition,
  moveVisualization,
  blindfoldGame,
  knightTour,
  checkDetection,
}

class VisionTrainingHub extends ConsumerWidget {
  const VisionTrainingHub({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Vision Training',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepPurple,
                      Colors.purple.shade700,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.visibility,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildListDelegate([
                _buildModeCard(
                  context,
                  'Position Memory',
                  'Memorize and reconstruct chess positions',
                  Icons.memory,
                  Colors.blue,
                  VisionTrainingMode.positionMemory,
                ),
                _buildModeCard(
                  context,
                  'Coordinate Training',
                  'Master board coordinates and square names',
                  Icons.grid_on,
                  Colors.green,
                  VisionTrainingMode.coordinateTraining,
                ),
                _buildModeCard(
                  context,
                  'Pattern Recognition',
                  'Identify tactical patterns instantly',
                  Icons.analytics,
                  Colors.orange,
                  VisionTrainingMode.patternRecognition,
                ),
                _buildModeCard(
                  context,
                  'Move Visualization',
                  'Visualize piece movements blindfolded',
                  Icons.play_arrow,
                  Colors.purple,
                  VisionTrainingMode.moveVisualization,
                ),
                _buildModeCard(
                  context,
                  'Blindfold Game',
                  'Play complete games without seeing the board',
                  Icons.visibility_off,
                  Colors.red,
                  VisionTrainingMode.blindfoldGame,
                ),
                _buildModeCard(
                  context,
                  'Knight Tour',
                  'Navigate the knight across the board',
                  Icons.local_fire_department,
                  Colors.indigo,
                  VisionTrainingMode.knightTour,
                ),
                _buildModeCard(
                  context,
                  'Check Detection',
                  'Find checks and threats quickly',
                  Icons.warning,
                  Colors.amber,
                  VisionTrainingMode.checkDetection,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(
      BuildContext context,
      String title,
      String description,
      IconData icon,
      Color color,
      VisionTrainingMode mode,
      ) {
    return GestureDetector(
      onTap: () => _navigateToMode(context, mode),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _navigateToMode(BuildContext context, VisionTrainingMode mode) {
    Widget? page;

    switch (mode) {
      case VisionTrainingMode.positionMemory:
      // Import: import 'vision_trainer_page.dart';
        page = const VisionTrainerPage();
        break;
      case VisionTrainingMode.coordinateTraining:
        page = const CoordinateTrainingPage();
        break;
      case VisionTrainingMode.patternRecognition:
        page = const PatternRecognitionPage();
        break;
      case VisionTrainingMode.moveVisualization:
      // Import: import 'move_visualization_page.dart';
        page = const MoveVisualizationPage();
        break;
      case VisionTrainingMode.blindfoldGame:
      // Import: import 'blindfold_game_page.dart';
        page = const BlindfoldGamePage();
        break;
      case VisionTrainingMode.knightTour:
        page = const KnightTourPage();
        break;
      case VisionTrainingMode.checkDetection:
      // Import: import 'check_detection_page.dart';
        page = const CheckDetectionPage();
        break;
    }

    if (page != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page!),
      );
    }
  }
}

// ============================================
// COORDINATE TRAINING MODE
// ============================================

class CoordinateTrainingPage extends ConsumerStatefulWidget {
  const CoordinateTrainingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CoordinateTrainingPage> createState() => _CoordinateTrainingPageState();
}

class _CoordinateTrainingPageState extends ConsumerState<CoordinateTrainingPage> {
  String _targetSquare = '';
  int _score = 0;
  int _timeLimit = 5;
  int _remainingTime = 5;
  bool _gameActive = false;
  final List<String> _squares = [];

  @override
  void initState() {
    super.initState();
    _generateSquares();
    _startRound();
  }

  void _generateSquares() {
    for (int rank = 1; rank <= 8; rank++) {
      for (int file = 0; file < 8; file++) {
        _squares.add('${String.fromCharCode(97 + file)}$rank');
      }
    }
  }

  void _startRound() {
    setState(() {
      _targetSquare = _squares[DateTime.now().millisecond % _squares.length];
      _remainingTime = _timeLimit;
      _gameActive = true;
    });
  }

  void _onSquareSelected(String square) {
    if (!_gameActive) return;

    final isCorrect = square == _targetSquare;
    if (isCorrect) {
      setState(() {
        _score += 10;
        _gameActive = false;
      });
      Future.delayed(const Duration(milliseconds: 500), _startRound);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coordinate Training'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.green.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Score', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('$_score', style: const TextStyle(fontSize: 24)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Time', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('$_remainingTime', style: const TextStyle(fontSize: 24)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Find: $_targetSquare',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: _buildChessBoard(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChessBoard() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      itemCount: 64,
      itemBuilder: (context, index) {
        final rank = 8 - (index ~/ 8);
        final file = index % 8;
        final square = '${String.fromCharCode(97 + file)}$rank';
        final isLight = (rank + file) % 2 == 0;

        return GestureDetector(
          onTap: () => _onSquareSelected(square),
          child: Container(
            decoration: BoxDecoration(
              color: isLight ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
            child: Center(
              child: Text(
                square,
                style: TextStyle(
                  color: isLight ? Colors.black54 : Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================
// PATTERN RECOGNITION MODE
// ============================================

enum TacticalPattern {
  fork,
  pin,
  skewer,
  discoveredAttack,
  backRankMate,
}

class PatternRecognitionPage extends ConsumerStatefulWidget {
  const PatternRecognitionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PatternRecognitionPage> createState() => _PatternRecognitionPageState();
}

class _PatternRecognitionPageState extends ConsumerState<PatternRecognitionPage> {
  int _score = 0;
  int _streak = 0;
  TacticalPattern? _currentPattern;

  final Map<TacticalPattern, String> _patternDescriptions = {
    TacticalPattern.fork: 'A piece attacks two or more enemy pieces simultaneously',
    TacticalPattern.pin: 'A piece cannot move without exposing a more valuable piece',
    TacticalPattern.skewer: 'Force a valuable piece to move, exposing a less valuable piece',
    TacticalPattern.discoveredAttack: 'Moving one piece reveals an attack by another',
    TacticalPattern.backRankMate: 'Checkmate on the back rank with trapped king',
  };

  @override
  void initState() {
    super.initState();
    _generatePattern();
  }

  void _generatePattern() {
    setState(() {
      _currentPattern = TacticalPattern.values[
      DateTime.now().millisecond % TacticalPattern.values.length
      ];
    });
  }

  void _checkAnswer(TacticalPattern selected) {
    final isCorrect = selected == _currentPattern;

    setState(() {
      if (isCorrect) {
        _score += 15;
        _streak++;
      } else {
        _streak = 0;
      }
    });

    _showFeedback(isCorrect);
    Future.delayed(const Duration(seconds: 2), _generatePattern);
  }

  void _showFeedback(bool isCorrect) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? '✓ Correct!' : '✗ Try again'),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pattern Recognition'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.orange.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Score', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('$_score', style: const TextStyle(fontSize: 24)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Streak', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('$_streak', style: const TextStyle(fontSize: 24)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Identify the Pattern:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Chess position would be displayed here
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('Chess Position Here'),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: TacticalPattern.values.map((pattern) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _checkAnswer(pattern),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade600,
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _formatPatternName(pattern),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPatternName(TacticalPattern pattern) {
    return pattern.name.replaceAllMapped(
      RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
    ).trim();
  }
}

// ============================================
// KNIGHT TOUR MODE
// ============================================

class KnightTourPage extends ConsumerStatefulWidget {
  const KnightTourPage({Key? key}) : super(key: key);

  @override
  ConsumerState<KnightTourPage> createState() => _KnightTourPageState();
}

class _KnightTourPageState extends ConsumerState<KnightTourPage> {
  String _knightPosition = 'e4';
  String _targetSquare = 'a1';
  int _moves = 0;
  int _bestScore = 0;
  final Set<String> _visitedSquares = {};

  @override
  void initState() {
    super.initState();
    _generateNewTarget();
  }

  void _generateNewTarget() {
    final squares = <String>[];
    for (int rank = 1; rank <= 8; rank++) {
      for (int file = 0; file < 8; file++) {
        final square = '${String.fromCharCode(97 + file)}$rank';
        if (square != _knightPosition) {
          squares.add(square);
        }
      }
    }
    setState(() {
      _targetSquare = squares[DateTime.now().millisecond % squares.length];
      _visitedSquares.clear();
      _visitedSquares.add(_knightPosition);
    });
  }

  bool _isValidKnightMove(String from, String to) {
    final fromFile = from.codeUnitAt(0) - 97;
    final fromRank = int.parse(from[1]);
    final toFile = to.codeUnitAt(0) - 97;
    final toRank = int.parse(to[1]);

    final fileDiff = (fromFile - toFile).abs();
    final rankDiff = (fromRank - toRank).abs();

    return (fileDiff == 2 && rankDiff == 1) || (fileDiff == 1 && rankDiff == 2);
  }

  void _onSquareTapped(String square) {
    if (!_isValidKnightMove(_knightPosition, square)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid knight move!'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      _knightPosition = square;
      _moves++;
      _visitedSquares.add(square);
    });

    if (square == _targetSquare) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    final score = 100 - (_moves * 5);
    if (score > _bestScore) {
      setState(() => _bestScore = score);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Target Reached!'),
        content: Text('Moves: $_moves\nScore: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _moves = 0;
              });
              _generateNewTarget();
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Knight Tour'),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.indigo.shade100,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Moves', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('$_moves', style: const TextStyle(fontSize: 24)),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Best', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('$_bestScore', style: const TextStyle(fontSize: 24)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Move knight to: $_targetSquare',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: _buildChessBoard(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChessBoard() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      itemCount: 64,
      itemBuilder: (context, index) {
        final rank = 8 - (index ~/ 8);
        final file = index % 8;
        final square = '${String.fromCharCode(97 + file)}$rank';
        final isLight = (rank + file) % 2 == 0;
        final isKnight = square == _knightPosition;
        final isTarget = square == _targetSquare;
        final isVisited = _visitedSquares.contains(square);

        return GestureDetector(
          onTap: () => _onSquareTapped(square),
          child: Container(
            decoration: BoxDecoration(
              color: isTarget
                  ? Colors.green.shade400
                  : isLight
                  ? Colors.grey.shade300
                  : Colors.grey.shade700,
            ),
            child: Center(
              child: isKnight
                  ? const Text('♞', style: TextStyle(fontSize: 40))
                  : isVisited
                  ? Icon(Icons.circle, size: 12, color: Colors.blue.shade300)
                  : null,
            ),
          ),
        );
      },
    );
  }
}