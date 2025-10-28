import 'package:flutter/material.dart';
import '../services/enhanced_puzzle_service.dart';
import '../models/chess_puzzle.dart';
import '../screens/puzzle_screen.dart';

class AdvancedFilterScreen extends StatefulWidget {
  const AdvancedFilterScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedFilterScreen> createState() => _AdvancedFilterScreenState();
}

class _AdvancedFilterScreenState extends State<AdvancedFilterScreen> {
  // Filter values
  String? selectedCategory;
  int? selectedDifficultyLevel;
  RangeValues ratingRange = const RangeValues(1000, 2500);
  List<String> selectedThemes = [];

  // Available themes
  static const List<String> availableThemes = [
    'fork', 'pin', 'skewer', 'discoveredAttack', 'doubleAttack',
    'sacrifice', 'mate', 'mateIn1', 'mateIn2', 'mateIn3',
    'hangingPiece', 'defensiveMove', 'attraction', 'deflection',
    'clearance', 'interference', 'zwischenzug', 'xRayAttack',
    'promotion', 'underPromotion', 'advancedPawn', 'backRankMate',
    'smotheredMate', 'arabianMate', 'anastasiasMate', 'kingsideAttack',
    'queensideAttack', 'exposedKing', 'trappedPiece'
  ];

