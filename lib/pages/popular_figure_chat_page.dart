import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'popular_figure_call_page.dart';

class PopularFigureChatPage extends StatefulWidget {
  final Map<String, dynamic> character;

  const PopularFigureChatPage({
    super.key,
    required this.character,
  });

  @override
  State<PopularFigureChatPage> createState() => _PopularFigureChatPageState();
}

class _PopularFigureChatPageState extends State<PopularFigureChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  String _getCharacterId() {
    return widget.character['RavoNickName'] ?? 'unknown';
  }

  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatKey = 'chat_history_${_getCharacterId()}';
      final chatJson = prefs.getString(chatKey);
      
      if (chatJson != null) {
        final List<dynamic> chatList = json.decode(chatJson);
        if (chatList.isNotEmpty) {
          setState(() {
            _messages = chatList.map((json) => ChatMessage.fromJson(json)).toList();
          });
        } else {
          // 如果有聊天记录文件但为空，添加欢迎消息
          _addWelcomeMessage();
        }
      } else {
        // 如果没有聊天记录，添加欢迎消息
        _addWelcomeMessage();
      }
    } catch (e) {
      debugPrint('Error loading chat history: $e');
      _addWelcomeMessage();
    }
  }

  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatKey = 'chat_history_${_getCharacterId()}';
      final chatJson = json.encode(_messages.map((message) => message.toJson()).toList());
      await prefs.setString(chatKey, chatJson);
    } catch (e) {
      debugPrint('Error saving chat history: $e');
    }
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      text: widget.character['RavoShowSayhi'] ?? 'Hello! I\'m ${widget.character['RavoNickName']}. How can I help you today?',
      isUser: false,
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.add(welcomeMessage);
    });
    
    // 保存欢迎消息到聊天记录
    _saveChatHistory();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF80FED6),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  widget.character['RavoUserIcon'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person,
                      color: Color(0xFF80FED6),
                      size: 25,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Dubbing script',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.phone,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PopularFigureCallPage(
                    character: widget.character,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFF5F5F5),
            ],
          ),
        ),
        child: Column(
          children: [
            // Character Images Section
            _buildCharacterImagesSection(),
            // Chat messages
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(_messages[index]);
                        },
                      ),
                    ),
                    // Loading indicator
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF80FED6),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'AI is thinking...',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Input area
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: 'Say something...',
                                prefixIcon: const Icon(
                                  Icons.mail_outline,
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: const BorderSide(color: Color(0xFF80FED6)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: null,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _isLoading ? null : _sendMessage,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterImagesSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFF0F8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF80FED6).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Character Images Row
          Row(
            children: [
              Expanded(
                child: _buildCharacterImage(widget.character['RavoShowPhoto']),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCharacterImage(
                  widget.character['RavoShowPhotoArray'] != null && 
                  (widget.character['RavoShowPhotoArray'] as List).isNotEmpty
                      ? (widget.character['RavoShowPhotoArray'] as List)[0]
                      : widget.character['RavoShowPhoto'],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCharacterImage(
                  widget.character['RavoShowPhotoArray'] != null && 
                  (widget.character['RavoShowPhotoArray'] as List).length > 1
                      ? (widget.character['RavoShowPhotoArray'] as List)[1]
                      : widget.character['RavoShowPhoto'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Timestamp
          Text(
            '12:08',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterImage(String imagePath) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF80FED6).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFF80FED6).withValues(alpha: 0.1),
              child: const Icon(
                Icons.person,
                color: Color(0xFF80FED6),
                size: 30,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF80FED6), width: 2),
              ),
              child: ClipOval(
                child: Image.asset(
                  widget.character['RavoUserIcon'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person,
                      color: Color(0xFF80FED6),
                      size: 16,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? const Color(0xFF80FED6) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.black : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser ? Colors.black54 : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF80FED6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.black,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
      _isLoading = true;
    });

    // 保存用户消息
    await _saveChatHistory();
    _scrollToBottom();

    try {
      final response = await _callZhipuAI(text);
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      
      // 保存AI回复
      await _saveChatHistory();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Sorry, I encountered an error. Please try again.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      
      // 保存错误消息
      await _saveChatHistory();
    }

    _scrollToBottom();
  }

  Future<String> _callZhipuAI(String userMessage) async {
    const apiKey = 'f5321fa3eeb5482e9e905c7ae40628ec.wmGC0GKyOO3P4R7d';
    const url = 'https://open.bigmodel.cn/api/paas/v4/chat/completions';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = {
      'model': 'glm-4-flash',
      'messages': [
        {
          'role': 'system',
          'content': 'You are ${widget.character['RavoNickName']}, a voice acting AI assistant. Respond in English. Be helpful, creative, and engaging. Keep responses concise but informative.',
        },
        {
          'role': 'user',
          'content': userMessage,
        },
      ],
      'temperature': 0.7,
      'max_tokens': 1000,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'] ?? 'Sorry, I couldn\'t generate a response.';
    } else {
      throw Exception('Failed to call Zhipu AI: ${response.statusCode}');
    }
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
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}
