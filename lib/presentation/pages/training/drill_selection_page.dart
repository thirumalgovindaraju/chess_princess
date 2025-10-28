// lib/presentation/pages/training/drill_selection_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess_princess/domain/entities/drill.dart';
import 'package:chess_princess/presentation/pages/training/drill_practice_page.dart';

class DrillSelectionPage extends ConsumerStatefulWidget {
  final DrillType drillType;

  const DrillSelectionPage({
    Key? key,
    required this.drillType,
  }) : super(key: key);

  @override
  ConsumerState<DrillSelectionPage> createState() => _DrillSelectionPageState();
}

class _DrillSelectionPageState extends ConsumerState<DrillSelectionPage> {
  List<Drill> _drills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrills();
  }

  Future<void> _loadDrills() async {
    setState(() => _isLoading = true);

    // Simulate loading drills - replace with actual data loading
    await Future.delayed(const Duration(milliseconds: 500));

    // Sample drills based on type
    final drills = _generateSampleDrills(widget.drillType);

    setState(() {
      _drills = drills;
      _isLoading = false;
    });
  }

  List<Drill> _generateSampleDrills(DrillType type) {
    switch (type) {
      case DrillType.endgame:
        return [
          Drill(
            id: 'eg1',
            name: 'King & Pawn Endgames',
            description: 'Learn fundamental king and pawn endgame techniques',
            type: DrillType.endgame,
            difficulty: 'beginner',
            solutionMoves: ['e4', 'Kf3', 'Bb5'],
            hints: ['Focus on keeping the king active'],
            fen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
          ),
          Drill(
            id: 'eg2',
            name: 'Rook Endgames',
            description: 'Master essential rook endgame positions',
            type: DrillType.endgame,
            difficulty: 'intermediate',
            solutionMoves: ['Rb7', 'Kg5', 'Rb5'],
            hints: ['Keep your rook active', 'Centralize your king'],
            fen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
          ),
          Drill(
            id: 'eg3',
            name: 'Queen vs Pawn',
            description: 'Practice queen versus advanced pawn positions',
            type: DrillType.endgame,
            difficulty: 'advanced',
            solutionMoves: ['Qd8', 'Qe7', 'Qf6'],
            hints: ['Stop the pawn first', 'Then move in for the win'],
            fen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
          ),
        ];
      case DrillType.opening:
        return [
          Drill(
            id: 'op1',
            name: 'Italian Game Basics',
            description: 'Learn the fundamental ideas of the Italian Game',
            type: DrillType.opening,
            difficulty: 'beginner',
            solutionMoves: ['e4', 'e5', 'Nf3', 'Nc6', 'Bc4'],
            hints: ['Control the center', 'Develop your pieces'],
            fen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
          ),
          Drill(
            id: 'op2',
            name: 'Sicilian Defense',
            description: 'Practice common Sicilian Defense variations',
            type: DrillType.opening,
            difficulty: 'intermediate',
            solutionMoves: ['e4', 'c5', 'Nf3', 'd6'],
            hints: ['Challenge White\'s center', 'Prepare for ...e5 or ...e6'],
            fen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
          ),
          Drill(
            id: 'op3',
            name: "Queen's Gambit",
            description: 'Master the Queen\'s Gambit opening',
            type: DrillType.opening,
            difficulty: 'intermediate',
            solutionMoves: ['d4', 'd5', 'c4', 'e6', 'Nc3'],
            hints: ['Control the center with pawns', 'Develop smoothly'],
            fen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
          ),
        ];
      case DrillType.tactics:
        return [
          Drill(
            id: 'ta1',
            name: 'Fork Patterns',
            description: 'Learn to recognize and execute forks',
            type: DrillType.tactics,
            difficulty: 'beginner',
            solutionMoves: ['Nxd5'],
            hints: ['Look for pieces that can attack multiple pieces'],
            fen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
          ),
          Drill(
            id: 'ta2',
            name: 'Pin and Skewer',
            description: 'Master pins and skewers',
            type: DrillType.tactics,
            difficulty: 'intermediate',
            solutionMoves: ['Bb5', 'Bxb5'],
            hints: ['Use pieces on the same line', 'Look for valuable pieces behind others'],
            fen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
          ),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.drillType.name} Drills'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _drills.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _drills.length,
        itemBuilder: (context, index) {
          final drill = _drills[index];
          return _buildDrillCard(drill);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No drills available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new training drills',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrillCard(Drill drill) {
    final difficultyColor = _getDifficultyColor(drill.difficulty);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DrillPracticePage(drill: drill),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      drill.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: difficultyColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: difficultyColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      drill.difficulty[0].toUpperCase() + drill.difficulty.substring(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: difficultyColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                drill.description ?? 'No description available',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.route, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    '${drill.solutionMoves.length} moves',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    return switch (difficulty.toLowerCase()) {
      'beginner' => Colors.green,
      'intermediate' => Colors.blue,
      'advanced' => Colors.orange,
      _ => Colors.grey,
    };
  }
}