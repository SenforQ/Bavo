import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'popular_figure_chat_page.dart';

class Tab3HistoryPage extends StatefulWidget {
  const Tab3HistoryPage({super.key});

  @override
  State<Tab3HistoryPage> createState() => _Tab3HistoryPageState();
}

class _Tab3HistoryPageState extends State<Tab3HistoryPage> {
  List<Map<String, dynamic>> _chatHistories = [];
  List<Map<String, dynamic>> _allCharacters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatHistories();
  }

  Future<void> _loadChatHistories() async {
    try {
      // Load all characters
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/dubbingAll.json');
      final dynamic jsonData = json.decode(jsonString);
      
      // Handle both List and Map formats
      List<dynamic> characters;
      if (jsonData is List) {
        characters = jsonData;
      } else if (jsonData is Map && jsonData.containsKey('characters')) {
        characters = jsonData['characters'] as List<dynamic>;
      } else {
        characters = [];
      }
      
      _allCharacters = characters.cast<Map<String, dynamic>>();

      // Load chat histories
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> histories = [];

      for (final character in _allCharacters) {
        final characterName = character['RavoNickName'] ?? '';
        final chatKey = 'chat_history_$characterName';
        final chatJson = prefs.getString(chatKey);
        
        if (chatJson != null) {
          final List<dynamic> chatList = json.decode(chatJson);
          if (chatList.isNotEmpty) {
            // Get the last message
            final lastMessage = chatList.last;
            final lastMessageTime = DateTime.parse(lastMessage['timestamp'] ?? DateTime.now().toIso8601String());
            
            histories.add({
              'character': character,
              'lastMessage': lastMessage['text'] ?? '',
              'lastMessageTime': lastMessageTime,
              'messageCount': chatList.length,
              'isUser': lastMessage['isUser'] ?? false,
            });
          }
        }
      }

      // Sort by last message time (most recent first)
      histories.sort((a, b) => b['lastMessageTime'].compareTo(a['lastMessageTime']));

      setState(() {
        _chatHistories = histories;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading chat histories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/base_bg.webp',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFE8F5E8), // Fallback color
                );
              },
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header Section
                _buildHeader(),
                // Chat List
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF80FED6),
                          ),
                        )
                      : _chatHistories.isEmpty
                          ? _buildEmptyState()
                          : _buildChatList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with decoration
          Row(
            children: [
              const Text(
                'Chat',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF80FED6),
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Quick access characters
          _buildQuickAccessCharacters(),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCharacters() {
    // Get first 3 characters with chat history
    final quickAccessCharacters = _chatHistories.take(3).toList();
    
    return Row(
      children: [
        // Character avatars
        ...quickAccessCharacters.map((history) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _navigateToChat(history['character']),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF80FED6),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    history['character']['RavoUserIcon'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        color: Color(0xFF80FED6),
                        size: 30,
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Chat History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start chatting with characters to see your history here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _chatHistories.length,
      itemBuilder: (context, index) {
        final history = _chatHistories[index];
        return _buildChatCard(history);
      },
    );
  }

  Widget _buildChatCard(Map<String, dynamic> history) {
    final character = history['character'];
    final lastMessage = history['lastMessage'];
    final lastMessageTime = history['lastMessageTime'] as DateTime;
    final messageCount = history['messageCount'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF80FED6).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToChat(character),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Character Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF80FED6),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      character['RavoUserIcon'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          color: Color(0xFF80FED6),
                          size: 30,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Chat Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        'Dubbing script',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Last message preview
                      Text(
                        lastMessage.length > 50 
                            ? '${lastMessage.substring(0, 50)}...'
                            : lastMessage,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Timestamp and Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Timestamp
                    Text(
                      _formatTime(lastMessageTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Message count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF80FED6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        messageCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }

  void _navigateToChat(Map<String, dynamic> character) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PopularFigureChatPage(
          character: character,
        ),
      ),
    ).then((_) {
      // Refresh the list when returning from chat
      _loadChatHistories();
    });
  }

}
