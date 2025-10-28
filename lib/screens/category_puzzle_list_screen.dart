import 'package:flutter/material.dart';
import '../services/enhanced_puzzle_service.dart';
import '../models/chess_puzzle.dart';
import 'puzzle_screen.dart';

class CategoryPuzzleListScreen extends StatefulWidget {
  final PuzzleCategory category;
  final int totalPuzzles;

  const CategoryPuzzleListScreen({
    super.key,
    required this.category,
    required this.totalPuzzles,
  });

  @override
  State<CategoryPuzzleListScreen> createState() => _CategoryPuzzleListScreenState();
}

class _CategoryPuzzleListScreenState extends State<CategoryPuzzleListScreen> {
  final ScrollController _scrollController = ScrollController();
  List<ChessPuzzle> puzzles = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  String sortBy = 'rating'; // rating, difficulty, recent

  // Filters
  int? selectedDifficultyLevel;
  int? minRating;
  int? maxRating;

  @override
  void initState() {
    super.initState();
    _loadPuzzles();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMore();
    }
  }

  Future<void> _loadPuzzles() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final newPuzzles = await EnhancedPuzzleService.getPuzzlesByCategory(
        widget.category.id,
        page: currentPage,
        pageSize: 100, // Load 100 at a time for better UX
      );

      setState(() {
        if (currentPage == 1) {
          puzzles = newPuzzles;
        } else {
          puzzles.addAll(newPuzzles);
        }
        hasMore = newPuzzles.length == 100;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading puzzles: $e');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load puzzles: $e')),
        );
      }
    }
  }

  Future<void> _loadMore() async {
    if (!hasMore || isLoading) return;

    currentPage++;
    await _loadPuzzles();
  }

  Future<void> _refresh() async {
    setState(() {
      currentPage = 1;
      puzzles.clear();
      hasMore = true;
    });
    await _loadPuzzles();
  }

  void _playRandom() async {
    setState(() => isLoading = true);
    final puzzle = await EnhancedPuzzleService.getRandomPuzzleByCategory(widget.category.id);
    setState(() => isLoading = false);

    if (puzzle != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PuzzleScreen(
            selectedDifficulty: puzzle.difficulty,
            puzzle: puzzle,
          ),
        ),
      );
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => _buildFilterSheet(scrollController),
      ),
    );
  }

  Widget _buildFilterSheet(ScrollController scrollController) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ListView(
        controller: scrollController,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Puzzles',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Difficulty Filter
          const Text('Difficulty Level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: List.generate(6, (index) {
              final level = index + 1;
              return FilterChip(
                label: Text(_getDifficultyLabel(level)),
                selected: selectedDifficultyLevel == level,
                onSelected: (selected) {
                  setState(() {
                    selectedDifficultyLevel = selected ? level : null;
                  });
                  _refresh();
                  Navigator.pop(context);
                },
              );
            }),
          ),

          const SizedBox(height: 20),
          const Divider(),

          // Rating Range
          const Text('Rating Range', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Min Rating',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    minRating = int.tryParse(value);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Max Rating',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    maxRating = int.tryParse(value);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _refresh();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(widget.category.color),
              padding: const EdgeInsets.all(16),
            ),
            child: const Text('Apply Filters', style: TextStyle(fontSize: 16)),
          ),

          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              setState(() {
                selectedDifficultyLevel = null;
                minRating = null;
                maxRating = null;
              });
              _refresh();
              Navigator.pop(context);
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: Color(widget.category.color),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: _playRandom,
            tooltip: 'Random Puzzle',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildProgressIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: puzzles.isEmpty && isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : puzzles.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                controller: _scrollController,
                itemCount: puzzles.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == puzzles.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return _buildPuzzleCard(puzzles[index], index);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _playRandom,
        backgroundColor: Color(widget.category.color),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Play Random'),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(widget.category.color).withValues(alpha: 0.2),
            Color(widget.category.color).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: Color(widget.category.color).withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(widget.category.color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.category.icon,
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category.description,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.totalPuzzles.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} puzzles available',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    if (puzzles.isEmpty) return const SizedBox.shrink();

    final loadedCount = puzzles.length;
    final progress = (loadedCount / widget.totalPuzzles).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Loaded $loadedCount of ${widget.totalPuzzles}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(widget.category.color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(Color(widget.category.color)),
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzleCard(ChessPuzzle puzzle, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PuzzleScreen(
                selectedDifficulty: puzzle.difficulty,
                puzzle: puzzle,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Number Badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getDifficultyColor(puzzle.difficulty).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _getDifficultyColor(puzzle.difficulty),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: _getDifficultyColor(puzzle.difficulty),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Puzzle Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          puzzle.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildDifficultyBadge(puzzle.difficulty),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      puzzle.name!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.emoji_events, size: 14, color: Colors.amber.shade700),
                        const SizedBox(width: 4),
                        Text(
                          puzzle.theme,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_right,
                color: Color(widget.category.color),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(PuzzleDifficulty difficulty) {
    final color = _getDifficultyColor(difficulty);
    final label = difficulty.toString().split('.').last.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No puzzles found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                selectedDifficultyLevel = null;
                minRating = null;
                maxRating = null;
              });
              _refresh();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Clear Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(widget.category.color),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(PuzzleDifficulty difficulty) {
    switch (difficulty) {
      case PuzzleDifficulty.easy:
        return Colors.green;
      case PuzzleDifficulty.medium:
        return Colors.orange;
      case PuzzleDifficulty.hard:
        return Colors.red;
      case PuzzleDifficulty.expert:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getDifficultyLabel(int level) {
    switch (level) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Easy';
      case 3:
        return 'Medium';
      case 4:
        return 'Hard';
      case 5:
        return 'Expert';
      case 6:
        return 'Master';
      default:
        return 'Level $level';
    }
  }
}