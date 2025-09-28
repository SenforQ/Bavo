import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../services/user_info_service.dart';
import '../services/character_filter_service.dart';
import 'report_detail_page.dart';
import 'popular_figure_detail_info_page.dart';
import 'fullscreen_image_preview_page.dart';

class PopularFigureDetailPage extends StatefulWidget {
  final Map<String, dynamic> character;
  final VoidCallback? onCharacterFiltered;

  const PopularFigureDetailPage({
    super.key,
    required this.character,
    this.onCharacterFiltered,
  });

  @override
  State<PopularFigureDetailPage> createState() => _PopularFigureDetailPageState();
}

class _PopularFigureDetailPageState extends State<PopularFigureDetailPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final PageController _pageController = PageController();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isPlaying = false;
  bool _isFollowing = false;
  int _currentImageIndex = 0;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  List<Map<String, dynamic>> _comments = [];
  String _userAvatarPath = 'assets/user_defalut_icon.webp';
  String _userName = 'You';

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _loadFollowStatus();
    _loadComments();
    _loadUserInfo();
  }

  String _getCharacterId() {
    // 使用角色名称作为唯一标识符
    return widget.character['RavoNickName'] ?? 'unknown';
  }

  Future<void> _loadFollowStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final followKey = 'follow_${_getCharacterId()}';
      final isFollowing = prefs.getBool(followKey) ?? false;
      if (mounted) {
        setState(() {
          _isFollowing = isFollowing;
        });
      }
    } catch (e) {
      // 如果加载失败，保持默认状态
      debugPrint('Error loading follow status: $e');
    }
  }

  Future<void> _saveFollowStatus(bool isFollowing) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final followKey = 'follow_${_getCharacterId()}';
      await prefs.setBool(followKey, isFollowing);
    } catch (e) {
      debugPrint('Error saving follow status: $e');
    }
  }

  Future<void> _loadComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final commentsKey = 'comments_${_getCharacterId()}';
      final commentsJson = prefs.getString(commentsKey);
      if (commentsJson != null) {
        final List<dynamic> commentsList = json.decode(commentsJson);
        if (mounted) {
          setState(() {
            _comments = commentsList.cast<Map<String, dynamic>>();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading comments: $e');
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await UserInfoService.getUserInfo();
      if (mounted) {
        setState(() {
          _userName = userInfo.name;
          _userAvatarPath = userInfo.avatarPath;
        });
      }
    } catch (e) {
      debugPrint('Error loading user info: $e');
    }
  }

  Future<void> _saveComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final commentsKey = 'comments_${_getCharacterId()}';
      final commentsJson = json.encode(_comments);
      await prefs.setString(commentsKey, commentsJson);
    } catch (e) {
      debugPrint('Error saving comments: $e');
    }
  }

  void _addComment() {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    final now = DateTime.now();
    final newComment = {
      'id': now.millisecondsSinceEpoch.toString(),
      'text': commentText,
      'author': _userName,
      'avatarPath': _userAvatarPath,
      'timestamp': now.toIso8601String(),
      'time': _formatTime(now),
    };

    setState(() {
      _comments.insert(0, newComment);
    });

    _commentController.clear();
    _commentFocusNode.unfocus();
    _saveComments();
  }

  void _initAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  List<String> _getCharacterImages() {
    List<String> images = [];
    
    // 添加主照片
    if (widget.character['RavoShowPhoto'] != null) {
      images.add(widget.character['RavoShowPhoto']);
    }
    
    // 添加照片数组中的所有图片
    if (widget.character['RavoShowPhotoArray'] != null) {
      List<dynamic> photoArray = widget.character['RavoShowPhotoArray'];
      for (String photo in photoArray) {
        if (!images.contains(photo)) {
          images.add(photo);
        }
      }
    }
    
    return images;
  }

  Future<void> _playPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    } else {
      // 获取音频文件路径，去掉 'assets/' 前缀
      String audioPath = widget.character['RavoPlayMusic'].replaceFirst('assets/', '');
      await _audioPlayer.play(AssetSource(audioPath));
      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _toggleFollow() async {
    final newFollowStatus = !_isFollowing;
    
    setState(() {
      _isFollowing = newFollowStatus;
    });
    
    // Save follow status to local storage
    await _saveFollowStatus(newFollowStatus);
    
    // Add actual follow/unfollow API call here
    // For example: await _followUser(widget.character['id']);
    
    // Show notification message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newFollowStatus ? 'You are now following ${widget.character['RavoNickName']}' : 'You unfollowed ${widget.character['RavoNickName']}',
          ),
          backgroundColor: newFollowStatus ? const Color(0xFF80FED6) : Colors.grey[600],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _pageController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_horiz,
              color: Colors.black,
              size: 24,
            ),
            onPressed: _showActionSheet,
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              child: TextField(
                controller: _commentController,
                focusNode: _commentFocusNode,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _addComment(),
              ),
            ),
            
            GestureDetector(
              onTap: _addComment,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF80FED6), Color(0xFF4FC3F7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        child: Column(
          children: [
          // Dubbing Script Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PopularFigureDetailInfoPage(
                          character: widget.character,
                          onCharacterFiltered: widget.onCharacterFiltered,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
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
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Dubbing script',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _toggleFollow,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: _isFollowing 
                          ? const LinearGradient(
                              colors: [Color(0xFFE53E3E), Color(0xFFC53030)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF80FED6), Color(0xFF4FC3F7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isFollowing ? 'Unfollow' : 'Follow',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Voice Player Area
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Character Images Carousel
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemCount: _getCharacterImages().length,
                          itemBuilder: (context, index) {
                            final images = _getCharacterImages();
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullscreenImagePreviewPage(
                                      images: images,
                                      initialIndex: index,
                                    ),
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: Image.asset(
                                  images[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: const Color(0xFF80FED6),
                                      child: const Center(
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 80,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        // Page Indicators
                        if (_getCharacterImages().length > 1)
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _getCharacterImages().length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentImageIndex == index
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Voice Player Controls
                Row(
                  children: [
                    // Play/Pause Button
                    GestureDetector(
                      onTap: _playPause,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF80FED6), Color(0xFF4FC3F7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF80FED6).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Progress Bar and Time
                    Expanded(
                      child: Column(
                        children: [
                          // Progress Bar
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _duration.inMilliseconds > 0
                                      ? _position.inMilliseconds / _duration.inMilliseconds
                                      : 0.0,
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF80FED6), Color(0xFF4FC3F7)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Time Display
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_position),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _formatDuration(_duration),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Comments Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 20,
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
                const SizedBox(height: 16),
                // Comments List
                if (_comments.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'No comments yet. Be the first to comment!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF80FED6),
                                  width: 1,
                                ),
                              ),
                              child: ClipOval(
                                child: comment['avatarPath'] != null && comment['avatarPath'].startsWith('assets/')
                                    ? Image.asset(
                                        comment['avatarPath'],
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/user_defalut_icon.webp',
                                            width: 32,
                                            height: 32,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      )
                                    : comment['avatarPath'] != null
                                        ? FutureBuilder<String?>(
                                            future: UserInfoService.getFullImagePath(comment['avatarPath']),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData && snapshot.data != null) {
                                                return Image.file(
                                                  File(snapshot.data!),
                                                  width: 32,
                                                  height: 32,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Image.asset(
                                                      'assets/user_defalut_icon.webp',
                                                      width: 32,
                                                      height: 32,
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                );
                                              }
                                              return Image.asset(
                                                'assets/user_defalut_icon.webp',
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            'assets/user_defalut_icon.webp',
                                            width: 32,
                                            height: 32,
                                            fit: BoxFit.cover,
                                          ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        comment['author'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        comment['time'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment['text'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          // Bottom spacing to avoid floating input box overlap
          const SizedBox(height: 100),
          ],
        ),
      ),
    );
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
                  // Notify popular page to refresh data
                  widget.onCharacterFiltered?.call();
                  // Return to previous page to trigger data refresh
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
                  // Notify popular page to refresh data
                  widget.onCharacterFiltered?.call();
                  // Return to previous page to trigger data refresh
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
}
