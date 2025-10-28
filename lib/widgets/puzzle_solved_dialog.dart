// lib/widgets/puzzle_solved_dialog.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class PuzzleSolvedDialog extends StatefulWidget {
  final String puzzleId;
  final int moves;
  final int timeInSeconds;
  final VoidCallback onTryAgain;
  final VoidCallback onNextPuzzle;

  const PuzzleSolvedDialog({
    super.key,
    required this.puzzleId,
    required this.moves,
    required this.timeInSeconds,
    required this.onTryAgain,
    required this.onNextPuzzle,
  });

  @override
  State<PuzzleSolvedDialog> createState() => _PuzzleSolvedDialogState();
}

class _PuzzleSolvedDialogState extends State<PuzzleSolvedDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scaleController.forward();
      _slideController.forward();
      _confettiController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '$minutes min ${secs} sec';
    }
    return '$secs seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        children: [
          // Confetti background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ConfettiPainter(_confettiController.value),
                );
              },
            ),
          ),
          // Main dialog content
          SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF8F9FF),
                      Color(0xFFFFFFFF),
                      Color(0xFFF0F4FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                      spreadRadius: -10,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Trophy/Success Icon with gradient background
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF6366F1),
                            Color(0xFF8B5CF6),
                            Color(0xFFA855F7),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Trophy Icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Title
                          const Text(
                            '🎉 Puzzle Solved!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Stats Section
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          // Success message
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF475569),
                                height: 1.5,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Congratulations! You solved ',
                                ),
                                TextSpan(
                                  text: '"Puzzle ${widget.puzzleId}"',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                                TextSpan(
                                  text: ' in ${widget.moves} move${widget.moves == 1 ? '' : 's'}.',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Stats Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.touch_app,
                                  label: 'Moves',
                                  value: '${widget.moves}',
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF10B981), Color(0xFF34D399)],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.timer_outlined,
                                  label: 'Time',
                                  value: _formatTime(widget.timeInSeconds),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: _buildButton(
                                  onPressed: widget.onTryAgain,
                                  text: 'Try Again',
                                  icon: Icons.refresh,
                                  isPrimary: false,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildButton(
                                  onPressed: widget.onNextPuzzle,
                                  text: 'Next Puzzle',
                                  icon: Icons.arrow_forward,
                                  isPrimary: true,
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required bool isPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            )
                : null,
            color: isPrimary ? null : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
            border: isPrimary
                ? null
                : Border.all(
              color: const Color(0xFFE2E8F0),
              width: 2,
            ),
            boxShadow: isPrimary
                ? [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : const Color(0xFF475569),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Confetti Painter for celebration effect
class ConfettiPainter extends CustomPainter {
  final double progress;
  final List<ConfettiParticle> particles;

  ConfettiPainter(this.progress)
      : particles = List.generate(
    50,
        (index) => ConfettiParticle(index),
  );

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final x = particle.x * size.width;
      final y = particle.startY +
          (progress * size.height * 1.5) +
          math.sin(progress * math.pi * 4 + particle.offset) * 30;

      if (y < size.height + 50) {
        final paint = Paint()
          ..color = particle.color.withOpacity((1 - progress).clamp(0.0, 1.0))
          ..style = PaintingStyle.fill;

        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(progress * math.pi * 4 + particle.rotation);

        switch (particle.shape) {
          case 0:
            canvas.drawCircle(Offset.zero, particle.size, paint);
            break;
          case 1:
            canvas.drawRect(
              Rect.fromCenter(
                center: Offset.zero,
                width: particle.size * 2,
                height: particle.size * 2,
              ),
              paint,
            );
            break;
          case 2:
            final path = Path()
              ..moveTo(0, -particle.size)
              ..lineTo(particle.size, particle.size)
              ..lineTo(-particle.size, particle.size)
              ..close();
            canvas.drawPath(path, paint);
            break;
        }

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

class ConfettiParticle {
  final double x;
  final double startY;
  final Color color;
  final double size;
  final int shape;
  final double offset;
  final double rotation;

  ConfettiParticle(int seed) :
        x = (math.Random(seed).nextDouble()),
        startY = -50 - (math.Random(seed + 1).nextDouble() * 100),
        color = [
          const Color(0xFFF59E0B),
          const Color(0xFFEF4444),
          const Color(0xFF10B981),
          const Color(0xFF3B82F6),
          const Color(0xFF8B5CF6),
          const Color(0xFFEC4899),
        ][math.Random(seed + 2).nextInt(6)],
        size = 4 + math.Random(seed + 3).nextDouble() * 6,
        shape = math.Random(seed + 4).nextInt(3),
        offset = math.Random(seed + 5).nextDouble() * math.pi * 2,
        rotation = math.Random(seed + 6).nextDouble() * math.pi * 2;
}