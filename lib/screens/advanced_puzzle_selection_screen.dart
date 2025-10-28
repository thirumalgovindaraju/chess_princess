import 'package:flutter/material.dart';
import '../models/chess_puzzle.dart';
import '../services/enhanced_puzzle_service.dart';
import 'category_puzzle_list_screen.dart';
import 'puzzle_screen.dart';
import '../database/database_helper.dart';

class AdvancedPuzzleSelectionScreen extends StatefulWidget {
  const AdvancedPuzzleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedPuzzleSelectionScreen> createState() => _AdvancedPuzzleSelectionScreenState();
}

class _AdvancedPuzzleSelectionScreenState extends State<AdvancedPuzzleSelectionScreen> {
  Map<String, int> categoryStats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => isLoading = true);
    try {
      final stats = await EnhancedPuzzleService.getCategoryStats();
      setState(() {
        categoryStats = stats;
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
        title: const Text('1M+ Chess Puzzles'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Navigate to advanced search
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Daily Challenge
              _buildDailyChallenge(),
              const SizedBox(height: 24),

              // Stats Header
              _buildStatsHeader(),
              const SizedBox(height: 16),

              // Categories Grid
              _buildCategoriesGrid(),
              const SizedBox(height: 24),

              // Quick Start Section
              _buildQuickStart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyChallenge() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.amber.shade400, Colors.orange.shade600],
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(20),
          leading: const Icon(Icons.star, size: 48, color: Colors.white),
          title: const Text(
            'Daily Challenge',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: const Text(
            'New puzzle every day!',
            style: TextStyle(color: Colors.white70),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
          onTap: () async {
            final puzzle = await EnhancedPuzzleService.getDailyPuzzle();
            if (puzzle != null && mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PuzzleScreen(
                    selectedDifficulty: puzzle.difficulty,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildStatsHeader() {
    final total = categoryStats.values.fold(0, (sum, count) => sum + count);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Puzzles',
            total.toString(),
            Icons.extension,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Categories',
            '${categoryStats.length}',
            Icons.category,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Browse by Category',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: EnhancedPuzzleService.categories.length,
          itemBuilder: (context, index) {
            final category = EnhancedPuzzleService.categories[index];
            final count = categoryStats[category.id] ?? 0;

            return _buildCategoryCard(category, count);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(PuzzleCategory category, int count) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryPuzzleListScreen(
                category: category,
                totalPuzzles: count,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Color(category.color),
                Color(category.color).withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.icon,
                style: const TextStyle(fontSize: 36),
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count puzzles',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Start',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildQuickStartButton(
          'Random Puzzle',
          Icons.shuffle,
          Colors.teal,
              () async {
            final puzzle = await DatabaseHelper.instance.getRandomPuzzle();
            // Navigate to puzzle
          },
        ),
        const SizedBox(height: 8),
        _buildQuickStartButton(
          'Continue Training',
          Icons.play_arrow,
          Colors.green,
              () {
            // Navigate to last puzzle
          },
        ),
      ],
    );
  }

  Widget _buildQuickStartButton(
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}