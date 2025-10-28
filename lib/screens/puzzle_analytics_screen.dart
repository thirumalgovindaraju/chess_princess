import 'package:flutter/material.dart';
import '../services/enhanced_puzzle_service.dart';
import '../database/database_helper.dart';

class PuzzleAnalyticsScreen extends StatefulWidget {
  const PuzzleAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<PuzzleAnalyticsScreen> createState() => _PuzzleAnalyticsScreenState();
}

class _PuzzleAnalyticsScreenState extends State<PuzzleAnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Map<String, int> categoryStats = {};
  Map<int, int> difficultyStats = {};
  Map<String, int> ratingDistribution = {};
  Map<String, int> themeStats = {};
  int totalPuzzles = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllStats() async {
    setState(() => isLoading = true);

    try {
      final results = await Future.wait([
        EnhancedPuzzleService.getCategoryStats(),
        EnhancedPuzzleService.getDifficultyLevelStats(),
        DatabaseHelper.instance.getRatingDistribution(),
        DatabaseHelper.instance.getThemeStats(limit: 30),
        DatabaseHelper.instance.getTotalPuzzleCount(),
      ]);

      setState(() {
        categoryStats = results[0] as Map<String, int>;
        difficultyStats = results[1] as Map<int, int>;
        ratingDistribution = results[2] as Map<String, int>;
        themeStats = results[3] as Map<String, int>;
        totalPuzzles = results[4] as int;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading stats: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle Analytics'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.category), text: 'Categories'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Difficulty'),
            Tab(icon: Icon(Icons.trending_up), text: 'Ratings'),
            Tab(icon: Icon(Icons.lightbulb), text: 'Themes'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryTab(),
          _buildDifficultyTab(),
          _buildRatingTab(),
          _buildThemeTab(),
        ],
      ),
    );
  }

  Widget _buildCategoryTab() {
    return RefreshIndicator(
      onRefresh: _loadAllStats,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOverviewCard(),
          const SizedBox(height: 16),
          const Text(
            'Categories Distribution',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...categoryStats.entries.map((entry) {
            final percentage = (entry.value / totalPuzzles * 100);
            return _buildStatBar(
              entry.key,
              entry.value,
              percentage,
              _getCategoryColor(entry.key),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDifficultyTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDifficultyOverview(),
        const SizedBox(height: 16),
        const Text(
          'Difficulty Levels',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...difficultyStats.entries.map((entry) {
          final percentage = (entry.value / totalPuzzles * 100);
          return _buildStatBar(
            _getDifficultyLabel(entry.key),
            entry.value,
            percentage,
            _getDifficultyColor(entry.key),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRatingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildRatingOverview(),
        const SizedBox(height: 16),
        const Text(
          'Rating Distribution',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...ratingDistribution.entries.map((entry) {
          final total = ratingDistribution.values.reduce((a, b) => a + b);
          final percentage = (entry.value / total * 100);
          return _buildStatBar(
            entry.key,
            entry.value,
            percentage,
            Colors.blue.shade700,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildThemeTab() {
    final sortedThemes = themeStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildThemeOverview(),
        const SizedBox(height: 16),
        const Text(
          'Most Popular Themes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Top ${sortedThemes.length} tactical themes',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        ...sortedThemes.map((entry) {
          final total = themeStats.values.reduce((a, b) => a + b);
          final percentage = (entry.value / total * 100);
          return _buildStatBar(
            _formatThemeName(entry.key),
            entry.value,
            percentage,
            Colors.purple.shade700,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildOverviewCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.emoji_events, size: 48, color: Colors.amber),
            const SizedBox(height: 12),
            Text(
              totalPuzzles.toString().replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
              ),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const Text(
              'Total Puzzles',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat('Categories', categoryStats.length.toString(), Icons.category),
                _buildMiniStat('Difficulty Levels', difficultyStats.length.toString(), Icons.bar_chart),
                _buildMiniStat('Themes', themeStats.length.toString(), Icons.lightbulb),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyOverview() {
    final easiest = difficultyStats[1] ?? 0;
    final hardest = difficultyStats[6] ?? 0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Difficulty Balance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDifficultyCard('Beginner', easiest, Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDifficultyCard('Master', hardest, Colors.purple),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingOverview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Rating Range',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Lowest',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const Text(
                      '500',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 2,
                  height: 50,
                  color: Colors.grey.shade300,
                ),
                Column(
                  children: [
                    Text(
                      'Highest',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const Text(
                      '3000+',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOverview() {
    final mostPopular = themeStats.entries.reduce((a, b) => a.value > b.value ? a : b);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.star, size: 48, color: Colors.amber),
            const SizedBox(height: 12),
            const Text(
              'Most Popular Theme',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _formatThemeName(mostPopular.key),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            Text(
              '${mostPopular.value} puzzles',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.indigo),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDifficultyCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            'puzzles',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, int value, double percentage, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} (${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final cat = EnhancedPuzzleService.categories.firstWhere(
          (c) => c.id == category,
      orElse: () => EnhancedPuzzleService.categories.last,
    );
    return Color(cat.color);
  }

  String _getDifficultyLabel(int level) {
    switch (level) {
      case 1: return 'Beginner';
      case 2: return 'Easy';
      case 3: return 'Medium';
      case 4: return 'Hard';
      case 5: return 'Expert';
      case 6: return 'Master';
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
}