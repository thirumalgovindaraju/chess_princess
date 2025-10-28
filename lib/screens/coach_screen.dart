// lib/screens/coach_screen.dart

import 'package:flutter/material.dart';
import '../models/coach_suggestion.dart';
import '../models/chess_board.dart';
import '../services/chess_coach.dart';
import '../widgets/coach_suggestion_widget.dart';
import '../widgets/chess_board_widget.dart';

class CoachScreen extends StatefulWidget {
  final ChessBoard currentBoard;
  final List<String> moveHistory;
  final Function(String)? onMoveApplied;

  const CoachScreen({
    Key? key,
    required this.currentBoard,
    required this.moveHistory,
    this.onMoveApplied,
  }) : super(key: key);

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen>
    with SingleTickerProviderStateMixin {
  final ChessCoach _coach = ChessCoach();
  CoachAnalysis? _analysis;
  bool _isAnalyzing = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _analyzePosition();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _analyzePosition() async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final analysis = await _coach.analyzePosition(
        widget.currentBoard,
        widget.moveHistory,
      );

      if (mounted) {
        setState(() {
          _analysis = analysis;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing position: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chess Coach'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _analyzePosition,
            tooltip: 'Refresh Analysis',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showHelpDialog(),
            tooltip: 'Help',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.lightbulb), text: 'Suggestions'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Analysis'),
            Tab(icon: Icon(Icons.trending_up), text: 'Best Moves'),
          ],
        ),
      ),
      body: _isAnalyzing
          ? _buildLoadingState()
          : _analysis == null
          ? _buildErrorState()
          : TabBarView(
        controller: _tabController,
        children: [
          _buildSuggestionsTab(),
          _buildAnalysisTab(),
          _buildBestMovesTab(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Analyzing position...',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'The AI coach is evaluating your game',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to analyze position',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _analyzePosition,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsTab() {
    final suggestions = _analysis!.suggestions;

    if (suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Great job!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No critical suggestions at the moment',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return CoachSuggestionWidget(
          suggestion: suggestion,
          onDismiss: () {
            setState(() {
              _analysis!.suggestions.removeAt(index);
            });
          },
          onApply: suggestion.move != null
              ? () {
            if (widget.onMoveApplied != null) {
              widget.onMoveApplied!(suggestion.move!);
              Navigator.pop(context);
            }
          }
              : null,
        );
      },
    );
  }

  Widget _buildAnalysisTab() {
    final stats = _analysis!.statistics;
    final eval = _analysis!.positionEvaluation;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalysisCard(
            'Position Evaluation',
            Icons.analytics,
            Colors.blue,
            [
              _buildStatRow('Evaluation', '${eval.toStringAsFixed(1)}'),
              _buildStatRow('Game Phase', _analysis!.gamePhase.toUpperCase()),
            ],
          ),
          const SizedBox(height: 16),
          _buildAnalysisCard(
            'Material Count',
            Icons.extension,
            Colors.orange,
            [
              _buildStatRow(
                'White Material',
                '${stats['whiteMaterial']}',
              ),
              _buildStatRow(
                'Black Material',
                '${stats['blackMaterial']}',
              ),
              _buildStatRow(
                'Advantage',
                '${stats['materialAdvantage'] > 0 ? '+' : ''}${stats['materialAdvantage']}',
                valueColor: stats['materialAdvantage'] > 0
                    ? Colors.green
                    : stats['materialAdvantage'] < 0
                    ? Colors.red
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAnalysisCard(
            'Piece Count',
            Icons.grid_4x4,
            Colors.purple,
            [
              _buildStatRow('White Pieces', '${stats['whitePieces']}'),
              _buildStatRow('Black Pieces', '${stats['blackPieces']}'),
              _buildStatRow(
                'Total Pieces',
                '${stats['whitePieces'] + stats['blackPieces']}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEvaluationBar(eval),
        ],
      ),
    );
  }

  Widget _buildBestMovesTab() {
    final bestMoves = _coach.suggestBestMoves(widget.currentBoard, count: 5);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Top Recommended Moves',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'These are the strongest moves in the current position',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        if (bestMoves.isEmpty)
          const Center(
            child: Text('No moves available'),
          )
        else
          ...bestMoves.asMap().entries.map((entry) {
            final index = entry.key;
            final move = entry.value;
            return _buildMoveCard(move, index + 1);
          }).toList(),
      ],
    );
  }

  Widget _buildAnalysisCard(
      String title,
      IconData icon,
      Color color,
      List<Widget> children,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationBar(double evaluation) {
    final normalized = (evaluation / 1000).clamp(-1.0, 1.0);
    final percentage = ((normalized + 1) / 2 * 100).clamp(0.0, 100.0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Position Balance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: (100 - percentage).toInt(),
                          child: Container(color: Colors.grey[800]),
                        ),
                        Expanded(
                          flex: percentage.toInt(),
                          child: Container(color: Colors.white),
                        ),
                      ],
                    ),
                    Center(
                      child: Text(
                        evaluation > 0
                            ? 'White +${evaluation.toStringAsFixed(1)}'
                            : evaluation < 0
                            ? 'Black ${evaluation.toStringAsFixed(1)}'
                            : 'Equal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: evaluation.abs() < 100
                              ? Colors.grey[600]
                              : evaluation > 0
                              ? Colors.grey[800]
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoveCard(String move, int rank) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRankColor(rank),
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          _formatMove(move),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(_getMoveDescription(rank)),
        trailing: IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () {
            if (widget.onMoveApplied != null) {
              widget.onMoveApplied!(move);
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatMove(String move) {
    if (move.length >= 4) {
      return '${move.substring(0, 2)} → ${move.substring(2, 4)}';
    }
    return move;
  }

  String _getMoveDescription(int rank) {
    switch (rank) {
      case 1:
        return 'Best move - Strongest option';
      case 2:
        return 'Excellent alternative';
      case 3:
        return 'Good move';
      default:
        return 'Decent option';
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Coach Help'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpSection(
                'Suggestions',
                'Get personalized advice about your position, tactics, and strategy.',
              ),
              const SizedBox(height: 12),
              _buildHelpSection(
                'Analysis',
                'View detailed statistics about material balance and position evaluation.',
              ),
              const SizedBox(height: 12),
              _buildHelpSection(
                'Best Moves',
                'See the top recommended moves for the current position.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Priority Levels:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildPriorityInfo('Critical', Colors.red),
              _buildPriorityInfo('High', Colors.orange),
              _buildPriorityInfo('Medium', Colors.blue),
              _buildPriorityInfo('Low', Colors.green),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(description),
      ],
    );
  }

  Widget _buildPriorityInfo(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}