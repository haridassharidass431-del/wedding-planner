import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/ai_message.dart';
import '../../../data/models/wedding_context.dart';
import '../../../data/repositories/mock_wedding_repository.dart';
import '../../../data/services/wedding_ai_service.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});
  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _service = DemoWeddingAiService();
  final _repository = MockWeddingRepository();
  final List<AiMessage> _messages = [];
  bool _sending = false;
  final _suggestions = const [
    'What should I book first?',
    'Create a 6-month wedding plan',
    'How can I reduce wedding expenses?',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? text]) async {
    final prompt = (text ?? _controller.text).trim();
    if (prompt.isEmpty || _sending) {
      return;
    }
    _controller.clear();
    setState(() {
      _messages.add(
        AiMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          content: prompt,
          role: AiMessageRole.user,
        ),
      );
      _sending = true;
    });
    final response = await _service.reply(
      message: prompt,
      context: WeddingContext(location: _repository.selectedLocation),
    );
    if (!mounted) return;
    setState(() {
      _messages.add(
        AiMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          content: response,
          role: AiMessageRole.assistant,
        ),
      );
      _sending = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Wedding assistant'), centerTitle: false),
    body: Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? _welcome()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(18),
                  itemCount: _messages.length + (_sending ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (_sending && i == _messages.length) {
                      return const _ChatBubble(
                        content: 'Putting your plan together...',
                        isUser: false,
                      );
                    }
                    final message = _messages[i];
                    return _ChatBubble(
                      content: message.content,
                      isUser: message.role == AiMessageRole.user,
                    );
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: 'Ask anything about your wedding',
                      prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sending ? null : () => _send(),
                  icon: const Icon(Icons.arrow_upward_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _welcome() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
    children: [
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.plumTint,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primaryPlum,
              size: 30,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your wedding, thoughtfully planned.',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tell me about your date, guest count, budget, or ideas. I can help you plan the next step.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 14),
            const Text(
              'Demo assistant · Secure AI backend can be connected later',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const Text(
        'TRY ASKING',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: AppColors.textMuted,
        ),
      ),
      const SizedBox(height: 10),
      ..._suggestions.map(
        (s) => Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: ActionChip(
            label: Text(s),
            onPressed: () => _send(s),
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.borderLight),
          ),
        ),
      ),
    ],
  );
}

class _ChatBubble extends StatelessWidget {
  final String content;
  final bool isUser;
  const _ChatBubble({required this.content, required this.isUser});
  @override
  Widget build(BuildContext context) => Align(
    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * .82,
      ),
      decoration: BoxDecoration(
        color: isUser ? AppColors.primaryPlum : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isUser ? null : Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        content,
        style: TextStyle(
          color: isUser ? Colors.white : AppColors.textPrimary,
          height: 1.45,
        ),
      ),
    ),
  );
}
