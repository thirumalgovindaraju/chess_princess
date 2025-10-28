// lib/widgets/coach_suggestion_widget.dart

import 'package:flutter/material.dart';
import '../models/coach_suggestion.dart';

class CoachSuggestionWidget extends StatelessWidget {
  final CoachSuggestion suggestion;
  final VoidCallback? onDismiss;
  final VoidCallback? onApply;

  const CoachSuggestionWidget({
    Key? key,
    required this.suggestion,
    this.onDismiss,
    this.onApply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(suggestion.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _getPriorityColor().withOpacity(0.3),
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () => _showDetailDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildTypeIcon(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestion.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            suggestion.message,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _buildPriorityBadge(),
                  ],
                ),
                if (suggestion.move != null) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Suggested: ${_formatMove(suggestion.move!)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                      if (onApply != null)
                        ElevatedButton.icon(
                          onPressed: onApply,
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text('Apply'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData icon;
    Color color;

    switch (suggestion.type) {
      case SuggestionType.tactical:
        icon = Icons.flash_on;
        color = Colors.orange;
        break;
      case SuggestionType.positional:
        icon = Icons.grid_4x4;
        color = Colors.blue;
        break;
      case SuggestionType.strategic:
        icon = Icons.psychology;
        color = Colors.purple;
        break;
      case SuggestionType.mistake:
        icon = Icons.error;
        color = Colors.red;
        break;
      case SuggestionType.warning:
        icon = Icons.warning_amber;
        color = Colors.orange;
        break;
      case SuggestionType.praise:
        icon = Icons.star;
        color = Colors.green;
        break;
      case SuggestionType.opening:
        icon = Icons.wb_sunny;
        color = Colors.amber;
        break;
      case SuggestionType.endgame:
        icon = Icons.flag;
        color = Colors.indigo;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildPriorityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getPriorityColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getPriorityText(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getPriorityColor() {
    switch (suggestion.priority) {
      case SuggestionPriority.critical:
        return Colors.red;
      case SuggestionPriority.high:
        return Colors.orange;
      case SuggestionPriority.medium:
        return Colors.blue;
      case SuggestionPriority.low:
        return Colors.green;
    }
  }

  String _getPriorityText() {
    switch (suggestion.priority) {
      case SuggestionPriority.critical:
        return 'CRITICAL';
      case SuggestionPriority.high:
        return 'HIGH';
      case SuggestionPriority.medium:
        return 'MEDIUM';
      case SuggestionPriority.low:
        return 'LOW';
    }
  }

  String _formatMove(String move) {
    if (move.length >= 4) {
      return '${move.substring(0, 2)} → ${move.substring(2, 4)}';
    }
    return move;
  }

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            _buildTypeIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion.title,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                suggestion.message,
                style: const TextStyle(fontSize: 16),
              ),
              if (suggestion.explanation != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Explanation:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  suggestion.explanation!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
              if (suggestion.move != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Suggested Move:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_forward, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        _formatMove(suggestion.move!),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (suggestion.variations != null &&
                  suggestion.variations!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Variations:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...suggestion.variations!.map((variation) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '• $variation',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (onApply != null && suggestion.move != null)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onApply?.call();
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Apply Move'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}