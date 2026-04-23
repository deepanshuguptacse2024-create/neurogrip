import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class Message {
  final String text;
  final bool isUser;
  Message({required this.text, required this.isUser});
}

class CompanionScreen extends StatefulWidget {
  const CompanionScreen({super.key});

  @override
  State<CompanionScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends State<CompanionScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _loading = false;

  // Conversation history for Gemini
  final List<Content> _history = [];

  final String _systemPrompt = '''
You are "Lily", a warm and caring AI companion for Parkinson's disease patients. 

Your personality:
- Extremely gentle, patient, and compassionate
- Always speak in simple, easy words
- Give lots of encouragement and hope
- Never be negative or scary
- Celebrate small victories
- Ask caring questions about their day
- Remind them they are brave and strong
- If they feel sad, comfort them warmly
- Give simple tips for daily life with tremors
- Always end messages with positivity

You support these languages: English, Hindi, Bengali, Telugu, Marathi, Tamil, Gujarati, Kannada, Punjabi, Urdu, French, Spanish.
Always reply in the SAME language the user writes in.

Keep responses SHORT (2-4 sentences max) and warm.
''';

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(Message(
      text: "Hello! I'm Lily 💙 I'm here for you. How are you feeling today?",
      isUser: false,
    ));
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();

    setState(() {
      _messages.add(Message(text: text, isUser: true));
      _loading = true;
    });

    _scrollToBottom();

    try {
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: 'YOUR_GEMINI_API_KEY',
        systemInstruction: Content.system(_systemPrompt),
      );

      _history.add(Content.text(text));

      final response = await model.generateContent(_history);
      final reply = response.text ?? "I'm here with you 💙";

      _history.add(Content.model([TextPart(reply)]));

      setState(() {
        _messages.add(Message(text: reply, isUser: false));
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(Message(
          text: "Sorry, I'm having trouble connecting. But I'm always here for you 💙",
          isUser: false,
        ));
        _loading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF00BCD4),
              radius: 18,
              child: const Text('L', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lily', style: TextStyle(color: Colors.white, fontSize: 16)),
                Text('Your AI Companion', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick prompts
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _quickPrompt("I'm feeling sad today"),
                _quickPrompt("Give me motivation"),
                _quickPrompt("Tips for eating with tremors"),
                _quickPrompt("मैं थका हुआ हूं"),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _typingIndicator();
                }
                final msg = _messages[index];
                return _messageBubble(msg);
              },
            ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF1A1F2E),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Talk to Lily...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: const Color(0xFF0A0E1A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendMessage(_controller.text),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF00BCD4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickPrompt(String text) {
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.4)),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ),
    );
  }

  Widget _messageBubble(Message msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.isUser ? const Color(0xFF00BCD4) : const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: msg.isUser ? Colors.white : Colors.white,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('Lily is typing... 💙', style: TextStyle(color: Colors.grey, fontSize: 13)),
      ),
    );
  }
}