  // Results
  List<ChessPuzzle> searchResults = [];
  bool isSearching = false;
  bool hasSearched = false;
  int totalResults = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Search'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetFilters,
            tooltip: 'Reset Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Category', Icons.category),
                  _buildCategorySelector(),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Difficulty Level', Icons.bar_chart),
                  _buildDifficultySelector(),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Rating Range', Icons.trending_up),
                  _buildRatingSlider(),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Tactical Themes', Icons.lightbulb),
                  _buildThemeSelector(),
                  const SizedBox(height: 24),

                  if (hasSearched) ...[
                    const Divider(height: 32),
                    _buildResultsSection(),
                  ],
                ],
              ),
            ),
          ),
          _buildSearchButton(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.indigo.shade700),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedCategory ?? 'all',
              decoration: InputDecoration(
                labelText: 'Select Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.category),
              ),
              items: [
                const DropdownMenuItem(
                  value: 'all',
                  child: Text('All Categories'),
                ),
                ...EnhancedPuzzleService.categories.map(
                      (cat) => DropdownMenuItem<String>(
                    value: cat.id, // must be non-null
                    child: Row(
                      children: [
                        Text(cat.icon, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(cat.name),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedCategory = (value == 'all') ? null : value;
                });
              },
            )

          ],
        ),
      ),
    );
  }


  Widget _buildDifficultySelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select one or leave empty for all'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(6, (index) {
                final level = index + 1;
                final isSelected = selectedDifficultyLevel == level;

                return FilterChip(
                  label: Text(_getDifficultyLabel(level)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedDifficultyLevel = selected ? level : null;
                    });
                  },
                  selectedColor: _getDifficultyColor(level).withOpacity(0.3),
                  checkmarkColor: _getDifficultyColor(level),
                  labelStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? _getDifficultyColor(level) : Colors.black87,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSlider() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Min: ${ratingRange.start.round()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Max: ${ratingRange.end.round()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            RangeSlider(
              values: ratingRange,
              min: 500,
              max: 3000,
              divisions: 50,
              labels: RangeLabels(
                ratingRange.start.round().toString(),
                ratingRange.end.round().toString(),
              ),
              onChanged: (values) => setState(() => ratingRange = values),
              activeColor: Colors.indigo.shade700,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('500', style: TextStyle(color: Colors.grey.shade600)),
                Text('3000', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select themes (${selectedThemes.length} selected)',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableThemes.map((theme) {
                final isSelected = selectedThemes.contains(theme);
                return FilterChip(
                  label: Text(_formatThemeName(theme)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedThemes.add(theme);
                      } else {
                        selectedThemes.remove(theme);
                      }
                    });
                  },
                  selectedColor: Colors.indigo.shade100,
                  checkmarkColor: Colors.indigo.shade700,
                );
              }).toList(),
            ),
            if (selectedThemes.isNotEmpty) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => setState(() => selectedThemes.clear()),
                icon: const Icon(Icons.clear),
                label: const Text('Clear all themes'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchResults.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
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
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Found ${totalResults} puzzles',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _viewAllResults,
              icon: const Icon(Icons.list),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...searchResults.take(5).map((puzzle) => _buildResultCard(puzzle)),
        if (searchResults.length > 5) ...[
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: _viewAllResults,
              child: Text('View All ${totalResults} Results'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultCard(ChessPuzzle puzzle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getDifficultyColorFromPuzzle(puzzle).withValues(alpha: 0.2),
          child: Icon(
            Icons.extension,
            color: _getDifficultyColorFromPuzzle(puzzle),
          ),
        ),
        title: Text(puzzle.name ?? 'Unnamed Puzzle'),  // Fix line 368
        subtitle: Text(puzzle.description ?? 'No description'),  // Fix line 592
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
      ),
    );
  }

  Widget _buildSearchButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _performSearch,
                icon: const Icon(Icons.search),
                label: const Text(
                  'Search Puzzles',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (hasSearched) ...[
              const SizedBox(width: 12),
              IconButton(
                onPressed: _resetFilters,
                icon: const Icon(Icons.refresh),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _performSearch() async {
    setState(() {
      isSearching = true;
      hasSearched = true;
    });

    try {
      final results = await EnhancedPuzzleService.getFilteredPuzzles(
        category: selectedCategory,
        difficultyLevel: selectedDifficultyLevel,
        minRating: ratingRange.start.round(),
        maxRating: ratingRange.end.round(),
        themes: selectedThemes.isNotEmpty ? selectedThemes : null,
        pageSize: 100,
      );

      setState(() {
        searchResults = results;
        totalResults = results.length;
        isSearching = false;
      });

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No puzzles match your criteria')),
        );
      }
    } catch (e) {
      setState(() => isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    }
  }

  void _viewAllResults() {
    // Navigate to a full results screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(
          filters: {
            'category': selectedCategory,
            'difficultyLevel': selectedDifficultyLevel,
            'minRating': ratingRange.start.round(),
            'maxRating': ratingRange.end.round(),
            'themes': selectedThemes,
          },
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      selectedCategory = null;
      selectedDifficultyLevel = null;
      ratingRange = const RangeValues(1000, 2500);
      selectedThemes.clear();
      searchResults.clear();
      hasSearched = false;
    });
  }

  String _formatThemeName(String theme) {
    return theme
        .replaceAllMapped(
      RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
    )
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _getDifficultyLabel(int level) {
    switch (level) {
      case 1: return 'Beginner (500-1200)';
      case 2: return 'Easy (1200-1500)';
      case 3: return 'Medium (1500-1800)';
      case 4: return 'Hard (1800-2100)';
      case 5: return 'Expert (2100-2400)';
      case 6: return 'Master (2400+)';
      default: return 'Level $level';
    }
  }

  Color _getDifficultyColor(int level) {
    switch (level) {
      case 1: return Colors.green;
      case 2: return Colors.lightGreen;
      case 3: return Colors.orange;
      case 4: return Colors.deepOrange;
      case 5: return Colors.red;
      case 6: return Colors.purple;
      default: return Colors.grey;
    }
  }

  Color _getDifficultyColorFromPuzzle(ChessPuzzle puzzle) {
    switch (puzzle.difficulty) {
      case PuzzleDifficulty.easy: return Colors.green;
      case PuzzleDifficulty.medium: return Colors.orange;
      case PuzzleDifficulty.hard: return Colors.red;
      case PuzzleDifficulty.expert: return Colors.purple;
      default: return Colors.grey;
    }
  }
}

// Simple results screen
class SearchResultsScreen extends StatelessWidget {
  final Map<String, dynamic> filters;

  const SearchResultsScreen({Key? key, required this.filters}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<ChessPuzzle>>(
        future: EnhancedPuzzleService.getFilteredPuzzles(
          category: filters['category'],
          difficultyLevel: filters['difficultyLevel'],
          minRating: filters['minRating'],
          maxRating: filters['maxRating'],
          themes: filters['themes'],
          pageSize: 1000, // Load more for full results
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final puzzles = snapshot.data ?? [];

          return ListView.builder(
            itemCount: puzzles.length,
            itemBuilder: (context, index) {
              final puzzle = puzzles[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(puzzle.name),
                  subtitle: Text(puzzle.description ?? 'No description'),  // Fix line 592
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}