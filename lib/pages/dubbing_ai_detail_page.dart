import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dubbing_chat_detail_page.dart';
import 'report_detail_page.dart';
import '../services/character_filter_service.dart';

class DubbingAIDetailPage extends StatefulWidget {
  final Map<String, dynamic> character;
  final VoidCallback? onCharacterFiltered;

  const DubbingAIDetailPage({
    super.key,
    required this.character,
    this.onCharacterFiltered,
  });

  @override
  State<DubbingAIDetailPage> createState() => _DubbingAIDetailPageState();
}

class _DubbingAIDetailPageState extends State<DubbingAIDetailPage> {
  bool _isFollowing = false;
  bool _isLiked = false;
  int _followCount = 0;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _followCount = widget.character['RavoShowFollowNum'] ?? 0;
    _likeCount = widget.character['RavoShowLike'] ?? 0;
    _loadUserInteractions();
  }

  Future<void> _loadUserInteractions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final characterId = widget.character['RavoNickName'] ?? '';
      
      final isFollowing = prefs.getBool('follow_$characterId') ?? false;
      final isLiked = prefs.getBool('like_$characterId') ?? false;
      
      setState(() {
        _isFollowing = isFollowing;
        _isLiked = isLiked;
        
        // 根据状态调整数量
        if (_isFollowing) {
          _followCount = (widget.character['RavoShowFollowNum'] ?? 0) + 1;
        }
        if (_isLiked) {
          _likeCount = (widget.character['RavoShowLike'] ?? 0) + 1;
        }
      });
    } catch (e) {
      // 如果加载失败，使用默认值
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Character Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_horiz,
              color: Colors.white,
              size: 24,
            ),
            onPressed: _showActionSheet,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Character image - True full screen
          Positioned.fill(
            child: Image.asset(
              widget.character['RavoShowPhoto'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFE0E0E0),
                  child: const Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          // Bottom overlay with character info
          Positioned(
            bottom: 100, // 为底部按钮留出空间
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Character name and avatar
                              Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        widget.character['RavoUserIcon'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 30,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.character['RavoNickName'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${widget.character['RavoShowFollowNum']} people have dubbed',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Character motto
                              Text(
                                widget.character['RavoShowMotto'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Character sayhi
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '"${widget.character['RavoShowSayhi']}"',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Stats - Capsule buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildCapsuleButton(
                                    'Followers',
                                    _followCount.toString(),
                                    Icons.people,
                                    _isFollowing,
                                    () => _toggleFollow(),
                                  ),
                                  _buildCapsuleButton(
                                    'Likes',
                                    _likeCount.toString(),
                                    Icons.favorite,
                                    _isLiked,
                                    () => _toggleLike(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
          // Bottom action button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    // 跳转到AI聊天页面
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DubbingChatDetailPage(character: widget.character),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/dubbing_ai_voice.webp',
                    width: 290,
                    height: 73,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 290,
                        height: 73,
                        decoration: BoxDecoration(
                          color: const Color(0xFF80FED6),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Center(
                          child: Text(
                            'Start Dubbing',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFollow() async {
    setState(() {
      _isFollowing = !_isFollowing;
      if (_isFollowing) {
        _followCount++;
      } else {
        _followCount--;
      }
    });
    
    // 保存状态到本地存储
    await _saveFollowState();
  }

  Future<void> _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeCount++;
      } else {
        _likeCount--;
      }
    });
    
    // 保存状态到本地存储
    await _saveLikeState();
  }

  Future<void> _saveFollowState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final characterId = widget.character['RavoNickName'] ?? '';
      await prefs.setBool('follow_$characterId', _isFollowing);
    } catch (e) {
      // 保存失败，忽略错误
    }
  }

  Future<void> _saveLikeState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final characterId = widget.character['RavoNickName'] ?? '';
      await prefs.setBool('like_$characterId', _isLiked);
    } catch (e) {
      // 保存失败，忽略错误
    }
  }

  void _showActionSheet() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          'Character Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        message: Text(
          'Choose an action for ${widget.character['RavoNickName']}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _blockCharacter();
            },
            child: Text(
              'Block',
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _blacklistCharacter();
            },
            child: Text(
              'Blacklist',
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _reportCharacter();
            },
            child: Text(
              'Report',
              style: TextStyle(
                color: Colors.orange[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.blue[600],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _blockCharacter() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Block Character'),
          content: Text('Are you sure you want to block ${widget.character['RavoNickName']}? You won\'t see their content anymore.'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Block'),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                navigator.pop();
                await CharacterFilterService.blockCharacter(widget.character['RavoNickName']);
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('${widget.character['RavoNickName']} has been blocked'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  // 通知发现页面刷新数据
                  widget.onCharacterFiltered?.call();
                  // 返回上一页，触发数据刷新
                  navigator.pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _blacklistCharacter() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Blacklist Character'),
          content: Text('Are you sure you want to blacklist ${widget.character['RavoNickName']}? This action cannot be undone.'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Blacklist'),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                navigator.pop();
                await CharacterFilterService.blacklistCharacter(widget.character['RavoNickName']);
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('${widget.character['RavoNickName']} has been blacklisted'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  // 通知发现页面刷新数据
                  widget.onCharacterFiltered?.call();
                  // 返回上一页，触发数据刷新
                  navigator.pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _reportCharacter() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReportDetailPage(
          character: widget.character,
          onCharacterFiltered: widget.onCharacterFiltered,
        ),
      ),
    );
  }

  Widget _buildCapsuleButton(String label, String value, IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
            ? const Color(0xFF80FED6).withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive 
              ? const Color(0xFF80FED6)
              : Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.black : Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                color: isActive ? Colors.black : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.black.withValues(alpha: 0.7) : Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

