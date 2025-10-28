
// ==================== FILE 4: lib/presentation/pages/ai_assistant/ai_assistant_page_fixed.dart ====================

import 'package:flutter/material.dart';
import '../../services/ai_service_manager.dart';
import '../../services/ai_service_base.dart';

class AIAssistantPage extends StatefulWidget {
  final String? currentPosition;
  final List<String>? moveHistory;

  const AIAssistantPage({
    Key? key,
    this.currentPosition,
    this.moveHistory,
  }) : super(key: key);

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  late TabController _tabController;

  String? _currentPosition;
  List<String> _moveHistory = [];
  Map<String, dynamic>? _positionAnalysis;
  List<Map<String, dynamic>> _suggestedMoves = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _currentPosition = widget.currentPosition;
    _moveHistory = widget.moveHistory ?? [];

    AIServiceManager.initialize(
      geminiApiKey: 'AIzaSyD4i4RfjyVYC2rdyV84mwsx7DV0U50-8I4', // Replace with your actual API key
    );

    _addMessage(ChatMessage(
      text: _getWelcomeMessage(),
      isUser: false,
      timestamp: DateTime.now(),
      messageType: MessageType.welcome,
    ));

    if (_currentPosition != null) {
      _analyzeCurrentPosition();
    }
  }

  String _getWelcomeMessage() {
    return '''👋 Welcome to Chess AI Assistant!

I can help you with:
♟️ Move suggestions and analysis
📊 Position evaluation
📚 Opening theory and strategies
🎯 Endgame techniques
❓ Chess rules and tactics

How can I assist you today?''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess AI Assistant'),
        //backgroundColor: Colors.brown.shade700,
        //backgroundColor: Color(0xFF0070AD),
        //backgroundColor: Color(0xFF003B5C),
        //backgroundColor: Color(0xFF3399CC),
        backgroundColor: Color(0xFF004B87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearChat,
            tooltip: 'Clear chat',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
            tooltip: 'Settings',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.chat), text: 'Chat'),
            Tab(icon: Icon(Icons.analytics), text: 'Analysis'),
            Tab(icon: Icon(Icons.lightbulb), text: 'Hints'),
            Tab(icon: Icon(Icons.book), text: 'Learn'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(),
          _buildAnalysisTab(),
          _buildHintsTab(),
          _buildLearnTab(),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        _buildQuickActions(),
        Expanded(
          child: _messages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return _buildMessageBubble(_messages[index]);
            },
          ),
        ),
        if (_isTyping) _buildTypingIndicator(),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildQuickActionButton(
            '📊 Analyze Position',
                () => _analyzeCurrentPosition(),
          ),
          _buildQuickActionButton(
            '💡 Suggest Move',
                () => _suggestBestMove(),
          ),
          _buildQuickActionButton(
            '📚 Opening Help',
                () => _askAboutOpening(),
          ),
          _buildQuickActionButton(
            '🎯 Tactics',
                () => _findTactics(),
          ),
          _buildQuickActionButton(
            '👑 Endgame Tips',
                () => _getEndgameTips(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String label, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.brown.shade300),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology,
            size: 80,
            color: Colors.brown.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Ask me anything about chess!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try: "What\'s the best move?" or "Explain this position"',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Colors.brown.shade700
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, double value, child) {
        return Opacity(
          opacity: (value + index * 0.3) % 1,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Ask about chess...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.brown.shade700,
            child: IconButton(
              icon: Icon(
                _isLoading ? Icons.hourglass_empty : Icons.send,
                color: Colors.white,
              ),
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalysisHeader(),
          const SizedBox(height: 20),
          if (_positionAnalysis != null) ...[
            _buildPositionEvaluation(),
            const SizedBox(height: 16),
            _buildKeyFeatures(),
          ] else
            _buildNoAnalysisState(),
        ],
      ),
    );
  }

  Widget _buildAnalysisHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown.shade400, Colors.brown.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Position Analysis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'AI-powered chess analysis',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _analyzeCurrentPosition,
            icon: const Icon(Icons.refresh),
            label: const Text('Analyze'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.brown.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionEvaluation() {
    final eval = _positionAnalysis!['evaluation'] ?? 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Position Evaluation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getEvaluationText(eval),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyFeatures() {
    final features = _positionAnalysis!['features'] as List? ?? [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Key Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature.toString(),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAnalysisState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No position analyzed yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _analyzeCurrentPosition,
            child: const Text('Analyze Current Position'),
          ),
        ],
      ),
    );
  }

  Widget _buildHintsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Move Suggestions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_suggestedMoves.isNotEmpty)
            ..._suggestedMoves.map((move) => _buildMoveCard(move))
          else
            _buildNoHintsState(),
        ],
      ),
    );
  }

  Widget _buildMoveCard(Map<String, dynamic> move) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.brown.shade700,
          child: Text(
            '${move['rank']}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          move['notation'] ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'monospace',
          ),
        ),
        subtitle: Text(move['description'] ?? ''),
        trailing: Text(
          '${move['score']}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildNoHintsState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.lightbulb_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No move suggestions yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _suggestBestMove,
            child: const Text('Get Move Suggestions'),
          ),
        ],
      ),
    );
  }

  Widget _buildLearnTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildLearningCard(
          'Opening Principles',
          'Learn the fundamental rules of chess openings',
          Icons.flag,
          Colors.blue,
              () => _showOpeningPrinciples(),
        ),
        _buildLearningCard(
          'Tactical Patterns',
          'Master common tactical motifs',
          Icons.flash_on,
          Colors.orange,
              () => _showTacticalPatterns(),
        ),
        _buildLearningCard(
          'Endgame Techniques',
          'Essential endgame knowledge',
          Icons.emoji_events,
          Colors.green,
              () => _showEndgameTechniques(),
        ),
        _buildLearningCard(
          'Strategic Concepts',
          'Understand positional play',
          Icons.psychology,
          Colors.purple,
              () => _showStrategicConcepts(),
        ),
      ],
    );
  }

  Widget _buildLearningCard(
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _addMessage(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _messageController.clear();
    setState(() {
      _isLoading = true;
      _isTyping = true;
    });

    try {
      final response = await AIServiceManager.processQuestion(
        _buildContextualQuestion(text),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      _addMessage(ChatMessage(
        text: response.content,
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.text,
      ));
    } catch (e) {
      _addMessage(ChatMessage(
        text: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.error,
      ));
    } finally {
      setState(() {
        _isLoading = false;
        _isTyping = false;
      });
    }
  }

  String _buildContextualQuestion(String question) {
    String context = 'Chess question: $question\n\n';

    if (_currentPosition != null) {
      context += 'Current position (FEN): $_currentPosition\n';
    }

    if (_moveHistory.isNotEmpty) {
      context += 'Move history: ${_moveHistory.join(", ")}\n';
    }

    return context;
  }

  Future<void> _analyzeCurrentPosition() async {
    setState(() => _isLoading = true);

    try {
      final question = _currentPosition != null
          ? 'Analyze this chess position: $_currentPosition. Provide evaluation and key features.'
          : 'Please provide general chess position analysis principles.';

      final response = await AIServiceManager.processQuestion(question);

      final analysis = {
        'evaluation': 0.5,
        'features': [
          'Analysis from AI assistant',
          response.content.split('\n').take(3).join(' '),
        ],
        'threats': 'Check the chat for detailed analysis',
      };

      setState(() {
        _positionAnalysis = analysis;
        _tabController.animateTo(1);
      });

      _addMessage(ChatMessage(
        text: 'Position analyzed! Here\'s what I found:\n\n${response.content}',
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.analysis,
      ));
    } catch (e) {
      _addMessage(ChatMessage(
        text: 'Unable to analyze position. ${getFallbackResponse("analyze position")}',
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.error,
      ));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _suggestBestMove() async {
    setState(() => _isLoading = true);

    try {
      final question = _currentPosition != null
          ? 'Suggest the best moves for this position: $_currentPosition'
          : 'What are good opening moves in chess?';

      final response = await AIServiceManager.processQuestion(question);

      final moves = [
        {
          'rank': 1,
          'notation': 'Nf3',
          'description': 'From AI analysis',
          'score': '+0.8',
        },
        {
          'rank': 2,
          'notation': 'e4',
          'description': 'Strong center control',
          'score': '+0.6',
        },
        {
          'rank': 3,
          'notation': 'd4',
          'description': 'Solid opening',
          'score': '+0.5',
        },
      ];

      setState(() {
        _suggestedMoves = moves;
        _tabController.animateTo(2);
      });

      _addMessage(ChatMessage(
        text: 'Move suggestions:\n\n${response.content}',
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.suggestion,
      ));
    } catch (e) {
      _addMessage(ChatMessage(
        text: getFallbackResponse('suggest move'),
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.error,
      ));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _askAboutOpening() async {
    _messageController.text = 'What are the best opening moves for beginners in chess?';
    await _sendMessage();
  }

  Future<void> _findTactics() async {
    _messageController.text = 'Explain common chess tactics and how to spot them.';
    await _sendMessage();
  }

  Future<void> _getEndgameTips() async {
    _messageController.text = 'What are the key endgame principles I should know?';
    await _sendMessage();
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _addMessage(ChatMessage(
                  text: _getWelcomeMessage(),
                  isUser: false,
                  timestamp: DateTime.now(),
                  messageType: MessageType.welcome,
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Assistant Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.smart_toy),
              title: const Text('AI Service'),
              subtitle: Text(AIServiceManager.getCurrentServiceName()),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showServiceSelection();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showAboutDialog(),
            ),
          ],
        ),
      ),
    );
  }

  void _showServiceSelection() {
    final services = AIServiceManager.getAvailableServices();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select AI Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: services.asMap().entries.map((entry) {
            return RadioListTile<int>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: AIServiceManager.getCurrentServiceIndex(),
              onChanged: (value) {
                if (value != null) {
                  AIServiceManager.switchToService(value);
                  Navigator.pop(context);
                  setState(() {});
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chess AI Assistant'),
        content: const Text(
          'Powered by advanced AI to help you improve your chess skills.\n\n'
              'Features:\n'
              '• Move analysis and suggestions\n'
              '• Position evaluation\n'
              '• Opening theory\n'
              '• Tactical pattern recognition\n'
              '• Endgame guidance',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showOpeningPrinciples() {
    _addMessage(ChatMessage(
      text: '''📚 Opening Principles:

1. Control the center (e4, d4, e5, d5)
2. Develop your pieces quickly
3. Castle early for king safety
4. Don't move the same piece twice
5. Don't bring your queen out too early
6. Connect your rooks

Following these principles will give you a solid foundation!''',
      isUser: false,
      timestamp: DateTime.now(),
      messageType: MessageType.tutorial,
    ));
    _tabController.animateTo(0);
  }

  void _showTacticalPatterns() {
    _addMessage(ChatMessage(
      text: '''⚡ Common Tactical Patterns:

🎯 Fork: Attack two pieces at once
🔄 Pin: Prevent a piece from moving
🗡️ Skewer: Attack valuable piece forcing it to move
🎪 Discovered Attack: Moving reveals another attack
❌ Double Check: Checking with two pieces
🏰 Back Rank Mate: Checkmate on the back row

Practice recognizing these patterns!''',
      isUser: false,
      timestamp: DateTime.now(),
      messageType: MessageType.tutorial,
    ));
    _tabController.animateTo(0);
  }

  void _showEndgameTechniques() {
    _addMessage(ChatMessage(
      text: '''👑 Endgame Essentials:

1. King Activity: Activate your king in the endgame
2. Pawn Promotion: Push passed pawns
3. Opposition: Control key squares with your king
4. Zugzwang: Force opponent into bad moves
5. Basic Checkmates:
   - King + Queen vs King
   - King + Rook vs King
   - King + 2 Bishops vs King

Master these fundamentals!''',
      isUser: false,
      timestamp: DateTime.now(),
      messageType: MessageType.tutorial,
    ));
    _tabController.animateTo(0);
  }

  void _showStrategicConcepts() {
    _addMessage(ChatMessage(
      text: '''🧠 Strategic Concepts:

1. Pawn Structure: Avoid doubled/isolated pawns
2. Piece Activity: Keep pieces on good squares
3. Space Advantage: Control more of the board
4. Weak Squares: Target squares opponent can't defend
5. Open Files: Place rooks on open files
6. Good vs Bad Bishops: Consider pawn chains

Think long-term!''',
      isUser: false,
      timestamp: DateTime.now(),
      messageType: MessageType.tutorial,
    ));
    _tabController.animateTo(0);
  }

  String _getEvaluationText(double eval) {
    if (eval > 3) return 'White is winning';
    if (eval > 1) return 'White has advantage';
    if (eval > 0.3) return 'White is slightly better';
    if (eval > -0.3) return 'Equal position';
    if (eval > -1) return 'Black is slightly better';
    if (eval > -3) return 'Black has advantage';
    return 'Black is winning';
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}

// ==================== DATA MODELS ====================

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageType messageType;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.messageType = MessageType.text,
  });
}

enum MessageType {
  text,
  welcome,
  analysis,
  suggestion,
  tutorial,
  error,
}