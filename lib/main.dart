import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'openai_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final OpenAIService openAIService = OpenAIService();

  List<Map<String, dynamic>> messages = [];
  bool isTyping = false;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({"text": text, "isUser": true});
      isTyping = true;
    });

    _controller.clear();

    final aiResponse = await openAIService.sendMessage(text);

    setState(() {
      isTyping = false;
      messages.add({"text": aiResponse, "isUser": false});
    });

    await Future.delayed(const Duration(milliseconds: 100));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 80,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: Stack(
        children: [
          buildBackground(),
          Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? buildLanding()
                    : buildMessageList(),
              ),
              buildFloatingInput(),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.3,
          colors: [
            Color(0xFF1A1F2E),
            Color(0xFF0B0F19),
          ],
        ),
      ),
    );
  }

  Widget buildLanding() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "Hare Kṛṣṇa",
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w600,
              color: Color(0xFFD4AF37),
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "How may I serve you?",
            style: TextStyle(
              color: Colors.white60,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < messages.length) {
          final message = messages[index];
          final bool isUser = message["isUser"] == true;


          return Align(
            alignment:
                isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFFD4AF37).withValues(alpha: 0.9)
                    : const Color(0xFF1A1F2E).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: isUser
                  ? Text(
                      message["text"],
                      style: const TextStyle(color: Colors.black87),
                    )
                  : MarkdownBody(
                      data: message["text"],
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(color: Colors.white70, fontSize: 16),
                        code: const TextStyle(
                          color: Color(0xFFD4AF37),
                          backgroundColor: Color(0xFF1A1F2E),
                          fontFamily: 'SourceCodePro',
                        ),
                      ),
                    ),
            ),
          );
        } else {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Thinking...",
              style: TextStyle(color: Colors.white54),
            ),
          );
        }
      },
    );
  }

  Widget buildFloatingInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF111827).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Ask Anudāsa...",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    onSubmitted: sendMessage,
                  ),
                ),
                GestureDetector(
                  onTap: () => sendMessage(_controller.text),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
