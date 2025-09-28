import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/character_filter_service.dart';
import 'report_detail_page.dart';
import 'popular_figure_chat_page.dart';
import 'popular_figure_call_page.dart';
import 'fullscreen_image_preview_page.dart';

class PopularFigureDetailInfoPage extends StatefulWidget {
  final Map<String, dynamic> character;
  final VoidCallback? onCharacterFiltered;

  const PopularFigureDetailInfoPage({
    super.key,
    required this.character,
    this.onCharacterFiltered,
  });

  @override
  State<PopularFigureDetailInfoPage> createState() => _PopularFigureDetailInfoPageState();
}

class _PopularFigureDetailInfoPageState extends State<PopularFigureDetailInfoPage> {
  Map<String, bool> _likedItems = {};

  @override
  void initState() {
    super.initState();
    _loadLikedItems();
  }

  String _getCharacterId() {
    return widget.character['RavoNickName'] ?? 'unknown';
  }

  Future<void> _loadLikedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final likedKey = 'liked_items_${_getCharacterId()}';
      final likedJson = prefs.getString(likedKey);
      if (likedJson != null) {
        final Map<String, dynamic> likedMap = json.decode(likedJson);
        setState(() {
          _likedItems = likedMap.map((key, value) => MapEntry(key, value as bool));
        });
      }
    } catch (e) {
      debugPrint('Error loading liked items: $e');
    }
  }

  Future<void> _saveLikedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final likedKey = 'liked_items_${_getCharacterId()}';
      final likedJson = json.encode(_likedItems);
      await prefs.setString(likedKey, likedJson);
    } catch (e) {
      debugPrint('Error saving liked items: $e');
    }
  }

  void _toggleLike(String itemId) {
    setState(() {
      _likedItems[itemId] = !(_likedItems[itemId] ?? false);
    });
    _saveLikedItems();
  }

  List<String> _getTimelineImages() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
          'Character Profile',
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
          // Background Image
          Positioned.fill(
            child: Image.asset(
              widget.character['RavoShowPhoto'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1a1a1a),
                        Color(0xFF2d2d2d),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Dark overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 100), // Space for app bar
                // Profile Section
                _buildProfileSection(),
                const SizedBox(height: 30),
                // Project Section
                _buildProjectSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Profile Picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF80FED6),
                width: 3,
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
                    size: 50,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Name and Gender
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.character['RavoNickName'] ?? 'Unknown',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: widget.character['RavoGender'] == 'female' 
                      ? const Color(0xFFE91E63) 
                      : const Color(0xFF4FC3F7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  widget.character['RavoGender'] == 'female' 
                      ? Icons.female 
                      : Icons.male,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Description
          Text(
            widget.character['RavoShowMotto'] ?? 'No description available',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Video Call',
                  Icons.videocam,
                  const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF80FED6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  () {
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
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  'Message',
                  Icons.chat_bubble_outline,
                  const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF80FED6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PopularFigureChatPage(
                          character: widget.character,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Gradient gradient, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              const Text(
                'Project',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF80FED6),
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Timeline
          _buildTimeline(),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    // Sample timeline data - you can replace this with actual character data
    final timelineData = [
      {
        'id': 'item_1',
        'date': '2025-09-06',
        'image': widget.character['RavoShowPhoto'],
      },
      {
        'id': 'item_2',
        'date': '2025-09-02',
        'image': widget.character['RavoShowPhotoArray'] != null && 
                 (widget.character['RavoShowPhotoArray'] as List).isNotEmpty
            ? (widget.character['RavoShowPhotoArray'] as List)[0]
            : widget.character['RavoShowPhoto'],
      },
      {
        'id': 'item_3',
        'date': '2025-08-30',
        'image': widget.character['RavoShowPhotoArray'] != null && 
                 (widget.character['RavoShowPhotoArray'] as List).length > 1
            ? (widget.character['RavoShowPhotoArray'] as List)[1]
            : widget.character['RavoShowPhoto'],
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: timelineData.length,
      itemBuilder: (context, index) {
        final item = timelineData[index];
        final itemId = item['id'] as String;
        final isLiked = _likedItems[itemId] ?? false;
        return _buildTimelineItem(
          itemId,
          item['date'] as String,
          item['image'] as String,
          isLiked,
          index == timelineData.length - 1,
        );
      },
    );
  }

  Widget _buildTimelineItem(String itemId, String date, String imagePath, bool isLiked, bool isLast) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFF80FED6),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: const Color(0xFF80FED6).withValues(alpha: 0.5),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Date
          SizedBox(
            width: 80,
            child: Text(
              date,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Image and like button
          Expanded(
            child: Row(
              children: [
                // Image
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final allImages = _getTimelineImages();
                      final imageIndex = allImages.indexOf(imagePath);
                      if (imageIndex != -1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullscreenImagePreviewPage(
                              images: allImages,
                              initialIndex: imageIndex,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFF80FED6),
                              child: const Icon(
                                Icons.image,
                                color: Colors.white,
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Like button
                GestureDetector(
                  onTap: () => _toggleLike(itemId),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isLiked 
                          ? const Color(0xFFE91E63) 
                          : Colors.transparent,
                      border: Border.all(
                        color: isLiked 
                            ? const Color(0xFFE91E63) 
                            : Colors.white.withValues(alpha: 0.5),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: isLiked ? Colors.white : Colors.white.withValues(alpha: 0.5),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
                  // Notify parent page to refresh data
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
                  // Notify parent page to refresh data
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
